import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/pin_auth_service.dart';
import '../../core/services/qr_pairing_service.dart';
import '../../core/services/workspace_backup_service.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/models/device.dart';
import '../../domain/models/workspace.dart';
import '../../domain/repositories/device_repository.dart';
import 'product_providers.dart';
import 'sync_providers.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope.',
  );
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return DeviceRepositoryImpl(db);
});

final pinAuthServiceProvider = Provider<PinAuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PinAuthService(prefs: prefs);
});

final qrPairingServiceProvider = Provider<QrPairingService>((ref) {
  return QrPairingService();
});

final workspaceBackupServiceProvider = Provider<WorkspaceBackupService>((ref) {
  return WorkspaceBackupService();
});

enum AuthStatus {
  loading,
  needsOnboarding,
  locked,
  unlocked,
  revoked,
}

class AuthState {
  final AuthStatus status;
  final Workspace? workspace;
  final Device? device;
  final bool sessionExpiringSoon;
  final Duration? remainingBeforeLock;

  const AuthState({
    required this.status,
    this.workspace,
    this.device,
    this.sessionExpiringSoon = false,
    this.remainingBeforeLock,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);

  AuthState copyWith({
    AuthStatus? status,
    Workspace? workspace,
    Device? device,
    bool? sessionExpiringSoon,
    Duration? remainingBeforeLock,
  }) {
    return AuthState(
      status: status ?? this.status,
      workspace: workspace ?? this.workspace,
      device: device ?? this.device,
      sessionExpiringSoon: sessionExpiringSoon ?? this.sessionExpiringSoon,
      remainingBeforeLock: remainingBeforeLock ?? this.remainingBeforeLock,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;
  Timer? _idleCheckTimer;
  DateTime _lastActivityAt = DateTime.now();

  AuthController(this._ref, {AuthState? initialState})
      : super(initialState ?? const AuthState.loading()) {
    if (initialState == null) {
      _initialize();
    }
  }

  Future<void> _initialize() async {
    final deviceRepo = _ref.read(deviceRepositoryProvider);
    final pinService = _ref.read(pinAuthServiceProvider);

    final workspace = await deviceRepo.getActiveWorkspace();
    final localDeviceId = pinService.getLocalDeviceId();
    final hasPin = pinService.hasPinConfigured();

    if (workspace == null || localDeviceId == null || !hasPin) {
      state = const AuthState(status: AuthStatus.needsOnboarding);
      return;
    }

    final device = await deviceRepo.getDeviceById(localDeviceId);
    if (device == null) {
      state = const AuthState(status: AuthStatus.needsOnboarding);
      return;
    }

    if (device.isRevoked) {
      state = AuthState(
        status: AuthStatus.revoked,
        workspace: workspace,
        device: device,
      );
      return;
    }

    state = AuthState(
      status: AuthStatus.locked,
      workspace: workspace,
      device: device,
    );
  }

  Future<void> createWorkspaceAndAdmin({
    required String workspaceName,
    required String displayName,
    required String pin,
  }) async {
    final deviceRepo = _ref.read(deviceRepositoryProvider);
    final pinService = _ref.read(pinAuthServiceProvider);

    final result = await deviceRepo.createWorkspaceAndAdmin(
      workspaceName: workspaceName,
      adminDisplayName: displayName,
    );
    await pinService.setLocalDeviceId(result.adminDevice.id);
    await pinService.setPin(pin);

    _startSessionTimer();
    state = AuthState(
      status: AuthStatus.unlocked,
      workspace: result.workspace,
      device: result.adminDevice,
    );
  }

  Future<void> completeQrPairing({
    required QrPairingPayload payload,
    required String pin,
  }) async {
    if (payload.role == DeviceRole.admin) {
      throw ArgumentError('Cannot pair an ADMIN device via QR code.');
    }

    final deviceRepo = _ref.read(deviceRepositoryProvider);
    final pinService = _ref.read(pinAuthServiceProvider);

    final now = DateTime.now();
    final workspace = Workspace(
      id: payload.workspaceId,
      name: payload.workspaceName,
      workspaceKey: payload.workspaceKey,
      createdAt: now,
    );
    final device = Device(
      id: payload.deviceId,
      displayName: payload.displayName,
      role: payload.role,
      pairedAt: now,
      lastSeenAt: now,
    );

    await deviceRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: device,
    );
    await pinService.setLocalDeviceId(device.id);
    await pinService.setPin(pin);

    _startSessionTimer();
    state = AuthState(
      status: AuthStatus.unlocked,
      workspace: workspace,
      device: device,
    );
  }

  Future<void> restoreAdminBackup({
    required WorkspaceBackupBundle bundle,
    required String pin,
  }) async {
    final deviceRepo = _ref.read(deviceRepositoryProvider);
    final productRepo = _ref.read(productRepositoryProvider);
    final pinService = _ref.read(pinAuthServiceProvider);

    final adminDevice = bundle.devices.firstWhere(
      (d) => d.role == DeviceRole.admin && !d.isRevoked,
      orElse: () => Device(
        id: 'admin_${DateTime.now().millisecondsSinceEpoch}',
        displayName: 'System Administrator',
        role: DeviceRole.admin,
        pairedAt: DateTime.now(),
        lastSeenAt: DateTime.now(),
      ),
    );

    await deviceRepo.saveWorkspaceAndLocalDevice(
      workspace: bundle.workspace,
      localDevice: adminDevice,
      additionalDevices: bundle.devices,
    );

    if (bundle.productTypes.isNotEmpty) {
      await productRepo.applySyncedProductTypesAtomically(bundle.productTypes);
    }

    for (final product in bundle.products) {
      await productRepo.saveProduct(product);
    }

    await pinService.setLocalDeviceId(adminDevice.id);
    await pinService.setPin(pin);

    _startSessionTimer();
    state = AuthState(
      status: AuthStatus.unlocked,
      workspace: bundle.workspace,
      device: adminDevice,
    );
  }

  Future<PinVerificationResult> unlockWithPin(String pin) async {
    final pinService = _ref.read(pinAuthServiceProvider);
    final deviceRepo = _ref.read(deviceRepositoryProvider);

    final result = await pinService.verifyPin(pin);
    if (!result.success) {
      return result;
    }

    final currentDevice = state.device;
    if (currentDevice != null) {
      final refreshed = await deviceRepo.getDeviceById(currentDevice.id);
      if (refreshed != null && refreshed.isRevoked) {
        state = state.copyWith(status: AuthStatus.revoked, device: refreshed);
        return const PinVerificationResult(
          success: false,
          errorMessage: 'This device has been revoked by an Administrator.',
        );
      }
      await deviceRepo.updateLastSeen(currentDevice.id, DateTime.now());
      _startSessionTimer();
      state = state.copyWith(
        status: AuthStatus.unlocked,
        device: refreshed ?? currentDevice,
        sessionExpiringSoon: false,
      );
    } else {
      _startSessionTimer();
      state = state.copyWith(
        status: AuthStatus.unlocked,
        sessionExpiringSoon: false,
      );
    }

    return result;
  }

  Future<bool> unlockWithBiometrics() async {
    final pinService = _ref.read(pinAuthServiceProvider);
    final ok = await pinService.authenticateWithBiometrics();
    if (!ok) return false;

    final currentDevice = state.device;
    if (currentDevice != null) {
      await _ref
          .read(deviceRepositoryProvider)
          .updateLastSeen(currentDevice.id, DateTime.now());
    }

    _startSessionTimer();
    state = state.copyWith(
      status: AuthStatus.unlocked,
      sessionExpiringSoon: false,
    );
    return true;
  }

  void lockNow() {
    _idleCheckTimer?.cancel();
    _idleCheckTimer = null;
    if (state.status == AuthStatus.unlocked) {
      state = state.copyWith(
        status: AuthStatus.locked,
        sessionExpiringSoon: false,
      );
    }
  }

  void recordActivity() {
    if (state.status != AuthStatus.unlocked) return;
    if (!state.sessionExpiringSoon) {
      _lastActivityAt = DateTime.now();
    }
  }

  void extendSession() {
    if (state.status != AuthStatus.unlocked) return;
    _lastActivityAt = DateTime.now();
    state = state.copyWith(sessionExpiringSoon: false);
  }

  Future<void> refreshCurrentDevice() async {
    final current = state.device;
    if (current == null) return;
    final updated =
        await _ref.read(deviceRepositoryProvider).getDeviceById(current.id);
    if (updated != null) {
      if (updated.isRevoked) {
        _idleCheckTimer?.cancel();
        state = state.copyWith(status: AuthStatus.revoked, device: updated);
      } else {
        state = state.copyWith(device: updated);
      }
    }
  }

  void _startSessionTimer() {
    _lastActivityAt = DateTime.now();
    _idleCheckTimer?.cancel();
    _idleCheckTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      checkIdleTimeout();
    });
  }

  void checkIdleTimeout([DateTime? now]) {
    if (state.status != AuthStatus.unlocked) return;
    final current = now ?? DateTime.now();
    final elapsed = current.difference(_lastActivityAt);
    final warningThreshold = AppConstants.sessionIdleTimeout -
        AppConstants.sessionWarningBeforeTimeout;

    if (elapsed >= AppConstants.sessionIdleTimeout) {
      lockNow();
    } else if (elapsed >= warningThreshold) {
      final remaining = AppConstants.sessionIdleTimeout - elapsed;
      state = state.copyWith(
        sessionExpiringSoon: true,
        remainingBeforeLock: remaining,
      );
    }
  }

  Future<void> factoryReset() async {
    _idleCheckTimer?.cancel();
    await _ref.read(syncControllerProvider.notifier).stop();
    await _ref.read(databaseProvider).clearAllData();
    await _ref.read(pinAuthServiceProvider).clearAllAuthData();
    await _ref.read(sharedPreferencesProvider).clear();

    _ref.invalidate(searchQueryProvider);
    _ref.invalidate(selectedTypeFilterProvider);
    _ref.invalidate(selectedComponentFilterProvider);
    _ref.invalidate(selectedIngredientFilterProvider);
    _ref.invalidate(myProductsOnlyProvider);

    state = const AuthState(status: AuthStatus.needsOnboarding);
  }

  @override
  void dispose() {
    _idleCheckTimer?.cancel();
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
