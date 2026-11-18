import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Typography tokens for ServicePilot.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto'; // Default robust cross-platform font

  // Display Headings
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    height: 1.2,
    color: AppColors.textPrimaryLight,
  );

  // Page Title (AppBars & Main Screen Headers)
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.25,
    color: AppColors.textPrimaryLight,
  );

  // Section Title (Group Headers, Detail Section Dividers)
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: AppColors.textSecondaryLight,
  );

  // Card / Module Title
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
    color: AppColors.textPrimaryLight,
  );

  // Body Regular
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.45,
    color: AppColors.textSecondaryLight,
  );

  // Body Bold / Emphasis
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.4,
    color: AppColors.textPrimaryLight,
  );

  // Labels (Input Field Headers, Badge Text, Metric Titles)
  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.textSecondaryLight,
  );

  // Input Field Value
  static const TextStyle input = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryLight,
  );

  // Captions & Secondary Supporting Text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    color: AppColors.textMutedLight,
  );

  // Button Labels
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: Colors.white,
  );

  // Currency & Metric Stat Large
  static const TextStyle statValue = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    color: AppColors.textPrimaryLight,
  );
}
