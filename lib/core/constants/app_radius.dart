import 'package:flutter/material.dart';

/// All Border Radius Tokens and Component usage per DigiKhata Clone Design System in agents.md.
class AppRadius {
  AppRadius._();

  // ===========================================================================
  // Raw Radius Tokens
  // ===========================================================================
  static const double xs = 4.0;
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double pill = 999.0;

  // ===========================================================================
  // Semantic Usage Tokens per agents.md
  // ===========================================================================
  /// Buttons radius: 12
  static const double button = medium;
  static final BorderRadius buttonRadius = BorderRadius.circular(button);

  /// Cards radius: 16
  static const double card = large;
  static final BorderRadius cardRadius = BorderRadius.circular(card);

  /// Bottom Sheets top corners radius: 24
  static const double bottomSheet = xxl;
  static final BorderRadius bottomSheetRadius = const BorderRadius.only(
    topLeft: Radius.circular(bottomSheet),
    topRight: Radius.circular(bottomSheet),
  );

  /// Dialogs radius: 20
  static const double dialog = xl;
  static final BorderRadius dialogRadius = BorderRadius.circular(dialog);

  /// Text Fields radius: 12
  static const double textField = medium;
  static final BorderRadius textFieldRadius = BorderRadius.circular(textField);

  /// Chips radius: 16 (Pill/Half of height 32)
  static const double chip = large;
  static final BorderRadius chipRadius = BorderRadius.circular(chip);
}
