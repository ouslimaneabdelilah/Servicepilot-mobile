import 'package:flutter/material.dart';
import 'wave_dots_indicator.dart';

class AppLoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const AppLoadingButton({
    super.key,
    required this.onPressed,
    this.loading = false,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.height = 52.0,
    this.borderRadius = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = textColor ?? Colors.white;

    return SizedBox(
      height: height,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ?? const Color(0xFF2457D6),
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: (backgroundColor ?? const Color(0xFF2457D6)).withAlpha(190),
          disabledForegroundColor: effectiveTextColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: loading ? 0 : 1,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: loading
              ? WaveDotsIndicator(
                  key: const ValueKey('loading_dots'),
                  color: effectiveTextColor,
                  size: 8,
                  waveHeight: 6,
                )
              : Row(
                  key: const ValueKey('button_content'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(label),
                  ],
                ),
        ),
      ),
    );
  }
}
