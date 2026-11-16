import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/pin_auth_service.dart';
import '../../../core/services/workspace_backup_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/device.dart';
import '../../providers/auth_providers.dart';
import '../../providers/device_providers.dart';
import '../../providers/product_providers.dart';
import '../../providers/theme_providers.dart';
import '../../widgets/synprod_ui.dart';

class DeviceProfileScreen extends ConsumerStatefulWidget {
  const DeviceProfileScreen({super.key});

  @override
  ConsumerState<DeviceProfileScreen> createState() =>
      _DeviceProfileScreenState();
}

class _DeviceProfileScreenState extends ConsumerState<DeviceProfileScreen> {
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

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

  Future<void> _showChangePinDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    await showSynProdDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SynProdDialog(
          icon: Icons.pin_outlined,
          title: 'Change Device PIN',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: currentCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Current PIN',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'New PIN (4–6 digits)',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Confirm New PIN',
                  counterText: '',
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
                final pinService = ref.read(pinAuthServiceProvider);
                final verify =
                    await pinService.verifyPin(currentCtrl.text.trim());
                if (!verify.success) {
                  setDialogState(
                    () => error = verify.errorMessage ?? 'Incorrect current PIN.',
                  );
                  return;
                }
                final nextPin = newCtrl.text.trim();
                if (!PinAuthService.isValidPinFormat(nextPin)) {
                  setDialogState(
                    () => error = 'New PIN must be 4 to 6 digits.',
                  );
                  return;
                }
                if (nextPin != confirmCtrl.text.trim()) {
                  setDialogState(() => error = 'New PINs do not match.');
                  return;
                }
                await pinService.setPin(nextPin);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device PIN updated.')),
                );
              },
              child: const Text('Save PIN'),
            ),
          ],
        ),
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

                final xfile = XFile.fromData(
                  utf8.encode(encrypted),
                  mimeType: 'application/octet-stream',
                  name: 'synprod_workspace_backup.synprod',
                );
                await Share.shareXFiles(
                  [xfile],
                  subject: 'SynProd Workspace Backup (${workspace.name})',
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, size: 18),
                  SizedBox(width: 6),
                  Text('Export & Share'),
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
      appBar: const SynProdAppBar(
        title: SynProdGradientText('Device Profile'),
      ),
      body: SynProdCanvas(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SynProdCard(
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
            ),
            const SizedBox(height: 16),
            SynProdCard(
              padding: const EdgeInsets.all(16),
              child: Column(
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
              ),
            ),
            const SizedBox(height: 16),
            SynProdCard(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                        Icon(Icons.lock_outline, size: 18),
                        SizedBox(width: 8),
                        Text('Lock App Now'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (device.role == DeviceRole.admin) ...[
              const SizedBox(height: 16),
              SynProdCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Admin Recovery',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: headingColor,
                      ),
                    ),
                    const SizedBox(height: 6),
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
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
