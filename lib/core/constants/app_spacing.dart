import 'package:flutter/material.dart';

/// All Spacing Tokens and Component Padding rules per DigiKhata Clone Design System in agents.md.
///
/// Spacing System uses an 8-point grid with half-step (4px) and intermediate increments.
class AppSpacing {
  AppSpacing._();

  // ===========================================================================
  // Raw Spacing Tokens (8pt Grid)
  // ===========================================================================
  static const double s4 = 4.0;
  static const double s8 = 8.0;
  static const double s12 = 12.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s56 = 56.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;
  static const double s96 = 96.0;

  // ===========================================================================
  // Component Padding Tokens
  // ===========================================================================
  /// Card internal padding: 16px
  static const EdgeInsets cardPadding = EdgeInsets.all(s16);

  /// Screen external/edge padding: 20px
  static const EdgeInsets screenPadding = EdgeInsets.all(s20);

  /// Dialog internal padding: 24px
  static const EdgeInsets dialogPadding = EdgeInsets.all(s24);

  /// Button padding: Horizontal 20px, Vertical 14px
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: s20,
    vertical: 14.0,
  );

  /// Standard horizontal screen margin
  static const EdgeInsets horizontalScreen = EdgeInsets.symmetric(
    horizontal: s20,
  );
}
