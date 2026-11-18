import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/wave_dots_indicator.dart';

/// Professional branded startup splash screen.
/// Displays while restoring user session from local secure storage,
/// ensuring zero visual flickering of the Login screen for logged-in users.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Brand Icon Card
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.30),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.home_repair_service_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Brand Name
              const Text(
                'SERVICEPILOT',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Field Service Management',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondaryLight,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(flex: 2),

              // Modern Loading Wave
              const SizedBox(
                height: 24,
                child: WaveDotsIndicator(
                  color: AppColors.primary,
                  size: 8,
                  waveHeight: 6,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
