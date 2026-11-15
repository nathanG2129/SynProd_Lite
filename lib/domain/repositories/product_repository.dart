import '../models/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchActiveProducts();
  Future<List<Product>> getActiveProducts();
  Future<Product?> getProductById(String id);
  Future<void> saveProduct(Product product);
  Future<void> softDeleteProduct(String id);
  Future<List<String>> getDistinctComponents();
  Future<List<String>> getDistinctIngredients();
  Future<void> seedInitialDataIfEmpty();
}
