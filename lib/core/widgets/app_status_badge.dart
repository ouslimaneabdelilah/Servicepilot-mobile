import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum BadgeVariant { success, warning, error, info, neutral }

/// Semantic status badge for Work Orders, Estimates, Invoices, and Requests.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final double fontSize;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.variant,
    this.icon,
    this.fontSize = 11.5,
  });

  /// Factory helper that automatically parses any domain status string.
  factory AppStatusBadge.fromStatus(String? status) {
    final s = (status ?? 'unknown').toLowerCase().trim();

    // Success: completed, approved, paid, active
    if (s == 'completed' || s == 'approved' || s == 'paid' || s == 'active') {
      return AppStatusBadge(
        label: _format(s),
        variant: BadgeVariant.success,
        icon: Icons.check_circle_rounded,
      );
    }

    // Warning: pending, draft, partial, rescheduled, expiring
    if (s == 'pending' || s == 'draft' || s == 'partial' || s == 'rescheduled' || s == 'medium') {
      return AppStatusBadge(
        label: _format(s),
        variant: BadgeVariant.warning,
        icon: Icons.access_time_rounded,
      );
    }

    // Error: overdue, rejected, cancelled, voided, urgent, failed
    if (s == 'overdue' || s == 'rejected' || s == 'cancelled' || s == 'void' || s == 'urgent' || s == 'emergency') {
      return AppStatusBadge(
        label: _format(s),
        variant: BadgeVariant.error,
        icon: Icons.warning_amber_rounded,
      );
    }

    // Info: scheduled, in_progress, sent, en_route
    if (s == 'scheduled' || s == 'in_progress' || s == 'en_route' || s == 'sent' || s == 'low') {
      return AppStatusBadge(
        label: _format(s),
        variant: BadgeVariant.info,
        icon: Icons.info_outline_rounded,
      );
    }

    return AppStatusBadge(
      label: _format(s),
      variant: BadgeVariant.neutral,
    );
  }

  static String _format(String str) {
    return str.replaceAll('_', ' ').split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color text;

    switch (variant) {
      case BadgeVariant.success:
        bg = AppColors.successSurface;
        border = AppColors.successBorder;
        text = AppColors.successText;
        break;
      case BadgeVariant.warning:
        bg = AppColors.warningSurface;
        border = AppColors.warningBorder;
        text = AppColors.warningText;
        break;
      case BadgeVariant.error:
        bg = AppColors.errorSurface;
        border = AppColors.errorBorder;
        text = AppColors.errorText;
        break;
      case BadgeVariant.info:
        bg = AppColors.infoSurface;
        border = AppColors.infoBorder;
        text = AppColors.infoText;
        break;
      case BadgeVariant.neutral:
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFFE2E8F0);
        text = const Color(0xFF475569);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 1, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
