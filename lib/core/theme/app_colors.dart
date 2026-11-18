import 'package:flutter/material.dart';

/// Centralized semantic design tokens for ServicePilot.
/// Designed for enterprise B2B Field Service SaaS (American trades: HVAC, Plumbing, Electrical).
class AppColors {
  AppColors._();

  // Primary & Brand (Professional Deep Navy & Electric Royal Blue)
  static const Color primary = Color(0xFF1E3A8A); // Deep Navy
  static const Color primaryLight = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF172554); // Midnight
  static const Color primarySurface = Color(0xFFEFF6FF); // Light Blue Tint

  // Secondary & Accents
  static const Color secondary = Color(0xFF0F766E); // Deep Teal / Precision
  static const Color secondarySurface = Color(0xFFF0FDFA);
  static const Color accent = Color(0xFF4F46E5); // Indigo Accent

  // Neutral Surfaces (Light Mode)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceCardLight = Color(0xFFFFFFFF);
  static const Color surfaceSecondaryLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtleLight = Color(0xFFF1F5F9);

  // Neutral Surfaces (Dark Mode)
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color surfaceCardDark = Color(0xFF1E293B);
  static const Color surfaceSecondaryDark = Color(0xFF334155); // Slate 700
  static const Color borderDark = Color(0xFF334155); // Slate 700
  static const Color borderSubtleDark = Color(0xFF1E293B);

  // Text Colors (Light Mode)
  static const Color textPrimaryLight = Color(0xFF0F172A); // Slate 900
  static const Color textSecondaryLight = Color(0xFF475569); // Slate 600
  static const Color textMutedLight = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Text Colors (Dark Mode)
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color textMutedDark = Color(0xFF64748B); // Slate 500

  // Semantic Status Colors (Consistent across themes)
  // Success (Completed, Approved, Paid)
  static const Color success = Color(0xFF16A34A); // Green 600
  static const Color successSurface = Color(0xFFF0FDF4); // Green 50
  static const Color successBorder = Color(0xFFBBF7D0); // Green 200
  static const Color successText = Color(0xFF15803D); // Green 700

  // Warning (Pending, Expiring, Rescheduled)
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningSurface = Color(0xFFFFFBEB); // Amber 50
  static const Color warningBorder = Color(0xFFFDE68A); // Amber 200
  static const Color warningText = Color(0xFFB45309); // Amber 700

  // Danger / Error (Overdue, Rejected, Cancelled, Deleted)
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorSurface = Color(0xFFFEF2F2); // Red 50
  static const Color errorBorder = Color(0xFFFECACA); // Red 200
  static const Color errorText = Color(0xFFB91C1C); // Red 700

  // Information (Scheduled, In Progress, Draft)
  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoSurface = Color(0xFFF0F9FF); // Sky 50
  static const Color infoBorder = Color(0xFFBAE6FD); // Sky 200
  static const Color infoText = Color(0xFF0369A1); // Sky 700
}
