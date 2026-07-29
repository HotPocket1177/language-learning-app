import 'package:flutter/material.dart';

/// Brand colors that stay constant across themes, plus the per-mode surfaces.
///
/// The app's identity is warm and cozy: a soft brown on cream in light mode,
/// and the same brown family on a "lamp-lit" warm dark brown in dark mode.
/// A punchy coral accent keeps things lively so the eye stays awake.
class BrandColors {
  // Core identity
  static const Color primary = Color(0xFF8b6f47); // warm brown

  // Lively accent — used sparingly for energy (streaks, heroes, CTAs)
  static const Color coral = Color(0xFFFF6B5C); // warm coral
  static const Color coralDark = Color(0xFFFF8578); // lifted for dark mode

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

/// A warm-but-varied palette that gives each content category its own
/// identity. Colors are mid-saturation so they stay legible on both the
/// cream (light) and warm-brown (dark) surfaces. Used for chips, badges,
/// and category headers to make lists "pop" without feeling loud.
class CategoryColors {
  const CategoryColors._();

  static const Map<String, Color> _byName = {
    'Greetings': Color(0xFFFF6B5C), // coral
    'Food': Color(0xFFE8883A), // amber
    'Animals': Color(0xFF6B9E64), // fern green
    'Verbs': Color(0xFF9B72CF), // violet
    'Numbers': Color(0xFF2FA8A0), // teal
    'Colors': Color(0xFFD96BA0), // magenta
    'Travel': Color(0xFF4B93C4), // sky blue
    'Basics': Color(0xFF7A8B99), // slate
  };

  // Fallback ring for unknown categories — same warm-varied family.
  static const List<Color> _ring = [
    Color(0xFFFF6B5C),
    Color(0xFFE8883A),
    Color(0xFF6B9E64),
    Color(0xFF9B72CF),
    Color(0xFF2FA8A0),
    Color(0xFFD96BA0),
    Color(0xFF4B93C4),
    Color(0xFF7A8B99),
  ];

  /// A stable color for [category]. Known categories get a curated hue;
  /// anything else is hashed onto the fallback ring so it stays consistent.
  static Color of(String category) {
    final known = _byName[category];
    if (known != null) return known;
    final idx = category.hashCode.abs() % _ring.length;
    return _ring[idx];
  }
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

  /// Lively secondary accent: coral, lifted a touch in dark mode.
  Color get coral => _isDark ? BrandColors.coralDark : BrandColors.coral;

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

  /// The curated color for a content category (chips, badges, headers).
  Color categoryColor(String category) => CategoryColors.of(category);

  /// The warm "hero" gradient — brown into coral. Great for headers and CTAs.
  /// Reads as energetic but stays in the cozy family.
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: _isDark
            ? const [Color(0xFF6E5636), Color(0xFFB5543F)]
            : const [BrandColors.primary, Color(0xFFC1614E)],
      );
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
        appBarBg: BrandColors.cream,
        appBarFg: BrandColors.primary,
        buttonFg: Colors.white,
      );

  static ThemeData get dark => _theme(
        brightness: Brightness.dark,
        accent: BrandColors.darkPrimary,
        scaffold: BrandColors.darkBg,
        surface: BrandColors.darkSurface,
        bodyText: BrandColors.darkText,
        appBarBg: BrandColors.darkBg,
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
    // Warm shadow instead of stock gray — makes elevation feel cozy, not cold.
    final shadow = (isDark ? Colors.black : BrandColors.primary)
        .withValues(alpha: isDark ? 0.45 : 0.16);

    return ThemeData(
      brightness: brightness,
      primaryColor: accent,
      scaffoldBackgroundColor: scaffold,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BrandColors.primary,
        brightness: brightness,
        surface: surface,
        primary: accent,
        secondary: isDark ? BrandColors.coralDark : BrandColors.coral,
      ),
      fontFamily: 'serif',
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: appBarFg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'serif',
          color: appBarFg,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: shadow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: accent.withValues(alpha: isDark ? 0.22 : 0.12),
            width: 1,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: buttonFg,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'serif',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: accent,
        ),
        headlineMedium: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          color: accent,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: accent,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: bodyText,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: bodyText, height: 1.35),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: track,
        circularTrackColor: track,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: accent.withValues(alpha: isDark ? 0.16 : 0.08),
        selectedColor: accent.withValues(alpha: 0.3),
        labelStyle: TextStyle(
          color: bodyText,
          fontWeight: FontWeight.w600,
          fontFamily: 'serif',
        ),
        checkmarkColor: accent,
        side: BorderSide(color: accent.withValues(alpha: 0.25)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
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
