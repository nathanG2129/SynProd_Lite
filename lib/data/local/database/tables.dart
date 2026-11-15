import 'package:drift/drift.dart';

@DataClassName('ProductEntry')
class ProductsTable extends Table {
  @override
  String get tableName => 'products';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get productTypeCode => text()();
  TextColumn get createdByDeviceId => text()();
  TextColumn get createdByDisplayName => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CompositionEntry')
class CompositionsTable extends Table {
  @override
  String get tableName => 'compositions';

  TextColumn get id => text()();
  TextColumn get productId => text().references(ProductsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get componentName => text()();
  RealColumn get percentage => real()();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AdditionalIngredientEntry')
class AdditionalIngredientsTable extends Table {
  @override
  String get tableName => 'additional_ingredients';

  TextColumn get id => text()();
  TextColumn get productId => text().references(ProductsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get ingredientName => text()();
  RealColumn get quantity => real()();
  TextColumn get unit => text()();
  TextColumn get notes => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DeviceEntry')
class DevicesTable extends Table {
  @override
  String get tableName => 'devices';

  TextColumn get id => text()();
  TextColumn get displayName => text()();
  TextColumn get roleCode => text()();
  DateTimeColumn get pairedAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime()();
  BoolColumn get isRevoked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkspaceEntry')
class WorkspacesTable extends Table {
  @override
  String get tableName => 'workspaces';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get workspaceKey => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
