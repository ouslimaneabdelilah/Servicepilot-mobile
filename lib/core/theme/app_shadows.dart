import 'package:flutter/material.dart';

/// Centralized Elevation and Shadow Tokens for Enterprise SaaS UI.
class AppShadows {
  AppShadows._();

  // Subtle Card Elevation
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.04),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.02),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  // Elevated Card / Interactive Component on Hover/Active
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.08),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  // Dropdown / Popover / Tooltip
  static const List<BoxShadow> dropdown = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.12),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // Bottom Sheet / Modal Dialog
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.20),
      blurRadius: 32,
      offset: Offset(0, -4),
    ),
  ];
}
