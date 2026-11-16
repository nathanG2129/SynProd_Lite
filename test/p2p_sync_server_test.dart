import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:synprod_lite/core/services/p2p_sync_server.dart';
import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/product_type.dart';
import 'package:synprod_lite/domain/models/sync_models.dart';
import 'package:synprod_lite/domain/models/workspace.dart';
import 'package:synprod_lite/domain/repositories/device_repository.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';

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
  Stream<List<ProductType>> watchProductTypes() =>
      Stream.value(ProductType.defaults);
  @override
  Future<List<ProductType>> getProductTypes() async => ProductType.defaults;
  @override
  Future<void> saveProductType(ProductType productType) async {}
  @override
  Future<void> deleteProductType(String code) async {}
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
}
