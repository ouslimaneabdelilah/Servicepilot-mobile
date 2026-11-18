import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'wave_dots_indicator.dart';

/// Enterprise native mobile button with tactile depth, rounded geometry,
/// smooth micro-interactions, and integrated wave loading animation.
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

  const AppLoadingButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 54.0,
    this.borderRadius = 16.0,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.primary;
    final effectiveTextColor = textColor ?? (outlined ? effectiveBg : Colors.white);
    final isInteractive = !loading && onPressed != null;

    if (outlined) {
      return SizedBox(
        height: height,
        child: OutlinedButton(
          onPressed: isInteractive ? onPressed : null,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: effectiveTextColor,
            side: BorderSide(color: effectiveBg, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            elevation: 0,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.2),
          ),
          child: _buildContent(effectiveTextColor),
        ),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isInteractive
            ? [
                BoxShadow(
                  color: effectiveBg.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
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
          splashColor: Colors.white.withValues(alpha: 0.20),
          highlightColor: Colors.white.withValues(alpha: 0.10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildContent(effectiveTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color textCol) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: loading
          ? Center(
              key: const ValueKey('btn_loading'),
              child: WaveDotsIndicator(
                color: textCol,
                size: 8,
                waveHeight: 6,
              ),
            )
          : Row(
              key: const ValueKey('btn_content'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: textCol),
                  const SizedBox(width: 9),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                    color: textCol,
                  ),
                ),
              ],
            ),
    );
  }
}
