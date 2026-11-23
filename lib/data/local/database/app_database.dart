import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

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
      : super(
          executor ??
              driftDatabase(
                name: 'synprod_lite',
                native: DriftNativeOptions(
                  databaseDirectory: _resolveDatabaseDirectory,
                ),
              ),
        );

  static Future<Directory> _resolveDatabaseDirectory() async {
    if (!Platform.isWindows) {
      return getApplicationDocumentsDirectory();
    }

    final supportDir = await getApplicationSupportDirectory();
    await supportDir.create(recursive: true);

    const dbBaseName = 'synprod_lite.sqlite';
    final targetDb = File('${supportDir.path}${Platform.pathSeparator}$dbBaseName');
    if (!await targetDb.exists()) {
      final docsDir = await getApplicationDocumentsDirectory();
      for (final suffix in ['', '-wal', '-shm']) {
        final fileName = '$dbBaseName$suffix';
        final legacyFile = File('${docsDir.path}${Platform.pathSeparator}$fileName');
        if (await legacyFile.exists()) {
          final destPath = '${supportDir.path}${Platform.pathSeparator}$fileName';
          try {
            await legacyFile.rename(destPath);
          } on FileSystemException {
            // Fall back to copy + delete when Documents and AppData are on different volumes.
            await legacyFile.copy(destPath);
            await legacyFile.delete();
          }
        }
      }
    }

    return supportDir;
  }

  @override
  int get schemaVersion => 6;

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
          if (from < 5) {
            await m.addColumn(productTypesTable, productTypesTable.isArchived);
          }
          if (from < 6) {
            await m.addColumn(productsTable, productsTable.hasPendingLocalEdit);
            await m.addColumn(productTypesTable, productTypesTable.version);
            await m.addColumn(productTypesTable, productTypesTable.updatedAt);
            await m.addColumn(
                productTypesTable, productTypesTable.updatedByDeviceId);
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
