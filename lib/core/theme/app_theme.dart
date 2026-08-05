import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_radius.dart';

/// Single Light Theme per DigiKhata Clone Design System in agents.md.
///
/// Features:
/// - Primary Blue #285CCC + Buttermilk #FFF2BD palette
/// - No dark mode
/// - 8pt grid spacing and radius consistency
/// - Poppins typography scale
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.surfaceGray,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: AppColors.white,
        primaryContainer: AppColors.buttermilk,
        onPrimaryContainer: AppColors.primaryBlue,
        secondary: AppColors.buttermilk,
        onSecondary: AppColors.primaryBlue,
        surface: AppColors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.errorPrimary,
        onError: AppColors.white,
      ),

      // AppBar Theme (Height 64, Background White, Title H5) per agents.md
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTypography.h5,
        iconTheme: const IconThemeData(
          color: AppColors.primaryBlue,
          size: 24,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Elevated Button Theme (Height 52, Radius 12, Primary Blue #285CCC)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size(64, 52),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTypography.h6.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme (Secondary Button - Buttermilk bg, Blue border)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.buttermilk,
          foregroundColor: AppColors.primaryBlue,
          minimumSize: const Size(64, 52),
          side: const BorderSide(color: AppColors.primaryBlue, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.buttonRadius,
          ),
          textStyle: AppTypography.h6.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme (No background, Blue text)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryBlue,
          textStyle: AppTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme (Height 56, Radius 12, Border Gray)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTypography.body.copyWith(
          color: AppColors.textSecondary,
        ),
        labelStyle: AppTypography.label.copyWith(
          color: AppColors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: const BorderSide(color: AppColors.borderGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: const BorderSide(color: AppColors.errorPrimary),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.textFieldRadius,
          borderSide: const BorderSide(
            color: AppColors.errorPrimary,
            width: 1.5,
          ),
        ),
      ),

      // Card Theme (Background White, Radius 16, Soft Shadow)
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
      ),

      // Chip Theme (Height 32, Radius 16)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.buttermilk,
        labelStyle: AppTypography.small.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.chipRadius,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Dialog Theme (Radius 20, Padding 24)
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialogRadius,
        ),
      ),

      // Bottom Sheet Theme (Radius 24)
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheetRadius,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardRadius,
        ),
      ),

      // Bottom Navigation Bar Theme (Height 72, Primary Blue)
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryBlue,
        selectedItemColor: AppColors.white,
        unselectedItemColor: AppColors.primaryBlueLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTypography.caption.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.caption.copyWith(
          color: AppColors.primaryBlueLight,
        ),
      ),
    );
  }
}
