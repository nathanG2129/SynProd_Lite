import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/product.dart';
import '../../providers/device_providers.dart';
import '../../providers/product_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/synprod_ui.dart';
import '../device_management/device_management_screen.dart';
import '../product_form/product_form_screen.dart';
import '../profile/device_profile_screen.dart';
import '../recipe_detail/recipe_detail_screen.dart';
import '../sync/sync_status_screen.dart';

class RecipeLibraryScreen extends ConsumerStatefulWidget {
  const RecipeLibraryScreen({super.key});

  @override
  ConsumerState<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends ConsumerState<RecipeLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _filtersExpanded = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedTypeFilterProvider.notifier).state = null;
    ref.read(selectedComponentFilterProvider.notifier).state = null;
    ref.read(selectedIngredientFilterProvider.notifier).state = null;
    ref.read(myProductsOnlyProvider.notifier).state = false;
  }

  bool _hasActiveFilters(WidgetRef ref) {
    return ref.watch(searchQueryProvider).isNotEmpty ||
        ref.watch(selectedTypeFilterProvider) != null ||
        ref.watch(selectedComponentFilterProvider) != null ||
        ref.watch(selectedIngredientFilterProvider) != null ||
        ref.watch(myProductsOnlyProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Ensure initial seed completes if database is fresh
    ref.watch(databaseInitProvider);

    final currentDevice = ref.watch(currentDeviceProvider);
    final syncState = ref.watch(syncControllerProvider);
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final productTypes = ref.watch(productTypesProvider);
    final selectedType = ref.watch(selectedTypeFilterProvider);
    final selectedComp = ref.watch(selectedComponentFilterProvider);
    final selectedIng = ref.watch(selectedIngredientFilterProvider);
    final myProductsOnly = ref.watch(myProductsOnlyProvider);

    final distinctCompsAsync = ref.watch(distinctComponentsProvider);
    final distinctIngsAsync = ref.watch(distinctIngredientsProvider);

    final hasFilters = _hasActiveFilters(ref);

    return Scaffold(
      floatingActionButton: currentDevice.role.canCreateProduct
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductFormScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('New Recipe'),
            )
          : null,
      appBar: SynProdAppBar(
        title: const SynProdGradientText('SynProd Lite'),
        actions: [
          IconButton(
            tooltip: syncState.peers.isNotEmpty
                ? 'Local Sync (${syncState.peers.length} peer${syncState.peers.length == 1 ? '' : 's'})'
                : 'Local Sync & Conflict History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SyncStatusScreen(),
                ),
              );
            },
            icon: Badge(
              isLabelVisible: syncState.unresolvedConflictsCount > 0 ||
                  syncState.peers.isNotEmpty,
              backgroundColor: syncState.unresolvedConflictsCount > 0
                  ? Colors.amber.shade700
                  : AppTheme.primaryOlive,
              label: Text(
                syncState.unresolvedConflictsCount > 0
                    ? '${syncState.unresolvedConflictsCount}'
                    : '${syncState.peers.length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: Icon(
                syncState.isSyncing
                    ? Icons.sync
                    : (syncState.isRunning
                        ? Icons.wifi_tethering
                        : Icons.sync_disabled),
                color: AppTheme.headingColorFor(context),
              ),
            ),
          ),
          if (currentDevice.role.canManageDevices)
            IconButton(
              tooltip: 'Device Management',
              icon: Icon(
                Icons.devices_outlined,
                color: AppTheme.headingColorFor(context),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeviceManagementScreen(),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Material(
                color: Colors.transparent,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeviceProfileScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SynProdAvatar(displayName: currentDevice.displayName),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentDevice.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryTextFor(context),
                              ),
                            ),
                            Text(
                              currentDevice.role.displayName.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.isDark(context)
                                    ? AppTheme.darkOliveAccent
                                    : AppTheme.oliveMuted,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by recipe, component, or ingredient...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.headingColorFor(context),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.isDark(context)
                    ? AppTheme.darkInputFill
                    : AppTheme.slate50,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkBorder
                        : AppTheme.borderInput,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.isDark(context)
                        ? AppTheme.darkBorder
                        : AppTheme.borderInput,
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.headingColorFor(context),
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),
        ),
      ),
      body: SynProdCanvas(
        child: Column(
        children: [
          // Filter Chips Section (Collapsible)
          Container(
            color: AppTheme.cardColorFor(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tune,
                          size: 16,
                          color: AppTheme.headingColorFor(context),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.headingColorFor(context),
                          ),
                        ),
                        if (selectedType != null ||
                            selectedComp != null ||
                            selectedIng != null ||
                            myProductsOnly) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.softTintColorFor(context),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${(selectedType != null ? 1 : 0) + (selectedComp != null ? 1 : 0) + (selectedIng != null ? 1 : 0) + (myProductsOnly ? 1 : 0)} active',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.headingColorFor(context),
                              ),
                            ),
                          ),
                        ],
                        const Spacer(),
                        Icon(
                          _filtersExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          size: 20,
                          color: AppTheme.mutedTextFor(context),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  sizeCurve: Curves.easeOutCubic,
                  crossFadeState: _filtersExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Type Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('All Types'),
                                selected: selectedType == null,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref
                                        .read(selectedTypeFilterProvider.notifier)
                                        .state = null;
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              ...productTypes.map((type) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: FilterChip(
                                    label: Text(type.displayName),
                                    selected: selectedType == type,
                                    onSelected: (selected) {
                                      ref
                                          .read(selectedTypeFilterProvider
                                              .notifier)
                                          .state = selected ? type : null;
                                    },
                                  ),
                                );
                              }),
                              if (currentDevice.role.canCreateProduct)
                                FilterChip(
                                  avatar:
                                      const Icon(Icons.person_outline, size: 16),
                                  label: const Text('My Products'),
                                  selected: myProductsOnly,
                                  onSelected: (selected) {
                                    ref
                                        .read(myProductsOnlyProvider.notifier)
                                        .state = selected;
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Component & Ingredient Filter Dropdowns
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: distinctCompsAsync.when(
                                  data: (components) => _buildDropdownFilter(
                                    label: 'Component',
                                    value: selectedComp,
                                    items: components,
                                    onChanged: (val) {
                                      ref
                                          .read(selectedComponentFilterProvider
                                              .notifier)
                                          .state = val;
                                    },
                                  ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: distinctIngsAsync.when(
                                  data: (ingredients) => _buildDropdownFilter(
                                    label: 'Ingredient',
                                    value: selectedIng,
                                    items: ingredients,
                                    onChanged: (val) {
                                      ref
                                          .read(selectedIngredientFilterProvider
                                              .notifier)
                                          .state = val;
                                    },
                                  ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (_, _) => const SizedBox.shrink(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),

          const Divider(),

          // Results Count & Clear Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              children: [
                filteredProductsAsync.when(
                  data: (products) => Text(
                    'All Recipes (${products.length})',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.secondaryTextFor(context),
                    ),
                  ),
                  loading: () => const Text('Loading recipes...'),
                  error: (_, _) => const Text('Error loading recipes'),
                ),
                const Spacer(),
                if (hasFilters)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.filter_alt_off, size: 16),
                    label: const Text('Clear Filters'),
                    onPressed: _clearFilters,
                  ),
              ],
            ),
          ),

          // Recipe List
          Expanded(
            child: filteredProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off,
                              size: 48, color: AppTheme.mutedTextFor(context)),
                          const SizedBox(height: 12),
                          Text(
                            'No recipes found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryTextFor(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try adjusting your search query or removing active filters.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.secondaryTextFor(context),
                            ),
                          ),
                          if (hasFilters) ...[
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _RecipeCard(
                      product: product,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RecipeDetailScreen(product: product),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text('Failed to load recipes: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.isDark(context)
            ? AppTheme.darkSurfaceElevated
            : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value != null
              ? AppTheme.headingColorFor(context)
              : (AppTheme.isDark(context)
                  ? AppTheme.darkBorder
                  : AppTheme.borderInput),
          width: value != null ? 1.5 : 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: value,
          isExpanded: true,
          hint: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryTextFor(context),
            ),
          ),
          icon: const Icon(Icons.arrow_drop_down, size: 20),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All ${label}s',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            ...items.map(
              (item) => DropdownMenuItem<String?>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _RecipeCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SynProdCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextFor(context),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppTheme.softTintGradientFor(context),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.primaryOlive.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  product.productType.displayName,
                  style: TextStyle(
                    color: AppTheme.headingColorFor(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          if (product.description != null &&
              product.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              product.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.mutedTextFor(context),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.scale_outlined,
                  size: 15, color: AppTheme.mutedTextFor(context)),
              const SizedBox(width: 4),
              Text(
                '${product.productType.baseWeightGrams.toInt()}g base',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextFor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 14),
              Icon(Icons.pie_chart_outline,
                  size: 15, color: AppTheme.mutedTextFor(context)),
              const SizedBox(width: 4),
              Text(
                '${product.compositions.length} components',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.secondaryTextFor(context),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (product.additionalIngredients.isNotEmpty) ...[
                const SizedBox(width: 14),
                Icon(Icons.add_circle_outline,
                    size: 15, color: AppTheme.mutedTextFor(context)),
                const SizedBox(width: 4),
                Text(
                  '${product.additionalIngredients.length} ingredients',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.secondaryTextFor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const Spacer(),
              Icon(Icons.chevron_right, color: AppTheme.mutedTextFor(context)),
            ],
          ),
        ],
      ),
    );
  }
}
