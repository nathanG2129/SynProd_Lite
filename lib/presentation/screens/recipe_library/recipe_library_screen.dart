import 'package:flutter/gestures.dart';
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
  final bool embedded;

  const RecipeLibraryScreen({super.key, this.embedded = false});

  @override
  ConsumerState<RecipeLibraryScreen> createState() => _RecipeLibraryScreenState();
}

class _RecipeLibraryScreenState extends ConsumerState<RecipeLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _typeScrollController = ScrollController();
  final ValueNotifier<({bool left, bool right})> _typeScrollArrows =
      ValueNotifier((left: false, right: false));
  String? _selectedProductId;

  @override
  void dispose() {
    _searchController.dispose();
    _typeScrollController.dispose();
    _typeScrollArrows.dispose();
    super.dispose();
  }

  void _updateTypeScrollArrows(ScrollMetrics metrics) {
    final next = (
      left: metrics.pixels > 2,
      right: metrics.maxScrollExtent > 0 &&
          metrics.pixels < metrics.maxScrollExtent - 2,
    );
    if (_typeScrollArrows.value != next) {
      _typeScrollArrows.value = next;
    }
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

    final hasFilters = _hasActiveFilters(ref);
    final secondaryFilterCount = (selectedComp != null ? 1 : 0) +
        (selectedIng != null ? 1 : 0) +
        (myProductsOnly ? 1 : 0);

    return LayoutBuilder(
      builder: (context, outerConstraints) {
        final isMasterDetail = outerConstraints.maxWidth >= 900;
        final showFab = currentDevice.role.canCreateProduct &&
            !(widget.embedded && isMasterDetail);

        return Scaffold(
          floatingActionButton: showFab
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
            automaticallyImplyLeading: !widget.embedded,
            title: const SynProdGradientText('SynProd Lite'),
            actions: [
              if (!widget.embedded) ...[
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
              ],
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
                            SynProdAvatar(
                                displayName: currentDevice.displayName),
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
          ),
          body: SynProdCanvas(
            child: isMasterDetail
                ? Row(
                    children: [
                      RepaintBoundary(
                        child: Container(
                          width: 390,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: AppTheme.cardBorderFor(context),
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: _buildLibraryColumn(
                            context: context,
                            filteredProductsAsync: filteredProductsAsync,
                            productTypes: productTypes,
                            selectedType: selectedType,
                            hasFilters: hasFilters,
                            secondaryFilterCount: secondaryFilterCount,
                            isMasterDetail: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: RepaintBoundary(
                          child: filteredProductsAsync.when(
                            data: (products) {
                              if (products.isEmpty) {
                                return Center(
                                  child: Text(
                                    'Select or create a recipe to view details.',
                                    style: TextStyle(
                                      color: AppTheme.mutedTextFor(context),
                                    ),
                                  ),
                                );
                              }
                              final selectedProduct = products
                                      .where((p) => p.id == _selectedProductId)
                                      .firstOrNull ??
                                  products.first;
                              return RecipeDetailScreen(
                                product: selectedProduct,
                                embedded: true,
                                onDeleted: () =>
                                    setState(() => _selectedProductId = null),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (_, _) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ],
                  )
                : _buildLibraryColumn(
                    context: context,
                    filteredProductsAsync: filteredProductsAsync,
                    productTypes: productTypes,
                    selectedType: selectedType,
                    hasFilters: hasFilters,
                    secondaryFilterCount: secondaryFilterCount,
                    isMasterDetail: false,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildLibraryColumn({
    required BuildContext context,
    required AsyncValue<List<Product>> filteredProductsAsync,
    required List<dynamic> productTypes,
    required dynamic selectedType,
    required bool hasFilters,
    required int secondaryFilterCount,
    required bool isMasterDetail,
  }) {
    return Column(
      children: [
        // Slim Search + Filters Row
        Container(
          color: AppTheme.cardColorFor(context),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search recipes, components...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.headingColorFor(context),
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(searchQueryProvider.notifier).state =
                                      '';
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.isDark(context)
                            ? AppTheme.darkInputFill
                            : AppTheme.slate50,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppTheme.isDark(context)
                                ? AppTheme.darkBorder
                                : AppTheme.borderInput,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: AppTheme.isDark(context)
                                ? AppTheme.darkBorder
                                : AppTheme.borderInput,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
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
                  const SizedBox(width: 8),
                  Badge(
                    isLabelVisible: secondaryFilterCount > 0,
                    backgroundColor: AppTheme.primaryOlive,
                    label: Text(
                      '$secondaryFilterCount',
                      style: const TextStyle(fontSize: 10),
                    ),
                    child: IconButton.outlined(
                      tooltip: 'More Filters',
                      onPressed: () => _showFiltersSheet(context),
                      icon: Icon(
                        Icons.tune,
                        color: secondaryFilterCount > 0
                            ? AppTheme.headingColorFor(context)
                            : AppTheme.secondaryTextFor(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTypeFilterStrip(context, productTypes, selectedType),
            ],
          ),
        ),
        const Divider(height: 1),
        // Results Count & Clear Filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              filteredProductsAsync.when(
                data: (products) => Text(
                  'All Recipes (${products.length})',
                  style: TextStyle(
                    fontSize: 13,
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
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: AppTheme.mutedTextFor(context),
                        ),
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

              final activeId = _selectedProductId ?? products.first.id;

              if (isMasterDetail) {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildRecipeCard(
                      context,
                      product,
                      isMasterDetail: true,
                      isSelected: product.id == activeId,
                    );
                  },
                );
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isTwoColumn = constraints.maxWidth >= 640;
                  if (!isTwoColumn) {
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _buildRecipeCard(
                        context,
                        products[index],
                      ),
                    );
                  }

                  final rowCount = (products.length / 2).ceil();
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 88),
                    itemCount: rowCount,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, rowIndex) {
                      final leftIndex = rowIndex * 2;
                      final rightIndex = leftIndex + 1;
                      final hasRight = rightIndex < products.length;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildRecipeCard(
                              context,
                              products[leftIndex],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: hasRight
                                ? _buildRecipeCard(
                                    context,
                                    products[rightIndex],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
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
    );
  }

  Future<void> _showFiltersSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.cardColorFor(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Consumer(
        builder: (ctx, sheetRef, _) {
          final currentDevice = sheetRef.watch(currentDeviceProvider);
          final selectedComp = sheetRef.watch(selectedComponentFilterProvider);
          final selectedIng = sheetRef.watch(selectedIngredientFilterProvider);
          final myProductsOnly = sheetRef.watch(myProductsOnlyProvider);
          final distinctCompsAsync = sheetRef.watch(distinctComponentsProvider);
          final distinctIngsAsync = sheetRef.watch(distinctIngredientsProvider);

          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune, color: AppTheme.headingColorFor(ctx)),
                      const SizedBox(width: 8),
                      Text(
                        'Filter Recipes',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.headingColorFor(ctx),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          _clearFilters();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Reset All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  distinctCompsAsync.when(
                    data: (components) => _buildDropdownFilter(
                      label: 'Component',
                      value: selectedComp,
                      items: components,
                      onChanged: (val) {
                        sheetRef
                            .read(selectedComponentFilterProvider.notifier)
                            .state = val;
                      },
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),
                  distinctIngsAsync.when(
                    data: (ingredients) => _buildDropdownFilter(
                      label: 'Ingredient',
                      value: selectedIng,
                      items: ingredients,
                      onChanged: (val) {
                        sheetRef
                            .read(selectedIngredientFilterProvider.notifier)
                            .state = val;
                      },
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                  if (currentDevice.role.canCreateProduct) ...[
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('My Products Only'),
                      value: myProductsOnly,
                      onChanged: (val) {
                        sheetRef.read(myProductsOnlyProvider.notifier).state =
                            val;
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  SynProdGradientButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeCard(
    BuildContext context,
    Product product, {
    bool isMasterDetail = false,
    bool isSelected = false,
  }) {
    return _RecipeCard(
      product: product,
      isSelected: isSelected,
      onTap: () {
        if (isMasterDetail) {
          setState(() => _selectedProductId = product.id);
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailScreen(product: product),
          ),
        );
      },
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

  Widget _buildTypeFilterStrip(
    BuildContext context,
    List<dynamic> productTypes,
    dynamic selectedType,
  ) {
    void scrollBy(double delta) {
      if (!_typeScrollController.hasClients) return;
      final pos = _typeScrollController.position;
      final target = (pos.pixels + delta).clamp(0.0, pos.maxScrollExtent);
      _typeScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }

    return Row(
      children: [
        ValueListenableBuilder<({bool left, bool right})>(
          valueListenable: _typeScrollArrows,
          builder: (context, arrows, _) {
            if (!arrows.left) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Scroll types left',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: () => scrollBy(-140),
            );
          },
        ),
        Expanded(
          child: Listener(
            onPointerSignal: (event) {
              if (event is PointerScrollEvent &&
                  _typeScrollController.hasClients) {
                final pos = _typeScrollController.position;
                if (pos.maxScrollExtent > 0) {
                  final delta = event.scrollDelta.dy != 0
                      ? event.scrollDelta.dy
                      : event.scrollDelta.dx;
                  final target =
                      (pos.pixels + delta).clamp(0.0, pos.maxScrollExtent);
                  _typeScrollController.jumpTo(target);
                }
              }
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _updateTypeScrollArrows(notification.metrics);
                return false;
              },
              child: NotificationListener<ScrollMetricsNotification>(
                onNotification: (notification) {
                  _updateTypeScrollArrows(notification.metrics);
                  return false;
                },
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: const {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                      PointerDeviceKind.trackpad,
                      PointerDeviceKind.stylus,
                    },
                  ),
                  child: SingleChildScrollView(
                    controller: _typeScrollController,
                    scrollDirection: Axis.horizontal,
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
                                    .read(selectedTypeFilterProvider.notifier)
                                    .state = selected ? type : null;
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ValueListenableBuilder<({bool left, bool right})>(
          valueListenable: _typeScrollArrows,
          builder: (context, arrows, _) {
            if (!arrows.right) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Scroll types right',
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 32),
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: () => scrollBy(140),
            );
          },
        ),
      ],
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final bool isSelected;

  const _RecipeCard({
    required this.product,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = SynProdCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14.0),
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
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildMetaItem(
                      context,
                      icon: Icons.scale_outlined,
                      label:
                          '${product.productType.baseWeightGrams.toInt()}g base',
                    ),
                    _buildMetaItem(
                      context,
                      icon: Icons.pie_chart_outline,
                      label: '${product.compositions.length} components',
                    ),
                    if (product.additionalIngredients.isNotEmpty)
                      _buildMetaItem(
                        context,
                        icon: Icons.add_circle_outline,
                        label:
                            '${product.additionalIngredients.length} ingredients',
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppTheme.mutedTextFor(context)),
            ],
          ),
        ],
      ),
    );
    if (!isSelected) return card;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryOlive, width: 2),
      ),
      child: card,
    );
  }

  Widget _buildMetaItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppTheme.mutedTextFor(context)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextFor(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
