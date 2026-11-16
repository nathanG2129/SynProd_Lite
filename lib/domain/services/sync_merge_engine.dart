import 'dart:convert';

import '../../core/error/failures.dart';
import '../../core/utils/uuid_generator.dart';
import '../models/device.dart';
import '../models/product.dart';
import '../models/sync_models.dart';
import 'product_validator.dart';

class SyncMergeEngine {
  final DateTime Function() _now;

  SyncMergeEngine({DateTime Function()? now}) : _now = now ?? DateTime.now;

  SyncMergeResult merge({
    required Device localDevice,
    required List<Device> localDevices,
    required List<Product> localProducts,
    required SyncSnapshot incoming,
  }) {
    final now = _now();
    final deviceMap = <String, Device>{
      for (final d in localDevices) d.id: d,
    };

    final senderInRegistry = deviceMap[incoming.senderDeviceId];
    final senderInIncoming = incoming.devices
        .where((d) => d.id == incoming.senderDeviceId)
        .firstOrNull;
    final hasExistingAdmin =
        deviceMap.values.any((d) => d.role == DeviceRole.admin);

    final Device? effectiveSender;
    if (senderInRegistry != null) {
      effectiveSender = senderInRegistry.isRevoked ? null : senderInRegistry;
    } else if (senderInIncoming != null &&
        !senderInIncoming.isRevoked &&
        (senderInIncoming.role != DeviceRole.admin || !hasExistingAdmin)) {
      effectiveSender = senderInIncoming;
    } else {
      effectiveSender = null;
    }

    if (effectiveSender == null) {
      return SyncMergeResult(
        updatedDevices: localDevices,
        productsToSave: const [],
        newConflicts: const [],
      );
    }

    final senderIsAdmin = effectiveSender.role == DeviceRole.admin;
    final updatedDevicesMap = Map<String, Device>.from(deviceMap);
    if (senderInRegistry == null) {
      updatedDevicesMap[effectiveSender.id] = effectiveSender;
    }
    var localDeviceRevoked = false;

    for (final remoteDevice in incoming.devices) {
      final existing = updatedDevicesMap[remoteDevice.id];
      if (existing == null) {
        if (senderIsAdmin && remoteDevice.role != DeviceRole.admin) {
          updatedDevicesMap[remoteDevice.id] = remoteDevice;
        }
      } else {
        if (senderIsAdmin && remoteDevice.role != DeviceRole.admin) {
          final merged = existing.copyWith(
            displayName: remoteDevice.displayName,
            role: remoteDevice.role,
            isRevoked: remoteDevice.isRevoked,
            lastSeenAt: remoteDevice.lastSeenAt.isAfter(existing.lastSeenAt)
                ? remoteDevice.lastSeenAt
                : existing.lastSeenAt,
          );
          updatedDevicesMap[remoteDevice.id] = merged;
          if (remoteDevice.id == localDevice.id && merged.isRevoked) {
            localDeviceRevoked = true;
          }
        } else if (remoteDevice.lastSeenAt.isAfter(existing.lastSeenAt)) {
          updatedDevicesMap[remoteDevice.id] = existing.copyWith(
            lastSeenAt: remoteDevice.lastSeenAt,
          );
        }
      }
    }

    updatedDevicesMap[incoming.senderDeviceId] = effectiveSender.copyWith(
      lastSeenAt: now,
    );

    final localProductMap = <String, Product>{
      for (final p in localProducts) p.id: p,
    };
    final mergedProductMap = Map<String, Product>.from(localProductMap);
    final productsToSave = <Product>[];
    final newConflicts = <SyncConflictRecord>[];

    for (final remote in incoming.products) {
      final existing = localProductMap[remote.id];
      final modifierId = remote.effectiveUpdatedByDeviceId;
      final modifierDevice = updatedDevicesMap[modifierId];

      final permissionError = _checkAuthority(
        existing: existing,
        incoming: remote,
        modifierDevice: modifierDevice,
      );
      if (permissionError != null) {
        newConflicts.add(
          SyncConflictRecord(
            id: UuidGenerator.v4(),
            productId: remote.id,
            productName: remote.name,
            conflictType: SyncConflictType.permissionRejected,
            winningDeviceId: existing?.effectiveUpdatedByDeviceId ?? localDevice.id,
            winningDeviceName:
                existing?.effectiveUpdatedByDisplayName ?? localDevice.displayName,
            losingDeviceId: modifierId,
            losingDeviceName: remote.effectiveUpdatedByDisplayName,
            losingProductJson: jsonEncode(remote.toMap()),
            reason: permissionError,
            occurredAt: now,
          ),
        );
        continue;
      }

      if (!remote.isDeleted) {
        final validationError = _validateIncomingProduct(remote);
        if (validationError != null) {
          newConflicts.add(
            SyncConflictRecord(
              id: UuidGenerator.v4(),
              productId: remote.id,
              productName: remote.name,
              conflictType: SyncConflictType.validationRejected,
              winningDeviceId:
                  existing?.effectiveUpdatedByDeviceId ?? localDevice.id,
              winningDeviceName:
                  existing?.effectiveUpdatedByDisplayName ?? localDevice.displayName,
              losingDeviceId: modifierId,
              losingDeviceName: remote.effectiveUpdatedByDisplayName,
              losingProductJson: jsonEncode(remote.toMap()),
              reason: validationError,
              occurredAt: now,
            ),
          );
          continue;
        }
      }

      if (existing == null) {
        mergedProductMap[remote.id] = remote;
        productsToSave.add(remote);
        continue;
      }

      if (_areEquivalent(existing, remote)) {
        continue;
      }

      final comparison = _compareLww(remote, existing);
      final isTrueConcurrentConflict = localDevice.role.canCreateProduct &&
          (remote.version == existing.version ||
              (existing.effectiveUpdatedByDeviceId == localDevice.id &&
                  remote.effectiveUpdatedByDeviceId != localDevice.id));
      if (comparison > 0) {
        mergedProductMap[remote.id] = remote;
        productsToSave.add(remote);
        if (isTrueConcurrentConflict) {
          newConflicts.add(
            SyncConflictRecord(
              id: UuidGenerator.v4(),
              productId: remote.id,
              productName: remote.name,
              conflictType: SyncConflictType.lwwOverwritten,
              winningDeviceId: remote.effectiveUpdatedByDeviceId,
              winningDeviceName: remote.effectiveUpdatedByDisplayName,
              losingDeviceId: existing.effectiveUpdatedByDeviceId,
              losingDeviceName: existing.effectiveUpdatedByDisplayName,
              losingProductJson: jsonEncode(existing.toMap()),
              reason:
                  'Local version v${existing.version} overwritten by v${remote.version} from ${remote.effectiveUpdatedByDisplayName}.',
              occurredAt: now,
            ),
          );
        }
      } else if (isTrueConcurrentConflict) {
        newConflicts.add(
          SyncConflictRecord(
            id: UuidGenerator.v4(),
            productId: existing.id,
            productName: existing.name,
            conflictType: SyncConflictType.lwwOverwritten,
            winningDeviceId: existing.effectiveUpdatedByDeviceId,
            winningDeviceName: existing.effectiveUpdatedByDisplayName,
            losingDeviceId: remote.effectiveUpdatedByDeviceId,
            losingDeviceName: remote.effectiveUpdatedByDisplayName,
            losingProductJson: jsonEncode(remote.toMap()),
            reason:
                'Incoming version v${remote.version} from ${remote.effectiveUpdatedByDisplayName} lost to local v${existing.version}.',
            occurredAt: now,
          ),
        );
      }
    }

    // Check case-insensitive duplicate product names across active products
    final activeByLowerName = <String, List<Product>>{};
    for (final p in mergedProductMap.values) {
      if (p.isDeleted) continue;
      final key = p.name.trim().toLowerCase();
      activeByLowerName.putIfAbsent(key, () => []).add(p);
    }

    for (final entry in activeByLowerName.entries) {
      if (entry.value.length <= 1) continue;
      final sorted = List<Product>.from(entry.value)
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      final first = sorted.first;
      for (var i = 1; i < sorted.length; i++) {
        final duplicate = sorted[i];
        final wasJustSynced =
            productsToSave.any((saved) => saved.id == duplicate.id) ||
                productsToSave.any((saved) => saved.id == first.id);
        if (!wasJustSynced) continue;

        newConflicts.add(
          SyncConflictRecord(
            id: UuidGenerator.v4(),
            productId: duplicate.id,
            productName: duplicate.name,
            conflictType: SyncConflictType.nameConflict,
            winningDeviceId: first.createdByDeviceId,
            winningDeviceName: first.createdByDisplayName,
            losingDeviceId: duplicate.createdByDeviceId,
            losingDeviceName: duplicate.createdByDisplayName,
            losingProductJson: jsonEncode(duplicate.toMap()),
            reason:
                'Duplicate product name "${duplicate.name}" created offline. Rename one of the recipes.',
            occurredAt: now,
          ),
        );
      }
    }

    final replaceProductTypes =
        senderIsAdmin && incoming.productTypes.isNotEmpty;

    return SyncMergeResult(
      updatedDevices: updatedDevicesMap.values.toList(),
      productsToSave: productsToSave,
      productTypesToSave:
          replaceProductTypes ? incoming.productTypes : const [],
      replaceProductTypes: replaceProductTypes,
      newConflicts: newConflicts,
      localDeviceRevoked: localDeviceRevoked,
    );
  }

  static const String seedDeviceId = 'device_seed_001';

  String? _checkAuthority({
    required Product? existing,
    required Product incoming,
    required Device? modifierDevice,
  }) {
    if (modifierDevice == null) {
      if (incoming.effectiveUpdatedByDeviceId == seedDeviceId &&
          !incoming.isDeleted) {
        return null;
      }
      return 'Modifying device (${incoming.effectiveUpdatedByDeviceId}) is not in the workspace registry.';
    }
    if (modifierDevice.isRevoked) {
      return 'Modifying device ${modifierDevice.displayName} is revoked.';
    }
    if (modifierDevice.role == DeviceRole.production) {
      return 'Production device ${modifierDevice.displayName} cannot push recipe changes.';
    }
    if (incoming.isDeleted && modifierDevice.role != DeviceRole.admin) {
      return 'Only ADMIN devices may delete products (attempted by ${modifierDevice.displayName}).';
    }
    if (existing != null &&
        modifierDevice.role == DeviceRole.manager &&
        existing.createdByDeviceId != modifierDevice.id) {
      return 'Manager ${modifierDevice.displayName} cannot edit product created by ${existing.createdByDisplayName}.';
    }
    return null;
  }

  String? _validateIncomingProduct(Product product) {
    try {
      ProductValidator.validateProduct(product);
      return null;
    } on ValidationFailure catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  int _compareLww(Product a, Product b) {
    if (a.version != b.version) {
      return a.version.compareTo(b.version);
    }
    final timeCmp = a.updatedAt.toUtc().compareTo(b.updatedAt.toUtc());
    if (timeCmp != 0) return timeCmp;
    return a.effectiveUpdatedByDeviceId.compareTo(b.effectiveUpdatedByDeviceId);
  }

  bool _areEquivalent(Product a, Product b) {
    return a.version == b.version &&
        a.isDeleted == b.isDeleted &&
        a.updatedAt.toUtc() == b.updatedAt.toUtc() &&
        a.name == b.name &&
        a.description == b.description &&
        a.productType == b.productType &&
        a.compositions.length == b.compositions.length &&
        a.additionalIngredients.length == b.additionalIngredients.length;
  }
}
