import 'package:flutter/material.dart';

/// Extension methods for easier theme access
extension ThemeExtension on BuildContext {
  /// Get the current color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;

  /// Get the current text theme
  TextTheme get textStyles => Theme.of(this).textTheme;

  /// Get card background color
  Color get cardColor => Theme.of(this).cardTheme.color ?? Colors.white;

  /// Get primary text color
  Color get primaryText => textStyles.bodyLarge?.color ?? Colors.black;

  /// Get secondary text color
  Color get secondaryText => textStyles.bodyMedium?.color ?? Colors.grey;

  /// Get tertiary (hint) text color
  Color get tertiaryText => textStyles.bodySmall?.color ?? Colors.grey;

  /// Get scaffold background color
  Color get scaffoldBackground => Theme.of(this).scaffoldBackgroundColor;

  /// Get divider color
  Color get dividerColor => Theme.of(this).dividerTheme.color ?? Colors.grey;

  /// Check if current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
