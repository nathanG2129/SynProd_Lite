import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/device.dart';
import '../../domain/models/product.dart';
import '../../domain/models/workspace.dart';
import 'auth_providers.dart';

/// Provides the currently active local device from [authControllerProvider].
final currentDeviceProvider = Provider<Device>((ref) {
  final device = ref.watch(authControllerProvider.select((s) => s.device));
  if (device != null) return device;

  final now = DateTime.now();
  return Device(
    id: 'unpaired_device',
    displayName: 'Unpaired Device',
    role: DeviceRole.production,
    pairedAt: now,
    lastSeenAt: now,
  );
});

final allDevicesProvider = StreamProvider<List<Device>>((ref) {
  return ref.watch(deviceRepositoryProvider).watchAllDevices();
});

final activeWorkspaceProvider = StreamProvider<Workspace?>((ref) {
  return ref.watch(deviceRepositoryProvider).watchActiveWorkspace();
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
