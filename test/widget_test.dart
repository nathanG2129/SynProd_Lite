import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/workspace.dart';
import 'package:synprod_lite/domain/repositories/device_repository.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';
import 'package:synprod_lite/main.dart';
import 'package:synprod_lite/presentation/providers/auth_providers.dart';
import 'package:synprod_lite/presentation/providers/product_providers.dart';

class _SmokeDeviceRepository implements DeviceRepository {
  @override
  Future<Workspace?> getActiveWorkspace() async => null;
  @override
  Stream<Workspace?> watchActiveWorkspace() => Stream.value(null);
  @override
  Future<Device?> getDeviceById(String id) async => null;
  @override
  Stream<Device?> watchDeviceById(String id) => Stream.value(null);
  @override
  Stream<List<Device>> watchAllDevices() => Stream.value(const []);
  @override
  Future<List<Device>> getAllDevices() async => const [];
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
  }) async {}
  @override
  Future<void> upsertDevice(Device device) async {}
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
  }) =>
      throw UnimplementedError();
  @override
  Future<PairingTokenRecord?> getPairingToken(String tokenId) async => null;
  @override
  Future<void> markPairingTokenUsed(String tokenId) async {}
}

class _SmokeProductRepository implements ProductRepository {
  @override
  Stream<List<Product>> watchActiveProducts() => Stream.value(const []);
  @override
  Future<List<Product>> getActiveProducts() async => const [];
  @override
  Future<Product?> getProductById(String id) async => null;
  @override
  Future<void> saveProduct(Product product) async {}
  @override
  Future<void> softDeleteProduct(String id) async {}
  @override
  Future<List<String>> getDistinctComponents() async => const [];
  @override
  Future<List<String>> getDistinctIngredients() async => const [];
  @override
  Future<void> seedInitialDataIfEmpty() async {}
}

void main() {
  testWidgets('SynProdLiteApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          deviceRepositoryProvider.overrideWithValue(_SmokeDeviceRepository()),
          productRepositoryProvider
              .overrideWithValue(_SmokeProductRepository()),
        ],
        child: const SynProdLiteApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('SynProd Lite'), findsOneWidget);
  });
}
