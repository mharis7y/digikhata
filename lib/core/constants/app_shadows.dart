import 'package:flutter/material.dart';

/// All Elevation & Shadow Tokens per DigiKhata Clone Design System in agents.md.
///
/// Use soft shadows instead of heavy borders.
class AppShadows {
  AppShadows._();

  /// Elevation Level 1: 0 2 8 rgba(0,0,0,.06)
  /// Used for standard cards and buttons.
  static final List<BoxShadow> level1 = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      offset: const Offset(0, 2),
      blurRadius: 8.0,
      spreadRadius: 0,
    ),
  ];

  /// Elevation Level 2: 0 6 20 rgba(0,0,0,.08)
  /// Used for dropdowns, hover states, and elevated cards.
  static final List<BoxShadow> level2 = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.08),
      offset: const Offset(0, 6),
      blurRadius: 20.0,
      spreadRadius: 0,
    ),
  ];

  /// Elevation Level 3: 0 10 32 rgba(0,0,0,.12)
  /// Used for modals, dialogs, and bottom sheets.
  static final List<BoxShadow> level3 = [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.12),
      offset: const Offset(0, 10),
      blurRadius: 32.0,
      spreadRadius: 0,
    ),
  ];
}
