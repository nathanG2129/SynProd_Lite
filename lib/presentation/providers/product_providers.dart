import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/error/failures.dart';
import '../../data/local/database/app_database.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/models/device.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_type.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/services/product_validator.dart';
import 'device_providers.dart';

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
  final products = await ref.watch(activeProductsStreamProvider.future);
  final set = <String>{};
  for (final product in products) {
    for (final comp in product.compositions) {
      set.add(comp.componentName);
    }
  }
  final list = set.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return list;
});

final distinctIngredientsProvider = FutureProvider<List<String>>((ref) async {
  final products = await ref.watch(activeProductsStreamProvider.future);
  final set = <String>{};
  for (final product in products) {
    for (final ing in product.additionalIngredients) {
      set.add(ing.ingredientName);
    }
  }
  final list = set.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return list;
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedTypeFilterProvider = StateProvider<ProductType?>((ref) => null);
final selectedComponentFilterProvider = StateProvider<String?>((ref) => null);
final selectedIngredientFilterProvider = StateProvider<String?>((ref) => null);
final myProductsOnlyProvider = StateProvider<bool>((ref) => false);

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(activeProductsStreamProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final typeFilter = ref.watch(selectedTypeFilterProvider);
  final compFilter = ref.watch(selectedComponentFilterProvider);
  final ingFilter = ref.watch(selectedIngredientFilterProvider);
  final myProductsOnly = ref.watch(myProductsOnlyProvider);
  final currentDevice = ref.watch(currentDeviceProvider);

  return productsAsync.whenData((products) {
    final filtered = products.where((product) {
      if (myProductsOnly && product.createdByDeviceId != currentDevice.id) {
        return false;
      }

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
    }).toList();

    if (myProductsOnly) {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      filtered.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return filtered;
  });
});

class ProductMutationService {
  final ProductRepository _repository;
  final Device _currentDevice;

  ProductMutationService(this._repository, this._currentDevice);

  Future<void> saveProduct(Product product, {required bool isEditing}) async {
    if (isEditing) {
      if (!canDeviceEditProduct(_currentDevice, product)) {
        throw const ValidationFailure(
          'You do not have permission to edit this product.',
        );
      }
    } else {
      if (!_currentDevice.role.canCreateProduct) {
        throw const ValidationFailure(
          'You do not have permission to create products.',
        );
      }
    }

    ProductValidator.validateProduct(product);

    final existingProducts = await _repository.getActiveProducts();
    ProductValidator.validateUniqueName(
      candidateName: product.name,
      currentProductId: product.id,
      existingProducts: existingProducts,
    );

    final sanitizedProduct = product.copyWith(
      name: product.name.trim(),
      description: product.description?.trim().isEmpty == true
          ? null
          : product.description?.trim(),
      updatedByDeviceId: _currentDevice.id,
      updatedByDisplayName: _currentDevice.displayName,
      updatedAt: DateTime.now(),
      version: isEditing ? product.version + 1 : product.version,
    );

    await _repository.saveProduct(sanitizedProduct);
  }

  Future<void> softDeleteProduct(Product product) async {
    if (!canDeviceDeleteProduct(_currentDevice)) {
      throw const ValidationFailure(
        'Only administrators can delete products.',
      );
    }
    await _repository.softDeleteProduct(
      product.id,
      deletedByDeviceId: _currentDevice.id,
      deletedByDisplayName: _currentDevice.displayName,
    );
  }
}

final productMutationServiceProvider = Provider<ProductMutationService>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  final device = ref.watch(currentDeviceProvider);
  return ProductMutationService(repo, device);
});
