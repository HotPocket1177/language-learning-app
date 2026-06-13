import 'package:flutter/material.dart';

/// Brand colors that stay constant across themes, plus the per-mode surfaces.
///
/// The app's identity is warm and cozy: a soft brown on cream in light mode,
/// and the same brown family on a "lamp-lit" warm dark brown in dark mode.
class BrandColors {
  // Core identity
  static const Color primary = Color(0xFF8b6f47); // warm brown
  static const Color primaryDark = Color(0xFF6f583a);

  // Light mode
  static const Color cream = Color(0xFFF5EBE0); // scaffold bg
  static const Color lightSurface = Colors.white; // cards
  static const Color lightText = Color(0xFF4a4a4a);

  // Dark mode ("lamp-lit" — warm, never pure black)
  static const Color darkBg = Color(0xFF1E1813); // scaffold bg
  static const Color darkSurface = Color(0xFF2A221B); // cards
  static const Color darkPrimary = Color(0xFFC9A876); // lighter tan accent
  static const Color darkText = Color(0xFFEAE0D2); // warm off-white
}

/// Centralized light + dark themes. Built from the original inline theme in
/// main.dart so the light look is unchanged.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    const seed = BrandColors.primary;
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: seed,
      scaffoldBackgroundColor: BrandColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
        surface: BrandColors.lightSurface, // white cards; scaffold stays cream
      ),
      fontFamily: 'serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      cardTheme: _cardTheme(BrandColors.lightSurface, seed),
      elevatedButtonTheme: _buttonTheme(seed),
      textTheme: _textTheme(headingColor: seed, bodyColor: BrandColors.lightText),
    );
  }

  static ThemeData get dark {
    const accent = BrandColors.darkPrimary;
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accent,
      scaffoldBackgroundColor: BrandColors.darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.primary,
        brightness: Brightness.dark,
        surface: BrandColors.darkSurface,
        primary: accent,
      ),
      fontFamily: 'serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: BrandColors.darkSurface,
        foregroundColor: BrandColors.darkText,
        elevation: 2,
      ),
      cardTheme: _cardTheme(BrandColors.darkSurface, accent),
      elevatedButtonTheme: _buttonTheme(accent, onColor: const Color(0xFF1E1813)),
      textTheme:
          _textTheme(headingColor: accent, bodyColor: BrandColors.darkText),
    );
  }

  // ---- Shared builders ----

  static CardThemeData _cardTheme(Color color, Color border) => CardThemeData(
        color: color,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border.withValues(alpha: 0.3), width: 1),
        ),
      );

  static ElevatedButtonThemeData _buttonTheme(Color bg,
          {Color onColor = Colors.white}) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: onColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static TextTheme _textTheme(
          {required Color headingColor, required Color bodyColor}) =>
      TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: headingColor,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: headingColor,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: bodyColor),
      );
}
