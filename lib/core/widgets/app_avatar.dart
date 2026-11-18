import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// User and company avatar with fallback initials and optional online/role status ring.
class AppAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBadge;
  final Color? badgeColor;

  const AppAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 38.0,
    this.backgroundColor,
    this.textColor,
    this.showBadge = false,
    this.badgeColor,
  });

  String _getInitials() {
    if (name == null || name!.trim().isEmpty) return 'SP';
    final parts = name!.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final effectiveBg = backgroundColor ?? AppColors.primarySurface;
    final effectiveText = textColor ?? AppColors.primary;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: effectiveBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: effectiveText.withAlpha(50),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: effectiveText,
                fontSize: size * 0.38,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
