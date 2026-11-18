import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Responsive scaffold wrapper that adapts between BottomNavigationBar (Mobile)
/// and NavigationRail / Sidebar (Tablet / Desktop / Landscape).
class AppScaffold extends ConsumerWidget {
  final Widget child;
  final int currentIndex;

  const AppScaffold({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(
      label: 'Dashboard',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      path: '/dashboard',
    ),
    _NavItem(
      label: 'Customers',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      path: '/customers',
    ),
    _NavItem(
      label: 'Schedule',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      path: '/schedule',
    ),
    _NavItem(
      label: 'Jobs',
      icon: Icons.engineering_outlined,
      activeIcon: Icons.engineering_rounded,
      path: '/work-orders',
    ),
    _NavItem(
      label: 'More',
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      path: '/more',
    ),
  ];

  void _onNavigate(BuildContext context, int index) {
    if (index != currentIndex && index >= 0 && index < _navItems.length) {
      context.go(_navItems[index].path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final isTablet = width >= AppSpacing.breakpointTablet;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isTablet) {
      // Tablet / Landscape / Desktop Layout: NavigationRail + Main Content
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (idx) => _onNavigate(context, idx),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.home_repair_service_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              destinations: _navItems.map((item) {
                return NavigationRailDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.activeIcon),
                  label: Text(item.label),
                );
              }).toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Standard Mobile Layout: Main Content + BottomNavigationBar
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (idx) => _onNavigate(context, idx),
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            items: _navItems.map((item) {
              return BottomNavigationBarItem(
                icon: Icon(item.icon),
                activeIcon: Icon(item.activeIcon),
                label: item.label,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String path;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.path,
  });
}
