import 'package:flutter/material.dart';

class AppColors {
  // Legacy colors (kept for backwards compatibility)
  static const Color blueColor = Color.fromRGBO(1, 96, 143, 1);
  static const Color errorColor = Color.fromRGBO(220, 38, 38, 1);
  static const Color orangeColor = Color.fromRGBO(180, 83, 9, 1);
  static const Color redColor = Color.fromRGBO(223, 28, 65, 1);

  // New semantic color system (light theme)
  static const LightColors light = LightColors();

  // New semantic color system (dark theme)
  static const DarkColors dark = DarkColors();

  // Backward compatibility getters - maps old property names to new structure
  // These allow existing code to continue working while we migrate
  static Color get darkScaffoldColor => dark.scaffold;
  static Color get lightScaffoldColor => light.scaffold;
  static Color get lightScaffoldColor2 => light.cardSecondary;
  static Color get darkCardColor => dark.card;
  static Color get lightCardColor => light.card;
  static Color get darkTextColor =>
      light.textPrimary; // Note: confusing name, but keeping for compatibility
  static Color get lightTextColor => dark.textPrimary;
  static Color get textSubColor => light.textSecondary;
  static Color get greyTextColor => light.textTertiary;
  static Color get darkButtonColor => dark.cardSecondary;
  static Color lightCardColor2 = light.cardSecondary.withValues(alpha: 0.07);
  static Color dividerColor = light.scaffold.withValues(alpha: 0.1);
}

/// Light theme color palette
class LightColors {
  const LightColors();

  // Surfaces
  final Color scaffold = const Color.fromRGBO(247, 247, 247, 1);
  final Color card = Colors.white;
  final Color cardSecondary = const Color.fromRGBO(240, 240, 240, 1);
  final Color input = const Color(0xFFF5F7FA);

  // Text
  final Color textPrimary = const Color.fromRGBO(17, 24, 39, 1);
  final Color textSecondary = const Color.fromRGBO(82, 88, 102, 1);
  final Color textTertiary = const Color.fromRGBO(134, 140, 152, 1);
  final Color textOnDark = Colors.white;

  // Borders & Dividers
  final Color border = const Color.fromRGBO(229, 231, 235, 1);
  final Color borderLight = const Color.fromRGBO(243, 244, 246, 1);
  final Color divider = const Color.fromRGBO(10, 13, 20, 0.1);

  // Interactive
  final Color buttonPrimary = const Color.fromRGBO(1, 96, 143, 1);
  final Color buttonSecondary = const Color.fromRGBO(229, 231, 235, 1);
  final Color buttonDanger = const Color.fromRGBO(220, 38, 38, 1);

  // Status
  final Color success = const Color(0xFF059669);
  final Color error = const Color.fromRGBO(220, 38, 38, 1);
  final Color warning = const Color.fromRGBO(180, 83, 9, 1);
  final Color info = const Color.fromRGBO(1, 96, 143, 1);
}

/// Dark theme color palette
class DarkColors {
  const DarkColors();

  // Surfaces
  final Color scaffold = const Color.fromRGBO(10, 13, 20, 1);
  final Color card = const Color.fromARGB(255, 21, 24, 30);
  final Color cardSecondary = const Color.fromRGBO(39, 41, 48, 1);
  final Color input = const Color.fromARGB(255, 21, 24, 30);

  // Text
  final Color textPrimary = const Color.fromARGB(255, 232, 232, 232);
  final Color textSecondary = const Color.fromRGBO(156, 163, 175, 1);
  final Color textTertiary = const Color.fromRGBO(107, 114, 128, 1);
  final Color textOnDark = Colors.white;

  // Borders & Dividers
  final Color border = const Color.fromRGBO(55, 65, 81, 1);
  final Color borderLight = const Color.fromRGBO(75, 85, 99, 1);
  final Color divider = const Color.fromARGB(26, 48, 43, 43);

  // Interactive
  final Color buttonPrimary = const Color.fromRGBO(1, 96, 143, 1);
  final Color buttonSecondary = const Color.fromRGBO(55, 65, 81, 1);
  final Color buttonDanger = const Color.fromRGBO(239, 68, 68, 1);

  // Status
  final Color success = const Color(0xFF10B981);
  final Color error = const Color.fromRGBO(239, 68, 68, 1);
  final Color warning = const Color.fromRGBO(251, 146, 60, 1);
  final Color info = const Color.fromRGBO(14, 165, 233, 1);
}
