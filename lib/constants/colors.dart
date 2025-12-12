import 'package:flutter/material.dart';

// Light Theme Colors (Yellow/Gold Palette)
class AppColorsLight {
  // Primary Colors
  static const Color primary = Color(0xFFFCB90B); // Primary Yellow/Gold
  static const Color primaryHighlight = Color(0xFFFFECA1); // Highlight
  static const Color primaryDarker = Color(0xFFD18E00); // Darker Yellow

  // Background & Surface
  static const Color background = Color(0xFFF1F1F1); // Background Light
  static const Color surface = Color(0xFFFFFFFF); // Surface Light
  static const Color cardSurface = Color(0xFFFFFFFF); // Card Surface Light

  // Text & Stroke
  static const Color textPrimary = Color(0xFF45464A); // Stroke/Line
  static const Color textSecondary = Color(0xFF9E9E9E); // Disabled Text
  static const Color textDisabled = Color(0xFF9E9E9E);

  // Borders & Dividers
  static const Color divider = Color(0xFFD9D9D9);
  static const Color stroke = Color(0xFF45464A);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFDC2626);
  static const Color dangerBg = Color(0xFFFEF2F2);

  // Special
  static const Color shadow = Color(0x10000000);
}

// Dark Theme Colors (Gold Palette - Consistent with Light)
class AppColorsDark {
  // Primary Colors
  static const Color primary =
      Color(0xFFFCB90B); // Primary Gold (same as light)
  static const Color primaryHighlight =
      Color(0xFFFFECA1); // Highlight (same as light)
  static const Color primaryDarker =
      Color(0xFFD18E00); // Darker Gold (same as light)

  // Background & Surface
  static const Color background = Color(0xFF1A1B1E); // Background Dark
  static const Color surface = Color(0xFF2C2D31); // Surface Dark
  static const Color cardSurface = Color(0xFF2C2D31); // Card Surface Dark

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFF9E9E9E);

  // Borders & Dividers
  static const Color divider = Color(0xFFD9D9D9);
  static const Color stroke = Color(0xFF45464A);

  // Status Colors
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFEAB308);
  static const Color error = Color(0xFFEF4444);
  static const Color dangerBg = Color(0xFF451A1A);

  // Special
  static const Color shadow = Color(0xFF010102); // Deepest Shadow
}

// Helper class to get colors based on brightness
class AppColors {
  static Color primary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.primary
        : AppColorsDark.primary;
  }

  static Color primaryHighlight(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.primaryHighlight
        : AppColorsDark.primaryHighlight;
  }

  static Color primaryDarker(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.primaryDarker
        : AppColorsDark.primaryDarker;
  }

  static Color background(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.background
        : AppColorsDark.background;
  }

  static Color surface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.surface
        : AppColorsDark.surface;
  }

  static Color cardSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.cardSurface
        : AppColorsDark.cardSurface;
  }

  static Color textPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.textPrimary
        : AppColorsDark.textPrimary;
  }

  static Color textSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.textSecondary
        : AppColorsDark.textSecondary;
  }

  static Color textDisabled(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.textDisabled
        : AppColorsDark.textDisabled;
  }

  static Color divider(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.divider
        : AppColorsDark.divider;
  }

  static Color stroke(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.stroke
        : AppColorsDark.stroke;
  }

  static Color success(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.success
        : AppColorsDark.success;
  }

  static Color warning(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.warning
        : AppColorsDark.warning;
  }

  static Color error(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.error
        : AppColorsDark.error;
  }

  static Color dangerBg(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.dangerBg
        : AppColorsDark.dangerBg;
  }

  static Color shadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? AppColorsLight.shadow
        : AppColorsDark.shadow;
  }

  // Alias methods for convenience
  static Color highlight(BuildContext context) {
    return primaryHighlight(context);
  }

  static Color darker(BuildContext context) {
    return primaryDarker(context);
  }

  static Color disabled(BuildContext context) {
    return textDisabled(context);
  }
}
