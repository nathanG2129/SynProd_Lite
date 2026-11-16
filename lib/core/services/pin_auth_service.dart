import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinVerificationResult {
  final bool success;
  final Duration? lockoutRemaining;
  final int failedAttempts;
  final String? errorMessage;

  const PinVerificationResult({
    required this.success,
    this.lockoutRemaining,
    this.failedAttempts = 0,
    this.errorMessage,
  });
}

class PinAuthService {
  static const String _keyLocalDeviceId = 'synprod_local_device_id';
  static const String _keyPinHash = 'synprod_pin_hash';
  static const String _keyPinSalt = 'synprod_pin_salt';
  static const String _keyBiometricEnabled = 'synprod_biometric_enabled';
  static const String _keyFailedAttempts = 'synprod_pin_failed_attempts';
  static const String _keyLockoutUntil = 'synprod_pin_lockout_until';

  static const int minPinLength = 6;
  static const int maxPinLength = 6;
  static const int freeAttemptsBeforeLockout = 5;

  final SharedPreferences _prefs;
  final LocalAuthentication _localAuth;
  final DateTime Function() _now;

  PinAuthService({
    required SharedPreferences prefs,
    LocalAuthentication? localAuth,
    DateTime Function()? now,
  })  : _prefs = prefs,
        _localAuth = localAuth ?? LocalAuthentication(),
        _now = now ?? DateTime.now;

  static bool isValidPinFormat(String pin) {
    if (pin.length < minPinLength || pin.length > maxPinLength) return false;
    return RegExp(r'^\d+$').hasMatch(pin);
  }

  String? getLocalDeviceId() => _prefs.getString(_keyLocalDeviceId);

  Future<void> setLocalDeviceId(String deviceId) async {
    await _prefs.setString(_keyLocalDeviceId, deviceId);
  }

  bool hasPinConfigured() {
    final hash = _prefs.getString(_keyPinHash);
    final salt = _prefs.getString(_keyPinSalt);
    return hash != null && hash.isNotEmpty && salt != null && salt.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    if (!isValidPinFormat(pin)) {
      throw ArgumentError('PIN must be 6 digits.');
    }
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await _prefs.setString(_keyPinSalt, salt);
    await _prefs.setString(_keyPinHash, hash);
    await resetLockout();
  }

  Duration? getLockoutRemaining() {
    final lockoutMillis = _prefs.getInt(_keyLockoutUntil);
    if (lockoutMillis == null) return null;
    final lockoutUntil = DateTime.fromMillisecondsSinceEpoch(lockoutMillis);
    final remaining = lockoutUntil.difference(_now());
    if (remaining <= Duration.zero) {
      return null;
    }
    return remaining;
  }

  int getFailedAttempts() => _prefs.getInt(_keyFailedAttempts) ?? 0;

  Future<PinVerificationResult> verifyPin(String pin) async {
    final remaining = getLockoutRemaining();
    if (remaining != null) {
      return PinVerificationResult(
        success: false,
        lockoutRemaining: remaining,
        failedAttempts: getFailedAttempts(),
        errorMessage:
            'Too many failed attempts. Try again in ${_formatDuration(remaining)}.',
      );
    }

    final salt = _prefs.getString(_keyPinSalt);
    final expectedHash = _prefs.getString(_keyPinHash);
    if (salt == null || expectedHash == null) {
      return const PinVerificationResult(
        success: false,
        errorMessage: 'No PIN configured on this device.',
      );
    }

    final actualHash = _hashPin(pin, salt);
    if (actualHash == expectedHash) {
      await resetLockout();
      return const PinVerificationResult(success: true);
    }

    final attempts = getFailedAttempts() + 1;
    await _prefs.setInt(_keyFailedAttempts, attempts);

    final lockoutDuration = _lockoutDurationForAttempts(attempts);
    if (lockoutDuration != null) {
      final until = _now().add(lockoutDuration);
      await _prefs.setInt(_keyLockoutUntil, until.millisecondsSinceEpoch);
      return PinVerificationResult(
        success: false,
        lockoutRemaining: lockoutDuration,
        failedAttempts: attempts,
        errorMessage:
            'Incorrect PIN. Locked for ${_formatDuration(lockoutDuration)}.',
      );
    }

    final remainingBeforeLock = freeAttemptsBeforeLockout - attempts;
    return PinVerificationResult(
      success: false,
      failedAttempts: attempts,
      errorMessage:
          'Incorrect PIN ($remainingBeforeLock attempt${remainingBeforeLock == 1 ? '' : 's'} remaining before lockout).',
    );
  }

  Future<void> resetLockout() async {
    await _prefs.remove(_keyFailedAttempts);
    await _prefs.remove(_keyLockoutUntil);
  }

  bool isBiometricEnabled() => _prefs.getBool(_keyBiometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_keyBiometricEnabled, enabled);
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    if (!isBiometricEnabled()) return false;
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Unlock SynProd Lite',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  Future<void> clearAllAuthData() async {
    await _prefs.remove(_keyLocalDeviceId);
    await _prefs.remove(_keyPinHash);
    await _prefs.remove(_keyPinSalt);
    await _prefs.remove(_keyBiometricEnabled);
    await resetLockout();
  }

  Duration? _lockoutDurationForAttempts(int attempts) {
    if (attempts < freeAttemptsBeforeLockout) return null;
    switch (attempts) {
      case 5:
        return const Duration(seconds: 30);
      case 6:
        return const Duration(minutes: 1);
      case 7:
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 15);
    }
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  String _hashPin(String pin, String salt) {
    final bytes = utf8.encode('$salt:$pin');
    return sha256.convert(bytes).toString();
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes >= 1) {
      final mins = duration.inMinutes;
      final secs = duration.inSeconds % 60;
      return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
    }
    return '${duration.inSeconds}s';
  }
}
