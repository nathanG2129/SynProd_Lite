import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/sync_models.dart';
import '../../providers/device_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/synprod_ui.dart';
import '../product_form/product_form_screen.dart';

class SyncStatusScreen extends ConsumerWidget {
  final bool embedded;

  const SyncStatusScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    final conflictsAsync = ref.watch(conflictHistoryProvider);
    final currentDevice = ref.watch(currentDeviceProvider);
    final canRecoverOrEdit = currentDevice.role.canCreateProduct;

    return Scaffold(
      appBar: SynProdAppBar(
        automaticallyImplyLeading: !embedded,
        title: const SynProdGradientText('Local Wi-Fi Sync'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Sync Now',
              onPressed: syncState.isSyncing
                  ? null
                  : () => ref.read(syncControllerProvider.notifier).syncNow(),
              icon: syncState.isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.sync, color: AppTheme.headingColorFor(context)),
            ),
          ),
        ],
      ),
      body: SynProdCanvas(
        child: SynProdCenteredBody(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatusCard(context, ref, syncState),
              const SizedBox(height: 16),
              _buildPeersCard(context, syncState),
              const SizedBox(height: 16),
              _buildConflictsSection(
                context,
                ref,
                conflictsAsync,
                canRecoverOrEdit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    WidgetRef ref,
    SyncStatusState syncState,
  ) {
    final lastSyncedText = syncState.lastSyncedAt == null
        ? 'Never synced yet'
        : DateFormat('MMM d, yyyy • HH:mm:ss').format(syncState.lastSyncedAt!);

    return SynProdCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                syncState.isRunning ? Icons.wifi_tethering : Icons.wifi_off,
                color: syncState.isRunning
                    ? AppTheme.primaryOlive
                    : AppTheme.mutedTextFor(context),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      syncState.isRunning
                          ? 'Peer Discovery Active'
                          : 'Peer Discovery Paused',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryTextFor(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last synced: $lastSyncedText',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.secondaryTextFor(context),
                      ),
                    ),
                  ],
                ),
              ),
              SynProdGradientButton(
                onPressed: syncState.isSyncing
                    ? null
                    : () => ref.read(syncControllerProvider.notifier).syncNow(),
                child: Text(syncState.isSyncing ? 'Syncing...' : 'Sync Now'),
              ),
            ],
          ),
          if (syncState.lastError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorBgFor(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.inputErrorBorder),
              ),
              child: Text(
                syncState.lastError!,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.errorTextFor(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPeersCard(BuildContext context, SyncStatusState syncState) {
    return SynProdCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Paired Peers (${syncState.peers.length})',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.headingColorFor(context),
            ),
          ),
          const SizedBox(height: 10),
          if (syncState.peers.isEmpty)
            Text(
              'No paired devices currently detected on this Wi-Fi network.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.secondaryTextFor(context),
              ),
            )
          else
            ...syncState.peers.map(
              (peer) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SynProdAvatar(displayName: peer.displayName),
                title: Text(
                  peer.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextFor(context),
                  ),
                ),
                subtitle: Text(
                  '${peer.host}:${peer.port}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mutedTextFor(context),
                  ),
                ),
                trailing: const Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryOlive,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConflictsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SyncConflictRecord>> conflictsAsync,
    bool canRecoverOrEdit,
  ) {
    return SynProdCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sync Conflict & Audit History',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.headingColorFor(context),
            ),
          ),
          const SizedBox(height: 10),
          conflictsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Failed to load conflict history: $e'),
            data: (records) {
              if (records.isEmpty) {
                return Text(
                  'No sync conflicts or overwritten versions recorded.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryTextFor(context),
                  ),
                );
              }
              return Column(
                children: records
                    .map(
                      (record) => _ConflictTile(
                        record: record,
                        canRecoverOrEdit: canRecoverOrEdit,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConflictTile extends ConsumerWidget {
  final SyncConflictRecord record;
  final bool canRecoverOrEdit;

  const _ConflictTile({
    required this.record,
    required this.canRecoverOrEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timestamp = DateFormat('MMM d, HH:mm').format(record.occurredAt);
    final losingProduct = record.tryDecodeLosingProduct();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: record.isResolved
            ? AppTheme.elevatedSurfaceFor(context)
            : AppTheme.warningBgFor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: record.isResolved
              ? AppTheme.borderFor(context)
              : AppTheme.amberWarning,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${record.productName} • ${record.conflictType.displayName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.primaryTextFor(context),
                  ),
                ),
              ),
              Text(
                timestamp,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.mutedTextFor(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            record.reason,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryTextFor(context),
            ),
          ),
          if (!record.isResolved) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (canRecoverOrEdit &&
                    record.conflictType == SyncConflictType.lwwOverwritten &&
                    losingProduct != null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref
                          .read(syncControllerProvider.notifier)
                          .recoverConflictVersion(record);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Recovered "${record.productName}" as latest version.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.restore, size: 16),
                    label: const Text('Recover Version'),
                  ),
                if (canRecoverOrEdit &&
                    record.conflictType == SyncConflictType.nameConflict &&
                    losingProduct != null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductFormScreen(product: losingProduct),
                        ),
                      );
                      await ref
                          .read(syncControllerProvider.notifier)
                          .dismissConflict(record.id);
                    },
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Rename Recipe'),
                  ),
                TextButton(
                  onPressed: () => ref
                      .read(syncControllerProvider.notifier)
                      .dismissConflict(record.id),
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
