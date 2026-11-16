import 'package:drift/drift.dart';

import '../../domain/models/composition.dart';
import '../../domain/models/ingredient.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_type.dart';
import '../../domain/models/sync_models.dart';
import '../../domain/repositories/product_repository.dart';
import '../local/database/app_database.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase db;

  ProductRepositoryImpl(this.db);

  @override
  Stream<List<Product>> watchActiveProducts() {
    final query = db.select(db.productsTable)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);

    return query.watch().asyncMap((rows) async {
      final catalog = await getProductTypes();
      final products = <Product>[];
      for (final row in rows) {
        final compRows = await (db.select(db.compositionsTable)
              ..where((tbl) => tbl.productId.equals(row.id))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
            .get();

        final ingRows = await (db.select(db.additionalIngredientsTable)
              ..where((tbl) => tbl.productId.equals(row.id))
              ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
            .get();

        products.add(_mapToProduct(row, compRows, ingRows, catalog));
      }
      return products;
    });
  }

  @override
  Future<List<Product>> getActiveProducts() async {
    return _fetchProducts(includeDeleted: false);
  }

  @override
  Future<List<Product>> getAllProductsIncludingDeleted() async {
    return _fetchProducts(includeDeleted: true);
  }

  Future<List<Product>> _fetchProducts({required bool includeDeleted}) async {
    final query = db.select(db.productsTable)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]);
    if (!includeDeleted) {
      query.where((tbl) => tbl.isDeleted.equals(false));
    }
    final rows = await query.get();
    final catalog = await getProductTypes();

    final products = <Product>[];
    for (final row in rows) {
      final compRows = await (db.select(db.compositionsTable)
            ..where((tbl) => tbl.productId.equals(row.id))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
          .get();

      final ingRows = await (db.select(db.additionalIngredientsTable)
            ..where((tbl) => tbl.productId.equals(row.id))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
          .get();

      products.add(_mapToProduct(row, compRows, ingRows, catalog));
    }
    return products;
  }

  @override
  Future<Product?> getProductById(String id) async {
    final row = await (db.select(db.productsTable)
          ..where((tbl) => tbl.id.equals(id) & tbl.isDeleted.equals(false)))
        .getSingleOrNull();

    if (row == null) return null;

    final catalog = await getProductTypes();

    final compRows = await (db.select(db.compositionsTable)
          ..where((tbl) => tbl.productId.equals(row.id))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();

    final ingRows = await (db.select(db.additionalIngredientsTable)
          ..where((tbl) => tbl.productId.equals(row.id))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();

    return _mapToProduct(row, compRows, ingRows, catalog);
  }

  @override
  Future<void> saveProduct(Product product) {
    return db.transaction(() => _upsertProductInTransaction(product));
  }

  @override
  Future<void> applySyncedProductsAtomically(List<Product> products) {
    if (products.isEmpty) return Future.value();
    return db.transaction(() async {
      for (final product in products) {
        await _upsertProductInTransaction(product);
      }
    });
  }

  Future<void> _upsertProductInTransaction(Product product) async {
    await db.into(db.productsTable).insertOnConflictUpdate(
          ProductsTableCompanion.insert(
            id: product.id,
            name: product.name,
            description: Value(product.description),
            productTypeCode: product.productType.code,
            createdByDeviceId: product.createdByDeviceId,
            createdByDisplayName: product.createdByDisplayName,
            updatedByDeviceId: Value(product.effectiveUpdatedByDeviceId),
            updatedByDisplayName: Value(product.effectiveUpdatedByDisplayName),
            createdAt: product.createdAt,
            updatedAt: product.updatedAt,
            isDeleted: Value(product.isDeleted),
            version: Value(product.version),
          ),
        );

    await (db.delete(db.compositionsTable)
          ..where((tbl) => tbl.productId.equals(product.id)))
        .go();

    for (int i = 0; i < product.compositions.length; i++) {
      final c = product.compositions[i];
      await db.into(db.compositionsTable).insert(
            CompositionsTableCompanion.insert(
              id: '${product.id}_comp_$i',
              productId: product.id,
              componentName: c.componentName,
              percentage: c.percentage,
              notes: Value(c.notes),
              sortOrder: Value(c.sortOrder),
            ),
          );
    }

    await (db.delete(db.additionalIngredientsTable)
          ..where((tbl) => tbl.productId.equals(product.id)))
        .go();

    for (int i = 0; i < product.additionalIngredients.length; i++) {
      final ing = product.additionalIngredients[i];
      await db.into(db.additionalIngredientsTable).insert(
            AdditionalIngredientsTableCompanion.insert(
              id: '${product.id}_ing_$i',
              productId: product.id,
              ingredientName: ing.ingredientName,
              quantity: ing.quantity,
              unit: ing.unit,
              notes: Value(ing.notes),
              sortOrder: Value(ing.sortOrder),
            ),
          );
    }
  }

  @override
  Future<void> softDeleteProduct(
    String id, {
    String? deletedByDeviceId,
    String? deletedByDisplayName,
  }) async {
    final existing = await (db.select(db.productsTable)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (existing == null) return;

    await (db.update(db.productsTable)..where((tbl) => tbl.id.equals(id))).write(
      ProductsTableCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
        version: Value(existing.version + 1),
        updatedByDeviceId: deletedByDeviceId != null
            ? Value(deletedByDeviceId)
            : const Value.absent(),
        updatedByDisplayName: deletedByDisplayName != null
            ? Value(deletedByDisplayName)
            : const Value.absent(),
      ),
    );
  }

  @override
  Future<List<String>> getDistinctComponents() async {
    final query = db.selectOnly(db.compositionsTable, distinct: true)
      ..addColumns([db.compositionsTable.componentName])
      ..orderBy([OrderingTerm.asc(db.compositionsTable.componentName)]);
    final rows = await query.get();
    return rows.map((r) => r.read(db.compositionsTable.componentName)!).toList();
  }

  @override
  Future<List<String>> getDistinctIngredients() async {
    final query = db.selectOnly(db.additionalIngredientsTable, distinct: true)
      ..addColumns([db.additionalIngredientsTable.ingredientName])
      ..orderBy([OrderingTerm.asc(db.additionalIngredientsTable.ingredientName)]);
    final rows = await query.get();
    return rows.map((r) => r.read(db.additionalIngredientsTable.ingredientName)!).toList();
  }

  @override
  Future<void> seedInitialDataIfEmpty() async {
    await _seedProductTypesIfEmpty();
  }

  Future<void> _seedProductTypesIfEmpty() async {
    final countExp = db.productTypesTable.code.count();
    final query = db.selectOnly(db.productTypesTable)..addColumns([countExp]);
    final result = await query.getSingle();
    final count = result.read(countExp) ?? 0;
    if (count > 0) return;

    await db.transaction(() async {
      for (final type in ProductType.defaults) {
        await db.into(db.productTypesTable).insertOnConflictUpdate(
              ProductTypesTableCompanion.insert(
                code: type.code,
                displayName: type.displayName,
                baseWeightGrams: type.baseWeightGrams,
                packagingJson:
                    ProductType.encodePackagingList(type.packagingOptions),
                sortOrder: Value(type.sortOrder),
              ),
            );
      }
    });
  }

  @override
  Stream<List<ProductType>> watchProductTypes() {
    final query = db.select(db.productTypesTable)
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.sortOrder),
        (tbl) => OrderingTerm.asc(tbl.displayName),
      ]);
    return query.watch().map((rows) {
      if (rows.isEmpty) return ProductType.defaults;
      return rows.map(_mapToProductType).toList();
    });
  }

  @override
  Future<List<ProductType>> getProductTypes() async {
    final query = db.select(db.productTypesTable)
      ..orderBy([
        (tbl) => OrderingTerm.asc(tbl.sortOrder),
        (tbl) => OrderingTerm.asc(tbl.displayName),
      ]);
    final rows = await query.get();
    if (rows.isEmpty) return ProductType.defaults;
    return rows.map(_mapToProductType).toList();
  }

  @override
  Future<void> saveProductType(ProductType productType) async {
    await db.into(db.productTypesTable).insertOnConflictUpdate(
          ProductTypesTableCompanion.insert(
            code: productType.code,
            displayName: productType.displayName,
            baseWeightGrams: productType.baseWeightGrams,
            packagingJson:
                ProductType.encodePackagingList(productType.packagingOptions),
            sortOrder: Value(productType.sortOrder),
          ),
        );
  }

  @override
  Future<void> deleteProductType(String code) async {
    await (db.delete(db.productTypesTable)
          ..where((tbl) => tbl.code.equals(code)))
        .go();
  }

  ProductType _mapToProductType(ProductTypeEntry row) {
    return ProductType(
      code: row.code,
      displayName: row.displayName,
      baseWeightGrams: row.baseWeightGrams,
      packagingOptions: ProductType.decodePackagingList(row.packagingJson),
      sortOrder: row.sortOrder,
    );
  }

  @override
  Stream<List<SyncConflictRecord>> watchConflictHistory() {
    final query = db.select(db.syncConflictsTable)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.occurredAt)]);
    return query.watch().map((rows) => rows.map(_mapToConflict).toList());
  }

  @override
  Future<List<SyncConflictRecord>> getConflictHistory() async {
    final query = db.select(db.syncConflictsTable)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.occurredAt)]);
    final rows = await query.get();
    return rows.map(_mapToConflict).toList();
  }

  @override
  Future<void> saveConflictRecords(List<SyncConflictRecord> records) async {
    if (records.isEmpty) return;
    await db.transaction(() async {
      for (final r in records) {
        await db.into(db.syncConflictsTable).insertOnConflictUpdate(
              SyncConflictsTableCompanion.insert(
                id: r.id,
                productId: r.productId,
                productName: r.productName,
                conflictType: r.conflictType.code,
                winningDeviceId: r.winningDeviceId,
                winningDeviceName: r.winningDeviceName,
                losingDeviceId: r.losingDeviceId,
                losingDeviceName: r.losingDeviceName,
                losingProductJson: r.losingProductJson,
                reason: r.reason,
                occurredAt: r.occurredAt,
                isResolved: Value(r.isResolved),
              ),
            );
      }
    });
  }

  @override
  Future<void> markConflictResolved(String conflictId) async {
    await (db.update(db.syncConflictsTable)
          ..where((tbl) => tbl.id.equals(conflictId)))
        .write(const SyncConflictsTableCompanion(isResolved: Value(true)));
  }

  SyncConflictRecord _mapToConflict(SyncConflictEntry row) {
    return SyncConflictRecord(
      id: row.id,
      productId: row.productId,
      productName: row.productName,
      conflictType: SyncConflictType.fromCode(row.conflictType),
      winningDeviceId: row.winningDeviceId,
      winningDeviceName: row.winningDeviceName,
      losingDeviceId: row.losingDeviceId,
      losingDeviceName: row.losingDeviceName,
      losingProductJson: row.losingProductJson,
      reason: row.reason,
      occurredAt: row.occurredAt,
      isResolved: row.isResolved,
    );
  }

  Product _mapToProduct(
    ProductEntry row,
    List<CompositionEntry> compRows,
    List<AdditionalIngredientEntry> ingRows,
    List<ProductType> catalog,
  ) {
    return Product(
      id: row.id,
      name: row.name,
      description: row.description,
      productType: ProductType.fromCode(row.productTypeCode, catalog: catalog),
      createdByDeviceId: row.createdByDeviceId,
      createdByDisplayName: row.createdByDisplayName,
      updatedByDeviceId: row.updatedByDeviceId ?? row.createdByDeviceId,
      updatedByDisplayName: row.updatedByDisplayName ?? row.createdByDisplayName,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isDeleted: row.isDeleted,
      version: row.version,
      compositions: compRows
          .map((c) => Composition(
                componentName: c.componentName,
                percentage: c.percentage,
                notes: c.notes,
                sortOrder: c.sortOrder,
              ))
          .toList(),
      additionalIngredients: ingRows
          .map((i) => AdditionalIngredient(
                ingredientName: i.ingredientName,
                quantity: i.quantity,
                unit: i.unit,
                notes: i.notes,
                sortOrder: i.sortOrder,
              ))
          .toList(),
    );
  }
}
