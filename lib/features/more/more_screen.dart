import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_header.dart';

/// Business Hub screen for secondary modules:
/// Estimates, Invoices, Payments, Services, Requests, Team, Reports, Automations.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const AppHeader(
        title: 'Business Hub',
        subtitle: 'All tools, operations & settings',
        showCompanySwitcher: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Operations Section
          _sectionHeader('DAILY OPERATIONS'),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.assignment_outlined,
                  iconColor: const Color(0xFF2563EB),
                  title: 'Service Requests',
                  subtitle: 'Triage incoming customer repair calls & requests',
                  onTap: () => context.push('/service-requests'),
                ),
                const Divider(height: 1),
                _menuTile(
                  icon: Icons.calendar_month_outlined,
                  iconColor: const Color(0xFF0F766E),
                  title: 'Appointments & Dispatch',
                  subtitle: 'Daily technician calendar & scheduling',
                  onTap: () => context.push('/schedule'),
                ),
                const Divider(height: 1),
                _menuTile(
                  icon: Icons.construction_outlined,
                  iconColor: const Color(0xFFD97706),
                  title: 'Work Orders & Field Jobs',
                  subtitle: 'Technician checklists, photos & customer sign-off',
                  onTap: () => context.push('/work-orders'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Financials & Sales
          _sectionHeader('SALES & BILLING'),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.request_quote_outlined,
                  iconColor: const Color(0xFF7C3AED),
                  title: 'Estimates & Quotes',
                  subtitle: 'Create bids, send for approval & auto-generate jobs',
                  onTap: () => context.push('/estimates'),
                ),
                const Divider(height: 1),
                _menuTile(
                  icon: Icons.receipt_long_outlined,
                  iconColor: const Color(0xFF16A34A),
                  title: 'Invoices & Balances',
                  subtitle: 'Manage client billing, overdue balances & PDFs',
                  onTap: () => context.push('/invoices'),
                ),
                const Divider(height: 1),
                _menuTile(
                  icon: Icons.payments_outlined,
                  iconColor: const Color(0xFF0D9488),
                  title: 'Payment Transactions',
                  subtitle: 'Record cash, check, and card payments',
                  onTap: () => context.push('/payments'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Catalog & Settings
          _sectionHeader('CATALOG & AUTOMATION'),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.category_outlined,
                  iconColor: const Color(0xFF0284C7),
                  title: 'Services & Pricing Catalog',
                  subtitle: 'Manage HVAC, plumbing & repair price books',
                  onTap: () => context.push('/services'),
                ),
                const Divider(height: 1),
                _menuTile(
                  icon: Icons.auto_mode_rounded,
                  iconColor: const Color(0xFFEA580C),
                  title: 'Business Automations',
                  subtitle: 'Auto-invoice, auto-work-order & reminder rules',
                  onTap: () => context.push('/automations'),
                ),
                const Divider(height: 1),
                _menuTile(
                  icon: Icons.analytics_outlined,
                  iconColor: const Color(0xFF4F46E5),
                  title: 'Reports & Business Analytics',
                  subtitle: 'Revenue, job completion rates & team performance',
                  onTap: () => context.push('/reports'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Team & Organization
          _sectionHeader('COMPANY & TEAM'),
          const SizedBox(height: 8),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.badge_outlined,
                  iconColor: const Color(0xFF475569),
                  title: 'Team & Technicians',
                  subtitle: 'Manage roster, technician skills & invite staff',
                  onTap: () => context.push('/team'),
                ),
                const Divider(height: 1),
                _menuTile(
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.error,
                  title: 'Sign Out',
                  subtitle: 'End current session on this device',
                  onTap: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
          color: AppColors.textMutedLight,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: AppTypography.cardTitle.copyWith(fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.caption,
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: AppColors.textMutedLight,
      ),
      onTap: onTap,
    );
  }
}
