import 'package:flutter/material.dart';

/// Brand colors that stay constant across themes, plus the per-mode surfaces.
///
/// The app's identity is warm and cozy: a soft brown on cream in light mode,
/// and the same brown family on a "lamp-lit" warm dark brown in dark mode.
class BrandColors {
  // Core identity
  static const Color primary = Color(0xFF8b6f47); // warm brown

  // Light mode
  static const Color cream = Color(0xFFF5EBE0); // scaffold bg
  static const Color lightSurface = Colors.white; // cards, sheets, inputs
  static const Color lightText = Color(0xFF4a4a4a);

  // Dark mode ("lamp-lit" — warm, never pure black)
  static const Color darkBg = Color(0xFF1E1813); // scaffold bg
  static const Color darkSurface = Color(0xFF2A221B); // cards, sheets, inputs
  static const Color darkPrimary = Color(0xFFC9A876); // lighter tan accent
  static const Color darkText = Color(0xFFEAE0D2); // warm off-white
}

/// Semantic, theme-aware colors for widget code.
///
/// Prefer these over `Theme.of(context).colorScheme...` chains: they keep
/// screens terse and guarantee text stays legible in both modes. Dark mode
/// uses higher alphas than light because light-on-dark text needs more
/// opacity for the same perceived contrast.
extension AppColorsX on BuildContext {
  ColorScheme get _scheme => Theme.of(this).colorScheme;
  bool get _isDark => _scheme.brightness == Brightness.dark;

  /// Brand accent: warm brown (light) / soft tan (dark).
  Color get accent => _scheme.primary;

  /// Card / sheet / input background.
  Color get surface => _scheme.surface;

  /// Primary body text.
  Color get textPrimary => _scheme.onSurface;

  /// Subtitles, captions, counts.
  Color get textSecondary =>
      _scheme.onSurface.withValues(alpha: _isDark ? 0.78 : 0.65);

  /// Hints and disabled labels.
  Color get textFaint =>
      _scheme.onSurface.withValues(alpha: _isDark ? 0.55 : 0.45);

  /// Subtle accent fill behind icons, tags, and highlights.
  Color get accentSoft =>
      _scheme.primary.withValues(alpha: _isDark ? 0.16 : 0.10);

  /// Borders and outlines on cards and inputs.
  Color get outline => _scheme.primary.withValues(alpha: 0.3);

  /// Unfilled portion of progress bars.
  Color get track => _scheme.primary.withValues(alpha: _isDark ? 0.22 : 0.15);
}

/// Centralized light + dark themes. Component defaults (cards, chips,
/// progress bars, dialogs, dividers) live here so screens rarely need to
/// style them inline.
class AppTheme {
  AppTheme._();

  static ThemeData get light => _theme(
        brightness: Brightness.light,
        accent: BrandColors.primary,
        scaffold: BrandColors.cream,
        surface: BrandColors.lightSurface,
        bodyText: BrandColors.lightText,
        appBarBg: BrandColors.primary,
        appBarFg: Colors.white,
        buttonFg: Colors.white,
      );

  static ThemeData get dark => _theme(
        brightness: Brightness.dark,
        accent: BrandColors.darkPrimary,
        scaffold: BrandColors.darkBg,
        surface: BrandColors.darkSurface,
        bodyText: BrandColors.darkText,
        appBarBg: BrandColors.darkSurface,
        appBarFg: BrandColors.darkText,
        buttonFg: BrandColors.darkBg,
      );

  static ThemeData _theme({
    required Brightness brightness,
    required Color accent,
    required Color scaffold,
    required Color surface,
    required Color bodyText,
    required Color appBarBg,
    required Color appBarFg,
    required Color buttonFg,
  }) {
    final isDark = brightness == Brightness.dark;
    final track = accent.withValues(alpha: isDark ? 0.22 : 0.15);

    return ThemeData(
      brightness: brightness,
      primaryColor: accent,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.primary,
        brightness: brightness,
        surface: surface,
        primary: accent,
      ),
      fontFamily: 'serif',
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 2,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: accent.withValues(alpha: 0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: buttonFg,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: accent,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: accent,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: bodyText),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: track,
        circularTrackColor: track,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accent.withValues(alpha: isDark ? 0.16 : 0.08),
        selectedColor: accent.withValues(alpha: 0.3),
        labelStyle: TextStyle(color: bodyText),
        checkmarkColor: accent,
        side: BorderSide(color: accent.withValues(alpha: 0.25)),
      ),
      dialogTheme: DialogThemeData(backgroundColor: surface),
      dividerTheme: DividerThemeData(
        color: accent.withValues(alpha: 0.15),
      ),
      // Sheets draw their own rounded containers; a transparent default
      // stops square corners peeking out behind them.
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
