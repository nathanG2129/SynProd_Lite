import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/device.dart';
import '../../../domain/models/product_type.dart';
import '../../providers/device_providers.dart';
import '../../providers/product_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/synprod_ui.dart';

class ProductTypesScreen extends ConsumerWidget {
  const ProductTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDevice = ref.watch(currentDeviceProvider);
    final typesAsync = ref.watch(productTypesStreamProvider);
    final products =
        ref.watch(activeProductsStreamProvider).valueOrNull ?? const [];

    if (currentDevice.role != DeviceRole.admin) {
      return Scaffold(
        appBar: const SynProdAppBar(
          title: SynProdGradientText('Product Types'),
        ),
        body: SynProdCanvas(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SynProdCard(
                padding: const EdgeInsets.all(20),
                child: const Text(
                  'Only Administrators can edit product types.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: SynProdAppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SynProdGradientText('Product Types'),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SynProdGradientButton(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: () => _showTypeEditorDialog(
                  context,
                  ref,
                  existingCount: typesAsync.valueOrNull?.length ?? 0,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16),
                    SizedBox(width: 4),
                    Text('Add Type'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SynProdCanvas(
        child: typesAsync.when(
          data: (types) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: types.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final type = types[index];
                final inUseCount = products
                    .where((p) => p.productType.code == type.code)
                    .length;
                final packagingSummary = type.packagingOptions
                    .map((p) => '${p.unitName} (${p.multiplier}x)')
                    .join(', ');

                return SynProdCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.displayName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryTextFor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Base weight: ${type.baseWeightGrams.toStringAsFixed(type.baseWeightGrams % 1 == 0 ? 0 : 1)} g',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.headingColorFor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Packaging: $packagingSummary',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.mutedTextFor(context),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              inUseCount == 0
                                  ? 'Unused'
                                  : 'Used by $inUseCount recipe${inUseCount == 1 ? '' : 's'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.mutedTextFor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit Type',
                        icon: Icon(
                          Icons.edit_outlined,
                          color: AppTheme.headingColorFor(context),
                        ),
                        onPressed: () => _showTypeEditorDialog(
                          context,
                          ref,
                          existing: type,
                          existingCount: types.length,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Delete Type',
                        icon: Icon(
                          Icons.delete_outline,
                          color: inUseCount > 0 || types.length <= 1
                              ? AppTheme.mutedTextFor(context)
                              : AppTheme.errorTextFor(context),
                        ),
                        onPressed: () => _confirmDeleteType(
                          context,
                          ref,
                          type: type,
                          inUseCount: inUseCount,
                          totalTypes: types.length,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteType(
    BuildContext context,
    WidgetRef ref, {
    required ProductType type,
    required int inUseCount,
    required int totalTypes,
  }) async {
    if (totalTypes <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one product type must remain.'),
        ),
      );
      return;
    }
    if (inUseCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete "${type.displayName}" while $inUseCount recipe(s) use it.',
          ),
        ),
      );
      return;
    }

    final confirmed = await showSynProdDialog<bool>(
      context: context,
      builder: (ctx) => SynProdDialog(
        icon: Icons.delete_outline,
        title: 'Delete Product Type',
        content: Text('Delete "${type.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          SynProdGradientButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(productRepositoryProvider).deleteProductType(type.code);
      ref.invalidate(activeProductsStreamProvider);
      ref.read(syncControllerProvider.notifier).scheduleSync();
    }
  }

  Future<void> _showTypeEditorDialog(
    BuildContext context,
    WidgetRef ref, {
    ProductType? existing,
    required int existingCount,
  }) async {
    final nameCtrl = TextEditingController(text: existing?.displayName ?? '');
    final weightCtrl = TextEditingController(
      text: existing != null
          ? existing.baseWeightGrams
              .toStringAsFixed(existing.baseWeightGrams % 1 == 0 ? 0 : 1)
          : '',
    );
    final packagingRows = (existing?.packagingOptions ??
            const [PackagingOption(unitName: 'Tubs', multiplier: 1.0)])
        .map((p) => (
              unitCtrl: TextEditingController(text: p.unitName),
              multCtrl: TextEditingController(text: p.multiplier.toString()),
            ))
        .toList();

    String? error;

    await showSynProdDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => SynProdDialog(
          icon: existing == null ? Icons.add_box_outlined : Icons.edit_outlined,
          title: existing == null ? 'Add Product Type' : 'Edit Product Type',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Type Name *',
                  hintText: 'e.g. Greek Yogurt',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Base Weight (grams) *',
                  hintText: 'e.g. 380',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Packaging Options',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.headingColorFor(context),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setDialogState(() {
                        packagingRows.add((
                          unitCtrl: TextEditingController(),
                          multCtrl: TextEditingController(text: '1.0'),
                        ));
                      });
                    },
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Unit'),
                  ),
                ],
              ),
              ...packagingRows.asMap().entries.map((entry) {
                final idx = entry.key;
                final row = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: row.unitCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Unit *',
                            hintText: 'Tubs',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.multCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Mult *',
                            hintText: '1.0',
                          ),
                        ),
                      ),
                      if (packagingRows.length > 1)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setDialogState(() {
                              final removed = packagingRows.removeAt(idx);
                              removed.unitCtrl.dispose();
                              removed.multCtrl.dispose();
                            });
                          },
                        ),
                    ],
                  ),
                );
              }),
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
                final weight = double.tryParse(weightCtrl.text.trim());
                if (name.isEmpty) {
                  setDialogState(() => error = 'Type name is required.');
                  return;
                }
                if (weight == null || weight <= 0) {
                  setDialogState(
                    () => error = 'Base weight must be a positive number.',
                  );
                  return;
                }

                final options = <PackagingOption>[];
                for (final row in packagingRows) {
                  final unit = row.unitCtrl.text.trim();
                  final mult = double.tryParse(row.multCtrl.text.trim());
                  if (unit.isEmpty || mult == null || mult <= 0) {
                    setDialogState(
                      () => error =
                          'Each packaging option needs a unit name and positive multiplier.',
                    );
                    return;
                  }
                  options.add(PackagingOption(unitName: unit, multiplier: mult));
                }

                final code = existing?.code ?? _generateTypeCode(name);
                final updated = ProductType(
                  code: code,
                  displayName: name,
                  baseWeightGrams: weight,
                  packagingOptions: options,
                  sortOrder: existing?.sortOrder ?? existingCount,
                );

                await ref
                    .read(productRepositoryProvider)
                    .saveProductType(updated);
                ref.invalidate(activeProductsStreamProvider);
                ref.read(syncControllerProvider.notifier).scheduleSync();
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _generateTypeCode(String name) {
    final sanitized = name
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final base = sanitized.isEmpty ? 'TYPE' : sanitized;
    return '${base}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
