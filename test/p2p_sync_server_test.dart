import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:synprod_lite/core/services/p2p_sync_server.dart';
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
  Future<List<String>> getDistinctComponents() async => const [];
  @override
  Future<List<String>> getDistinctIngredients() async => const [];
  @override
  Future<void> seedInitialDataIfEmpty() async {}
  @override
  Stream<List<ProductType>> watchProductTypes() => Stream.value(_productTypes);
  @override
  Future<List<ProductType>> getProductTypes() async => _productTypes;
  @override
  Future<void> saveProductType(ProductType productType) async {
    _productTypes = [
      for (final t in _productTypes)
        if (t.code == productType.code) productType else t,
      if (!_productTypes.any((t) => t.code == productType.code)) productType,
    ];
  }

  @override
  Future<void> applySyncedProductTypesAtomically(
    List<ProductType> productTypes,
  ) async {
    if (productTypes.isNotEmpty) {
      _productTypes = List<ProductType>.from(productTypes);
    }
  }

  @override
  Future<void> deleteProductType(String code) async {
    _productTypes.removeWhere((t) => t.code == code);
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
}
