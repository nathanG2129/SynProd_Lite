import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

import '../../domain/models/sync_models.dart';
import '../utils/uuid_generator.dart';

class SyncCryptoException implements Exception {
  final String message;
  const SyncCryptoException(this.message);

  @override
  String toString() => message;
}

class SyncCryptoService {
  static const Duration defaultReplayWindow = Duration(minutes: 5);
  static const int _ivLength = 16;

  final DateTime Function() _now;
  final Duration replayWindow;
  final Set<String> _seenNonces = <String>{};

  SyncCryptoService({
    DateTime Function()? now,
    this.replayWindow = defaultReplayWindow,
  }) : _now = now ?? DateTime.now;

  String encryptEnvelope({
    required SyncSnapshot snapshot,
    required String workspaceKey,
  }) {
    final random = Random.secure();
    final ivBytes = Uint8List.fromList(
      List<int>.generate(_ivLength, (_) => random.nextInt(256)),
    );
    final iv = enc.IV(ivBytes);
    final keyBytes = _deriveEncKey(workspaceKey);
    final macKey = _deriveMacKey(workspaceKey);

    final plaintext = jsonEncode(snapshot.toMap());
    final encrypter = enc.Encrypter(
      enc.AES(enc.Key(keyBytes), mode: enc.AESMode.cbc),
    );
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    final nonce = UuidGenerator.v4();
    final sentAt = _now().toUtc().toIso8601String();
    final ivB64 = base64Encode(ivBytes);
    final cipherB64 = encrypted.base64;

    final canonical = [
      snapshot.workspaceId,
      snapshot.senderDeviceId,
      sentAt,
      nonce,
      ivB64,
      cipherB64,
    ].join('|');

    final mac = Hmac(sha256, macKey).convert(utf8.encode(canonical)).toString();

    return jsonEncode({
      'v': 1,
      'wid': snapshot.workspaceId,
      'did': snapshot.senderDeviceId,
      'ts': sentAt,
      'nonce': nonce,
      'iv': ivB64,
      'ct': cipherB64,
      'mac': mac,
    });
  }

  SyncSnapshot decryptEnvelope({
    required String rawEnvelope,
    required String expectedWorkspaceId,
    required String workspaceKey,
  }) {
    final Map<String, dynamic> envelope;
    try {
      final decoded = jsonDecode(rawEnvelope);
      if (decoded is! Map<String, dynamic>) {
        throw const SyncCryptoException('Invalid sync envelope format.');
      }
      envelope = decoded;
    } catch (e) {
      if (e is SyncCryptoException) rethrow;
      throw const SyncCryptoException('Malformed JSON in sync envelope.');
    }

    final workspaceId = envelope['wid'] as String?;
    final senderDeviceId = envelope['did'] as String?;
    final tsRaw = envelope['ts'] as String?;
    final nonce = envelope['nonce'] as String?;
    final ivB64 = envelope['iv'] as String?;
    final cipherB64 = envelope['ct'] as String?;
    final mac = envelope['mac'] as String?;

    if (workspaceId == null ||
        senderDeviceId == null ||
        tsRaw == null ||
        nonce == null ||
        ivB64 == null ||
        cipherB64 == null ||
        mac == null) {
      throw const SyncCryptoException('Incomplete sync envelope headers.');
    }

    if (workspaceId != expectedWorkspaceId) {
      throw const SyncCryptoException('Workspace ID mismatch.');
    }

    final sentAt = DateTime.tryParse(tsRaw)?.toUtc();
    if (sentAt == null) {
      throw const SyncCryptoException('Invalid sync timestamp.');
    }

    final delta = _now().toUtc().difference(sentAt).abs();
    if (delta > replayWindow) {
      throw const SyncCryptoException('Sync envelope timestamp outside replay window.');
    }

    if (!_seenNonces.add('$senderDeviceId:$nonce')) {
      throw const SyncCryptoException('Duplicate sync nonce detected.');
    }
    if (_seenNonces.length > 500) {
      _seenNonces.remove(_seenNonces.first);
    }

    final canonical = [
      workspaceId,
      senderDeviceId,
      tsRaw,
      nonce,
      ivB64,
      cipherB64,
    ].join('|');

    final macKey = _deriveMacKey(workspaceKey);
    final expectedMac =
        Hmac(sha256, macKey).convert(utf8.encode(canonical)).toString();

    if (!_constantTimeEquals(mac, expectedMac)) {
      throw const SyncCryptoException('Sync envelope authentication failed.');
    }

    try {
      final keyBytes = _deriveEncKey(workspaceKey);
      final iv = enc.IV(base64Decode(ivB64));
      final encrypter = enc.Encrypter(
        enc.AES(enc.Key(keyBytes), mode: enc.AESMode.cbc),
      );
      final plaintext = encrypter.decrypt64(cipherB64, iv: iv);
      final decoded = jsonDecode(plaintext) as Map<String, dynamic>;
      final snapshot = SyncSnapshot.fromMap(decoded);

      if (snapshot.workspaceId != expectedWorkspaceId ||
          snapshot.senderDeviceId != senderDeviceId) {
        throw const SyncCryptoException('Sync payload identity mismatch.');
      }

      return snapshot;
    } catch (e) {
      if (e is SyncCryptoException) rethrow;
      throw const SyncCryptoException('Failed to decrypt sync payload.');
    }
  }

  Uint8List _deriveEncKey(String workspaceKey) {
    final digest = sha256.convert(utf8.encode('synprod:enc:$workspaceKey'));
    return Uint8List.fromList(digest.bytes);
  }

  List<int> _deriveMacKey(String workspaceKey) {
    return sha256.convert(utf8.encode('synprod:mac:$workspaceKey')).bytes;
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
