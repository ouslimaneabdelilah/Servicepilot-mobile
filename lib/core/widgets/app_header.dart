import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_avatar.dart';
import 'app_status_badge.dart';

/// Professional, adaptive header for ServicePilot.
/// Displays company switcher, page title, role badge, notifications, and user actions.
class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool showCompanySwitcher;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.actions,
    this.showCompanySwitcher = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(62.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final currentCompany = auth.currentCompany;
    final companyName = currentCompany?['name']?.toString() ?? 'ServicePilot';

    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          height: 1,
        ),
      ),
      titleSpacing: 16,
      title: Row(
        children: [
          // Back Button or Company Avatar Switcher
          if (showBack)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondaryLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ),
            )
          else if (showCompanySwitcher && auth.companies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _buildCompanySwitcher(context, ref, auth),
            ),

          // Page Title & Subtitle / Role Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: AppTypography.pageTitle.copyWith(
                          fontSize: 18,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (auth.role.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      _buildRoleBadge(auth.role),
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else if (showCompanySwitcher && currentCompany != null)
                  Text(
                    companyName,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (actions != null) ...actions!,

        // Quick User Profile & Logout Popover
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: PopupMenuButton<String>(
            tooltip: 'Account Options',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: AppAvatar(
              name: auth.user?['name']?.toString() ?? 'User',
              size: 34,
              backgroundColor: AppColors.primarySurface,
              textColor: AppColors.primary,
            ),
            onSelected: (val) async {
              if (val == 'logout') {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user?['name']?.toString() ?? 'Signed in user',
                      style: AppTypography.cardTitle.copyWith(fontSize: 14),
                    ),
                    Text(
                      auth.user?['email']?.toString() ?? '',
                      style: AppTypography.caption,
                    ),
                    const Divider(height: 16),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySwitcher(BuildContext context, WidgetRef ref, AuthState auth) {
    final current = auth.currentCompany;
    final currentId = current?['id'];

    return PopupMenuButton<int>(
      tooltip: 'Switch Company',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedLg),
      onSelected: (companyId) async {
        if (companyId != currentId) {
          final ok = await ref.read(authProvider.notifier).switchCompany(companyId);
          if (ok && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Switched active company workspace.'),
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: AppColors.primary.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppAvatar(
              name: current?['name']?.toString() ?? 'SP',
              size: 24,
              backgroundColor: AppColors.primary,
              textColor: Colors.white,
            ),
            const SizedBox(width: 6),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.primary),
          ],
        ),
      ),
      itemBuilder: (ctx) => [
        const PopupMenuItem(
          enabled: false,
          child: Text(
            'ACTIVE WORKSPACES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppColors.textMutedLight,
            ),
          ),
        ),
        ...auth.companies.map((c) {
          final isSelected = c['id'] == currentId;
          return PopupMenuItem<int>(
            value: c['id'] as int,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle_rounded : Icons.business_outlined,
                  size: 18,
                  color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    c['name']?.toString() ?? 'Company',
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRoleBadge(String role) {
    BadgeVariant variant;
    switch (role.toLowerCase()) {
      case 'owner':
        variant = BadgeVariant.info;
        break;
      case 'dispatcher':
        variant = BadgeVariant.warning;
        break;
      case 'technician':
        variant = BadgeVariant.success;
        break;
      default:
        variant = BadgeVariant.neutral;
    }

    return AppStatusBadge(
      label: role.toUpperCase(),
      variant: variant,
      fontSize: 9.5,
    );
  }
}
