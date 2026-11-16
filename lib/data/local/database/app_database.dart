import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ProductsTable,
  CompositionsTable,
  AdditionalIngredientsTable,
  DevicesTable,
  WorkspacesTable,
  PairingTokensTable,
  SyncConflictsTable,
  ProductTypesTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'synprod_lite'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(pairingTokensTable);
          }
          if (from < 3) {
            await m.addColumn(productsTable, productsTable.updatedByDeviceId);
            await m.addColumn(productsTable, productsTable.updatedByDisplayName);
            await m.createTable(syncConflictsTable);
          }
          if (from < 4) {
            await m.createTable(productTypesTable);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(compositionsTable).go();
      await delete(additionalIngredientsTable).go();
      await delete(productsTable).go();
      await delete(pairingTokensTable).go();
      await delete(syncConflictsTable).go();
      await delete(devicesTable).go();
      await delete(workspacesTable).go();
      await delete(productTypesTable).go();
    });
  }
}
