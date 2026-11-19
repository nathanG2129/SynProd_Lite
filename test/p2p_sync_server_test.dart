import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:synprod_lite/core/services/p2p_sync_server.dart';
import 'package:synprod_lite/core/services/sync_crypto_service.dart';
import 'package:synprod_lite/domain/models/composition.dart';
import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/product_type.dart';
import 'package:synprod_lite/domain/models/sync_models.dart';
import 'package:synprod_lite/domain/models/workspace.dart';
import 'package:synprod_lite/domain/repositories/device_repository.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';
import 'package:synprod_lite/domain/services/sync_merge_engine.dart';

class _InMemoryDeviceRepository implements DeviceRepository {
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
  Future<List<Device>> getAllDevices() async => _devices.values.toList();
  @override
  Stream<List<Device>> watchAllDevices() => Stream.value(_devices.values.toList());
  @override
  Future<void> upsertDevice(Device device) async => _devices[device.id] = device;
  @override
  Future<void> updateDeviceRole(String deviceId, DeviceRole role) async {}
  @override
  Future<void> setDeviceRevoked(String deviceId, bool isRevoked) async {}
  @override
  Future<void> updateLastSeen(String deviceId, DateTime timestamp) async {}
  @override
  Future<({Workspace workspace, Device adminDevice})> createWorkspaceAndAdmin({
    required String workspaceName,
    required String adminDisplayName,
  }) =>
      throw UnimplementedError();
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
  Future<PairingTokenRecord> createPairingToken({
    required String deviceId,
    required String displayName,
    required DeviceRole role,
    required Duration validity,
  }) =>
      throw UnimplementedError();
  @override
  Future<PairingTokenRecord?> getPairingToken(String tokenId) async => null;
  @override
  Future<void> markPairingTokenUsed(String tokenId) async {}
}

class _InMemoryProductRepository implements ProductRepository {
  final List<Product> _products = [];
  List<ProductType> _productTypes = List<ProductType>.from(ProductType.defaults);

  @override
  Stream<List<Product>> watchActiveProducts() => Stream.value(_products);
  @override
  Stream<List<Product>> watchArchivedProducts() => Stream.value(const []);
  @override
  Future<List<Product>> getActiveProducts() async => _products;
  @override
  Future<List<Product>> getAllProductsIncludingDeleted() async => _products;
  @override
  Future<Product?> getProductById(String id) async => null;
  @override
  Future<void> saveProduct(Product product) async {}
  @override
  Future<void> applySyncedProductsAtomically(List<Product> products) async {
    _products.addAll(products);
  }

  @override
  Future<void> softDeleteProduct(
    String id, {
    String? deletedByDeviceId,
    String? deletedByDisplayName,
  }) async {}
  @override
  Future<void> restoreProduct(
    String id, {
    String? restoredByDeviceId,
    String? restoredByDisplayName,
  }) async {}
  @override
  Future<List<String>> getDistinctComponents() async => const [];
  @override
  Future<List<String>> getDistinctIngredients() async => const [];
  @override
  Future<void> seedInitialDataIfEmpty() async {}
  @override
  Stream<List<ProductType>> watchProductTypes() =>
      Stream.value(_productTypes.where((t) => !t.isArchived).toList());
  @override
  Stream<List<ProductType>> watchArchivedProductTypes() =>
      Stream.value(_productTypes.where((t) => t.isArchived).toList());
  @override
  Future<List<ProductType>> getProductTypes() async =>
      _productTypes.where((t) => !t.isArchived).toList();
  @override
  Future<List<ProductType>> getAllProductTypesIncludingArchived() async =>
      _productTypes;
  @override
  Future<void> saveProductType(ProductType productType) async {
    final existing = _productTypes
        .where((t) => t.code == productType.code)
        .firstOrNull;
    final toSave = existing != null
        ? productType.copyWith(
            version: existing.version + 1,
            updatedAt: productType.updatedAt ?? DateTime.now(),
          )
        : productType;
    _productTypes = [
      for (final t in _productTypes)
        if (t.code == productType.code) toSave else t,
      if (existing == null) toSave,
    ];
  }

  @override
  Future<void> applySyncedProductTypesAtomically(
    List<ProductType> productTypes,
  ) async {
    for (final incoming in productTypes) {
      final idx = _productTypes.indexWhere((t) => t.code == incoming.code);
      if (idx >= 0) {
        _productTypes[idx] = incoming;
      } else {
        _productTypes.add(incoming);
      }
    }
  }

  @override
  Future<void> setProductTypeArchived(String code, bool isArchived) async {
    _productTypes = [
      for (final t in _productTypes)
        if (t.code == code) t.copyWith(isArchived: isArchived) else t,
    ];
  }

  @override
  Future<void> deleteProductType(String code) async {
    await setProductTypeArchived(code, true);
  }
  @override
  Stream<List<SyncConflictRecord>> watchConflictHistory() =>
      Stream.value(const []);
  @override
  Future<List<SyncConflictRecord>> getConflictHistory() async => const [];
  @override
  Future<void> saveConflictRecords(List<SyncConflictRecord> records) async {}
  @override
  Future<void> markConflictResolved(String conflictId) async {}
  @override
  Future<void> clearPendingLocalEdits(List<String> productIds) async {
    for (var i = 0; i < _products.length; i++) {
      if (productIds.contains(_products[i].id)) {
        _products[i] = _products[i].copyWith(hasPendingLocalEdit: false);
      }
    }
  }
  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();
}

void main() {
  test(
      'P2pSyncServer allows newly QR-paired peer without 403 and rejects revoked peer',
      () async {
    final adminDevRepo = _InMemoryDeviceRepository();
    final peerDevRepo = _InMemoryDeviceRepository();
    final adminProdRepo = _InMemoryProductRepository();
    final peerProdRepo = _InMemoryProductRepository();

    final now = DateTime.now();
    const workspaceId = 'ws-1';
    const workspaceKey = '0123456789abcdef0123456789abcdef';
    final workspace = Workspace(
      id: workspaceId,
      name: 'Test Workspace',
      workspaceKey: workspaceKey,
      createdAt: now,
    );
    final adminDevice = Device(
      id: 'admin-1',
      displayName: 'Admin Tablet',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final peerDevice = Device(
      id: 'peer-1',
      displayName: 'Floor Tablet',
      role: DeviceRole.production,
      pairedAt: now,
      lastSeenAt: now,
    );

    // Admin has both Admin and Peer; newly QR-paired Peer only has itself.
    await adminDevRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: adminDevice,
      additionalDevices: [peerDevice],
    );
    await peerDevRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: peerDevice,
    );

    final adminServer = P2pSyncServer(
      deviceRepository: adminDevRepo,
      productRepository: adminProdRepo,
      getLocalDeviceId: () => adminDevice.id,
    );
    final peerServer = P2pSyncServer(
      deviceRepository: peerDevRepo,
      productRepository: peerProdRepo,
      getLocalDeviceId: () => peerDevice.id,
    );

    try {
      final peerPort =
          await peerServer.start(bindAddress: InternetAddress.loopbackIPv4);
      final discoveredPeer = DiscoveredPeer(
        deviceId: peerDevice.id,
        displayName: peerDevice.displayName,
        workspaceId: workspaceId,
        host: InternetAddress.loopbackIPv4.address,
        port: peerPort,
        discoveredAt: now,
      );

      // Admin -> newly paired Peer should succeed (previously 403 Forbidden).
      await adminServer.syncWithPeer(discoveredPeer);

      final peerDevicesAfterSync = await peerDevRepo.getAllDevices();
      expect(
        peerDevicesAfterSync.any((d) => d.id == adminDevice.id),
        isTrue,
      );

      // Revoking the peer on Admin and syncing from Peer -> Admin should 403.
      final adminPort =
          await adminServer.start(bindAddress: InternetAddress.loopbackIPv4);
      await adminDevRepo.upsertDevice(peerDevice.copyWith(isRevoked: true));
      final discoveredAdmin = DiscoveredPeer(
        deviceId: adminDevice.id,
        displayName: adminDevice.displayName,
        workspaceId: workspaceId,
        host: InternetAddress.loopbackIPv4.address,
        port: adminPort,
        discoveredAt: now,
      );

      await expectLater(
        () => peerServer.syncWithPeer(discoveredAdmin),
        throwsA(
          isA<P2pSyncException>().having(
            (e) => e.message,
            'message',
            contains('403'),
          ),
        ),
      );
    } finally {
      await adminServer.stop();
      await peerServer.stop();
    }
  });

  test(
      'SyncMergeEngine accepts seeded device_seed_001 products and rejects unknown device IDs',
      () {
    final now = DateTime.now();
    final adminDevice = Device(
      id: 'admin-1',
      displayName: 'Admin Tablet',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final peerDevice = Device(
      id: 'peer-1',
      displayName: 'Floor Tablet',
      role: DeviceRole.production,
      pairedAt: now,
      lastSeenAt: now,
    );

    final seededProduct = Product(
      id: '00000000-0000-4000-8000-000000000001',
      name: 'Classic Greek Yogurt',
      productType: ProductType.greekYogurt,
      createdByDeviceId: SyncMergeEngine.seedDeviceId,
      createdByDisplayName: 'System Administrator',
      createdAt: now,
      updatedAt: now,
      compositions: const [
        Composition(componentName: 'Milk', percentage: 100.0, sortOrder: 0),
      ],
    );

    final unknownModifierProduct = Product(
      id: '00000000-0000-4000-8000-000000000099',
      name: 'Rogue Recipe',
      productType: ProductType.greekYogurt,
      createdByDeviceId: 'unknown_device_999',
      createdByDisplayName: 'Unknown',
      createdAt: now,
      updatedAt: now,
      compositions: const [
        Composition(componentName: 'Milk', percentage: 100.0, sortOrder: 0),
      ],
    );

    final engine = SyncMergeEngine(now: () => now);
    final result = engine.merge(
      localDevice: peerDevice,
      localDevices: [peerDevice, adminDevice],
      localProducts: const [],
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: adminDevice.id,
        generatedAt: now,
        devices: [adminDevice, peerDevice],
        products: [seededProduct, unknownModifierProduct],
      ),
    );

    expect(result.productsToSave.map((p) => p.id), [seededProduct.id]);
    expect(result.newConflicts.length, 1);
    expect(
      result.newConflicts.first.conflictType,
      SyncConflictType.permissionRejected,
    );
    expect(result.newConflicts.first.losingDeviceId, 'unknown_device_999');
  });

  test(
      'Admin product type changes sync to users and sequential v1->v2 updates do not log false LWW conflicts',
      () async {
    final adminDevRepo = _InMemoryDeviceRepository();
    final peerDevRepo = _InMemoryDeviceRepository();
    final adminProdRepo = _InMemoryProductRepository();
    final peerProdRepo = _InMemoryProductRepository();

    final now = DateTime.now();
    const workspaceId = 'ws-1';
    const workspaceKey = '0123456789abcdef0123456789abcdef';
    final workspace = Workspace(
      id: workspaceId,
      name: 'Test Workspace',
      workspaceKey: workspaceKey,
      createdAt: now,
    );
    final adminDevice = Device(
      id: 'admin-1',
      displayName: 'Admin',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final peerDevice = Device(
      id: 'peer-1',
      displayName: 'Production',
      role: DeviceRole.production,
      pairedAt: now,
      lastSeenAt: now,
    );

    await adminDevRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: adminDevice,
      additionalDevices: [peerDevice],
    );
    await peerDevRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: peerDevice,
      additionalDevices: [adminDevice],
    );

    // Admin customizes Greek Yogurt base weight and adds a new type
    final updatedYogurt = ProductType.greekYogurt.copyWith(
      baseWeightGrams: 420.0,
      displayName: 'Greek Yogurt Pro',
    );
    await adminProdRepo.saveProductType(updatedYogurt);

    final v1 = Product(
      id: '00000000-0000-4000-8000-000000000010',
      name: 'Pro Yogurt',
      productType: updatedYogurt,
      createdByDeviceId: adminDevice.id,
      createdByDisplayName: adminDevice.displayName,
      updatedByDeviceId: adminDevice.id,
      updatedByDisplayName: adminDevice.displayName,
      createdAt: now,
      updatedAt: now,
      version: 1,
      compositions: const [
        Composition(componentName: 'Milk', percentage: 100.0, sortOrder: 0),
      ],
    );
    final v2 = v1.copyWith(
      version: 2,
      updatedAt: now.add(const Duration(minutes: 1)),
      updatedByDeviceId: adminDevice.id,
      updatedByDisplayName: adminDevice.displayName,
    );

    await peerProdRepo.applySyncedProductsAtomically([v1]);
    await adminProdRepo.applySyncedProductsAtomically([v2]);

    final adminServer = P2pSyncServer(
      deviceRepository: adminDevRepo,
      productRepository: adminProdRepo,
      getLocalDeviceId: () => adminDevice.id,
    );
    final peerServer = P2pSyncServer(
      deviceRepository: peerDevRepo,
      productRepository: peerProdRepo,
      getLocalDeviceId: () => peerDevice.id,
    );

    try {
      final peerPort =
          await peerServer.start(bindAddress: InternetAddress.loopbackIPv4);
      final discoveredPeer = DiscoveredPeer(
        deviceId: peerDevice.id,
        displayName: peerDevice.displayName,
        workspaceId: workspaceId,
        host: InternetAddress.loopbackIPv4.address,
        port: peerPort,
        discoveredAt: now,
      );

      final result = await adminServer.syncWithPeer(discoveredPeer);
      expect(result.newConflicts, isEmpty);

      final peerTypes = await peerProdRepo.getProductTypes();
      final syncedYogurt =
          peerTypes.firstWhere((t) => t.code == ProductType.greekYogurt.code);
      expect(syncedYogurt.baseWeightGrams, 420.0);
      expect(syncedYogurt.displayName, 'Greek Yogurt Pro');
    } finally {
      await adminServer.stop();
      await peerServer.stop();
    }
  });

  test(
      'Revoked device historical recipes do not spam conflicts on sync and Admin can distribute them to new peers',
      () {
    final now = DateTime.now();
    final adminDevice = Device(
      id: 'admin-1',
      displayName: 'Admin',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final revokedManager = Device(
      id: 'mgr-revoked',
      displayName: 'Former Manager',
      role: DeviceRole.manager,
      pairedAt: now,
      lastSeenAt: now,
      isRevoked: true,
    );
    final productionDevice = Device(
      id: 'prod-1',
      displayName: 'Floor Tablet',
      role: DeviceRole.production,
      pairedAt: now,
      lastSeenAt: now,
    );

    final historicalProduct = Product(
      id: '00000000-0000-4000-8000-000000000050',
      name: 'Historical Yogurt',
      productType: ProductType.greekYogurt,
      createdByDeviceId: revokedManager.id,
      createdByDisplayName: revokedManager.displayName,
      updatedByDeviceId: revokedManager.id,
      updatedByDisplayName: revokedManager.displayName,
      createdAt: now,
      updatedAt: now,
      compositions: const [
        Composition(componentName: 'Milk', percentage: 100.0, sortOrder: 0),
      ],
    );

    final engine = SyncMergeEngine(now: () => now);

    // 1. Production syncs identical historical product back to Admin: no conflict spam.
    final adminMergeResult = engine.merge(
      localDevice: adminDevice,
      localDevices: [adminDevice, revokedManager, productionDevice],
      localProducts: [historicalProduct],
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: productionDevice.id,
        generatedAt: now,
        devices: [productionDevice],
        products: [historicalProduct],
      ),
    );
    expect(adminMergeResult.newConflicts, isEmpty);
    expect(adminMergeResult.productsToSave, isEmpty);

    // 2. Admin distributes historical product to a newly paired Production peer: accepted without conflict.
    final newPeerResult = engine.merge(
      localDevice: productionDevice,
      localDevices: [productionDevice, adminDevice],
      localProducts: const [],
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: adminDevice.id,
        generatedAt: now,
        devices: [adminDevice, revokedManager, productionDevice],
        products: [historicalProduct],
      ),
    );
    expect(newPeerResult.newConflicts, isEmpty);
    expect(newPeerResult.productsToSave.map((p) => p.id), [historicalProduct.id]);

    // 3. Non-admin peer pushing a new/unseen recipe attributed to a revoked device is still rejected.
    final nonAdminPushResult = engine.merge(
      localDevice: adminDevice,
      localDevices: [adminDevice, revokedManager, productionDevice],
      localProducts: const [],
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: productionDevice.id,
        generatedAt: now,
        devices: [productionDevice],
        products: [historicalProduct],
      ),
    );
    expect(nonAdminPushResult.productsToSave, isEmpty);
    expect(nonAdminPushResult.newConflicts.length, 1);
    expect(
      nonAdminPushResult.newConflicts.first.conflictType,
      SyncConflictType.permissionRejected,
    );
  });

  test('Linear sequential edit without hasPendingLocalEdit produces zero conflicts', () {
    final now = DateTime.utc(2026, 5, 1, 10, 0);
    final engine = SyncMergeEngine(now: () => now);
    final admin = Device(
      id: 'admin-1',
      displayName: 'Admin',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final manager = Device(
      id: 'mgr-1',
      displayName: 'Manager',
      role: DeviceRole.manager,
      pairedAt: now,
      lastSeenAt: now,
    );

    final localV1 = Product(
      id: 'prod-lin-1',
      name: 'Mango Yogurt',
      productType: ProductType.greekYogurt,
      compositions: const [Composition(componentName: 'Base', percentage: 100)],
      createdByDeviceId: manager.id,
      createdByDisplayName: manager.displayName,
      updatedByDeviceId: manager.id,
      updatedByDisplayName: manager.displayName,
      createdAt: now,
      updatedAt: now,
      version: 1,
      hasPendingLocalEdit: false,
    );

    final remoteV2 = localV1.copyWith(
      name: 'Mango Yogurt Deluxe',
      updatedByDeviceId: admin.id,
      updatedByDisplayName: admin.displayName,
      updatedAt: now.add(const Duration(minutes: 2)),
      version: 2,
    );

    final result = engine.merge(
      localDevice: manager,
      localDevices: [manager, admin],
      localProducts: [localV1],
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: admin.id,
        generatedAt: now.add(const Duration(minutes: 2)),
        devices: [admin, manager],
        products: [remoteV2],
      ),
    );

    expect(result.productsToSave.length, 1);
    expect(result.productsToSave.first.version, 2);
    expect(result.newConflicts, isEmpty);
  });

  test('Conflict IDs are deterministic and deep equivalence detects value changes', () {
    final now = DateTime.utc(2026, 5, 1, 10, 0);
    final engine = SyncMergeEngine(now: () => now);
    final admin = Device(
      id: 'admin-1',
      displayName: 'Admin',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final manager = Device(
      id: 'mgr-1',
      displayName: 'Manager',
      role: DeviceRole.manager,
      pairedAt: now,
      lastSeenAt: now,
    );

    final localProd = Product(
      id: 'prod-det-1',
      name: 'Berry Yogurt',
      productType: ProductType.greekYogurt,
      compositions: const [Composition(componentName: 'Milk', percentage: 100)],
      createdByDeviceId: admin.id,
      createdByDisplayName: admin.displayName,
      updatedByDeviceId: admin.id,
      updatedByDisplayName: admin.displayName,
      createdAt: now,
      updatedAt: now,
      version: 2,
      hasPendingLocalEdit: true,
    );

    final remoteChangedComp = localProd.copyWith(
      compositions: const [Composition(componentName: 'Cream', percentage: 100)],
      updatedByDeviceId: manager.id,
      updatedByDisplayName: manager.displayName,
    );

    final res1 = engine.merge(
      localDevice: admin,
      localDevices: [admin, manager],
      localProducts: [localProd],
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: manager.id,
        generatedAt: now,
        devices: [admin, manager],
        products: [remoteChangedComp],
      ),
    );
    final res2 = engine.merge(
      localDevice: admin,
      localDevices: [admin, manager],
      localProducts: [localProd],
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: manager.id,
        generatedAt: now,
        devices: [admin, manager],
        products: [remoteChangedComp],
      ),
    );

    expect(res1.newConflicts.length, 1);
    expect(res2.newConflicts.length, 1);
    expect(res1.newConflicts.first.id, res2.newConflicts.first.id);
  });

  test('Transitive ProductType LWW gossip works across non-admin peers', () {
    final now = DateTime.utc(2026, 5, 1, 10, 0);
    final engine = SyncMergeEngine(now: () => now);
    final admin = Device(
      id: 'admin-1',
      displayName: 'Admin',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final manager = Device(
      id: 'mgr-1',
      displayName: 'Manager',
      role: DeviceRole.manager,
      pairedAt: now,
      lastSeenAt: now,
    );
    final prodDev = Device(
      id: 'prod-1',
      displayName: 'Production',
      role: DeviceRole.production,
      pairedAt: now,
      lastSeenAt: now,
    );

    final customType = ProductType(
      code: 'KEFIR',
      displayName: 'Kefir',
      baseWeightGrams: 250,
      packagingOptions: const [PackagingOption(unitName: 'Bottle', multiplier: 1)],
      version: 2,
      updatedAt: now,
      updatedByDeviceId: admin.id,
    );

    final res = engine.merge(
      localDevice: prodDev,
      localDevices: [prodDev, manager, admin],
      localProducts: const [],
      localProductTypes: ProductType.defaults,
      incoming: SyncSnapshot(
        workspaceId: 'ws-1',
        senderDeviceId: manager.id,
        generatedAt: now,
        devices: [manager, admin, prodDev],
        products: const [],
        productTypes: [customType],
      ),
    );

    expect(res.replaceProductTypes, isTrue);
    expect(res.productTypesToSave.map((t) => t.code), ['KEFIR']);
  });

  test('P2pSyncServer syncs cleanly even with 15-minute clock skew via challenge-response', () async {
    final baseTime = DateTime.utc(2026, 5, 1, 10, 0);
    final workspace = Workspace(
      id: 'ws-skew',
      name: 'Skew Factory',
      workspaceKey: 'skew-secret-key',
      createdAt: baseTime,
    );
    final admin = Device(
      id: 'admin-skew',
      displayName: 'Admin',
      role: DeviceRole.admin,
      pairedAt: baseTime,
      lastSeenAt: baseTime,
    );
    final peer = Device(
      id: 'peer-skew',
      displayName: 'Peer',
      role: DeviceRole.production,
      pairedAt: baseTime,
      lastSeenAt: baseTime,
    );

    final adminDevRepo = _InMemoryDeviceRepository();
    final peerDevRepo = _InMemoryDeviceRepository();
    await adminDevRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: admin,
      additionalDevices: [peer],
    );
    await peerDevRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: peer,
    );

    final adminServer = P2pSyncServer(
      deviceRepository: adminDevRepo,
      productRepository: _InMemoryProductRepository(),
      getLocalDeviceId: () => admin.id,
      cryptoService: SyncCryptoService(now: () => baseTime),
    );
    final peerServer = P2pSyncServer(
      deviceRepository: peerDevRepo,
      productRepository: _InMemoryProductRepository(),
      getLocalDeviceId: () => peer.id,
      cryptoService: SyncCryptoService(
        now: () => baseTime.add(const Duration(minutes: 15)),
      ),
    );

    final adminPort = await adminServer.start(bindAddress: InternetAddress.loopbackIPv4);
    await peerServer.start(bindAddress: InternetAddress.loopbackIPv4);
    try {
      final result = await peerServer.syncWithPeer(
        DiscoveredPeer(
          deviceId: admin.id,
          displayName: admin.displayName,
          workspaceId: workspace.id,
          host: InternetAddress.loopbackIPv4.address,
          port: adminPort,
          discoveredAt: baseTime,
        ),
      );
      expect(result.updatedDevices.map((d) => d.id), contains(admin.id));
    } finally {
      await adminServer.stop();
      await peerServer.stop();
    }
  });
}
