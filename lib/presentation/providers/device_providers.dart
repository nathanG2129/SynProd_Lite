import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/device.dart';
import '../../domain/models/product.dart';

/// Provides the currently active local device.
/// Defaults to the seeded local ADMIN device until Phase 4 implements QR pairing & PIN auth.
final currentDeviceProvider = Provider<Device>((ref) {
  final now = DateTime.now();
  return Device(
    id: 'device_seed_001',
    displayName: 'System Administrator',
    role: DeviceRole.admin,
    pairedAt: now,
    lastSeenAt: now,
  );
});

bool canDeviceEditProduct(Device device, Product product) {
  if (device.role == DeviceRole.admin) return true;
  if (device.role == DeviceRole.manager) {
    return product.createdByDeviceId == device.id;
  }
  return false;
}

bool canDeviceDeleteProduct(Device device) {
  return device.role.canDeleteProduct;
}
