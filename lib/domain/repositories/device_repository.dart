import '../models/device.dart';
import '../models/workspace.dart';

class PairingTokenRecord {
  final String id;
  final String deviceId;
  final String displayName;
  final DeviceRole role;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isUsed;

  const PairingTokenRecord({
    required this.id,
    required this.deviceId,
    required this.displayName,
    required this.role,
    required this.createdAt,
    required this.expiresAt,
    required this.isUsed,
  });
}

abstract class DeviceRepository {
  Future<Workspace?> getActiveWorkspace();
  Stream<Workspace?> watchActiveWorkspace();

  Future<Device?> getDeviceById(String id);
  Stream<Device?> watchDeviceById(String id);
  Stream<List<Device>> watchAllDevices();
  Future<List<Device>> getAllDevices();

  Future<({Workspace workspace, Device adminDevice})> createWorkspaceAndAdmin({
    required String workspaceName,
    required String adminDisplayName,
  });

  Future<void> saveWorkspaceAndLocalDevice({
    required Workspace workspace,
    required Device localDevice,
    List<Device> additionalDevices = const [],
  });

  Future<void> upsertDevice(Device device);
  Future<void> updateDeviceRole(String deviceId, DeviceRole role);
  Future<void> setDeviceRevoked(String deviceId, bool isRevoked);
  Future<void> updateLastSeen(String deviceId, DateTime timestamp);

  Future<PairingTokenRecord> createPairingToken({
    required String deviceId,
    required String displayName,
    required DeviceRole role,
    required Duration validity,
  });

  Future<PairingTokenRecord?> getPairingToken(String tokenId);
  Future<void> markPairingTokenUsed(String tokenId);
}
