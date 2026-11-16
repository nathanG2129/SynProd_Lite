import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/services/pin_auth_service.dart';
import '../../../core/services/qr_pairing_service.dart';
import '../../../core/services/workspace_backup_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/synprod_pin_pad.dart';
import '../../widgets/synprod_ui.dart';

enum _OnboardingMode { choose, createAdmin, createAdminPin, joinQr, restoreBackup }

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _OnboardingMode _mode = _OnboardingMode.choose;
  bool _isBusy = false;
  String? _error;

  // Create Admin controllers
  final _workspaceNameCtrl = TextEditingController();
  final _deviceNameCtrl = TextEditingController();
  String? _pendingAdminPin;
  int _pinMismatchCount = 0;

  // PIN controllers (shared across flows)
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  // QR Join state
  final _qrRawCtrl = TextEditingController();
  QrPairingPayload? _validatedQr;

  // Restore Backup state
  String? _backupFileContent;
  String? _backupFileName;
  final _backupPasswordCtrl = TextEditingController();

  @override
  void dispose() {
    _workspaceNameCtrl.dispose();
    _deviceNameCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    _qrRawCtrl.dispose();
    _backupPasswordCtrl.dispose();
    super.dispose();
  }

  void _switchMode(_OnboardingMode mode) {
    setState(() {
      _mode = mode;
      _error = null;
      _pendingAdminPin = null;
      _pinCtrl.clear();
      _confirmPinCtrl.clear();
    });
  }

  void _handleBack() {
    if (_mode == _OnboardingMode.createAdminPin) {
      if (_pendingAdminPin != null) {
        setState(() {
          _pendingAdminPin = null;
          _error = null;
        });
      } else {
        setState(() {
          _mode = _OnboardingMode.createAdmin;
          _error = null;
        });
      }
      return;
    }
    _switchMode(_OnboardingMode.choose);
  }

  String? _validatePinFields() {
    final pin = _pinCtrl.text.trim();
    final confirm = _confirmPinCtrl.text.trim();
    if (!PinAuthService.isValidPinFormat(pin)) {
      return 'PIN must be 4 to 6 digits.';
    }
    if (pin != confirm) {
      return 'PINs do not match.';
    }
    return null;
  }

  void _continueToAdminPin() {
    final workspaceName = _workspaceNameCtrl.text.trim();
    final deviceName = _deviceNameCtrl.text.trim();
    if (workspaceName.isEmpty) {
      setState(() => _error = 'Workspace name is required.');
      return;
    }
    if (deviceName.isEmpty) {
      setState(() => _error = 'Device display name is required.');
      return;
    }
    setState(() {
      _mode = _OnboardingMode.createAdminPin;
      _pendingAdminPin = null;
      _error = null;
    });
  }

  Future<void> _submitCreateAdminWithPin(String pin) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).createWorkspaceAndAdmin(
            workspaceName: _workspaceNameCtrl.text.trim(),
            displayName: _deviceNameCtrl.text.trim(),
            pin: pin,
          );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _validateQrString(String raw) {
    final result = ref.read(qrPairingServiceProvider).validateRawPayload(raw);
    if (!result.isValid) {
      setState(() {
        _validatedQr = null;
        _error = result.errorMessage;
      });
      return;
    }
    setState(() {
      _validatedQr = result.payload;
      _error = null;
    });
  }

  Future<void> _openQrScanner() async {
    final scanned = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.72,
        child: Column(
          children: [
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: AppTheme.brandHeadingGradient,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.cardColorFor(ctx),
                border: Border(
                  bottom: BorderSide(
                    color: AppTheme.isDark(ctx)
                        ? AppTheme.darkOliveAccent
                        : AppTheme.forestGreen,
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    color: AppTheme.headingColorFor(ctx),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Scan Pairing QR Code',
                      style: TextStyle(
                        color: AppTheme.headingColorFor(ctx),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.headingColorFor(ctx),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MobileScanner(
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    final raw = barcode.rawValue;
                    if (raw != null && raw.isNotEmpty) {
                      Navigator.of(ctx).pop(raw);
                      break;
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
    if (scanned != null && mounted) {
      _qrRawCtrl.text = scanned;
      _validateQrString(scanned);
    }
  }

  Future<void> _submitJoinQr() async {
    final payload = _validatedQr;
    if (payload == null) {
      setState(() => _error = 'Please scan or paste a valid QR pairing code.');
      return;
    }
    final pinErr = _validatePinFields();
    if (pinErr != null) {
      setState(() => _error = pinErr);
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).completeQrPairing(
            payload: payload,
            pin: _pinCtrl.text.trim(),
          );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      String? content;
      if (file.bytes != null) {
        content = String.fromCharCodes(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      }
      if (content != null && mounted) {
        setState(() {
          _backupFileContent = content;
          _backupFileName = file.name;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not read backup file: $e');
    }
  }

  Future<void> _submitRestoreBackup() async {
    final raw = _backupFileContent;
    if (raw == null || raw.isEmpty) {
      setState(() => _error = 'Please select a .synprod backup file.');
      return;
    }
    final password = _backupPasswordCtrl.text;
    if (password.isEmpty) {
      setState(() => _error = 'Backup password is required.');
      return;
    }
    final pinErr = _validatePinFields();
    if (pinErr != null) {
      setState(() => _error = pinErr);
      return;
    }

    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final bundle = ref.read(workspaceBackupServiceProvider).decryptBundle(
            rawContent: raw,
            password: password,
          );
      await ref.read(authControllerProvider.notifier).restoreAdminBackup(
            bundle: bundle,
            pin: _pinCtrl.text.trim(),
          );
    } on WorkspaceBackupException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SynProdCanvas(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: SynProdCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (_mode != _OnboardingMode.choose)
                            IconButton(
                              onPressed: _isBusy ? null : _handleBack,
                              icon: const Icon(Icons.arrow_back),
                              color: AppTheme.headingColorFor(context),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SynProdGradientText(
                                  'SynProd Lite',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  _subtitleForMode(),
                                  style: TextStyle(
                                    color: AppTheme.isDark(context)
                                        ? AppTheme.slate400
                                        : AppTheme.oliveMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_error != null &&
                          _mode != _OnboardingMode.createAdminPin) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
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
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_mode == _OnboardingMode.choose) _buildChooseMode(),
                      if (_mode == _OnboardingMode.createAdmin)
                        _buildCreateAdminForm(),
                      if (_mode == _OnboardingMode.createAdminPin)
                        _buildCreateAdminPinStep(),
                      if (_mode == _OnboardingMode.joinQr) _buildJoinQrForm(),
                      if (_mode == _OnboardingMode.restoreBackup)
                        _buildRestoreBackupForm(),
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

  String _subtitleForMode() {
    switch (_mode) {
      case _OnboardingMode.choose:
        return 'Offline Device Setup';
      case _OnboardingMode.createAdmin:
        return 'Create Workspace (Admin Device)';
      case _OnboardingMode.createAdminPin:
        return 'Set Device PIN';
      case _OnboardingMode.joinQr:
        return 'Join Workspace via QR Pairing';
      case _OnboardingMode.restoreBackup:
        return 'Restore Encrypted Admin Backup';
    }
  }

  Widget _buildChooseMode() {
    final isDark = AppTheme.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Scan a pairing QR code from an Admin device to join your team's offline workspace.",
          style: TextStyle(
            color: AppTheme.mutedTextFor(context),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        SynProdGradientButton(
          onPressed: () => _switchMode(_OnboardingMode.joinQr),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Join Existing Workspace (Scan QR)',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => _switchMode(_OnboardingMode.createAdmin),
            style: TextButton.styleFrom(
              foregroundColor:
                  isDark ? AppTheme.slate300 : AppTheme.oliveMuted,
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            child: const Text('Create New Workspace (Admin)'),
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: () => _switchMode(_OnboardingMode.restoreBackup),
            icon: const Icon(Icons.restore_outlined, size: 16),
            label: const Text('Restore Admin Workspace from Backup'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.headingColorFor(context),
              textStyle: const TextStyle(fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAdminForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _workspaceNameCtrl,
          decoration: const InputDecoration(
            labelText: 'Workspace Name *',
            hintText: 'e.g. Main Production Facility',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _deviceNameCtrl,
          decoration: const InputDecoration(
            labelText: 'This Device Name *',
            hintText: 'e.g. Admin Tablet',
          ),
        ),
        const SizedBox(height: 20),
        SynProdGradientButton(
          onPressed: _isBusy ? null : _continueToAdminPin,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_forward, size: 18),
              SizedBox(width: 8),
              Text('Continue'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateAdminPinStep() {
    final isConfirmStep = _pendingAdminPin != null;
    return SynProdPinPad(
      key: ValueKey('admin-pin-$isConfirmStep-$_pinMismatchCount'),
      title: isConfirmStep ? 'Confirm Device PIN' : 'Create Device PIN',
      subtitle: isConfirmStep
          ? 'Re-enter your PIN to confirm.'
          : 'Enter a 4–6 digit PIN to lock this device.',
      submitLabel: isConfirmStep
          ? (_isBusy ? 'Creating...' : 'Create Workspace')
          : 'Next',
      submitIcon:
          isConfirmStep ? Icons.check_circle_outline : Icons.arrow_forward,
      isBusy: _isBusy,
      errorText: _error,
      onSubmit: (pin) {
        if (!isConfirmStep) {
          setState(() {
            _pendingAdminPin = pin;
            _pinMismatchCount = 0;
            _error = null;
          });
          return;
        }
        if (pin != _pendingAdminPin) {
          setState(() {
            _pinMismatchCount++;
            _error = 'PINs do not match. Try again.';
          });
          return;
        }
        _submitCreateAdminWithPin(pin);
      },
    );
  }

  Widget _buildJoinQrForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SynProdSecondaryButton(
          onPressed: _isBusy ? null : _openQrScanner,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.qr_code_scanner, size: 18),
              SizedBox(width: 8),
              Text('Scan QR Code with Camera'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _qrRawCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Or Paste Pairing Payload',
            hintText: '{"v":1,"wid":...}',
          ),
          onChanged: (val) {
            if (val.trim().startsWith('{')) {
              _validateQrString(val);
            }
          },
        ),
        if (_validatedQr != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successBgFor(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryOlive),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Workspace: ${_validatedQr!.workspaceName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.successTextFor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Device: ${_validatedQr!.displayName} • Role: ${_validatedQr!.role.displayName}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.successTextFor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _buildPinInputs(),
          const SizedBox(height: 20),
          SynProdGradientButton(
            onPressed: _isBusy ? null : _submitJoinQr,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.link, size: 18),
                const SizedBox(width: 8),
                Text(_isBusy ? 'Pairing...' : 'Complete Pairing'),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRestoreBackupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SynProdSecondaryButton(
          onPressed: _isBusy ? null : _pickBackupFile,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.upload_file, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _backupFileName ?? 'Select Encrypted Backup (.synprod)',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _backupPasswordCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Backup Password *',
          ),
        ),
        const SizedBox(height: 14),
        _buildPinInputs(pinLabel: 'New Device PIN (4–6 digits) *'),
        const SizedBox(height: 20),
        SynProdGradientButton(
          onPressed: _isBusy ? null : _submitRestoreBackup,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.restore, size: 18),
              const SizedBox(width: 8),
              Text(_isBusy ? 'Restoring...' : 'Restore Workspace'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPinInputs({String pinLabel = 'Device PIN (4–6 digits) *'}) {
    return Column(
      children: [
        TextField(
          controller: _pinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: pinLabel,
            counterText: '',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _confirmPinCtrl,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            labelText: 'Confirm PIN *',
            counterText: '',
          ),
        ),
      ],
    );
  }
}
