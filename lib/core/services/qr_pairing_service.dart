import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/models/device.dart';
import '../../domain/models/workspace.dart';
import '../constants/app_constants.dart';
import '../utils/uuid_generator.dart';

class QrPairingPayload {
  final int version;
  final String workspaceId;
  final String workspaceName;
  final String workspaceKey;
  final String deviceId;
  final String displayName;
  final DeviceRole role;
  final String pairingSecret;
  final DateTime expiresAt;
  final String? addressHint;
  final String signature;

  const QrPairingPayload({
    this.version = 1,
    required this.workspaceId,
    required this.workspaceName,
    required this.workspaceKey,
    required this.deviceId,
    required this.displayName,
    required this.role,
    required this.pairingSecret,
    required this.expiresAt,
    this.addressHint,
    required this.signature,
  });

  bool isExpired([DateTime? now]) {
    final current = now ?? DateTime.now();
    return current.isAfter(expiresAt);
  }

  String toJsonString() {
    return jsonEncode({
      'v': version,
      'wid': workspaceId,
      'wn': workspaceName,
      'wk': workspaceKey,
      'did': deviceId,
      'dn': displayName,
      'r': role.code,
      'sec': pairingSecret,
      'exp': expiresAt.toUtc().toIso8601String(),
      if (addressHint != null && addressHint!.isNotEmpty) 'addr': addressHint,
      'sig': signature,
    });
  }

  static QrPairingPayload? tryParse(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final version = (decoded['v'] as num?)?.toInt() ?? 1;
      final workspaceId = decoded['wid'] as String?;
      final workspaceName = decoded['wn'] as String?;
      final workspaceKey = decoded['wk'] as String?;
      final deviceId = decoded['did'] as String?;
      final displayName = decoded['dn'] as String?;
      final roleCode = decoded['r'] as String?;
      final pairingSecret = decoded['sec'] as String?;
      final expiresAtRaw = decoded['exp'] as String?;
      final addressHint = decoded['addr'] as String?;
      final signature = decoded['sig'] as String?;

      if (workspaceId == null ||
          workspaceName == null ||
          workspaceKey == null ||
          deviceId == null ||
          displayName == null ||
          roleCode == null ||
          pairingSecret == null ||
          expiresAtRaw == null ||
          signature == null) {
        return null;
      }

      if (roleCode != DeviceRole.production.code &&
          roleCode != DeviceRole.manager.code &&
          roleCode != DeviceRole.admin.code) {
        return null;
      }

      return QrPairingPayload(
        version: version,
        workspaceId: workspaceId,
        workspaceName: workspaceName,
        workspaceKey: workspaceKey,
        deviceId: deviceId,
        displayName: displayName,
        role: DeviceRole.fromCode(roleCode),
        pairingSecret: pairingSecret,
        expiresAt: DateTime.parse(expiresAtRaw).toLocal(),
        addressHint: addressHint,
        signature: signature,
      );
    } catch (_) {
      return null;
    }
  }
}

class QrPairingValidationResult {
  final bool isValid;
  final QrPairingPayload? payload;
  final String? errorMessage;

  const QrPairingValidationResult({
    required this.isValid,
    this.payload,
    this.errorMessage,
  });
}

class QrPairingService {
  final DateTime Function() _now;

  QrPairingService({DateTime Function()? now}) : _now = now ?? DateTime.now;

  QrPairingPayload createPayload({
    required Workspace workspace,
    required String deviceId,
    required String displayName,
    required DeviceRole role,
    String? pairingSecret,
    String? addressHint,
    Duration validity = AppConstants.qrPairingExpiry,
  }) {
    if (role == DeviceRole.admin) {
      throw ArgumentError('Cannot pair an ADMIN device via QR code.');
    }

    final secret = pairingSecret ?? UuidGenerator.v4();
    final expiresAt = _now().add(validity);
    final signature = _computeSignature(
      workspaceId: workspace.id,
      workspaceKey: workspace.workspaceKey,
      deviceId: deviceId,
      displayName: displayName,
      role: role,
      pairingSecret: secret,
      expiresAt: expiresAt,
    );

    return QrPairingPayload(
      workspaceId: workspace.id,
      workspaceName: workspace.name,
      workspaceKey: workspace.workspaceKey,
      deviceId: deviceId,
      displayName: displayName,
      role: role,
      pairingSecret: secret,
      expiresAt: expiresAt,
      addressHint: addressHint,
      signature: signature,
    );
  }

  QrPairingValidationResult validateRawPayload(String raw) {
    final payload = QrPairingPayload.tryParse(raw.trim());
    if (payload == null) {
      return const QrPairingValidationResult(
        isValid: false,
        errorMessage: 'Invalid QR pairing code format.',
      );
    }

    if (payload.role == DeviceRole.admin) {
      return const QrPairingValidationResult(
        isValid: false,
        errorMessage: 'ADMIN role cannot be paired via QR code.',
      );
    }

    if (payload.isExpired(_now())) {
      return const QrPairingValidationResult(
        isValid: false,
        errorMessage: 'This QR pairing code has expired. Ask an Admin to generate a new one.',
      );
    }

    final expectedSig = _computeSignature(
      workspaceId: payload.workspaceId,
      workspaceKey: payload.workspaceKey,
      deviceId: payload.deviceId,
      displayName: payload.displayName,
      role: payload.role,
      pairingSecret: payload.pairingSecret,
      expiresAt: payload.expiresAt,
    );

    if (!_constantTimeEquals(payload.signature, expectedSig)) {
      return const QrPairingValidationResult(
        isValid: false,
        errorMessage: 'QR pairing signature verification failed.',
      );
    }

    return QrPairingValidationResult(
      isValid: true,
      payload: payload,
    );
  }

  String _computeSignature({
    required String workspaceId,
    required String workspaceKey,
    required String deviceId,
    required String displayName,
    required DeviceRole role,
    required String pairingSecret,
    required DateTime expiresAt,
  }) {
    final canonical = [
      workspaceId,
      deviceId,
      displayName,
      role.code,
      pairingSecret,
      expiresAt.toUtc().toIso8601String(),
    ].join('|');

    final hmac = Hmac(sha256, utf8.encode(workspaceKey));
    return hmac.convert(utf8.encode(canonical)).toString();
  }

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
