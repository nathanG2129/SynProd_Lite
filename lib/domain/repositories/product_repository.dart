import '../models/product.dart';
import '../models/product_type.dart';
import '../models/sync_models.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchActiveProducts();
  Stream<List<Product>> watchArchivedProducts();
  Future<List<Product>> getActiveProducts();
  Future<List<Product>> getAllProductsIncludingDeleted();
  Future<Product?> getProductById(String id);
  Future<void> saveProduct(Product product);
  Future<void> applySyncedProductsAtomically(List<Product> products);
  Future<void> softDeleteProduct(
    String id, {
    String? deletedByDeviceId,
    String? deletedByDisplayName,
  });
  Future<void> restoreProduct(
    String id, {
    String? restoredByDeviceId,
    String? restoredByDisplayName,
  });
  Future<List<String>> getDistinctComponents();
  Future<List<String>> getDistinctIngredients();
  Future<void> seedInitialDataIfEmpty();

  Stream<List<ProductType>> watchProductTypes();
  Stream<List<ProductType>> watchArchivedProductTypes();
  Future<List<ProductType>> getProductTypes();
  Future<List<ProductType>> getAllProductTypesIncludingArchived();
  Future<void> saveProductType(ProductType productType);
  Future<void> applySyncedProductTypesAtomically(List<ProductType> productTypes);
  Future<void> setProductTypeArchived(String code, bool isArchived);
  Future<void> deleteProductType(String code);

  Stream<List<SyncConflictRecord>> watchConflictHistory();
  Future<List<SyncConflictRecord>> getConflictHistory();
  Future<void> saveConflictRecords(List<SyncConflictRecord> records);
  Future<void> markConflictResolved(String conflictId);
  Future<void> clearPendingLocalEdits(List<String> productIds);
  Future<T> runInTransaction<T>(Future<T> Function() action);
}
