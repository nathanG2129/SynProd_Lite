import '../models/product.dart';
import '../models/product_type.dart';
import '../models/sync_models.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchActiveProducts();
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
  Future<List<String>> getDistinctComponents();
  Future<List<String>> getDistinctIngredients();
  Future<void> seedInitialDataIfEmpty();

  Stream<List<ProductType>> watchProductTypes();
  Future<List<ProductType>> getProductTypes();
  Future<void> saveProductType(ProductType productType);
  Future<void> deleteProductType(String code);

  Stream<List<SyncConflictRecord>> watchConflictHistory();
  Future<List<SyncConflictRecord>> getConflictHistory();
  Future<void> saveConflictRecords(List<SyncConflictRecord> records);
  Future<void> markConflictResolved(String conflictId);
}
