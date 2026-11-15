import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/p2p_sync_server.dart';
import '../../core/services/peer_discovery_service.dart';
import '../../domain/models/sync_models.dart';
import '../../domain/services/product_validator.dart';
import 'auth_providers.dart';
import 'device_providers.dart';
import 'product_providers.dart';

final peerDiscoveryServiceProvider = Provider<PeerDiscoveryService>((ref) {
  final service = NsdPeerDiscoveryService();
  ref.onDispose(() => service.stop());
  return service;
});

final conflictHistoryProvider = StreamProvider<List<SyncConflictRecord>>((ref) {
  return ref.watch(productRepositoryProvider).watchConflictHistory();
});

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncStatusState>((ref) {
  final controller = SyncController(ref);
  ref.listen<AuthState>(authControllerProvider, (previous, next) {
    if (next.status == AuthStatus.unlocked) {
      controller.start();
    } else {
      controller.stop();
    }
  });

  final currentAuth = ref.read(authControllerProvider);
  if (currentAuth.status == AuthStatus.unlocked) {
    controller.start();
  }

  return controller;
});

class SyncController extends StateNotifier<SyncStatusState> {
  static const String _lastSyncedPrefsKey = 'synprod_last_synced_at';

  final Ref _ref;
  P2pSyncServer? _server;
  StreamSubscription<List<DiscoveredPeer>>? _peersSub;
  StreamSubscription<List<SyncConflictRecord>>? _conflictsSub;
  bool _isStarting = false;

  SyncController(this._ref) : super(const SyncStatusState()) {
    _loadLastSyncedAt();
    _watchConflicts();
  }

  void _loadLastSyncedAt() {
    try {
      final prefs = _ref.read(sharedPreferencesProvider);
      final raw = prefs.getString(_lastSyncedPrefsKey);
      if (raw != null) {
        state = state.copyWith(lastSyncedAt: DateTime.tryParse(raw));
      }
    } catch (_) {}
  }

  void _watchConflicts() {
    _conflictsSub = _ref
        .read(productRepositoryProvider)
        .watchConflictHistory()
        .listen((records) {
      final unresolved = records.where((r) => !r.isResolved).length;
      state = state.copyWith(unresolvedConflictsCount: unresolved);
    });
  }

  Future<void> start() async {
    if (state.isRunning || _isStarting) return;
    final auth = _ref.read(authControllerProvider);
    final workspace = auth.workspace;
    final device = auth.device;
    if (auth.status != AuthStatus.unlocked ||
        workspace == null ||
        device == null) {
      return;
    }

    _isStarting = true;
    try {
      final server = P2pSyncServer(
        deviceRepository: _ref.read(deviceRepositoryProvider),
        productRepository: _ref.read(productRepositoryProvider),
        getLocalDeviceId: () =>
            _ref.read(authControllerProvider).device?.id ?? device.id,
        onLocalDeviceRevoked: () {
          _ref.read(authControllerProvider.notifier).refreshCurrentDevice();
        },
        onSyncCompleted: _recordSyncTimestamp,
      );
      final port = await server.start();
      _server = server;

      final discovery = _ref.read(peerDiscoveryServiceProvider);
      await _peersSub?.cancel();
      _peersSub = discovery.peersStream.listen((peers) {
        final previousIds = state.peers.map((p) => p.deviceId).toSet();
        state = state.copyWith(peers: peers);
        final newlyFound =
            peers.where((p) => !previousIds.contains(p.deviceId)).toList();
        if (newlyFound.isNotEmpty) {
          unawaited(_syncPeers(newlyFound));
        }
      });

      await discovery.start(
        workspaceId: workspace.id,
        localDeviceId: device.id,
        localDisplayName: device.displayName,
        port: port,
      );

      state = state.copyWith(isRunning: true, clearError: true);
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        lastError: 'Sync service unavailable: $e',
      );
    } finally {
      _isStarting = false;
    }
  }

  Future<void> stop() async {
    await _peersSub?.cancel();
    _peersSub = null;
    try {
      await _ref.read(peerDiscoveryServiceProvider).stop();
    } catch (_) {}
    await _server?.stop();
    _server = null;
    state = state.copyWith(isRunning: false, isSyncing: false, peers: const []);
  }

  Future<void> syncNow() async {
    if (!state.isRunning) {
      await start();
    }
    await _syncPeers(state.peers);
  }

  Future<void> _syncPeers(List<DiscoveredPeer> peers) async {
    final server = _server;
    if (server == null || peers.isEmpty || state.isSyncing) return;

    state = state.copyWith(isSyncing: true, clearError: true);
    String? firstError;

    for (final peer in peers) {
      try {
        await server.syncWithPeer(peer);
      } catch (e) {
        firstError ??= '${peer.displayName}: $e';
      }
    }

    state = state.copyWith(
      isSyncing: false,
      lastError: firstError,
      clearError: firstError == null,
    );
  }

  void _recordSyncTimestamp() {
    final now = DateTime.now();
    state = state.copyWith(lastSyncedAt: now, clearError: true);
    try {
      _ref
          .read(sharedPreferencesProvider)
          .setString(_lastSyncedPrefsKey, now.toIso8601String());
    } catch (_) {}
  }

  Future<void> recoverConflictVersion(SyncConflictRecord record) async {
    final losingProduct = record.tryDecodeLosingProduct();
    if (losingProduct == null) {
      throw StateError('Unable to decode saved conflict snapshot.');
    }
    final device = _ref.read(currentDeviceProvider);
    final repo = _ref.read(productRepositoryProvider);
    final current = await repo.getProductById(losingProduct.id);
    final nextVersion = (current?.version ?? losingProduct.version) + 1;

    ProductValidator.validateProduct(losingProduct);

    final recovered = losingProduct.copyWith(
      isDeleted: false,
      updatedByDeviceId: device.id,
      updatedByDisplayName: device.displayName,
      updatedAt: DateTime.now(),
      version: nextVersion,
    );
    await repo.saveProduct(recovered);
    await repo.markConflictResolved(record.id);
  }

  Future<void> dismissConflict(String conflictId) async {
    await _ref.read(productRepositoryProvider).markConflictResolved(conflictId);
  }

  @override
  void dispose() {
    _conflictsSub?.cancel();
    _peersSub?.cancel();
    _server?.stop();
    super.dispose();
  }
}
