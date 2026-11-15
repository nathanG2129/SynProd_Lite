enum DeviceRole {
  production(code: 'PRODUCTION', displayName: 'Production'),
  manager(code: 'MANAGER', displayName: 'Manager'),
  admin(code: 'ADMIN', displayName: 'Admin');

  final String code;
  final String displayName;

  const DeviceRole({required this.code, required this.displayName});

  bool get canCreateProduct => this == manager || this == admin;
  bool get canDeleteProduct => this == admin;
  bool get canManageDevices => this == admin;

  static DeviceRole fromCode(String code) {
    return DeviceRole.values.firstWhere(
      (role) => role.code == code || role.name == code,
      orElse: () => DeviceRole.production,
    );
  }
}

class Device {
  final String id;
  final String displayName;
  final DeviceRole role;
  final DateTime pairedAt;
  final DateTime lastSeenAt;
  final bool isRevoked;

  const Device({
    required this.id,
    required this.displayName,
    required this.role,
    required this.pairedAt,
    required this.lastSeenAt,
    this.isRevoked = false,
  });

  Device copyWith({
    String? id,
    String? displayName,
    DeviceRole? role,
    DateTime? pairedAt,
    DateTime? lastSeenAt,
    bool? isRevoked,
  }) {
    return Device(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isRevoked: isRevoked ?? this.isRevoked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'role': role.code,
      'pairedAt': pairedAt.toIso8601String(),
      'lastSeenAt': lastSeenAt.toIso8601String(),
      'isRevoked': isRevoked ? 1 : 0,
    };
  }

  factory Device.fromMap(Map<String, dynamic> map) {
    return Device(
      id: map['id'] as String,
      displayName: map['displayName'] as String,
      role: DeviceRole.fromCode(map['role'] as String),
      pairedAt: DateTime.parse(map['pairedAt'] as String),
      lastSeenAt: DateTime.parse(map['lastSeenAt'] as String),
      isRevoked: (map['isRevoked'] as num?) == 1,
    );
  }
}
