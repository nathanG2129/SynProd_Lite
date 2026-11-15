import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/utils/uuid_generator.dart';
import '../../domain/models/device.dart';
import '../../domain/models/workspace.dart';
import '../../domain/repositories/device_repository.dart';
import '../local/database/app_database.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final AppDatabase _db;

  DeviceRepositoryImpl(this._db);

  @override
  Future<Workspace?> getActiveWorkspace() async {
    final row = await (_db.select(_db.workspacesTable)..limit(1)).getSingleOrNull();
    return row == null ? null : _mapWorkspace(row);
  }

  @override
  Stream<Workspace?> watchActiveWorkspace() {
    return (_db.select(_db.workspacesTable)..limit(1))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapWorkspace(row));
  }

  @override
  Future<Device?> getDeviceById(String id) async {
    final row = await (_db.select(_db.devicesTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _mapDevice(row);
  }

  @override
  Stream<Device?> watchDeviceById(String id) {
    return (_db.select(_db.devicesTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapDevice(row));
  }

  @override
  Stream<List<Device>> watchAllDevices() {
    return (_db.select(_db.devicesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .watch()
        .map((rows) => rows.map(_mapDevice).toList());
  }

  @override
  Future<List<Device>> getAllDevices() async {
    final rows = await (_db.select(_db.devicesTable)
          ..orderBy([(t) => OrderingTerm.asc(t.displayName)]))
        .get();
    return rows.map(_mapDevice).toList();
  }

  @override
  Future<({Workspace workspace, Device adminDevice})> createWorkspaceAndAdmin({
    required String workspaceName,
    required String adminDisplayName,
  }) async {
    final now = DateTime.now();
    final workspace = Workspace(
      id: UuidGenerator.v4(),
      name: workspaceName.trim(),
      workspaceKey: _generateWorkspaceKey(),
      createdAt: now,
    );
    final adminDevice = Device(
      id: UuidGenerator.v4(),
      displayName: adminDisplayName.trim(),
      role: DeviceRole.admin,
      pairedAt: now,
      lastSeenAt: now,
    );

    await saveWorkspaceAndLocalDevice(
      workspace: workspace,
      localDevice: adminDevice,
    );

    return (workspace: workspace, adminDevice: adminDevice);
  }

  @override
  Future<void> saveWorkspaceAndLocalDevice({
    required Workspace workspace,
    required Device localDevice,
    List<Device> additionalDevices = const [],
  }) async {
    await _db.transaction(() async {
      await _db.into(_db.workspacesTable).insertOnConflictUpdate(
            WorkspacesTableCompanion.insert(
              id: workspace.id,
              name: workspace.name,
              workspaceKey: workspace.workspaceKey,
              createdAt: workspace.createdAt,
            ),
          );

      await _upsertDeviceRow(localDevice);
      for (final d in additionalDevices) {
        if (d.id != localDevice.id) {
          await _upsertDeviceRow(d);
        }
      }
    });
  }

  @override
  Future<void> upsertDevice(Device device) async {
    await _upsertDeviceRow(device);
  }

  @override
  Future<void> updateDeviceRole(String deviceId, DeviceRole role) async {
    await (_db.update(_db.devicesTable)..where((t) => t.id.equals(deviceId)))
        .write(DevicesTableCompanion(roleCode: Value(role.code)));
  }

  @override
  Future<void> setDeviceRevoked(String deviceId, bool isRevoked) async {
    await (_db.update(_db.devicesTable)..where((t) => t.id.equals(deviceId)))
        .write(DevicesTableCompanion(isRevoked: Value(isRevoked)));
  }

  @override
  Future<void> updateLastSeen(String deviceId, DateTime timestamp) async {
    await (_db.update(_db.devicesTable)..where((t) => t.id.equals(deviceId)))
        .write(DevicesTableCompanion(lastSeenAt: Value(timestamp)));
  }

  @override
  Future<PairingTokenRecord> createPairingToken({
    required String deviceId,
    required String displayName,
    required DeviceRole role,
    required Duration validity,
  }) async {
    final now = DateTime.now();
    final expiresAt = now.add(validity);
    final tokenId = UuidGenerator.v4();

    await _db.into(_db.pairingTokensTable).insert(
          PairingTokensTableCompanion.insert(
            id: tokenId,
            deviceId: deviceId,
            displayName: displayName.trim(),
            roleCode: role.code,
            createdAt: now,
            expiresAt: expiresAt,
            isUsed: const Value(false),
          ),
        );

    return PairingTokenRecord(
      id: tokenId,
      deviceId: deviceId,
      displayName: displayName.trim(),
      role: role,
      createdAt: now,
      expiresAt: expiresAt,
      isUsed: false,
    );
  }

  @override
  Future<PairingTokenRecord?> getPairingToken(String tokenId) async {
    final row = await (_db.select(_db.pairingTokensTable)
          ..where((t) => t.id.equals(tokenId)))
        .getSingleOrNull();
    if (row == null) return null;
    return PairingTokenRecord(
      id: row.id,
      deviceId: row.deviceId,
      displayName: row.displayName,
      role: DeviceRole.fromCode(row.roleCode),
      createdAt: row.createdAt,
      expiresAt: row.expiresAt,
      isUsed: row.isUsed,
    );
  }

  @override
  Future<void> markPairingTokenUsed(String tokenId) async {
    await (_db.update(_db.pairingTokensTable)
          ..where((t) => t.id.equals(tokenId)))
        .write(const PairingTokensTableCompanion(isUsed: Value(true)));
  }

  Future<void> _upsertDeviceRow(Device device) async {
    await _db.into(_db.devicesTable).insertOnConflictUpdate(
          DevicesTableCompanion.insert(
            id: device.id,
            displayName: device.displayName,
            roleCode: device.role.code,
            pairedAt: device.pairedAt,
            lastSeenAt: device.lastSeenAt,
            isRevoked: Value(device.isRevoked),
          ),
        );
  }

  Workspace _mapWorkspace(WorkspaceEntry row) {
    return Workspace(
      id: row.id,
      name: row.name,
      workspaceKey: row.workspaceKey,
      createdAt: row.createdAt,
    );
  }

  Device _mapDevice(DeviceEntry row) {
    return Device(
      id: row.id,
      displayName: row.displayName,
      role: DeviceRole.fromCode(row.roleCode),
      pairedAt: row.pairedAt,
      lastSeenAt: row.lastSeenAt,
      isRevoked: row.isRevoked,
    );
  }

  String _generateWorkspaceKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}
