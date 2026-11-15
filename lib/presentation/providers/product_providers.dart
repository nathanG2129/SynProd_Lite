import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database/app_database.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_type.dart';
import '../../domain/repositories/product_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ProductRepositoryImpl(db);
});

final databaseInitProvider = FutureProvider<void>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  await repo.seedInitialDataIfEmpty();
});

final activeProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return repo.watchActiveProducts();
});

final distinctComponentsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getDistinctComponents();
});

final distinctIngredientsProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getDistinctIngredients();
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTypeFilterProvider = StateProvider<ProductType?>((ref) => null);
final selectedComponentFilterProvider = StateProvider<String?>((ref) => null);
final selectedIngredientFilterProvider = StateProvider<String?>((ref) => null);

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(activeProductsStreamProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(selectedTypeFilterProvider);
  final compFilter = ref.watch(selectedComponentFilterProvider);
  final ingFilter = ref.watch(selectedIngredientFilterProvider);

  return productsAsync.whenData((products) {
    return products.where((product) {
      if (typeFilter != null && product.productType != typeFilter) {
        return false;
      }

      if (compFilter != null &&
          !product.compositions.any(
              (c) => c.componentName.toLowerCase() == compFilter.toLowerCase())) {
        return false;
      }

      if (ingFilter != null &&
          !product.additionalIngredients.any(
              (i) => i.ingredientName.toLowerCase() == ingFilter.toLowerCase())) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchesName = product.name.toLowerCase().contains(query);
        final matchesDesc =
            product.description?.toLowerCase().contains(query) ?? false;
        final matchesComp = product.compositions.any(
            (c) => c.componentName.toLowerCase().contains(query));
        final matchesIng = product.additionalIngredients.any(
            (i) => i.ingredientName.toLowerCase().contains(query));

        if (!matchesName && !matchesDesc && !matchesComp && !matchesIng) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  });
});
