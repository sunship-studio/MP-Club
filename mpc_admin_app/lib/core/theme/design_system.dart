import 'package:flutter/material.dart';

/// Design System Constants for MPC Admin App
/// Centralized design tokens for consistent UI across the application

// ==================== BORDER RADIUS ====================

/// Small border radius for inputs and minor UI elements
const double kBorderRadiusSmall = 8.0;

/// Medium border radius for buttons and medium-sized containers
const double kBorderRadiusMedium = 12.0;

/// Large border radius for larger containers and sections
const double kBorderRadiusLarge = 16.0;

/// Card border radius for main content cards (modern design standard)
const double kBorderRadiusCard = 20.0;

// ==================== SPACING ====================

/// Extra small spacing (4px) - for tight spacing between related elements
const double kSpacingXSmall = 4.0;

/// Small spacing (8px) - for compact layouts
const double kSpacingSmall = 8.0;

/// Medium spacing (12px) - for standard element separation
const double kSpacingMedium = 12.0;

/// Large spacing (16px) - for section padding and margins
const double kSpacingLarge = 16.0;

/// Extra large spacing (20px) - for major sections
const double kSpacingXLarge = 20.0;

/// Extra extra large spacing (24px) - for screen-level padding
const double kSpacingXXLarge = 24.0;

/// Extra extra extra large spacing (32px) - for major screen sections
const double kSpacingXXXLarge = 32.0;

// ==================== SHADOWS ====================

/// Light shadow for subtle elevation (buttons, small cards)
/// Theme-aware: Adjusts opacity based on light/dark mode
List<BoxShadow> kShadowLight(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

/// Medium shadow for standard cards and elevated content
/// Theme-aware: Adjusts opacity based on light/dark mode
List<BoxShadow> kShadowMedium(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Heavy shadow for modals, dialogs, and prominent UI elements
/// Theme-aware: Adjusts opacity based on light/dark mode
List<BoxShadow> kShadowHeavy(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

/// Extra heavy shadow for floating action buttons and popovers
/// Theme-aware: Adjusts opacity based on light/dark mode
List<BoxShadow> kShadowXHeavy(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return [
    BoxShadow(
      color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
  ];
}

// ==================== BACKGROUND COLORS ====================

/// Modern light background color (used in public_plan_editor.dart)
const Color kBackgroundLight = Color(0xFFF5F7FA);

/// Pure white background for cards and containers
const Color kBackgroundWhite = Colors.white;

// ==================== ANIMATION DURATIONS ====================

/// Fast animation duration for button presses and quick transitions
const Duration kAnimationFast = Duration(milliseconds: 150);

/// Standard animation duration for most transitions
const Duration kAnimationStandard = Duration(milliseconds: 300);

/// Slow animation duration for complex transitions
const Duration kAnimationSlow = Duration(milliseconds: 500);

// ==================== BORDER RADIUS HELPERS ====================

/// Helper to create consistent border radius for small elements
BorderRadius get kBorderRadiusSmallAll => BorderRadius.circular(kBorderRadiusSmall);

/// Helper to create consistent border radius for medium elements
BorderRadius get kBorderRadiusMediumAll => BorderRadius.circular(kBorderRadiusMedium);

/// Helper to create consistent border radius for large elements
BorderRadius get kBorderRadiusLargeAll => BorderRadius.circular(kBorderRadiusLarge);

/// Helper to create consistent border radius for cards
BorderRadius get kBorderRadiusCardAll => BorderRadius.circular(kBorderRadiusCard);

// ==================== COMMON DECORATIONS ====================

/// Standard card decoration with theme-aware background and shadow
/// Use: `kCardDecoration(context)`
BoxDecoration kCardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).cardTheme.color,
  borderRadius: kBorderRadiusCardAll,
  boxShadow: kShadowMedium(context),
);

/// Input decoration with theme-aware background and border
/// Use: `kInputDecoration(context)`
BoxDecoration kInputDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).inputDecorationTheme.fillColor,
  borderRadius: kBorderRadiusLargeAll,
  border: Border.all(
    color: Theme.of(context).dividerTheme.color ?? Colors.grey,
  ),
);
