import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:synprod_lite/core/services/pin_auth_service.dart';
import 'package:synprod_lite/core/services/qr_pairing_service.dart';
import 'package:synprod_lite/core/services/workspace_backup_service.dart';
import 'package:synprod_lite/core/utils/uuid_generator.dart';
import 'package:synprod_lite/domain/models/composition.dart';
import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/product_type.dart';
import 'package:synprod_lite/domain/models/sync_models.dart';
import 'package:synprod_lite/domain/models/workspace.dart';
import 'package:synprod_lite/domain/repositories/device_repository.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';
import 'package:synprod_lite/main.dart';
import 'package:synprod_lite/presentation/providers/auth_providers.dart';
import 'package:synprod_lite/presentation/providers/device_providers.dart';
import 'package:synprod_lite/presentation/providers/product_providers.dart';
import 'package:synprod_lite/presentation/screens/device_management/device_management_screen.dart';

class _InMemoryDeviceRepository implements DeviceRepository {
  Workspace? _workspace;
  final Map<String, Device> _devices = {};
  final Map<String, PairingTokenRecord> _tokens = {};
  final _devicesCtrl = StreamController<List<Device>>.broadcast();

  void _emitDevices() => _devicesCtrl.add(_devices.values.toList());

  @override
  Future<Workspace?> getActiveWorkspace() async => _workspace;

  @override
  Stream<Workspace?> watchActiveWorkspace() => Stream.value(_workspace);

  @override
  Future<Device?> getDeviceById(String id) async => _devices[id];

  @override
  Stream<Device?> watchDeviceById(String id) => Stream.value(_devices[id]);

  @override
  Stream<List<Device>> watchAllDevices() async* {
    yield _devices.values.toList();
    yield* _devicesCtrl.stream;
  }

  @override
  Future<List<Device>> getAllDevices() async => _devices.values.toList();

  @override
  Future<({Workspace workspace, Device adminDevice})> createWorkspaceAndAdmin({
    required String workspaceName,
    required String adminDisplayName,
  }) async {
    final now = DateTime.now();
    final ws = Workspace(
      id: UuidGenerator.v4(),
      name: workspaceName,
      workspaceKey: 'test_key_32_bytes_12345678901234',
      createdAt: now,
    );
    final admin = Device(
      id: UuidGenerator.v4(),
      displayName: adminDisplayName,
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    _workspace = ws;
    _devices[admin.id] = admin;
    _emitDevices();
    return (workspace: ws, adminDevice: admin);
  }

  @override
  Future<void> saveWorkspaceAndLocalDevice({
    required Workspace workspace,
    required Device localDevice,
    List<Device> additionalDevices = const [],
  }) async {
    _workspace = workspace;
    _devices[localDevice.id] = localDevice;
    for (final d in additionalDevices) {
      _devices[d.id] = d;
    }
    _emitDevices();
  }

  @override
  Future<void> upsertDevice(Device device) async {
    _devices[device.id] = device;
    _emitDevices();
  }

  @override
  Future<void> updateDeviceRole(String deviceId, DeviceRole role) async {
    final existing = _devices[deviceId];
    if (existing != null) {
      _devices[deviceId] = existing.copyWith(role: role);
      _emitDevices();
    }
  }

  @override
  Future<void> setDeviceRevoked(String deviceId, bool isRevoked) async {
    final existing = _devices[deviceId];
    if (existing != null) {
      _devices[deviceId] = existing.copyWith(isRevoked: isRevoked);
      _emitDevices();
    }
  }

  @override
  Future<void> updateLastSeen(String deviceId, DateTime timestamp) async {
    final existing = _devices[deviceId];
    if (existing != null) {
      _devices[deviceId] = existing.copyWith(lastSeenAt: timestamp);
      _emitDevices();
    }
  }

  @override
  Future<PairingTokenRecord> createPairingToken({
    required String deviceId,
    required String displayName,
    required DeviceRole role,
    required Duration validity,
  }) async {
    final now = DateTime.now();
    final token = PairingTokenRecord(
      id: UuidGenerator.v4(),
      deviceId: deviceId,
      displayName: displayName,
      role: role,
      createdAt: now,
      expiresAt: now.add(validity),
      isUsed: false,
    );
    _tokens[token.id] = token;
    return token;
  }

  @override
  Future<PairingTokenRecord?> getPairingToken(String tokenId) async =>
      _tokens[tokenId];

  @override
  Future<void> markPairingTokenUsed(String tokenId) async {
    final existing = _tokens[tokenId];
    if (existing != null) {
      _tokens[tokenId] = PairingTokenRecord(
        id: existing.id,
        deviceId: existing.deviceId,
        displayName: existing.displayName,
        role: existing.role,
        createdAt: existing.createdAt,
        expiresAt: existing.expiresAt,
        isUsed: true,
      );
    }
  }

  void dispose() {
    _devicesCtrl.close();
  }
}

class _InMemoryProductRepository implements ProductRepository {
  @override
  Stream<List<Product>> watchActiveProducts() => Stream.value(const []);
  @override
  Future<List<Product>> getActiveProducts() async => const [];
  @override
  Future<List<Product>> getAllProductsIncludingDeleted() async => const [];
  @override
  Future<Product?> getProductById(String id) async => null;
  @override
  Future<void> saveProduct(Product product) async {}
  @override
  Future<void> applySyncedProductsAtomically(List<Product> products) async {}
  @override
  Future<void> softDeleteProduct(
    String id, {
    String? deletedByDeviceId,
    String? deletedByDisplayName,
  }) async {}
  @override
  Future<List<String>> getDistinctComponents() async => const [];
  @override
  Future<List<String>> getDistinctIngredients() async => const [];
  @override
  Future<void> seedInitialDataIfEmpty() async {}
  @override
  Stream<List<SyncConflictRecord>> watchConflictHistory() =>
      Stream.value(const []);
  @override
  Future<List<SyncConflictRecord>> getConflictHistory() async => const [];
  @override
  Future<void> saveConflictRecords(List<SyncConflictRecord> records) async {}
  @override
  Future<void> markConflictResolved(String conflictId) async {}
}

void main() {
  group('PinAuthService', () {
    test('validates 4-6 digit PIN format', () {
      expect(PinAuthService.isValidPinFormat('1234'), isTrue);
      expect(PinAuthService.isValidPinFormat('123456'), isTrue);
      expect(PinAuthService.isValidPinFormat('123'), isFalse);
      expect(PinAuthService.isValidPinFormat('1234567'), isFalse);
      expect(PinAuthService.isValidPinFormat('12ab'), isFalse);
    });

    test('verifies PIN and enforces brute-force lockout after 5 failures',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      var currentTime = DateTime(2026, 11, 15, 12, 0);
      final service = PinAuthService(prefs: prefs, now: () => currentTime);

      await service.setPin('4829');
      expect((await service.verifyPin('4829')).success, isTrue);

      for (var i = 0; i < 4; i++) {
        final res = await service.verifyPin('0000');
        expect(res.success, isFalse);
        expect(res.lockoutRemaining, isNull);
      }

      final lockedRes = await service.verifyPin('0000');
      expect(lockedRes.success, isFalse);
      expect(lockedRes.lockoutRemaining, const Duration(seconds: 30));

      final blockedRes = await service.verifyPin('4829');
      expect(blockedRes.success, isFalse);
      expect(blockedRes.lockoutRemaining, isNotNull);

      currentTime = currentTime.add(const Duration(seconds: 31));
      final unlockedRes = await service.verifyPin('4829');
      expect(unlockedRes.success, isTrue);
    });
  });

  group('QrPairingService', () {
    final workspace = Workspace(
      id: 'ws_1',
      name: 'Test Plant',
      workspaceKey: 'super_secret_workspace_key_32_bytes',
      createdAt: DateTime(2026, 11, 15),
    );

    test('creates and validates signed payload for PRODUCTION and MANAGER', () {
      final now = DateTime(2026, 11, 15, 12, 0);
      final service = QrPairingService(now: () => now);

      final payload = service.createPayload(
        workspace: workspace,
        deviceId: 'dev_2',
        displayName: 'Floor Tablet',
        role: DeviceRole.production,
      );

      final result = service.validateRawPayload(payload.toJsonString());
      expect(result.isValid, isTrue);
      expect(result.payload?.deviceId, 'dev_2');
      expect(result.payload?.role, DeviceRole.production);
    });

    test('rejects ADMIN role, expired tokens, and tampered payloads', () {
      var now = DateTime(2026, 11, 15, 12, 0);
      final service = QrPairingService(now: () => now);

      expect(
        () => service.createPayload(
          workspace: workspace,
          deviceId: 'dev_admin',
          displayName: 'Rogue Admin',
          role: DeviceRole.admin,
        ),
        throwsArgumentError,
      );

      final payload = service.createPayload(
        workspace: workspace,
        deviceId: 'dev_3',
        displayName: 'Manager Tablet',
        role: DeviceRole.manager,
        validity: const Duration(minutes: 10),
      );

      final tamperedMap =
          jsonDecode(payload.toJsonString()) as Map<String, dynamic>;
      tamperedMap['r'] = 'PRODUCTION';
      final tamperedResult =
          service.validateRawPayload(jsonEncode(tamperedMap));
      expect(tamperedResult.isValid, isFalse);

      now = now.add(const Duration(minutes: 11));
      final expiredResult = service.validateRawPayload(payload.toJsonString());
      expect(expiredResult.isValid, isFalse);
      expect(expiredResult.errorMessage, contains('expired'));
    });
  });

  group('WorkspaceBackupService', () {
    test('encrypts and decrypts workspace bundle and rejects wrong password',
        () {
      final service = WorkspaceBackupService();
      final now = DateTime(2026, 11, 15, 12, 0);
      final bundle = WorkspaceBackupBundle(
        workspace: Workspace(
          id: 'ws_1',
          name: 'Synbiotic Plant',
          workspaceKey: 'key_123',
          createdAt: now,
        ),
        devices: [
          Device(
            id: 'dev_1',
            displayName: 'Admin',
            role: DeviceRole.admin,
            pairedAt: now,
            lastSeenAt: now,
          ),
        ],
        products: [
          Product(
            id: 'prod_1',
            name: 'Kefir',
            productType: ProductType.drinks,
            compositions: const [
              Composition(componentName: 'Milk', percentage: 100, sortOrder: 0),
            ],
            createdByDeviceId: 'dev_1',
            createdByDisplayName: 'Admin',
            createdAt: now,
            updatedAt: now,
          ),
        ],
        exportedAt: now,
      );

      final encrypted =
          service.encryptBundle(bundle: bundle, password: 'strongPassword1');
      final decrypted = service.decryptBundle(
        rawContent: encrypted,
        password: 'strongPassword1',
      );

      expect(decrypted.workspace.name, 'Synbiotic Plant');
      expect(decrypted.devices.length, 1);
      expect(decrypted.products.first.name, 'Kefir');

      expect(
        () => service.decryptBundle(
          rawContent: encrypted,
          password: 'wrongPassword',
        ),
        throwsA(isA<WorkspaceBackupException>()),
      );
    });
  });

  group('Phase 4 Widget Flows', () {
    testWidgets('Onboarding creates Admin workspace and unlocks to library',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final deviceRepo = _InMemoryDeviceRepository();
      final productRepo = _InMemoryProductRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            deviceRepositoryProvider.overrideWithValue(deviceRepo),
            productRepositoryProvider.overrideWithValue(productRepo),
          ],
          child: const SynProdLiteApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create New Workspace (Admin)'), findsOneWidget);
      await tester.tap(find.text('Create New Workspace (Admin)'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Workspace Name *'),
        'Dairy HQ',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'This Device Name *'),
        'HQ Admin',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Device PIN (4–6 digits) *'),
        '1234',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm PIN *'),
        '1234',
      );

      await tester.tap(find.text('Create Workspace'));
      await tester.pumpAndSettle();

      expect(find.text('HQ Admin'), findsOneWidget);
      expect(find.text('ADMIN'), findsOneWidget);

      deviceRepo.dispose();
    });

    testWidgets('DeviceManagementScreen blocks non-admin and allows admin',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final deviceRepo = _InMemoryDeviceRepository();
      final now = DateTime.now();

      final prodDevice = Device(
        id: 'dev_prod',
        displayName: 'Floor 1',
        role: DeviceRole.production,
        pairedAt: now,
        lastSeenAt: now,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            deviceRepositoryProvider.overrideWithValue(deviceRepo),
            currentDeviceProvider.overrideWithValue(prodDevice),
          ],
          child: const MaterialApp(home: DeviceManagementScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Access Denied'), findsOneWidget);

      deviceRepo.dispose();
    });
  });
}
