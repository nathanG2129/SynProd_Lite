import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:synprod_lite/core/theme/app_theme.dart';
import 'package:synprod_lite/domain/models/composition.dart';
import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/product_type.dart';
import 'package:synprod_lite/domain/models/sync_models.dart';
import 'package:synprod_lite/domain/models/workspace.dart';
import 'package:synprod_lite/domain/repositories/device_repository.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';
import 'package:synprod_lite/presentation/providers/auth_providers.dart';
import 'package:synprod_lite/presentation/providers/device_providers.dart';
import 'package:synprod_lite/presentation/providers/product_providers.dart';
import 'package:synprod_lite/presentation/screens/archive/archive_screen.dart';
import 'package:synprod_lite/presentation/screens/device_management/device_management_screen.dart';
import 'package:synprod_lite/presentation/screens/recipe_library/recipe_library_screen.dart';
import 'package:synprod_lite/presentation/widgets/synprod_ui.dart';

class _FakeDeviceRepo implements DeviceRepository {
  final List<Device> devices = [];
  final _devicesCtrl = StreamController<List<Device>>.broadcast();
  Workspace? workspace;

  void _emit() => _devicesCtrl.add(List<Device>.from(devices));

  @override
  Stream<List<Device>> watchAllDevices() async* {
    yield List<Device>.from(devices);
    yield* _devicesCtrl.stream;
  }

  @override
  Future<List<Device>> getAllDevices() async => List<Device>.from(devices);

  @override
  Future<void> setDeviceRevoked(String deviceId, bool isRevoked) async {
    for (var i = 0; i < devices.length; i++) {
      if (devices[i].id == deviceId) {
        devices[i] = devices[i].copyWith(isRevoked: isRevoked);
      }
    }
    _emit();
  }

  @override
  Future<Workspace?> getActiveWorkspace() async => workspace;
  @override
  Stream<Workspace?> watchActiveWorkspace() => Stream.value(workspace);
  @override
  Future<Device?> getDeviceById(String id) async =>
      devices.where((d) => d.id == id).firstOrNull;
  @override
  Stream<Device?> watchDeviceById(String id) =>
      watchAllDevices().map((list) => list.where((d) => d.id == id).firstOrNull);
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
    this.workspace = workspace;
    devices
      ..clear()
      ..add(localDevice)
      ..addAll(additionalDevices);
    _emit();
  }

  @override
  Future<void> upsertDevice(Device device) async {}
  @override
  Future<void> updateDeviceRole(String deviceId, DeviceRole role) async {}
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
  Future<void> applySyncedDevices(List<Device> devices) async {}
}

class _FakeProductRepo implements ProductRepository {
  final List<Product> products = [];
  final List<ProductType> types = List<ProductType>.from(ProductType.defaults);
  final _productsCtrl = StreamController<List<Product>>.broadcast();
  final _typesCtrl = StreamController<List<ProductType>>.broadcast();

  void _emitProducts() => _productsCtrl.add(List<Product>.from(products));
  void _emitTypes() => _typesCtrl.add(List<ProductType>.from(types));

  @override
  Stream<List<Product>> watchActiveProducts() async* {
    yield products.where((p) => !p.isDeleted).toList();
    yield* _productsCtrl.stream
        .map((list) => list.where((p) => !p.isDeleted).toList());
  }

  @override
  Stream<List<Product>> watchArchivedProducts() async* {
    yield products.where((p) => p.isDeleted).toList();
    yield* _productsCtrl.stream
        .map((list) => list.where((p) => p.isDeleted).toList());
  }

  @override
  Future<List<Product>> getActiveProducts() async =>
      products.where((p) => !p.isDeleted).toList();
  @override
  Future<List<Product>> getAllProductsIncludingDeleted() async =>
      List<Product>.from(products);
  @override
  Future<Product?> getProductById(String id) async =>
      products.where((p) => p.id == id).firstOrNull;
  @override
  Future<void> saveProduct(Product product) async {
    products.removeWhere((p) => p.id == product.id);
    products.add(product);
    _emitProducts();
  }

  @override
  Future<void> applySyncedProductsAtomically(List<Product> products) async {}
  @override
  Future<void> softDeleteProduct(
    String id, {
    String? deletedByDeviceId,
    String? deletedByDisplayName,
  }) async {
    for (var i = 0; i < products.length; i++) {
      if (products[i].id == id) {
        products[i] = products[i].copyWith(isDeleted: true);
      }
    }
    _emitProducts();
  }

  @override
  Future<void> restoreProduct(
    String id, {
    String? restoredByDeviceId,
    String? restoredByDisplayName,
  }) async {
    for (var i = 0; i < products.length; i++) {
      if (products[i].id == id) {
        products[i] = products[i].copyWith(isDeleted: false);
      }
    }
    _emitProducts();
  }

  @override
  Future<List<String>> getDistinctComponents() async => const [];
  @override
  Future<List<String>> getDistinctIngredients() async => const [];
  @override
  Future<void> seedInitialDataIfEmpty() async {}
  @override
  Stream<List<ProductType>> watchProductTypes() async* {
    yield types.where((t) => !t.isArchived).toList();
    yield* _typesCtrl.stream
        .map((list) => list.where((t) => !t.isArchived).toList());
  }

  @override
  Stream<List<ProductType>> watchArchivedProductTypes() async* {
    yield types.where((t) => t.isArchived).toList();
    yield* _typesCtrl.stream
        .map((list) => list.where((t) => t.isArchived).toList());
  }

  @override
  Future<List<ProductType>> getProductTypes() async =>
      types.where((t) => !t.isArchived).toList();
  @override
  Future<List<ProductType>> getAllProductTypesIncludingArchived() async =>
      List<ProductType>.from(types);
  @override
  Future<void> saveProductType(ProductType productType) async {
    types.removeWhere((t) => t.code == productType.code);
    types.add(productType);
    _emitTypes();
  }

  @override
  Future<void> applySyncedProductTypesAtomically(
    List<ProductType> productTypes,
  ) async {}

  @override
  Future<void> setProductTypeArchived(String code, bool isArchived) async {
    for (var i = 0; i < types.length; i++) {
      if (types[i].code == code) {
        types[i] = types[i].copyWith(isArchived: isArchived);
      }
    }
    _emitTypes();
  }

  @override
  Future<void> deleteProductType(String code) async =>
      setProductTypeArchived(code, true);
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
  testWidgets('SynProdSecondaryButton has generous vertical padding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SynProdSecondaryButton(
            onPressed: () {},
            child: const Text('Log Out'),
          ),
        ),
      ),
    );

    final button = tester.widget<SynProdSecondaryButton>(
      find.byType(SynProdSecondaryButton),
    );
    expect(
      button.padding,
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  });

  testWidgets(
      'DeviceManagementScreen can archive non-self Admin device and ArchiveScreen restores records',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final deviceRepo = _FakeDeviceRepo();
    final productRepo = _FakeProductRepo();

    final now = DateTime.now();
    final selfAdmin = Device(
      id: 'admin-self',
      displayName: 'Primary Admin',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final otherAdmin = Device(
      id: 'admin-other',
      displayName: 'Backup Admin',
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );
    final workspace = Workspace(
      id: 'ws-1',
      name: 'Test Workspace',
      workspaceKey: '0123456789abcdef0123456789abcdef',
      createdAt: now,
    );
    await deviceRepo.saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: selfAdmin,
      additionalDevices: [otherAdmin],
    );

    final archivedRecipe = Product(
      id: 'prod-1',
      name: 'Archived Yogurt',
      productType: ProductType.greekYogurt,
      createdByDeviceId: selfAdmin.id,
      createdByDisplayName: selfAdmin.displayName,
      createdAt: now,
      updatedAt: now,
      isDeleted: true,
      compositions: const [
        Composition(componentName: 'Milk', percentage: 100, sortOrder: 0),
      ],
    );
    await productRepo.saveProduct(archivedRecipe);
    await productRepo.setProductTypeArchived(ProductType.cheese.code, true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          deviceRepositoryProvider.overrideWithValue(deviceRepo),
          productRepositoryProvider.overrideWithValue(productRepo),
          currentDeviceProvider.overrideWithValue(selfAdmin),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme.copyWith(
            splashFactory: InkRipple.splashFactory,
          ),
          home: const DeviceManagementScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Backup Admin'), findsOneWidget);
    expect(find.text('Archive'), findsOneWidget);

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Archive Device'), findsOneWidget);
    await tester.tap(find.widgetWithText(SynProdGradientButton, 'Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Backup Admin'), findsNothing);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          deviceRepositoryProvider.overrideWithValue(deviceRepo),
          productRepositoryProvider.overrideWithValue(productRepo),
          currentDeviceProvider.overrideWithValue(selfAdmin),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme.copyWith(
            splashFactory: InkRipple.splashFactory,
          ),
          home: const ArchiveScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recipes (1)'), findsOneWidget);
    expect(find.text('Types (1)'), findsOneWidget);
    expect(find.text('Devices (1)'), findsOneWidget);
    expect(find.text('Archived Yogurt'), findsOneWidget);

    await tester.tap(find.text('Restore').first);
    await tester.pumpAndSettle();
    expect(find.text('Archived Yogurt'), findsNothing);
    expect(find.text('Recipes (0)'), findsOneWidget);

    await tester.tap(find.text('Types (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Cheese'), findsOneWidget);

    await tester.tap(find.text('Devices (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Backup Admin'), findsOneWidget);
  });

  testWidgets(
      'RecipeLibraryScreen shows scroll chevrons when type chips overflow',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final productRepo = _FakeProductRepo();
    for (var i = 0; i < 8; i++) {
      await productRepo.saveProductType(
        ProductType(
          code: 'EXTRA_$i',
          displayName: 'Extra Type $i',
          baseWeightGrams: 250,
          packagingOptions: const [
            PackagingOption(unitName: 'Tubs', multiplier: 1),
          ],
          sortOrder: 10 + i,
        ),
      );
    }

    final admin = Device(
      id: 'admin-1',
      displayName: 'Admin',
      role: DeviceRole.admin,
      pairedAt: DateTime.now(),
      lastSeenAt: DateTime.now(),
    );

    tester.view.physicalSize = const Size(420, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          productRepositoryProvider.overrideWithValue(productRepo),
          currentDeviceProvider.overrideWithValue(admin),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme.copyWith(
            splashFactory: InkRipple.splashFactory,
          ),
          home: const RecipeLibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Scroll types right'), findsOneWidget);
    await tester.tap(find.byTooltip('Scroll types right'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Scroll types left'), findsOneWidget);
  });
}
