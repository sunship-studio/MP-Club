import 'package:flutter/material.dart';
import 'package:mpc_admin_app/core/theme/app_colors.dart';
import 'package:mpc_admin_app/core/theme/design_system.dart';

/// Application theme configuration
/// Provides complete ThemeData for both light and dark modes
class AppTheme {
  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.light.buttonPrimary,
        secondary: AppColors.light.buttonPrimary,
        surface: AppColors.light.scaffold,
        error: AppColors.light.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.light.textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.light.scaffold,

      // Card
      cardTheme: CardThemeData(
        color: AppColors.light.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusCard),
        ),
        shadowColor: Colors.black.withOpacity(0.08),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.light.textSecondary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.light.textTertiary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.light.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w600,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: AppColors.light.textPrimary),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.light.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: AppColors.light.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: AppColors.light.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(
            color: AppColors.light.buttonPrimary,
            width: 2,
          ),
        ),
        hintStyle: TextStyle(
          color: AppColors.light.textTertiary,
          fontFamily: 'SF-Pro',
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.light.divider,
        thickness: 1,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.light.scaffold,
        foregroundColor: AppColors.light.textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.light.textPrimary),
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: AppColors.dark.buttonPrimary,
        secondary: AppColors.dark.buttonPrimary,
        surface: AppColors.dark.scaffold,
        error: AppColors.dark.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.dark.textPrimary,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.dark.scaffold,

      // Card
      cardTheme: CardThemeData(
        color: AppColors.dark.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusCard),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w700,
        ),
        displayMedium: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: AppColors.dark.textSecondary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: AppColors.dark.textTertiary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: AppColors.dark.textPrimary,
          fontFamily: 'SF-Pro',
          fontWeight: FontWeight.w600,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: AppColors.dark.textPrimary),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.dark.input,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: AppColors.dark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: AppColors.dark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusMedium),
          borderSide: BorderSide(color: AppColors.dark.buttonPrimary, width: 2),
        ),
        hintStyle: TextStyle(
          color: AppColors.dark.textTertiary,
          fontFamily: 'SF-Pro',
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.dark.divider,
        thickness: 1,
      ),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark.scaffold,
        foregroundColor: AppColors.dark.textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.dark.textPrimary),
      ),
    );
  }
}
