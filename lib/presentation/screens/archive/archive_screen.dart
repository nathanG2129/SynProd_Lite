import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/device.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/product_type.dart';
import '../../providers/auth_providers.dart';
import '../../providers/device_providers.dart';
import '../../providers/product_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/synprod_ui.dart';

class ArchiveScreen extends ConsumerWidget {
  final int initialTabIndex;

  const ArchiveScreen({super.key, this.initialTabIndex = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDevice = ref.watch(currentDeviceProvider);

    if (currentDevice.role != DeviceRole.admin) {
      return Scaffold(
        appBar: const SynProdAppBar(
          title: SynProdGradientText('Archive'),
        ),
        body: SynProdCanvas(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: const SynProdCard(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Only Administrators can view and restore archived records.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final archivedProductsAsync = ref.watch(archivedProductsStreamProvider);
    final archivedTypesAsync = ref.watch(archivedProductTypesStreamProvider);
    final allDevicesAsync = ref.watch(allDevicesProvider);

    final archivedProductCount = archivedProductsAsync.valueOrNull?.length ?? 0;
    final archivedTypeCount = archivedTypesAsync.valueOrNull?.length ?? 0;
    final archivedDeviceCount = (allDevicesAsync.valueOrNull ?? const [])
        .where((d) => d.isRevoked)
        .length;

    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex.clamp(0, 2),
      child: Scaffold(
        appBar: SynProdAppBar(
          title: const SynProdGradientText('Archive'),
          bottom: TabBar(
            labelColor: AppTheme.headingColorFor(context),
            unselectedLabelColor: AppTheme.mutedTextFor(context),
            indicatorColor: AppTheme.primaryOlive,
            tabs: [
              Tab(text: 'Recipes ($archivedProductCount)'),
              Tab(text: 'Types ($archivedTypeCount)'),
              Tab(text: 'Devices ($archivedDeviceCount)'),
            ],
          ),
        ),
        body: SynProdCanvas(
          child: SynProdCenteredBody(
            child: TabBarView(
              children: [
                _ArchivedRecipesTab(asyncProducts: archivedProductsAsync),
                _ArchivedTypesTab(asyncTypes: archivedTypesAsync),
                _ArchivedDevicesTab(asyncDevices: allDevicesAsync),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArchivedRecipesTab extends ConsumerWidget {
  final AsyncValue<List<Product>> asyncProducts;

  const _ArchivedRecipesTab({required this.asyncProducts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncProducts.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading archived recipes: $e')),
      data: (products) {
        if (products.isEmpty) {
          return const _EmptyArchiveState(
            icon: Icons.menu_book_outlined,
            message: 'No archived recipes.',
          );
        }
        final dateFormat = DateFormat('MMM d, yyyy HH:mm');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final product = products[index];
            return SynProdCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                product.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTextFor(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const _ArchivedBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${product.productType.displayName} • Archived ${dateFormat.format(product.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedTextFor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SynProdSecondaryButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(productMutationServiceProvider)
                            .restoreProduct(product);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Restored "${product.name}"'),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Cannot restore: $e'),
                              backgroundColor: AppTheme.redError,
                            ),
                          );
                        }
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restore, size: 16),
                        SizedBox(width: 6),
                        Text('Restore'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ArchivedTypesTab extends ConsumerWidget {
  final AsyncValue<List<ProductType>> asyncTypes;

  const _ArchivedTypesTab({required this.asyncTypes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncTypes.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading archived types: $e')),
      data: (types) {
        if (types.isEmpty) {
          return const _EmptyArchiveState(
            icon: Icons.category_outlined,
            message: 'No archived product types.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: types.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final type = types[index];
            final packagingSummary = type.packagingOptions
                .map((p) => '${p.unitName} (${p.multiplier}x)')
                .join(', ');
            return SynProdCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                type.displayName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryTextFor(context),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const _ArchivedBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Base weight: ${type.baseWeightGrams.toStringAsFixed(type.baseWeightGrams % 1 == 0 ? 0 : 1)} g • $packagingSummary',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedTextFor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SynProdSecondaryButton(
                    onPressed: () async {
                      await ref
                          .read(productRepositoryProvider)
                          .setProductTypeArchived(type.code, false);
                      ref.read(syncControllerProvider.notifier).scheduleSync();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Restored "${type.displayName}"'),
                          ),
                        );
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restore, size: 16),
                        SizedBox(width: 6),
                        Text('Restore'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ArchivedDevicesTab extends ConsumerWidget {
  final AsyncValue<List<Device>> asyncDevices;

  const _ArchivedDevicesTab({required this.asyncDevices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncDevices.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading archived devices: $e')),
      data: (devices) {
        final archived = devices.where((d) => d.isRevoked).toList();
        if (archived.isEmpty) {
          return const _EmptyArchiveState(
            icon: Icons.devices_outlined,
            message: 'No archived devices.',
          );
        }
        final dateFormat = DateFormat('MMM d, yyyy HH:mm');
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: archived.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final device = archived[index];
            return SynProdCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
                            const SizedBox(width: 8),
                            const _ArchivedBadge(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${device.role.displayName} • Last seen: ${dateFormat.format(device.lastSeenAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.mutedTextFor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SynProdSecondaryButton(
                    onPressed: () async {
                      await ref
                          .read(deviceRepositoryProvider)
                          .setDeviceRevoked(device.id, false);
                      ref.read(syncControllerProvider.notifier).scheduleSync();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Restored "${device.displayName}"'),
                          ),
                        );
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.restore, size: 16),
                        SizedBox(width: 6),
                        Text('Restore'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ArchivedBadge extends StatelessWidget {
  const _ArchivedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.errorBgFor(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.inputErrorBorder),
      ),
      child: Text(
        'ARCHIVED',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.errorTextFor(context),
        ),
      ),
    );
  }
}

class _EmptyArchiveState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyArchiveState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppTheme.mutedTextFor(context)),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.secondaryTextFor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Archived records are inactive and cannot be used until restored.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.mutedTextFor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
