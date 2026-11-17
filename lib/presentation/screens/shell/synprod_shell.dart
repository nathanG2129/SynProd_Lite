import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/device_providers.dart';
import '../../providers/sync_providers.dart';
import '../../widgets/synprod_ui.dart';
import '../device_management/device_management_screen.dart';
import '../product_form/product_form_screen.dart';
import '../profile/device_profile_screen.dart';
import '../recipe_library/recipe_library_screen.dart';
import '../sync/sync_status_screen.dart';

enum _ShellSection { recipes, sync, devices, profile }

class SynProdShell extends ConsumerStatefulWidget {
  const SynProdShell({super.key});

  @override
  ConsumerState<SynProdShell> createState() => _SynProdShellState();
}

class _SynProdShellState extends ConsumerState<SynProdShell> {
  _ShellSection _selectedSection = _ShellSection.recipes;

  List<_ShellSection> _availableSections(bool canManageDevices) {
    return [
      _ShellSection.recipes,
      _ShellSection.sync,
      if (canManageDevices) _ShellSection.devices,
      _ShellSection.profile,
    ];
  }

  Widget _iconFor(_ShellSection section, bool selected) {
    return switch (section) {
      _ShellSection.recipes =>
        Icon(selected ? Icons.menu_book : Icons.menu_book_outlined),
      _ShellSection.sync => const _SyncNavIcon(),
      _ShellSection.devices =>
        Icon(selected ? Icons.devices : Icons.devices_outlined),
      _ShellSection.profile =>
        Icon(selected ? Icons.person : Icons.person_outline),
    };
  }

  Widget _pageFor(_ShellSection section) {
    return switch (section) {
      _ShellSection.recipes => const RecipeLibraryScreen(embedded: true),
      _ShellSection.sync => const SyncStatusScreen(embedded: true),
      _ShellSection.devices => const DeviceManagementScreen(embedded: true),
      _ShellSection.profile => const DeviceProfileScreen(embedded: true),
    };
  }

  void _openNewRecipe() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentDevice = ref.watch(currentDeviceProvider);
    final sections = _availableSections(currentDevice.role.canManageDevices);
    final activeSection = sections.contains(_selectedSection)
        ? _selectedSection
        : _ShellSection.recipes;
    final activeIndex = sections.indexOf(activeSection);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isExpanded = constraints.maxWidth >= 900;

        if (isExpanded) {
          final isExtendedRail = constraints.maxWidth >= 1180;
          return Scaffold(
            body: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.cardColorFor(context),
                    border: Border(
                      right: BorderSide(
                        color: AppTheme.cardBorderFor(context),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: NavigationRail(
                    backgroundColor: Colors.transparent,
                    extended: isExtendedRail,
                    labelType: isExtendedRail
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    selectedIndex: activeIndex,
                    indicatorColor: AppTheme.softTintColorFor(context),
                    selectedIconTheme: IconThemeData(
                      color: AppTheme.headingColorFor(context),
                    ),
                    selectedLabelTextStyle: TextStyle(
                      color: AppTheme.headingColorFor(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: AppTheme.secondaryTextFor(context),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                    onDestinationSelected: (idx) {
                      setState(() => _selectedSection = sections[idx]);
                    },
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                      child: Column(
                        children: [
                          if (isExtendedRail)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: SynProdGradientText(
                                'SynProd Lite',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: AppTheme.brandHeadingGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.science_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          if (currentDevice.role.canCreateProduct)
                            isExtendedRail
                                ? SizedBox(
                                    width: 196,
                                    child: SynProdGradientButton(
                                      onPressed: _openNewRecipe,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 11,
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add, size: 18),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'New Recipe',
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : FloatingActionButton.small(
                                    heroTag: 'rail_new_recipe',
                                    tooltip: 'New Recipe',
                                    onPressed: _openNewRecipe,
                                    child: const Icon(Icons.add),
                                  ),
                        ],
                      ),
                    ),
                    destinations: sections.map((section) {
                      return NavigationRailDestination(
                        icon: _iconFor(section, false),
                        selectedIcon: _iconFor(section, true),
                        label: Text(_labelFor(section)),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: RepaintBoundary(
                    child: _pageFor(activeSection),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: _pageFor(activeSection),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: AppTheme.cardBorderFor(context),
                  width: 1,
                ),
              ),
            ),
            child: NavigationBar(
              selectedIndex: activeIndex,
              backgroundColor: AppTheme.cardColorFor(context),
              indicatorColor: AppTheme.softTintColorFor(context),
              onDestinationSelected: (idx) {
                setState(() => _selectedSection = sections[idx]);
              },
              destinations: sections.map((section) {
                return NavigationDestination(
                  icon: _iconFor(section, false),
                  selectedIcon: _iconFor(section, true),
                  label: _labelFor(section),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  String _labelFor(_ShellSection section) {
    return switch (section) {
      _ShellSection.recipes => 'Recipes',
      _ShellSection.sync => 'Sync',
      _ShellSection.devices => 'Devices',
      _ShellSection.profile => 'Profile',
    };
  }
}

class _SyncNavIcon extends ConsumerWidget {
  const _SyncNavIcon();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncControllerProvider);
    final icon = Icon(
      syncState.isSyncing
          ? Icons.sync
          : (syncState.isRunning ? Icons.wifi_tethering : Icons.sync_disabled),
    );
    final hasBadge =
        syncState.unresolvedConflictsCount > 0 || syncState.peers.isNotEmpty;
    if (!hasBadge) return icon;

    return Badge(
      backgroundColor: syncState.unresolvedConflictsCount > 0
          ? Colors.amber.shade700
          : AppTheme.primaryOlive,
      label: Text(
        syncState.unresolvedConflictsCount > 0
            ? '${syncState.unresolvedConflictsCount}'
            : '${syncState.peers.length}',
        style: const TextStyle(fontSize: 10),
      ),
      child: icon,
    );
  }
}
