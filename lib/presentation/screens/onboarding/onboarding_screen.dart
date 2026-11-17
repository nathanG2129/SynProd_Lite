import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/services/qr_pairing_service.dart';
import '../../../core/services/workspace_backup_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/synprod_pin_pad.dart';
import '../../widgets/synprod_ui.dart';

enum _OnboardingMode {
  choose,
  createAdmin,
  createAdminPin,
  joinQr,
  joinQrPin,
  restoreBackup,
  restoreBackupPin,
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  _OnboardingMode _mode = _OnboardingMode.choose;
  bool _navigatingForward = true;
  bool _isBusy = false;
  String? _error;

  // Create Admin controllers
  final _workspaceNameCtrl = TextEditingController();
  final _deviceNameCtrl = TextEditingController();
  String? _pendingPin;
  int _pinMismatchCount = 0;

  // QR Join state
  final _qrRawCtrl = TextEditingController();
  QrPairingPayload? _validatedQr;

  // Restore Backup state
  String? _backupFileContent;
  String? _backupFileName;
  final _backupPasswordCtrl = TextEditingController();
  WorkspaceBackupBundle? _decryptedBackup;

  @override
  void dispose() {
    _workspaceNameCtrl.dispose();
    _deviceNameCtrl.dispose();
    _qrRawCtrl.dispose();
    _backupPasswordCtrl.dispose();
    super.dispose();
  }

  bool get _isPinMode =>
      _mode == _OnboardingMode.createAdminPin ||
      _mode == _OnboardingMode.joinQrPin ||
      _mode == _OnboardingMode.restoreBackupPin;

  void _switchMode(_OnboardingMode mode, {bool forward = true}) {
    setState(() {
      _navigatingForward = forward;
      _mode = mode;
      _error = null;
      _pendingPin = null;
      _pinMismatchCount = 0;
    });
  }

  void _handleBack() {
    if (_isPinMode) {
      if (_pendingPin != null) {
        setState(() {
          _navigatingForward = false;
          _pendingPin = null;
          _error = null;
        });
        return;
      }
      final parentMode = switch (_mode) {
        _OnboardingMode.createAdminPin => _OnboardingMode.createAdmin,
        _OnboardingMode.joinQrPin => _OnboardingMode.joinQr,
        _OnboardingMode.restoreBackupPin => _OnboardingMode.restoreBackup,
        _ => _OnboardingMode.choose,
      };
      _switchMode(parentMode, forward: false);
      return;
    }
    _switchMode(_OnboardingMode.choose, forward: false);
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
    _switchMode(_OnboardingMode.createAdminPin);
  }

  void _continueToJoinQrPin() {
    if (_validatedQr == null) {
      setState(() => _error = 'Please scan or paste a valid QR pairing code.');
      return;
    }
    _switchMode(_OnboardingMode.joinQrPin);
  }

  void _continueToRestoreBackupPin() {
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
    try {
      final bundle = ref.read(workspaceBackupServiceProvider).decryptBundle(
            rawContent: raw,
            password: password,
          );
      _decryptedBackup = bundle;
      _switchMode(_OnboardingMode.restoreBackupPin);
    } on WorkspaceBackupException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _submitPinForMode(String pin) async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final auth = ref.read(authControllerProvider.notifier);
      switch (_mode) {
        case _OnboardingMode.createAdminPin:
          await auth.createWorkspaceAndAdmin(
            workspaceName: _workspaceNameCtrl.text.trim(),
            displayName: _deviceNameCtrl.text.trim(),
            pin: pin,
          );
        case _OnboardingMode.joinQrPin:
          final payload = _validatedQr;
          if (payload == null) throw StateError('Missing QR payload.');
          await auth.completeQrPairing(payload: payload, pin: pin);
        case _OnboardingMode.restoreBackupPin:
          final bundle = _decryptedBackup;
          if (bundle == null) throw StateError('Missing decrypted backup.');
          await auth.restoreAdminBackup(bundle: bundle, pin: pin);
        default:
          break;
      }
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
    final scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    var hasPopped = false;
    try {
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      onPressed: () {
                        if (hasPopped || !ctx.mounted) return;
                        hasPopped = true;
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MobileScanner(
                  controller: scannerController,
                  errorBuilder: (ctx, error, child) {
                    final message = switch (error.errorCode) {
                      MobileScannerErrorCode.permissionDenied =>
                        'Camera permission denied. Enable camera access in system settings or paste the QR payload manually.',
                      MobileScannerErrorCode.unsupported =>
                        'Camera scanning is not supported on this device. Paste the QR payload manually instead.',
                      _ =>
                        'Unable to start camera (${error.errorDetails?.message ?? error.errorCode.name}). You can close this sheet and paste the QR payload manually.',
                    };
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.videocam_off_outlined,
                              color: Colors.white70,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: Colors.white54),
                              ),
                              onPressed: () {
                                if (hasPopped || !ctx.mounted) return;
                                hasPopped = true;
                                Navigator.of(ctx).pop();
                              },
                              child: const Text('Enter Manually'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onDetect: (capture) {
                    if (hasPopped || !ctx.mounted) return;
                    for (final barcode in capture.barcodes) {
                      final raw = barcode.rawValue;
                      if (raw != null && raw.isNotEmpty) {
                        hasPopped = true;
                        unawaited(scannerController.stop());
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
    } finally {
      await scannerController.dispose();
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
                      if (_error != null && !_isPinMode) ...[
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
                      AnimatedSize(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: Builder(
                          builder: (context) {
                            final activeKey =
                                ValueKey('$_mode-${_pendingPin != null}');
                            return AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              layoutBuilder: (currentChild, previousChildren) {
                                return Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    ...previousChildren,
                                    ?currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (child, animation) {
                                final isIncoming = child.key == activeKey;
                                final beginOffset = isIncoming
                                    ? (_navigatingForward
                                        ? const Offset(0.25, 0)
                                        : const Offset(-0.25, 0))
                                    : (_navigatingForward
                                        ? const Offset(-0.25, 0)
                                        : const Offset(0.25, 0));
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: beginOffset,
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: KeyedSubtree(
                                key: activeKey,
                                child: _buildActiveStep(),
                              ),
                            );
                          },
                        ),
                      ),
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

  Widget _buildActiveStep() {
    switch (_mode) {
      case _OnboardingMode.choose:
        return _buildChooseMode();
      case _OnboardingMode.createAdmin:
        return _buildCreateAdminForm();
      case _OnboardingMode.createAdminPin:
        return _buildTwoStepPinStep(
          confirmLabel: _isBusy ? 'Creating...' : 'Create Workspace',
          confirmIcon: Icons.check_circle_outline,
        );
      case _OnboardingMode.joinQr:
        return _buildJoinQrForm();
      case _OnboardingMode.joinQrPin:
        return _buildTwoStepPinStep(
          confirmLabel: _isBusy ? 'Pairing...' : 'Complete Pairing',
          confirmIcon: Icons.link,
        );
      case _OnboardingMode.restoreBackup:
        return _buildRestoreBackupForm();
      case _OnboardingMode.restoreBackupPin:
        return _buildTwoStepPinStep(
          confirmLabel: _isBusy ? 'Restoring...' : 'Restore Workspace',
          confirmIcon: Icons.restore,
        );
    }
  }

  String _subtitleForMode() {
    switch (_mode) {
      case _OnboardingMode.choose:
        return 'Offline Device Setup';
      case _OnboardingMode.createAdmin:
        return 'Create Workspace (Admin Device)';
      case _OnboardingMode.createAdminPin:
      case _OnboardingMode.joinQrPin:
      case _OnboardingMode.restoreBackupPin:
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
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => _switchMode(_OnboardingMode.createAdmin),
                style: TextButton.styleFrom(
                  foregroundColor:
                      isDark ? AppTheme.slate300 : AppTheme.oliveMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
                child: const Text(
                  'Setup New Workspace',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextButton.icon(
                onPressed: () => _switchMode(_OnboardingMode.restoreBackup),
                icon: const Icon(Icons.restore_outlined, size: 16),
                label: const Text(
                  'Restore Workspace',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.headingColorFor(context),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
            ),
          ],
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

  Widget _buildTwoStepPinStep({
    required String confirmLabel,
    required IconData confirmIcon,
  }) {
    final isConfirmStep = _pendingPin != null;
    return SynProdPinPad(
      key: ValueKey('$_mode-$isConfirmStep-$_pinMismatchCount'),
      title: isConfirmStep ? 'Confirm Device PIN' : 'Create Device PIN',
      subtitle: isConfirmStep
          ? 'Re-enter your 6-digit PIN to confirm.'
          : 'Enter a 6-digit PIN to lock this device.',
      submitLabel: isConfirmStep ? confirmLabel : 'Next',
      submitIcon: isConfirmStep ? confirmIcon : Icons.arrow_forward,
      isBusy: _isBusy,
      errorText: _error,
      onSubmit: (pin) {
        if (!isConfirmStep) {
          setState(() {
            _navigatingForward = true;
            _pendingPin = pin;
            _pinMismatchCount = 0;
            _error = null;
          });
          return;
        }
        if (pin != _pendingPin) {
          setState(() {
            _pinMismatchCount++;
            _error = 'PINs do not match. Try again.';
          });
          return;
        }
        _submitPinForMode(pin);
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
          const SizedBox(height: 20),
          SynProdGradientButton(
            onPressed: _isBusy ? null : _continueToJoinQrPin,
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
        const SizedBox(height: 20),
        SynProdGradientButton(
          onPressed: _isBusy ? null : _continueToRestoreBackupPin,
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
}
