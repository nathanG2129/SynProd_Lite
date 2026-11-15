import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:synprod_lite/core/services/p2p_sync_server.dart';
import 'package:synprod_lite/core/services/sync_crypto_service.dart';
import 'package:synprod_lite/domain/models/composition.dart';
import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/ingredient.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/product_type.dart';
import 'package:synprod_lite/domain/models/sync_models.dart';
import 'package:synprod_lite/domain/models/workspace.dart';
import 'package:synprod_lite/domain/repositories/device_repository.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';
import 'package:synprod_lite/domain/services/sync_merge_engine.dart';

void main() {
  final baseTime = DateTime.utc(2026, 11, 15, 12, 0, 0);

  Device makeDevice(
    String id,
    String name,
    DeviceRole role, {
    bool isRevoked = false,
  }) {
    return Device(
      id: id,
      displayName: name,
      role: role,
      pairedAt: baseTime,
      lastSeenAt: baseTime,
      isRevoked: isRevoked,
    );
  }

  Product makeProduct({
    required String id,
    required String name,
    required String createdByDeviceId,
    required String createdByDisplayName,
    String? updatedByDeviceId,
    String? updatedByDisplayName,
    int version = 1,
    DateTime? updatedAt,
    bool isDeleted = false,
    double firstCompPct = 70.0,
    double secondCompPct = 30.0,
  }) {
    return Product(
      id: id,
      name: name,
      description: 'Test recipe',
      productType: ProductType.greekYogurt,
      createdByDeviceId: createdByDeviceId,
      createdByDisplayName: createdByDisplayName,
      updatedByDeviceId: updatedByDeviceId ?? createdByDeviceId,
      updatedByDisplayName: updatedByDisplayName ?? createdByDisplayName,
      createdAt: baseTime,
      updatedAt: updatedAt ?? baseTime,
      isDeleted: isDeleted,
      version: version,
      compositions: [
        Composition(
          componentName: 'Whole Milk',
          percentage: firstCompPct,
          sortOrder: 0,
        ),
        Composition(
          componentName: 'Starter Culture',
          percentage: secondCompPct,
          sortOrder: 1,
        ),
      ],
      additionalIngredients: const [
        AdditionalIngredient(
          ingredientName: 'Vanilla',
          quantity: 5.0,
          unit: 'ml',
          sortOrder: 0,
        ),
      ],
    );
  }

  group('SyncCryptoService', () {
    test('encrypts and decrypts snapshot envelope and rejects tampering/replay', () {
      final crypto = SyncCryptoService(now: () => baseTime);
      const workspaceKey = 'super-secret-workspace-key-123456';
      final snapshot = SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: 'dev-admin',
        generatedAt: baseTime,
        devices: [makeDevice('dev-admin', 'Admin Tablet', DeviceRole.admin)],
        products: [
          makeProduct(
            id: 'prod-1',
            name: 'Greek Base',
            createdByDeviceId: 'dev-admin',
            createdByDisplayName: 'Admin Tablet',
          ),
        ],
      );

      final encrypted = crypto.encryptEnvelope(
        snapshot: snapshot,
        workspaceKey: workspaceKey,
      );

      final decrypted = crypto.decryptEnvelope(
        rawEnvelope: encrypted,
        expectedWorkspaceId: 'ws-1',
        workspaceKey: workspaceKey,
      );
      expect(decrypted.products.length, 1);
      expect(decrypted.products.first.name, 'Greek Base');

      // Replay with same nonce must fail
      expect(
        () => crypto.decryptEnvelope(
          rawEnvelope: encrypted,
          expectedWorkspaceId: 'ws-1',
          workspaceKey: workspaceKey,
        ),
        throwsA(isA<SyncCryptoException>()),
      );

      // Wrong workspace ID must fail
      expect(
        () => crypto.decryptEnvelope(
          rawEnvelope: encrypted,
          expectedWorkspaceId: 'ws-other',
          workspaceKey: workspaceKey,
        ),
        throwsA(isA<SyncCryptoException>()),
      );

      // Tampered payload must fail
      final tampered = encrypted.replaceFirst('"wid":"ws-1"', '"wid":"ws-1" ')
          .replaceFirst('mac":"', 'mac":"0');
      expect(
        () => crypto.decryptEnvelope(
          rawEnvelope: tampered,
          expectedWorkspaceId: 'ws-1',
          workspaceKey: workspaceKey,
        ),
        throwsA(isA<SyncCryptoException>()),
      );
    });
  });

  group('SyncMergeEngine', () {
    final admin = makeDevice('dev-admin', 'Admin', DeviceRole.admin);
    final managerA = makeDevice('dev-mgr-a', 'Manager A', DeviceRole.manager);
    final managerB = makeDevice('dev-mgr-b', 'Manager B', DeviceRole.manager);
    final prodFloor =
        makeDevice('dev-prod', 'Floor Tablet', DeviceRole.production);
    final devices = [admin, managerA, managerB, prodFloor];

    test('LWW overwrites older version and preserves losing snapshot in history', () {
      final engine = SyncMergeEngine(now: () => baseTime.add(const Duration(minutes: 5)));
      final localProduct = makeProduct(
        id: 'prod-1',
        name: 'Kefir v1',
        createdByDeviceId: managerA.id,
        createdByDisplayName: managerA.displayName,
        version: 1,
      );
      final incomingProduct = makeProduct(
        id: 'prod-1',
        name: 'Kefir v2 (Admin Edit)',
        createdByDeviceId: managerA.id,
        createdByDisplayName: managerA.displayName,
        updatedByDeviceId: admin.id,
        updatedByDisplayName: admin.displayName,
        version: 2,
        updatedAt: baseTime.add(const Duration(minutes: 2)),
      );

      final result = engine.merge(
        localDevice: managerA,
        localDevices: devices,
        localProducts: [localProduct],
        incoming: SyncSnapshot(
          workspaceId: 'ws-1',
          senderDeviceId: admin.id,
          generatedAt: baseTime,
          devices: devices,
          products: [incomingProduct],
        ),
      );

      expect(result.productsToSave.length, 1);
      expect(result.productsToSave.first.name, 'Kefir v2 (Admin Edit)');
      expect(result.newConflicts.length, 1);
      expect(result.newConflicts.first.conflictType, SyncConflictType.lwwOverwritten);
      final recovered = result.newConflicts.first.tryDecodeLosingProduct();
      expect(recovered, isNotNull);
      expect(recovered!.name, 'Kefir v1');
      expect(recovered.version, 1);
    });

    test('enforces PRODUCTION read-only, MANAGER ownership, and 100% integrity', () {
      final engine = SyncMergeEngine(now: () => baseTime);
      final ownedByA = makeProduct(
        id: 'prod-a',
        name: 'Recipe A',
        createdByDeviceId: managerA.id,
        createdByDisplayName: managerA.displayName,
        version: 1,
      );

      // 1. Production device tries to push a product -> rejected
      final prodAttempt = makeProduct(
        id: 'prod-from-floor',
        name: 'Floor Hack',
        createdByDeviceId: prodFloor.id,
        createdByDisplayName: prodFloor.displayName,
      );
      // 2. Manager B tries to edit Manager A's product -> rejected
      final crossManagerEdit = ownedByA.copyWith(
        name: 'Hijacked Recipe A',
        updatedByDeviceId: managerB.id,
        updatedByDisplayName: managerB.displayName,
        version: 2,
      );
      // 3. Manager A tries to soft-delete own product -> rejected (ADMIN only)
      final managerDelete = ownedByA.copyWith(
        isDeleted: true,
        updatedByDeviceId: managerA.id,
        updatedByDisplayName: managerA.displayName,
        version: 2,
      );
      // 4. Admin pushes invalid composition sum (80% != 100%) -> rejected
      final invalidComposition = makeProduct(
        id: 'prod-bad-sum',
        name: 'Bad Sum',
        createdByDeviceId: admin.id,
        createdByDisplayName: admin.displayName,
        firstCompPct: 50.0,
        secondCompPct: 30.0,
      );

      final result = engine.merge(
        localDevice: admin,
        localDevices: devices,
        localProducts: [ownedByA],
        incoming: SyncSnapshot(
          workspaceId: 'ws-1',
          senderDeviceId: managerB.id,
          generatedAt: baseTime,
          devices: devices,
          products: [
            prodAttempt,
            crossManagerEdit,
            managerDelete,
            invalidComposition,
          ],
        ),
      );

      expect(result.productsToSave, isEmpty);
      expect(result.newConflicts.length, 4);
      expect(
        result.newConflicts.where((c) => c.conflictType == SyncConflictType.permissionRejected).length,
        3,
      );
      expect(
        result.newConflicts.where((c) => c.conflictType == SyncConflictType.validationRejected).length,
        1,
      );
    });

    test('detects duplicate product names created offline and revocation propagation', () {
      final engine = SyncMergeEngine(now: () => baseTime);
      final localProd = makeProduct(
        id: 'prod-1',
        name: 'Classic Yogurt',
        createdByDeviceId: admin.id,
        createdByDisplayName: admin.displayName,
      );
      final remoteDuplicateName = makeProduct(
        id: 'prod-2',
        name: 'classic yogurt',
        createdByDeviceId: managerB.id,
        createdByDisplayName: managerB.displayName,
      ).copyWith(createdAt: baseTime.add(const Duration(minutes: 1)));

      final revokedManagerA = managerA.copyWith(isRevoked: true);

      final result = engine.merge(
        localDevice: managerA,
        localDevices: devices,
        localProducts: [localProd],
        incoming: SyncSnapshot(
          workspaceId: 'ws-1',
          senderDeviceId: admin.id,
          generatedAt: baseTime,
          devices: [admin, revokedManagerA, managerB, prodFloor],
          products: [remoteDuplicateName],
        ),
      );

      expect(result.localDeviceRevoked, isTrue);
      expect(
        result.newConflicts.any((c) => c.conflictType == SyncConflictType.nameConflict),
        isTrue,
      );
    });
  });

  group('P2pSyncServer loopback integration', () {
    test('two instances exchange products atomically over local HTTP', () async {
      final devRepoA = _MemoryDeviceRepo();
      final prodRepoA = _MemoryProductRepo();
      final devRepoB = _MemoryDeviceRepo();
      final prodRepoB = _MemoryProductRepo();

      final ws = Workspace(
        id: 'ws-sync-test',
        name: 'Dairy Plant',
        workspaceKey: 'shared-workspace-secret-key-001',
        createdAt: baseTime,
      );

      final adminDev = makeDevice('dev-admin', 'Admin Tablet', DeviceRole.admin);
      final mgrDev = makeDevice('dev-mgr', 'Manager Phone', DeviceRole.manager);

      await devRepoA.saveWorkspaceAndLocalDevice(
        workspace: ws,
        localDevice: adminDev,
        additionalDevices: [mgrDev],
      );
      await devRepoB.saveWorkspaceAndLocalDevice(
        workspace: ws,
        localDevice: mgrDev,
        additionalDevices: [adminDev],
      );

      // Admin has Recipe A; Manager has Recipe B
      await prodRepoA.saveProduct(
        makeProduct(
          id: 'prod-a',
          name: 'Admin Greek Yogurt',
          createdByDeviceId: adminDev.id,
          createdByDisplayName: adminDev.displayName,
        ),
      );
      await prodRepoB.saveProduct(
        makeProduct(
          id: 'prod-b',
          name: 'Manager Cheddar',
          createdByDeviceId: mgrDev.id,
          createdByDisplayName: mgrDev.displayName,
        ),
      );

      final serverA = P2pSyncServer(
        deviceRepository: devRepoA,
        productRepository: prodRepoA,
        getLocalDeviceId: () => adminDev.id,
      );
      final serverB = P2pSyncServer(
        deviceRepository: devRepoB,
        productRepository: prodRepoB,
        getLocalDeviceId: () => mgrDev.id,
      );

      final portA = await serverA.start(bindAddress: InternetAddress.loopbackIPv4);
      final portB = await serverB.start(bindAddress: InternetAddress.loopbackIPv4);
      addTearDown(() async {
        await serverA.stop();
        await serverB.stop();
      });
      expect(portA, greaterThan(0));
      expect(portB, greaterThan(0));

      // Manager initiates sync with Admin
      await serverB.syncWithPeer(
        DiscoveredPeer(
          deviceId: adminDev.id,
          displayName: adminDev.displayName,
          workspaceId: ws.id,
          host: '127.0.0.1',
          port: portA,
          discoveredAt: baseTime,
        ),
      );

      final productsOnA = await prodRepoA.getActiveProducts();
      final productsOnB = await prodRepoB.getActiveProducts();

      expect(productsOnA.map((p) => p.id).toSet(), {'prod-a', 'prod-b'});
      expect(productsOnB.map((p) => p.id).toSet(), {'prod-a', 'prod-b'});
      expect(productsOnB.firstWhere((p) => p.id == 'prod-a').compositions.length, 2);
      expect(productsOnB.firstWhere((p) => p.id == 'prod-a').additionalIngredients.length, 1);
    });
  });
}

class _MemoryDeviceRepo implements DeviceRepository {
  Workspace? _workspace;
  final Map<String, Device> _devices = {};

  @override
  Future<Workspace?> getActiveWorkspace() async => _workspace;
  @override
  Stream<Workspace?> watchActiveWorkspace() => Stream.value(_workspace);
  @override
  Future<Device?> getDeviceById(String id) async => _devices[id];
  @override
  Stream<Device?> watchDeviceById(String id) => Stream.value(_devices[id]);
  @override
  Stream<List<Device>> watchAllDevices() => Stream.value(_devices.values.toList());
  @override
  Future<List<Device>> getAllDevices() async => _devices.values.toList();

  @override
  Future<({Workspace workspace, Device adminDevice})> createWorkspaceAndAdmin({
    required String workspaceName,
    required String adminDisplayName,
  }) => throw UnimplementedError();

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
  }

  @override
  Future<void> upsertDevice(Device device) async => _devices[device.id] = device;
  @override
  Future<void> updateDeviceRole(String deviceId, DeviceRole role) async {}
  @override
  Future<void> setDeviceRevoked(String deviceId, bool isRevoked) async {}
  @override
  Future<void> updateLastSeen(String deviceId, DateTime timestamp) async {}
  @override
  Future<PairingTokenRecord> createPairingToken({
    required String deviceId,
    required String displayName,
    required DeviceRole role,
    required Duration validity,
  }) => throw UnimplementedError();
  @override
  Future<PairingTokenRecord?> getPairingToken(String tokenId) async => null;
  @override
  Future<void> markPairingTokenUsed(String tokenId) async {}
}

class _MemoryProductRepo implements ProductRepository {
  final Map<String, Product> _products = {};
  final List<SyncConflictRecord> _conflicts = [];

  @override
  Stream<List<Product>> watchActiveProducts() =>
      Stream.value(_products.values.where((p) => !p.isDeleted).toList());
  @override
  Future<List<Product>> getActiveProducts() async =>
      _products.values.where((p) => !p.isDeleted).toList();
  @override
  Future<List<Product>> getAllProductsIncludingDeleted() async =>
      _products.values.toList();
  @override
  Future<Product?> getProductById(String id) async => _products[id];
  @override
  Future<void> saveProduct(Product product) async => _products[product.id] = product;
  @override
  Future<void> applySyncedProductsAtomically(List<Product> products) async {
    for (final p in products) {
      _products[p.id] = p;
    }
  }
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
  Stream<List<SyncConflictRecord>> watchConflictHistory() => Stream.value(_conflicts);
  @override
  Future<List<SyncConflictRecord>> getConflictHistory() async => _conflicts;
  @override
  Future<void> saveConflictRecords(List<SyncConflictRecord> records) async =>
      _conflicts.addAll(records);
  @override
  Future<void> markConflictResolved(String conflictId) async {}
}
