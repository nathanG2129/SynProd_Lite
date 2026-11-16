import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/synprod_ui.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  final _pinCtrl = TextEditingController();
  String? _error;
  bool _isBusy = false;
  bool _biometricsAvailable = false;
  Timer? _lockoutTimer;
  Duration? _lockoutRemaining;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAndLockout();
  }

  Future<void> _checkBiometricsAndLockout() async {
    final pinService = ref.read(pinAuthServiceProvider);
    _updateLockoutState();
    final available =
        pinService.isBiometricEnabled() && await pinService.isBiometricAvailable();
    if (mounted) {
      setState(() => _biometricsAvailable = available);
    }
  }

  void _updateLockoutState() {
    final remaining = ref.read(pinAuthServiceProvider).getLockoutRemaining();
    _lockoutTimer?.cancel();
    if (remaining != null) {
      setState(() => _lockoutRemaining = remaining);
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final next = ref.read(pinAuthServiceProvider).getLockoutRemaining();
        if (next == null) {
          _lockoutTimer?.cancel();
          setState(() {
            _lockoutRemaining = null;
            _error = null;
          });
        } else {
          setState(() => _lockoutRemaining = next);
        }
      });
    } else {
      setState(() => _lockoutRemaining = null);
    }
  }

  @override
  void dispose() {
    _lockoutTimer?.cancel();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPin() async {
    final pin = _pinCtrl.text.trim();
    if (pin.length < 4) {
      setState(() => _error = 'Enter your 4–6 digit PIN.');
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
    });

    final result =
        await ref.read(authControllerProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;

    setState(() => _isBusy = false);
    if (!result.success) {
      _pinCtrl.clear();
      _updateLockoutState();
      setState(() => _error = result.errorMessage ?? 'Incorrect PIN.');
    }
  }

  Future<void> _unlockBiometric() async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    final ok =
        await ref.read(authControllerProvider.notifier).unlockWithBiometrics();
    if (!mounted) return;
    setState(() => _isBusy = false);
    if (!ok) {
      setState(() => _error = 'Biometric unlock cancelled or failed. Use PIN.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final device = authState.device;
    final workspace = authState.workspace;
    final isRevoked = authState.status == AuthStatus.revoked;

    return Scaffold(
      body: SynProdCanvas(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: SynProdCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: SynProdAvatar(
                          displayName: device?.displayName ?? 'Device',
                          size: 52,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: SynProdGradientText(
                          'SynProd Lite',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (workspace != null) ...[
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            workspace.name,
                            style: const TextStyle(
                              color: AppTheme.oliveMuted,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      if (device != null) ...[
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            '${device.displayName} • ${device.role.displayName}',
                            style: TextStyle(
                              color: AppTheme.mutedTextFor(context),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      if (isRevoked) ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.errorBgFor(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.inputErrorBorder),
                          ),
                          child: Text(
                            'This device has been revoked by an Administrator. Ask an Admin to restore or re-pair this device.',
                            style: TextStyle(
                              color: AppTheme.errorTextFor(context),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ] else ...[
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.errorBgFor(context),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.inputErrorBorder),
                            ),
                            child: Text(
                              _error!,
                              style: TextStyle(
                                color: AppTheme.errorTextFor(context),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: _pinCtrl,
                          obscureText: true,
                          enabled: !_isBusy && _lockoutRemaining == null,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            letterSpacing: 8,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Enter Device PIN',
                            counterText: '',
                          ),
                          onSubmitted: (_) => _submitPin(),
                        ),
                        const SizedBox(height: 16),
                        SynProdGradientButton(
                          onPressed: (_isBusy || _lockoutRemaining != null)
                              ? null
                              : _submitPin,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lock_open, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _lockoutRemaining != null
                                    ? 'Locked (${_lockoutRemaining!.inSeconds}s)'
                                    : (_isBusy ? 'Unlocking...' : 'Unlock'),
                              ),
                            ],
                          ),
                        ),
                        if (_biometricsAvailable) ...[
                          const SizedBox(height: 12),
                          SynProdSecondaryButton(
                            onPressed: _isBusy ? null : _unlockBiometric,
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fingerprint, size: 18),
                                SizedBox(width: 8),
                                Text('Use Biometrics'),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
