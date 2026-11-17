import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

import '../../domain/models/device.dart';
import '../../domain/models/product.dart';
import '../../domain/models/product_type.dart';
import '../../domain/models/workspace.dart';

class WorkspaceBackupBundle {
  final Workspace workspace;
  final List<Device> devices;
  final List<Product> products;
  final List<ProductType> productTypes;
  final DateTime exportedAt;

  const WorkspaceBackupBundle({
    required this.workspace,
    required this.devices,
    required this.products,
    this.productTypes = const [],
    required this.exportedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'version': 1,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'workspace': workspace.toMap(),
      'devices': devices.map((d) => d.toMap()).toList(),
      'products': products.map((p) => p.toMap()).toList(),
      'productTypes': productTypes.map((t) => t.toMap()).toList(),
    };
  }

  factory WorkspaceBackupBundle.fromMap(Map<String, dynamic> map) {
    final workspace =
        Workspace.fromMap(map['workspace'] as Map<String, dynamic>);
    final devicesRaw = (map['devices'] as List<dynamic>? ?? []);
    final productsRaw = (map['products'] as List<dynamic>? ?? []);
    final productTypesRaw = (map['productTypes'] as List<dynamic>? ?? []);
    return WorkspaceBackupBundle(
      workspace: workspace,
      devices: devicesRaw
          .map((e) => Device.fromMap(e as Map<String, dynamic>))
          .toList(),
      products: productsRaw
          .map((e) => Product.fromMap(e as Map<String, dynamic>))
          .toList(),
      productTypes: productTypesRaw
          .map((e) => ProductType.fromMap(e as Map<String, dynamic>))
          .toList(),
      exportedAt: DateTime.parse(map['exportedAt'] as String),
    );
  }
}

class WorkspaceBackupException implements Exception {
  final String message;
  const WorkspaceBackupException(this.message);

  @override
  String toString() => message;
}

class WorkspaceBackupService {
  static const int _pbkdf2Iterations = 20000;
  static const int _saltLength = 16;
  static const int _ivLength = 16;

  String encryptBundle({
    required WorkspaceBackupBundle bundle,
    required String password,
  }) {
    if (password.length < 6) {
      throw const WorkspaceBackupException(
        'Backup password must be at least 6 characters.',
      );
    }

    final random = Random.secure();
    final salt =
        Uint8List.fromList(List<int>.generate(_saltLength, (_) => random.nextInt(256)));
    final ivBytes =
        Uint8List.fromList(List<int>.generate(_ivLength, (_) => random.nextInt(256)));

    final derived = _deriveKeys(password, salt);
    final encKey = enc.Key(derived.sublist(0, 32));
    final macKey = derived.sublist(32, 64);

    final iv = enc.IV(ivBytes);
    final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
    final plaintext = jsonEncode(bundle.toMap());
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    final macInput = <int>[...salt, ...ivBytes, ...encrypted.bytes];
    final mac = Hmac(sha256, macKey).convert(macInput).bytes;

    return jsonEncode({
      'format': 'synprod-backup-v1',
      'kdf': 'pbkdf2-sha256',
      'iter': _pbkdf2Iterations,
      'salt': base64Encode(salt),
      'iv': base64Encode(ivBytes),
      'ct': encrypted.base64,
      'mac': base64Encode(mac),
    });
  }

  WorkspaceBackupBundle decryptBundle({
    required String rawContent,
    required String password,
  }) {
    try {
      final envelope = jsonDecode(rawContent);
      if (envelope is! Map<String, dynamic> ||
          envelope['format'] != 'synprod-backup-v1') {
        throw const WorkspaceBackupException('Invalid SynProd backup file.');
      }

      final iterations = (envelope['iter'] as num?)?.toInt() ?? _pbkdf2Iterations;
      final salt = base64Decode(envelope['salt'] as String);
      final ivBytes = base64Decode(envelope['iv'] as String);
      final ctBase64 = envelope['ct'] as String;
      final ctBytes = base64Decode(ctBase64);
      final expectedMac = base64Decode(envelope['mac'] as String);

      final derived = _deriveKeys(password, salt, iterations: iterations);
      final encKey = enc.Key(derived.sublist(0, 32));
      final macKey = derived.sublist(32, 64);

      final macInput = <int>[...salt, ...ivBytes, ...ctBytes];
      final actualMac = Hmac(sha256, macKey).convert(macInput).bytes;
      if (!_constantTimeBytesEqual(actualMac, expectedMac)) {
        throw const WorkspaceBackupException(
          'Incorrect backup password or corrupted file.',
        );
      }

      final encrypter = enc.Encrypter(enc.AES(encKey, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decrypt64(ctBase64, iv: enc.IV(ivBytes));
      final map = jsonDecode(decrypted) as Map<String, dynamic>;
      return WorkspaceBackupBundle.fromMap(map);
    } on WorkspaceBackupException {
      rethrow;
    } catch (_) {
      throw const WorkspaceBackupException(
        'Failed to decrypt workspace backup. Check the file and password.',
      );
    }
  }

  Uint8List _deriveKeys(
    String password,
    List<int> salt, {
    int iterations = _pbkdf2Iterations,
  }) {
    final passwordBytes = utf8.encode(password);
    final hmac = Hmac(sha256, passwordBytes);
    final output = BytesBuilder();

    // Derive 64 bytes (2 blocks of 32 bytes for SHA-256)
    for (var blockIndex = 1; blockIndex <= 2; blockIndex++) {
      final blockSalt = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt)
        ..[salt.length] = (blockIndex >> 24) & 0xff
        ..[salt.length + 1] = (blockIndex >> 16) & 0xff
        ..[salt.length + 2] = (blockIndex >> 8) & 0xff
        ..[salt.length + 3] = blockIndex & 0xff;

      var u = Uint8List.fromList(hmac.convert(blockSalt).bytes);
      final t = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      output.add(t);
    }

    return output.toBytes();
  }

  bool _constantTimeBytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
