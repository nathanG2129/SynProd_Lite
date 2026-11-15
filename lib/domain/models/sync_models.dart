import 'dart:convert';

import 'device.dart';
import 'product.dart';

enum SyncConflictType {
  lwwOverwritten('LWW_OVERWRITTEN', 'Overwritten by Newer Version'),
  nameConflict('NAME_CONFLICT', 'Duplicate Product Name'),
  validationRejected('VALIDATION_REJECTED', 'Invalid Composition Rejected'),
  permissionRejected('PERMISSION_REJECTED', 'Unauthorized Edit Rejected');

  final String code;
  final String displayName;

  const SyncConflictType(this.code, this.displayName);

  static SyncConflictType fromCode(String code) {
    return SyncConflictType.values.firstWhere(
      (t) => t.code == code,
      orElse: () => SyncConflictType.lwwOverwritten,
    );
  }
}

class SyncConflictRecord {
  final String id;
  final String productId;
  final String productName;
  final SyncConflictType conflictType;
  final String winningDeviceId;
  final String winningDeviceName;
  final String losingDeviceId;
  final String losingDeviceName;
  final String losingProductJson;
  final String reason;
  final DateTime occurredAt;
  final bool isResolved;

  const SyncConflictRecord({
    required this.id,
    required this.productId,
    required this.productName,
    required this.conflictType,
    required this.winningDeviceId,
    required this.winningDeviceName,
    required this.losingDeviceId,
    required this.losingDeviceName,
    required this.losingProductJson,
    required this.reason,
    required this.occurredAt,
    this.isResolved = false,
  });

  Product? tryDecodeLosingProduct() {
    try {
      final decoded = jsonDecode(losingProductJson);
      if (decoded is Map<String, dynamic>) {
        return Product.fromMap(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}

class DiscoveredPeer {
  final String deviceId;
  final String displayName;
  final String workspaceId;
  final String host;
  final int port;
  final DateTime discoveredAt;

  const DiscoveredPeer({
    required this.deviceId,
    required this.displayName,
    required this.workspaceId,
    required this.host,
    required this.port,
    required this.discoveredAt,
  });

  String get endpointKey => '$host:$port';
}

class SyncSnapshot {
  final String workspaceId;
  final String senderDeviceId;
  final DateTime generatedAt;
  final List<Device> devices;
  final List<Product> products;

  const SyncSnapshot({
    required this.workspaceId,
    required this.senderDeviceId,
    required this.generatedAt,
    required this.devices,
    required this.products,
  });

  Map<String, dynamic> toMap() {
    return {
      'version': 1,
      'workspaceId': workspaceId,
      'senderDeviceId': senderDeviceId,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'devices': devices.map((d) => d.toMap()).toList(),
      'products': products.map((p) => p.toMap()).toList(),
    };
  }

  factory SyncSnapshot.fromMap(Map<String, dynamic> map) {
    final devicesRaw = map['devices'] as List<dynamic>? ?? const [];
    final productsRaw = map['products'] as List<dynamic>? ?? const [];
    return SyncSnapshot(
      workspaceId: map['workspaceId'] as String,
      senderDeviceId: map['senderDeviceId'] as String,
      generatedAt: DateTime.parse(map['generatedAt'] as String),
      devices: devicesRaw
          .map((e) => Device.fromMap(e as Map<String, dynamic>))
          .toList(),
      products: productsRaw
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SyncMergeResult {
  final List<Device> updatedDevices;
  final List<Product> productsToSave;
  final List<SyncConflictRecord> newConflicts;
  final bool localDeviceRevoked;

  const SyncMergeResult({
    required this.updatedDevices,
    required this.productsToSave,
    required this.newConflicts,
    this.localDeviceRevoked = false,
  });
}

class SyncStatusState {
  final bool isRunning;
  final bool isSyncing;
  final List<DiscoveredPeer> peers;
  final DateTime? lastSyncedAt;
  final int unresolvedConflictsCount;
  final String? lastError;

  const SyncStatusState({
    this.isRunning = false,
    this.isSyncing = false,
    this.peers = const [],
    this.lastSyncedAt,
    this.unresolvedConflictsCount = 0,
    this.lastError,
  });

  SyncStatusState copyWith({
    bool? isRunning,
    bool? isSyncing,
    List<DiscoveredPeer>? peers,
    DateTime? lastSyncedAt,
    int? unresolvedConflictsCount,
    String? lastError,
    bool clearError = false,
  }) {
    return SyncStatusState(
      isRunning: isRunning ?? this.isRunning,
      isSyncing: isSyncing ?? this.isSyncing,
      peers: peers ?? this.peers,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      unresolvedConflictsCount:
          unresolvedConflictsCount ?? this.unresolvedConflictsCount,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}
