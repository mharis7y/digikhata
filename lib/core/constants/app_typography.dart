import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// All Typography text styles per DigiKhata Clone Design System in agents.md.
///
/// Primary Font: Poppins
/// Fallback: Inter, SF Pro Display (iOS), Roboto (Android)
class AppTypography {
  AppTypography._();

  static const List<String> _fallbacks = [
    'Inter',
    'SF Pro Display',
    'Roboto',
    'sans-serif',
  ];

  /// Display: Size 40, Weight 700 (Bold), Line Height 48 (48/40 = 1.2)
  static TextStyle get display => GoogleFonts.poppins(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 48 / 40,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// H1: Size 32, Weight 700 (Bold), Line Height 40 (40/32 = 1.25)
  static TextStyle get h1 => GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 40 / 32,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// H2: Size 28, Weight 600 (SemiBold), Line Height 36 (36/28 ≈ 1.285)
  static TextStyle get h2 => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// H3: Size 24, Weight 600 (SemiBold), Line Height 32 (32/24 ≈ 1.333)
  static TextStyle get h3 => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// H4: Size 20, Weight 500 (Medium), Line Height 28 (28/20 = 1.4)
  static TextStyle get h4 => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 28 / 20,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// H5: Size 18, Weight 500 (Medium), Line Height 26 (26/18 ≈ 1.444)
  static TextStyle get h5 => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 26 / 18,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// H6: Size 16, Weight 500 (Medium), Line Height 24 (24/16 = 1.5)
  static TextStyle get h6 => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// Body Large: Size 16, Weight 400 (Regular), Line Height 24 (24/16 = 1.5)
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// Body: Size 14, Weight 400 (Regular), Line Height 22 (22/14 ≈ 1.571)
  static TextStyle get body => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 22 / 14,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// Small: Size 12, Weight 400 (Regular), Line Height 18 (18/12 = 1.5)
  static TextStyle get small => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 18 / 12,
        color: AppColors.textSecondary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// Caption: Size 11, Weight 500 (Medium), Line Height 16 (16/11 ≈ 1.454)
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        color: AppColors.textSecondary,
      ).copyWith(fontFamilyFallback: _fallbacks);

  /// Label: Size 13, Weight 500 (Medium), Line Height 20 (20/13 ≈ 1.538)
  static TextStyle get label => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 20 / 13,
        color: AppColors.textPrimary,
      ).copyWith(fontFamilyFallback: _fallbacks);
}
