import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/synprod_pin_pad.dart';
import '../../widgets/synprod_ui.dart';

class PinLockScreen extends ConsumerStatefulWidget {
  const PinLockScreen({super.key});

  @override
  ConsumerState<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends ConsumerState<PinLockScreen> {
  String? _error;
  int _pinResetNonce = 0;
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
    super.dispose();
  }

  Future<void> _submitPin(String pin) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });

    final result =
        await ref.read(authControllerProvider.notifier).unlockWithPin(pin);
    if (!mounted) return;

    setState(() => _isBusy = false);
    if (!result.success) {
      _updateLockoutState();
      setState(() {
        _pinResetNonce++;
        _error = result.errorMessage ?? 'Incorrect PIN.';
      });
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
                        SynProdPinPad(
                          key: ValueKey('lock-pin-$_pinResetNonce'),
                          title: 'Enter Device PIN',
                          subtitle: 'Enter your 6-digit PIN to unlock.',
                          submitLabel: _lockoutRemaining != null
                              ? 'Locked (${_lockoutRemaining!.inSeconds}s)'
                              : (_isBusy ? 'Unlocking...' : 'Unlock'),
                          submitIcon: Icons.lock_open,
                          enabled: _lockoutRemaining == null,
                          isBusy: _isBusy,
                          errorText: _error,
                          onSubmit: _submitPin,
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
