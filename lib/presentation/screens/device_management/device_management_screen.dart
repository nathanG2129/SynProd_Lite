import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/uuid_generator.dart';
import '../../../domain/models/device.dart';
import '../../providers/auth_providers.dart';
import '../../providers/device_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/synprod_ui.dart';
import '../archive/archive_screen.dart';

enum _DeviceSortField { name, role, pairedAt, lastSeenAt }

class DeviceManagementScreen extends ConsumerStatefulWidget {
  final bool embedded;

  const DeviceManagementScreen({super.key, this.embedded = false});

  @override
  ConsumerState<DeviceManagementScreen> createState() =>
      _DeviceManagementScreenState();
}

class _DeviceManagementScreenState
    extends ConsumerState<DeviceManagementScreen> {
  String _search = '';
  _DeviceSortField _sortField = _DeviceSortField.name;

  @override
  Widget build(BuildContext context) {
    final currentDevice = ref.watch(currentDeviceProvider);

    if (!currentDevice.role.canManageDevices) {
      return Scaffold(
        appBar: SynProdAppBar(
          automaticallyImplyLeading: !widget.embedded,
          title: const SynProdGradientText('Device Management'),
        ),
        body: SynProdCanvas(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SynProdCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 48,
                        color: AppTheme.errorTextFor(context),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Access Denied',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTextFor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Admins only. Only an Administrator device can manage paired devices and roles.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.mutedTextFor(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final devicesAsync = ref.watch(allDevicesProvider);

    return Scaffold(
      appBar: SynProdAppBar(
        automaticallyImplyLeading: !widget.embedded,
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SynProdGradientText('Device Management'),
        ),
        actions: [
          IconButton(
            tooltip: 'View Archive',
            icon: const Icon(Icons.archive_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ArchiveScreen(initialTabIndex: 2),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: SynProdGradientButton(
                onPressed: () => _showAddDeviceDialog(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_2, size: 18),
                    SizedBox(width: 6),
                    Text('Add Device'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SynProdCanvas(
        child: SynProdCenteredBody(
          maxWidth: 920,
          child: devicesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error loading devices: $e')),
          data: (devices) {
            final filtered = _filterAndSort(devices);
            return LayoutBuilder(
              builder: (context, constraints) {
                final isDesktopTable = constraints.maxWidth >= 780;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    SynProdCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Search by device name or role...',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (v) => setState(() => _search = v),
                                ),
                              ),
                              const SizedBox(width: 12),
                              DropdownButton<_DeviceSortField>(
                                value: _sortField,
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _sortField = val);
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(
                                    value: _DeviceSortField.name,
                                    child: Text('Sort: Name'),
                                  ),
                                  DropdownMenuItem(
                                    value: _DeviceSortField.role,
                                    child: Text('Sort: Role'),
                                  ),
                                  DropdownMenuItem(
                                    value: _DeviceSortField.pairedAt,
                                    child: Text('Sort: Paired Date'),
                                  ),
                                  DropdownMenuItem(
                                    value: _DeviceSortField.lastSeenAt,
                                    child: Text('Sort: Last Seen'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Paired Devices (${filtered.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.headingColorFor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      SynProdCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              'No matching devices found.',
                              style: TextStyle(
                                color: AppTheme.mutedTextFor(context),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (!isDesktopTable)
                      ...filtered.map(
                        (device) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildDeviceCard(
                            context,
                            device,
                            currentDevice,
                          ),
                        ),
                      )
                    else
                      SynProdCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            for (var i = 0; i < filtered.length; i++) ...[
                              _buildDesktopDeviceRow(
                                context,
                                filtered[i],
                                currentDevice,
                              ),
                              if (i < filtered.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
        ),
      ),
    );
  }

  List<Device> _filterAndSort(List<Device> devices) {
    final query = _search.trim().toLowerCase();
    final list = devices.where((d) {
      if (d.isRevoked) return false;
      if (query.isEmpty) return true;
      return d.displayName.toLowerCase().contains(query) ||
          d.role.displayName.toLowerCase().contains(query) ||
          d.role.code.toLowerCase().contains(query);
    }).toList();

    list.sort((a, b) {
      switch (_sortField) {
        case _DeviceSortField.name:
          return a.displayName.toLowerCase().compareTo(
                b.displayName.toLowerCase(),
              );
        case _DeviceSortField.role:
          return a.role.code.compareTo(b.role.code);
        case _DeviceSortField.pairedAt:
          return b.pairedAt.compareTo(a.pairedAt);
        case _DeviceSortField.lastSeenAt:
          return b.lastSeenAt.compareTo(a.lastSeenAt);
      }
    });
    return list;
  }

  Widget _buildDeviceCard(
    BuildContext context,
    Device device,
    Device currentDevice,
  ) {
    final isSelf = device.id == currentDevice.id;
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');

    return SynProdCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SynProdAvatar(displayName: device.displayName, size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            device.displayName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryTextFor(context),
                            ),
                          ),
                        ),
                        if (isSelf) ...[
                          const SizedBox(width: 8),
                          Text(
                            '(This Device)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.isDark(context)
                                  ? AppTheme.darkOliveAccent
                                  : AppTheme.oliveMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Paired: ${dateFormat.format(device.pairedAt)} • Last seen: ${dateFormat.format(device.lastSeenAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.mutedTextFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildRoleBadge(context, device),
            ],
          ),
          if (!isSelf) ...[
            const Divider(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (device.role != DeviceRole.admin)
                  OutlinedButton.icon(
                    onPressed: () => _toggleRole(device),
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: Text(
                      device.role == DeviceRole.production
                          ? 'Promote to Manager'
                          : 'Set to Production',
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => _archiveDevice(device),
                  icon: Icon(
                    Icons.archive_outlined,
                    size: 18,
                    color: AppTheme.errorTextFor(context),
                  ),
                  label: Text(
                    'Archive',
                    style: TextStyle(
                      color: AppTheme.errorTextFor(context),
                    ),
                  ),
                ),
                if (device.role != DeviceRole.admin)
                  OutlinedButton.icon(
                    onPressed: () => _showQrCodeDialog(
                      context: context,
                      deviceId: device.id,
                      displayName: device.displayName,
                      role: device.role,
                    ),
                    icon: const Icon(Icons.qr_code, size: 18),
                    label: const Text('Re-pair QR'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopDeviceRow(
    BuildContext context,
    Device device,
    Device currentDevice,
  ) {
    final isSelf = device.id == currentDevice.id;
    final dateFormat = DateFormat('MMM d, yyyy HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SynProdAvatar(displayName: device.displayName, size: 38),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        device.displayName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryTextFor(context),
                        ),
                      ),
                    ),
                    if (isSelf) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(This Device)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.isDark(context)
                              ? AppTheme.darkOliveAccent
                              : AppTheme.oliveMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Paired: ${dateFormat.format(device.pairedAt)} • Last seen: ${dateFormat.format(device.lastSeenAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedTextFor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildRoleBadge(context, device),
          const SizedBox(width: 12),
          if (isSelf)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'Active session',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.mutedTextFor(context),
                ),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (device.role != DeviceRole.admin) ...[
                  OutlinedButton.icon(
                    onPressed: () => _toggleRole(device),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(
                      device.role == DeviceRole.production
                          ? 'Promote'
                          : 'Set Production',
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Re-pair QR',
                    icon: const Icon(Icons.qr_code, size: 20),
                    onPressed: () => _showQrCodeDialog(
                      context: context,
                      deviceId: device.id,
                      displayName: device.displayName,
                      role: device.role,
                    ),
                  ),
                ],
                OutlinedButton.icon(
                  onPressed: () => _archiveDevice(device),
                  icon: Icon(
                    Icons.archive_outlined,
                    size: 16,
                    color: AppTheme.errorTextFor(context),
                  ),
                  label: Text(
                    'Archive',
                    style: TextStyle(
                      color: AppTheme.errorTextFor(context),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(BuildContext context, Device device) {
    final Color bg;
    final Color text;
    final Color border;
    final String label;

    if (device.isRevoked) {
      bg = AppTheme.errorBgFor(context);
      text = AppTheme.errorTextFor(context);
      border = AppTheme.inputErrorBorder;
      label = 'REVOKED';
    } else if (device.role == DeviceRole.admin) {
      bg = AppTheme.successBgFor(context);
      text = AppTheme.headingColorFor(context);
      border = AppTheme.primaryOlive;
      label = 'ADMIN';
    } else if (device.role == DeviceRole.manager) {
      bg = AppTheme.warningBgFor(context);
      text = AppTheme.warningTextFor(context);
      border = AppTheme.amberWarning;
      label = 'MANAGER';
    } else {
      bg = AppTheme.softTintColorFor(context);
      text = AppTheme.headingColorFor(context);
      border = AppTheme.borderFor(context);
      label = 'PRODUCTION';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: text,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Future<void> _toggleRole(Device device) async {
    final nextRole = device.role == DeviceRole.production
        ? DeviceRole.manager
        : DeviceRole.production;
    await ref.read(deviceRepositoryProvider).updateDeviceRole(device.id, nextRole);
    ref.read(syncControllerProvider.notifier).scheduleSync();
  }

  Future<void> _archiveDevice(Device device) async {
    final confirmed = await showSynProdDialog<bool>(
      context: context,
      builder: (ctx) => SynProdDialog(
        icon: Icons.archive_outlined,
        title: 'Archive Device',
        content: Text(
          'Archive "${device.displayName}" (${device.role.displayName})? '
          'Archived devices become inactive and cannot sync or be used until restored.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          SynProdGradientButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(deviceRepositoryProvider)
        .setDeviceRevoked(device.id, true);
    ref.read(syncControllerProvider.notifier).scheduleSync();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Archived "${device.displayName}"')),
      );
    }
  }

  Future<void> _showAddDeviceDialog(BuildContext context) async {
    final nameCtrl = TextEditingController();
    DeviceRole selectedRole = DeviceRole.production;
    String? error;

    await showSynProdDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SynProdDialog(
          icon: Icons.devices_outlined,
          title: 'Add Paired Device',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null) ...[
                Text(
                  error!,
                  style: TextStyle(
                    color: AppTheme.errorTextFor(ctx),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
              ],
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Device Display Name *',
                  hintText: 'e.g. Floor Tablet 2',
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<DeviceRole>(
                initialValue: selectedRole,
                decoration: const InputDecoration(labelText: 'Device Role'),
                items: const [
                  DropdownMenuItem(
                    value: DeviceRole.production,
                    child: Text('Production (Read-only)'),
                  ),
                  DropdownMenuItem(
                    value: DeviceRole.manager,
                    child: Text('Manager (Create & Edit Own)'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedRole = val);
                },
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
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  setDialogState(() => error = 'Display name is required.');
                  return;
                }
                final deviceId = UuidGenerator.v4();
                final now = DateTime.now();
                await ref.read(deviceRepositoryProvider).upsertDevice(
                      Device(
                        id: deviceId,
                        displayName: name,
                        role: selectedRole,
                        pairedAt: now,
                        lastSeenAt: now,
                      ),
                    );
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!context.mounted) return;
                await _showQrCodeDialog(
                  context: context,
                  deviceId: deviceId,
                  displayName: name,
                  role: selectedRole,
                );
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_2, size: 18),
                  SizedBox(width: 6),
                  Text('Generate QR'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQrCodeDialog({
    required BuildContext context,
    required String deviceId,
    required String displayName,
    required DeviceRole role,
  }) async {
    final workspace = ref.read(authControllerProvider).workspace;
    if (workspace == null) return;

    final token = await ref.read(deviceRepositoryProvider).createPairingToken(
          deviceId: deviceId,
          displayName: displayName,
          role: role,
          validity: AppConstants.qrPairingExpiry,
        );

    final payload = ref.read(qrPairingServiceProvider).createPayload(
          workspace: workspace,
          deviceId: deviceId,
          displayName: displayName,
          role: role,
          pairingSecret: token.id,
        );

    final rawJson = payload.toJsonString();
    if (!context.mounted) return;

    await showSynProdDialog<void>(
      context: context,
      builder: (ctx) => SynProdDialog(
        icon: Icons.qr_code_2,
        title: 'Pair $displayName',
        subtitle: '${role.displayName} Device',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderFor(ctx)),
              ),
              child: SizedBox(
                width: 220,
                height: 220,
                child: QrImageView(
                  data: rawJson,
                  version: QrVersions.auto,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Single-use code • Expires in 10 minutes.\nScan this code on the new device.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.mutedTextFor(ctx),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: rawJson));
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(content: Text('Pairing payload copied.')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy Payload'),
          ),
          SynProdGradientButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
