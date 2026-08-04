import 'package:flutter/material.dart';

/// All Brand and Semantic Colors per DigiKhata Clone Design System in agents.md.
///
/// Theme: Blue Theme throughout the app (Primary Blue #285CCC + Buttermilk #FFF2BD).
/// No dark mode is supported per design rules.
class AppColors {
  AppColors._();

  // ===========================================================================
  // Primary Palette
  // ===========================================================================
  /// Primary buttons, navigation, active states (#285CCC)
  static const Color primaryBlue = Color(0xFF285CCC);

  /// Button pressed state (#1F4AB0)
  static const Color primaryBlueDark = Color(0xFF1F4AB0);

  /// Hover and highlights (#4F7DDA)
  static const Color primaryBlueLight = Color(0xFF4F7DDA);

  /// Secondary background, cards, empty states (#FFF2BD)
  static const Color buttermilk = Color(0xFFFFF2BD);

  /// Main surfaces (#FFFFFF)
  static const Color white = Color(0xFFFFFFFF);

  /// App background (#F7F9FC)
  static const Color surfaceGray = Color(0xFFF7F9FC);

  /// Borders & dividers (#E6EAF2)
  static const Color borderGray = Color(0xFFE6EAF2);

  /// Main text (#1F2937)
  static const Color textPrimary = Color(0xFF1F2937);

  /// Secondary text (#6B7280)
  static const Color textSecondary = Color(0xFF6B7280);

  /// Disabled text (#9CA3AF)
  static const Color textDisabled = Color(0xFF9CA3AF);

  // ===========================================================================
  // Semantic Colors - Success (Credit transactions, alerts, positive growth)
  // ===========================================================================
  static const Color successPrimary = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);

  // ===========================================================================
  // Semantic Colors - Error (Debit transactions, validation errors, delete actions)
  // ===========================================================================
  static const Color errorPrimary = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  // ===========================================================================
  // Semantic Colors - Warning (Due reminders, pending actions, warnings)
  // ===========================================================================
  static const Color warningPrimary = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);

  // ===========================================================================
  // Semantic Colors - Information (Information cards, reports, notifications)
  // ===========================================================================
  static const Color infoPrimary = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ===========================================================================
  // Chart Colors per agents.md
  // ===========================================================================
  static const Color chartBlue = primaryBlue;
  static const Color chartGreen = successPrimary;
  static const Color chartOrange = warningPrimary;
  static const Color chartRed = errorPrimary;
  static const Color chartGray = textSecondary;
}
