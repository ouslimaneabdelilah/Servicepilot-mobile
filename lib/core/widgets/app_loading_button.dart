import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'wave_dots_indicator.dart';

/// Compact, sleek, professional native mobile button with clean icon integration.
/// Designed with refined 44px height, 12px rounded geometry, and subtle depth.
class AppLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;
  final bool outlined;
  final bool isIconOnly;

  const AppLoadingButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 44.0,
    this.borderRadius = 12.0,
    this.outlined = false,
    this.isIconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? (outlined ? effectiveBg : Colors.white);
    final isInteractive = !loading && onPressed != null;

    if (outlined) {
      return SizedBox(
        height: height,
        width: isIconOnly ? height : null,
        child: OutlinedButton(
          onPressed: isInteractive ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: effectiveTextColor,
            side: BorderSide(color: effectiveBg, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: isIconOnly ? 0 : 16),
            textStyle: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, letterSpacing: 0.2),
          ),
          child: _buildContent(effectiveTextColor),
        ),
      );
    }

    return Container(
      height: height,
      width: isIconOnly ? height : null,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isInteractive
            ? [
                BoxShadow(
                  color: effectiveBg.withValues(alpha: 0.20),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: isInteractive ? effectiveBg : effectiveBg.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isInteractive ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: Colors.white.withValues(alpha: 0.18),
          highlightColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isIconOnly ? 0 : 16),
            child: _buildContent(effectiveTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textCol) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: loading
          ? Center(
              key: const ValueKey('btn_loading'),
              child: WaveDotsIndicator(
                color: textCol,
                size: 6.5,
                waveHeight: 4.5,
              ),
            )
          : Row(
              key: const ValueKey('btn_content'),
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: isIconOnly ? MainAxisSize.min : MainAxisSize.max,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: textCol),
                  if (!isIconOnly && label.isNotEmpty) const SizedBox(width: 8),
                ],
                if (!isIconOnly && label.isNotEmpty)
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: textCol,
                    ),
                  ),
              ],
            ),
    );
  }
}
