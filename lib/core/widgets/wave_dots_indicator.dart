import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Professional animated wave dots loader (Tamwojat n9itat).
/// Replaces generic circular web-like progress indicators with a sleek native mobile feel.
class WaveDotsIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final double waveHeight;
  final int count;
  final Duration duration;

  const WaveDotsIndicator({
    super.key,
    this.color = Colors.white,
    this.size = 8.0,
    this.waveHeight = 6.0,
    this.count = 3,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  State<WaveDotsIndicator> createState() => _WaveDotsIndicatorState();
}

class _WaveDotsIndicatorState extends State<WaveDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.count, (index) {
            // Stagger each dot along a sine wave
            final step = (index / widget.count) * 2 * math.pi;
            final progress = (_controller.value * 2 * math.pi) - step;
            final sine = math.sin(progress);

            // Calculate vertical translation and opacity
            final dy = -sine.clamp(0.0, 1.0) * widget.waveHeight;
            final opacity = 0.35 + (0.65 * (sine + 1) / 2);
            final scale = 0.85 + (0.3 * (sine + 1) / 2);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: widget.size * 0.4),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity.clamp(0.2, 1.0),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: widget.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.color.withAlpha(60),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
