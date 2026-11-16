import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:synprod_lite/core/theme/app_theme.dart';
import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/sync_models.dart';
import 'package:synprod_lite/domain/models/workspace.dart';
import 'package:synprod_lite/domain/repositories/device_repository.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';
import 'package:synprod_lite/main.dart';
import 'package:synprod_lite/presentation/providers/auth_providers.dart';
import 'package:synprod_lite/presentation/providers/device_providers.dart';
import 'package:synprod_lite/presentation/providers/product_providers.dart';
import 'package:synprod_lite/presentation/providers/theme_providers.dart';
import 'package:synprod_lite/presentation/screens/device_management/device_management_screen.dart';
import 'package:synprod_lite/presentation/screens/profile/device_profile_screen.dart';
import 'package:synprod_lite/presentation/screens/recipe_library/recipe_library_screen.dart';
import 'package:synprod_lite/presentation/widgets/synprod_ui.dart';

class _SmokeDeviceRepository implements DeviceRepository {
  bool createdWorkspace = false;

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
  }) async {
    createdWorkspace = true;
    final now = DateTime.now();
    return (
      workspace: Workspace(
        id: 'ws-1',
        name: workspaceName,
        workspaceKey: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        createdAt: now,
      ),
      adminDevice: Device(
        id: 'dev-1',
        displayName: adminDisplayName,
        role: DeviceRole.admin,
        pairedAt: now,
        lastSeenAt: now,
      ),
    );
  }
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

  testWidgets('Create Workspace uses 2-step lock-screen PIN setup',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final deviceRepo = _SmokeDeviceRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          deviceRepositoryProvider.overrideWithValue(deviceRepo),
          productRepositoryProvider
              .overrideWithValue(_SmokeProductRepository()),
        ],
        child: const SynProdLiteApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedSize), findsOneWidget);
    expect(find.text('Restore Workspace'), findsOneWidget);
    await tester.tap(find.text('Setup New Workspace'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Workspace name is required.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Workspace Name *'),
      'Main Plant',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'This Device Name *'),
      'Admin Tablet',
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Create Device PIN'), findsOneWidget);

    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.text(digit));
    }
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Confirm Device PIN'), findsOneWidget);

    // Mismatching PIN shows error and stays on confirm step
    for (final digit in ['9', '9', '9', '9', '9', '9']) {
      await tester.tap(find.text(digit));
    }
    await tester.pump();
    await tester.tap(find.text('Create Workspace'));
    await tester.pump();
    expect(find.text('PINs do not match. Try again.'), findsOneWidget);
    expect(deviceRepo.createdWorkspace, isFalse);

    // Back button returns to Step 1, then to Create Workspace form preserving inputs
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Create Device PIN'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Main Plant'), findsOneWidget);
    expect(find.text('Admin Tablet'), findsOneWidget);

    // Complete matching 2-step PIN flow
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.text(digit));
    }
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    for (final digit in ['1', '2', '3', '4', '5', '6']) {
      await tester.tap(find.text(digit));
    }
    await tester.pump();
    await tester.tap(find.text('Create Workspace'));
    await tester.pumpAndSettle();

    expect(deviceRepo.createdWorkspace, isTrue);
  });

  testWidgets('ThemeModeNotifier persists and DeviceProfileScreen switches to dark mode',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          deviceRepositoryProvider.overrideWithValue(_SmokeDeviceRepository()),
          productRepositoryProvider.overrideWithValue(_SmokeProductRepository()),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            final themeMode = ref.watch(themeModeProvider);
            return MaterialApp(
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              home: const DeviceProfileScreen(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(prefs.getString('synprod_theme_mode'), isNull);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(prefs.getString('synprod_theme_mode'), 'dark');
    final scaffoldContext = tester.element(find.byType(Scaffold));
    expect(Theme.of(scaffoldContext).brightness, Brightness.dark);

    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();

    expect(prefs.getString('synprod_theme_mode'), 'light');
    expect(Theme.of(scaffoldContext).brightness, Brightness.light);
  });

  testWidgets('Topbar profile ripple and Add Device button have compact centered layout',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final adminDevice = Device(
      id: 'admin-1',
      displayName: 'Admin Tablet',
      role: DeviceRole.admin,
      pairedAt: DateTime(2026, 11, 16),
      lastSeenAt: DateTime(2026, 11, 16),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentDeviceProvider.overrideWithValue(adminDevice),
          deviceRepositoryProvider.overrideWithValue(_SmokeDeviceRepository()),
          productRepositoryProvider.overrideWithValue(_SmokeProductRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DeviceManagementScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final addDeviceButton = find.ancestor(
      of: find.text('Add Device'),
      matching: find.byType(SynProdGradientButton),
    );
    expect(addDeviceButton, findsOneWidget);
    final addButtonSize = tester.getSize(addDeviceButton);
    expect(addButtonSize.height, lessThan(50));

    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          currentDeviceProvider.overrideWithValue(adminDevice),
          deviceRepositoryProvider.overrideWithValue(_SmokeDeviceRepository()),
          productRepositoryProvider.overrideWithValue(_SmokeProductRepository()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RecipeLibraryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final profileInkWell = find.ancestor(
      of: find.byType(SynProdAvatar),
      matching: find.byType(InkWell),
    );
    expect(profileInkWell, findsOneWidget);
    final inkWellWidget = tester.widget<InkWell>(profileInkWell);
    expect(inkWellWidget.customBorder, const StadiumBorder());
    expect(tester.getSize(profileInkWell).height, lessThan(56));
  });

  testWidgets('AppTheme uses horizontal page transitions and showSynProdDialog slides',
      (WidgetTester tester) async {
    expect(
      AppTheme.lightTheme.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<CupertinoPageTransitionsBuilder>(),
    );
    expect(
      AppTheme.darkTheme.pageTransitionsTheme.builders[TargetPlatform.android],
      isA<CupertinoPageTransitionsBuilder>(),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showSynProdDialog<void>(
                    context: context,
                    builder: (_) => const SynProdDialog(
                      title: 'Animated Modal',
                      content: Text('Slide transition check'),
                    ),
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Modal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(SynProdDialog), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(SynProdDialog),
        matching: find.byType(SlideTransition),
      ),
      findsWidgets,
    );
  });
}
