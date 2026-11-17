import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/workspace_backup_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/device.dart';
import '../../../domain/models/workspace.dart';
import '../../providers/auth_providers.dart';
import '../../providers/device_providers.dart';
import '../../providers/product_providers.dart';
import '../../providers/theme_providers.dart';
import '../../widgets/synprod_pin_pad.dart';
import '../../widgets/synprod_ui.dart';
import '../archive/archive_screen.dart';
import '../product_types/product_types_screen.dart';

class DeviceProfileScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const DeviceProfileScreen({super.key, this.embedded = false});

  @override
  ConsumerState<DeviceProfileScreen> createState() =>
      _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends ConsumerState<DeviceProfileScreen> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  final _appearanceKey = GlobalKey();
  final _securityKey = GlobalKey();
  final _adminKey = GlobalKey();
  final _dangerKey = GlobalKey();

  void _scrollToSection(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final pinService = ref.read(pinAuthServiceProvider);
    final available = await pinService.isBiometricAvailable();
    if (mounted) {
      setState(() {
        _biometricAvailable = available;
        _biometricEnabled = pinService.isBiometricEnabled();
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    await ref.read(pinAuthServiceProvider).setBiometricEnabled(value);
    if (mounted) {
      setState(() => _biometricEnabled = value);
    }
  }

  Future<void> _showFactoryResetDialog() async {
    var step = 0; // 0 = warning, 1 = PIN #1, 2 = PIN #2
    String? error;
    var isBusy = false;
    var resetNonce = 0;

    await showSynProdDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (step == 0) {
            return SynProdDialog(
              icon: Icons.warning_amber_rounded,
              title: 'Factory Reset App',
              content: Text(
                'This will permanently erase all recipes, workspace data, paired devices, sync history, and your PIN from this device.\n\nYou will be asked to enter your 6-digit PIN twice to confirm.',
                style: TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.mutedTextFor(context),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                SynProdGradientButton(
                  onPressed: () {
                    setDialogState(() {
                      step = 1;
                      error = null;
                    });
                  },
                  child: const Text('Continue'),
                ),
              ],
            );
          }

          final isSecondStep = step == 2;
          return SynProdDialog(
            onBack: isBusy
                ? null
                : () {
                    if (isSecondStep) {
                      setDialogState(() {
                        step = 1;
                        error = null;
                      });
                    } else {
                      Navigator.of(ctx).pop();
                    }
                  },
            title: 'Factory Reset App',
            content: SynProdPinPad(
              key: ValueKey('factory-reset-$step-$resetNonce'),
              title: isSecondStep
                  ? 'Confirm PIN (2 of 2)'
                  : 'Verify PIN (1 of 2)',
              subtitle: isSecondStep
                  ? 'Re-enter your 6-digit PIN to permanently erase all data.'
                  : 'Enter your 6-digit PIN to authorize factory reset.',
              submitLabel: isSecondStep
                  ? (isBusy ? 'Resetting...' : 'Erase All Data')
                  : 'Next',
              submitIcon:
                  isSecondStep ? Icons.delete_forever : Icons.arrow_forward,
              isBusy: isBusy,
              errorText: error,
              onSubmit: (pin) async {
                setDialogState(() {
                  isBusy = true;
                  error = null;
                });
                final verify =
                    await ref.read(pinAuthServiceProvider).verifyPin(pin);
                if (!ctx.mounted) return;
                if (!verify.success) {
                  setDialogState(() {
                    isBusy = false;
                    resetNonce++;
                    error = verify.errorMessage ?? 'Incorrect PIN.';
                  });
                  return;
                }

                if (!isSecondStep) {
                  setDialogState(() {
                    isBusy = false;
                    step = 2;
                    error = null;
                  });
                  return;
                }

                await ref.read(authControllerProvider.notifier).factoryReset();
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!mounted) return;
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showChangePinDialog() async {
    var step = 0; // 0 = current, 1 = new, 2 = confirm
    String? pendingNewPin;
    String? error;
    var isBusy = false;
    var resetNonce = 0;

    await showSynProdDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final (title, subtitle, submitLabel, submitIcon) = switch (step) {
            0 => (
              'Current Device PIN',
              'Enter your current 6-digit PIN.',
              'Verify',
              Icons.arrow_forward,
            ),
            1 => (
              'New Device PIN',
              'Enter a new 6-digit PIN.',
              'Next',
              Icons.arrow_forward,
            ),
            _ => (
              'Confirm New PIN',
              'Re-enter your new 6-digit PIN.',
              isBusy ? 'Saving...' : 'Save PIN',
              Icons.check_circle_outline,
            ),
          };

          return SynProdDialog(
            onBack: isBusy
                ? null
                : () {
                    if (step > 0) {
                      setDialogState(() {
                        if (step == 2) {
                          step = 1;
                          pendingNewPin = null;
                        } else {
                          step = 0;
                        }
                        error = null;
                      });
                    } else {
                      Navigator.of(ctx).pop();
                    }
                  },
            title: 'Change Device PIN',
            content: SynProdPinPad(
              key: ValueKey('change-pin-$step-$resetNonce'),
              title: title,
              subtitle: subtitle,
              submitLabel: submitLabel,
              submitIcon: submitIcon,
              isBusy: isBusy,
              errorText: error,
              onSubmit: (pin) async {
                final pinService = ref.read(pinAuthServiceProvider);
                if (step == 0) {
                  setDialogState(() {
                    isBusy = true;
                    error = null;
                  });
                  final verify = await pinService.verifyPin(pin);
                  if (!ctx.mounted) return;
                  if (!verify.success) {
                    setDialogState(() {
                      isBusy = false;
                      resetNonce++;
                      error = verify.errorMessage ?? 'Incorrect current PIN.';
                    });
                    return;
                  }
                  setDialogState(() {
                    isBusy = false;
                    step = 1;
                    error = null;
                  });
                  return;
                }

                if (step == 1) {
                  setDialogState(() {
                    pendingNewPin = pin;
                    step = 2;
                    error = null;
                  });
                  return;
                }

                if (pin != pendingNewPin) {
                  setDialogState(() {
                    resetNonce++;
                    error = 'New PINs do not match. Try again.';
                  });
                  return;
                }

                setDialogState(() {
                  isBusy = true;
                  error = null;
                });
                await pinService.setPin(pin);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device PIN updated.')),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showExportBackupDialog() async {
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    await showSynProdDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SynProdDialog(
          icon: Icons.backup_outlined,
          title: 'Export Encrypted Workspace',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create a password-protected backup of your workspace, devices, and recipes.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.mutedTextFor(context),
                ),
              ),
              const SizedBox(height: 12),
              if (error != null) ...[
                Text(
                  error!,
                  style: TextStyle(
                    color: AppTheme.errorTextFor(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Backup Password (min 6 chars)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            SynProdGradientButton(
              onPressed: () async {
                final pwd = passwordCtrl.text;
                if (pwd.length < 6) {
                  setDialogState(
                    () => error = 'Password must be at least 6 characters.',
                  );
                  return;
                }
                if (pwd != confirmCtrl.text) {
                  setDialogState(() => error = 'Passwords do not match.');
                  return;
                }
                final workspace = ref.read(authControllerProvider).workspace;
                if (workspace == null) return;

                final devices =
                    await ref.read(deviceRepositoryProvider).getAllDevices();
                final products =
                    await ref.read(productRepositoryProvider).getActiveProducts();

                final bundle = WorkspaceBackupBundle(
                  workspace: workspace,
                  devices: devices,
                  products: products,
                  exportedAt: DateTime.now(),
                );
                final encrypted = ref
                    .read(workspaceBackupServiceProvider)
                    .encryptBundle(bundle: bundle, password: pwd);

                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();

                final bytes = Uint8List.fromList(utf8.encode(encrypted));
                try {
                  final isMobile = Platform.isAndroid || Platform.isIOS;
                  final outputPath = await FilePicker.platform.saveFile(
                    dialogTitle: 'Save Workspace Backup',
                    fileName: 'synprod_workspace_backup.synprod',
                    type: FileType.custom,
                    allowedExtensions: const ['synprod'],
                    bytes: isMobile ? bytes : null,
                  );
                  if (outputPath == null) return;

                  if (!isMobile) {
                    await File(outputPath).writeAsBytes(bytes);
                  }

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isMobile
                            ? 'Workspace backup saved.'
                            : 'Backup saved to $outputPath',
                      ),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to export backup: $e')),
                  );
                }
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_alt, size: 18),
                  SizedBox(width: 6),
                  Text('Export Backup'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final device = ref.watch(currentDeviceProvider);
    final workspace = authState.workspace;
    final themeMode = ref.watch(themeModeProvider);
    final headingColor = AppTheme.headingColorFor(context);
    final mutedColor = AppTheme.mutedTextFor(context);

    return Scaffold(
      appBar: SynProdAppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const SynProdGradientText('Device Profile'),
      ),
      body: SynProdCanvas(
        child: SynProdCenteredBody(
          maxWidth: 980,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 820;
              final identityCard = _buildIdentityCard(
                context,
                device: device,
                workspace: workspace,
                headingColor: headingColor,
                mutedColor: mutedColor,
              );
              final appearanceContent = _buildAppearanceContent(
                context,
                themeMode: themeMode,
                headingColor: headingColor,
                mutedColor: mutedColor,
              );
              final securityContent = _buildSecurityContent(
                context,
                headingColor: headingColor,
              );
              final adminContent = device.role == DeviceRole.admin
                  ? _buildAdminControlsContent(
                      context,
                      headingColor: headingColor,
                      mutedColor: mutedColor,
                    )
                  : null;
              final dangerContent = _buildDangerZoneContent(
                context,
                mutedColor: mutedColor,
              );

              if (!isDesktop) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    identityCard,
                    const SizedBox(height: 16),
                    SynProdCard(
                      padding: const EdgeInsets.all(16),
                      child: appearanceContent,
                    ),
                    const SizedBox(height: 16),
                    SynProdCard(
                      padding: const EdgeInsets.all(16),
                      child: securityContent,
                    ),
                    if (adminContent != null) ...[
                      const SizedBox(height: 16),
                      SynProdCard(
                        padding: const EdgeInsets.all(16),
                        child: adminContent,
                      ),
                    ],
                    const SizedBox(height: 16),
                    SynProdCard(
                      padding: const EdgeInsets.all(16),
                      child: dangerContent,
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          identityCard,
                          const SizedBox(height: 12),
                          SynProdCard(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              children: [
                                _buildSectionNavTile(
                                  context,
                                  icon: Icons.palette_outlined,
                                  label: 'Appearance',
                                  onTap: () =>
                                      _scrollToSection(_appearanceKey),
                                ),
                                _buildSectionNavTile(
                                  context,
                                  icon: Icons.security_outlined,
                                  label: 'Security & Session',
                                  onTap: () => _scrollToSection(_securityKey),
                                ),
                                if (adminContent != null)
                                  _buildSectionNavTile(
                                    context,
                                    icon: Icons.admin_panel_settings_outlined,
                                    label: 'Admin Controls',
                                    onTap: () => _scrollToSection(_adminKey),
                                  ),
                                _buildSectionNavTile(
                                  context,
                                  icon: Icons.warning_amber_outlined,
                                  label: 'Danger Zone',
                                  isDanger: true,
                                  onTap: () => _scrollToSection(_dangerKey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SynProdCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            KeyedSubtree(
                              key: _appearanceKey,
                              child: appearanceContent,
                            ),
                            const Divider(height: 36),
                            KeyedSubtree(
                              key: _securityKey,
                              child: securityContent,
                            ),
                            if (adminContent != null) ...[
                              const Divider(height: 36),
                              KeyedSubtree(
                                key: _adminKey,
                                child: adminContent,
                              ),
                            ],
                            const Divider(height: 36),
                            KeyedSubtree(
                              key: _dangerKey,
                              child: dangerContent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSectionNavTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger
        ? AppTheme.errorTextFor(context)
        : AppTheme.primaryTextFor(context);
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 19, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildIdentityCard(
    BuildContext context, {
    required Device device,
    required Workspace? workspace,
    required Color headingColor,
    required Color mutedColor,
  }) {
    return SynProdCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SynProdAvatar(displayName: device.displayName, size: 52),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryTextFor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Role: ${device.role.displayName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: headingColor,
                  ),
                ),
                if (workspace != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Workspace: ${workspace.name}',
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceContent(
    BuildContext context, {
    required ThemeMode themeMode,
    required Color headingColor,
    required Color mutedColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Appearance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose how SynProd Lite looks on this device.',
          style: TextStyle(
            fontSize: 13,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              icon: Icon(Icons.brightness_auto_outlined, size: 18),
              label: Text('System'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              icon: Icon(Icons.light_mode_outlined, size: 18),
              label: Text('Light'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              icon: Icon(Icons.dark_mode_outlined, size: 18),
              label: Text('Dark'),
            ),
          ],
          selected: {themeMode},
          onSelectionChanged: (selection) {
            ref
                .read(themeModeProvider.notifier)
                .setThemeMode(selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildSecurityContent(
    BuildContext context, {
    required Color headingColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          Text(
            'Security & Session',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.pin_outlined),
            title: const Text('Change Device PIN'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showChangePinDialog,
          ),
          if (_biometricAvailable)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Unlock'),
              subtitle: const Text(
                'Use fingerprint or face unlock with PIN fallback',
              ),
              value: _biometricEnabled,
              onChanged: _toggleBiometric,
            ),
          const Divider(),
          const SizedBox(height: 8),
          SynProdSecondaryButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).lockNow();
              Navigator.of(context).popUntil((r) => r.isFirst);
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 18),
                SizedBox(width: 8),
                Text('Log Out'),
              ],
            ),
          ),
        ],
      );
  }

  Widget _buildAdminControlsContent(
    BuildContext context, {
    required Color headingColor,
    required Color mutedColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Admin Controls',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: headingColor,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.category_outlined),
          title: const Text('Product Types'),
          subtitle: const Text(
            'Add or edit recipe types, base weights, and packaging units',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProductTypesScreen(),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.archive_outlined),
          title: const Text('Archive'),
          subtitle: const Text(
            'View and restore archived recipes, types, and devices',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ArchiveScreen(),
              ),
            );
          },
        ),
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Export an encrypted workspace backup to restore Admin access on a replacement device.',
          style: TextStyle(
            fontSize: 13,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 14),
        SynProdGradientButton(
          onPressed: _showExportBackupDialog,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.download_outlined, size: 18),
              SizedBox(width: 8),
              Text('Export Encrypted Backup'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDangerZoneContent(
    BuildContext context, {
    required Color mutedColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Danger Zone',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.errorTextFor(context),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Clean all workspace data, recipes, paired devices, and PIN settings from this device.',
          style: TextStyle(
            fontSize: 13,
            color: mutedColor,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _showFactoryResetDialog,
          icon: const Icon(Icons.delete_forever_outlined, size: 18),
          label: const Text('Factory Reset App'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.errorTextFor(context),
            side: BorderSide(color: AppTheme.errorTextFor(context)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
