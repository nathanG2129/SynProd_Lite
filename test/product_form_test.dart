import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:synprod_lite/domain/models/composition.dart';
import 'package:synprod_lite/domain/models/device.dart';
import 'package:synprod_lite/domain/models/product.dart';
import 'package:synprod_lite/domain/models/product_type.dart';
import 'package:synprod_lite/domain/repositories/product_repository.dart';
import 'package:synprod_lite/main.dart';
import 'package:synprod_lite/presentation/providers/device_providers.dart';
import 'package:synprod_lite/presentation/providers/product_providers.dart';
import 'package:synprod_lite/presentation/screens/product_form/product_form_screen.dart';
import 'package:synprod_lite/presentation/screens/recipe_detail/recipe_detail_screen.dart';

class _InMemoryProductRepository implements ProductRepository {
  final Map<String, Product> _store = {};
  final StreamController<List<Product>> _controller =
      StreamController<List<Product>>.broadcast();

  void _emit() {
    _controller.add(_activeList());
  }

  List<Product> _activeList() {
    return _store.values.where((p) => !p.isDeleted).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Stream<List<Product>> watchActiveProducts() async* {
    yield _activeList();
    yield* _controller.stream;
  }

  @override
  Future<List<Product>> getActiveProducts() async => _activeList();

  @override
  Future<Product?> getProductById(String id) async {
    final p = _store[id];
    if (p == null || p.isDeleted) return null;
    return p;
  }

  @override
  Future<void> saveProduct(Product product) async {
    _store[product.id] = product;
    _emit();
  }

  @override
  Future<void> softDeleteProduct(String id) async {
    final existing = _store[id];
    if (existing != null) {
      _store[id] = existing.copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      _emit();
    }
  }

  @override
  Future<List<String>> getDistinctComponents() async {
    final set = <String>{};
    for (final p in _activeList()) {
      for (final c in p.compositions) {
        set.add(c.componentName);
      }
    }
    return set.toList()..sort();
  }

  @override
  Future<List<String>> getDistinctIngredients() async {
    final set = <String>{};
    for (final p in _activeList()) {
      for (final i in p.additionalIngredients) {
        set.add(i.ingredientName);
      }
    }
    return set.toList()..sort();
  }

  @override
  Future<void> seedInitialDataIfEmpty() async {
    if (_store.isNotEmpty) return;
    final now = DateTime.now();
    await saveProduct(
      Product(
        id: 'seed_yogurt',
        name: 'Classic Greek Yogurt',
        description: 'Traditional strained whole milk Greek yogurt.',
        productType: ProductType.greekYogurt,
        compositions: const [
          Composition(
            componentName: 'Strained Whole Milk Base',
            percentage: 90.0,
            sortOrder: 0,
          ),
          Composition(
            componentName: 'Culture',
            percentage: 10.0,
            sortOrder: 1,
          ),
        ],
        createdByDeviceId: 'device_seed_001',
        createdByDisplayName: 'System Administrator',
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  Device makeDevice(DeviceRole role, {String id = 'device_test_1'}) {
    final now = DateTime.now();
    return Device(
      id: id,
      displayName: 'Test ${role.displayName}',
      role: role,
      pairedAt: now,
      lastSeenAt: now,
    );
  }

  testWidgets('Create product with Fill to 100% and save to repository',
      (WidgetTester tester) async {
    final repo = _InMemoryProductRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
        ],
        child: const MaterialApp(home: ProductFormScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Product Name *'),
      'Synbiotic Honey Yogurt',
    );

    // Add two composition rows
    await tester.tap(find.widgetWithText(TextButton, 'Add Row').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Add Row').first);
    await tester.pumpAndSettle();

    final compNameFields =
        find.widgetWithText(TextFormField, 'Component Name *');
    await tester.enterText(compNameFields.at(0), 'Milk Base');
    await tester.enterText(compNameFields.at(1), 'Culture');

    // Set first row percentage to 60.0
    final pctFields = find.widgetWithText(TextFormField, '0.0');
    await tester.enterText(pctFields.at(0), '60');
    await tester.pumpAndSettle();

    // Use Fill to 100% on second row
    final fillBtn = find.text('Fill to 100%').last;
    await tester.ensureVisible(fillBtn);
    await tester.pumpAndSettle();
    await tester.tap(fillBtn);
    await tester.pumpAndSettle();

    expect(
      find.text('Total: 100.0% (Balanced at 100%)'),
      findsOneWidget,
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = await repo.getActiveProducts();
    expect(
      saved.any((p) => p.name == 'Synbiotic Honey Yogurt'),
      isTrue,
    );

    repo.dispose();
  });

  testWidgets('Rejects duplicate product name and invalid composition sum',
      (WidgetTester tester) async {
    final repo = _InMemoryProductRepository();
    await repo.seedInitialDataIfEmpty();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
        ],
        child: const SynProdLiteApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Open New Recipe form
    await tester.tap(find.text('New Recipe'));
    await tester.pumpAndSettle();

    // Enter duplicate name (case-insensitive) of seeded product
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Product Name *'),
      'classic greek yogurt',
    );

    // Add a composition row with 50% (invalid sum)
    final addCompBtn = find.widgetWithText(TextButton, 'Add Row').first;
    await tester.ensureVisible(addCompBtn);
    await tester.tap(addCompBtn);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Component Name *'),
      'Milk',
    );
    await tester.enterText(find.widgetWithText(TextFormField, '0.0'), '50');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Total composition percentage must equal 100%'),
      findsOneWidget,
    );

    // Fix composition to 100% via Fill to 100%
    final fillBtn = find.text('Fill to 100%');
    await tester.ensureVisible(fillBtn);
    await tester.pumpAndSettle();
    await tester.tap(fillBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(
      find.text("Product with name 'classic greek yogurt' already exists"),
      findsOneWidget,
    );

    repo.dispose();
  });

  testWidgets('Admin can soft-delete product with confirmation',
      (WidgetTester tester) async {
    final repo = _InMemoryProductRepository();
    await repo.seedInitialDataIfEmpty();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
        ],
        child: const SynProdLiteApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Open Classic Greek Yogurt detail
    final yogurtFinder = find.text('Classic Greek Yogurt');
    await tester.ensureVisible(yogurtFinder);
    await tester.tap(yogurtFinder);
    await tester.pumpAndSettle();

    expect(find.byTooltip('Edit Product'), findsOneWidget);
    expect(find.byTooltip('Delete Product'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete Product'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Product'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    // Returned to library and product is gone from active list
    expect(find.text('SynProd Lite'), findsOneWidget);
    expect(find.text('Classic Greek Yogurt'), findsNothing);

    repo.dispose();
  });

  testWidgets(
      'Role permissions hide Create/Edit/Delete for PRODUCTION and enforce MANAGER ownership',
      (WidgetTester tester) async {
    final repo = _InMemoryProductRepository();
    final now = DateTime.now();
    final otherProduct = Product(
      id: 'prod_other',
      name: 'Other Manager Recipe',
      productType: ProductType.cheese,
      compositions: const [
        Composition(componentName: 'Curd', percentage: 100.0, sortOrder: 0),
      ],
      createdByDeviceId: 'other_device',
      createdByDisplayName: 'Other Manager',
      createdAt: now,
      updatedAt: now,
    );

    // 1. PRODUCTION role on Library
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
          currentDeviceProvider
              .overrideWithValue(makeDevice(DeviceRole.production)),
        ],
        child: const SynProdLiteApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('New Recipe'), findsNothing);
    expect(find.text('My Products'), findsNothing);

    // 2. MANAGER role on another device's product detail
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          productRepositoryProvider.overrideWithValue(repo),
          currentDeviceProvider
              .overrideWithValue(makeDevice(DeviceRole.manager)),
        ],
        child: MaterialApp(home: RecipeDetailScreen(product: otherProduct)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Edit Product'), findsNothing);
    expect(find.byTooltip('Delete Product'), findsNothing);

    repo.dispose();
  });
}
