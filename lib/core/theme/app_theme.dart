import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors (UI_DESIGN.md)
  static const Color primaryOlive = Color(0xFF91B029);
  static const Color primaryOliveHover = Color(0xFF7A9A1F);
  static const Color forestGreen = Color(0xFF445C3C);
  static const Color mossGreen = Color(0xFF5A6E42);
  static const Color oliveMuted = Color(0xFF6B7A42);

  // Neutral & Text Tokens
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color textDark = Color(0xFF2D3748);
  static const Color slate700 = Color(0xFF334155);
  static const Color textLabel = Color(0xFF4A5568);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color textMeta = Color(0xFFA0AEC0);
  static const Color borderInput = Color(0xFFD1D5DB);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // Legacy aliases mapped to SynProd palette for compatibility
  static const Color tealPrimary = primaryOlive;
  static const Color tealDark = forestGreen;
  static const Color tealLight = Color(0xFFE8F5C8);

  // Semantic & Status Colors
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningText = Color(0xFF92400E);

  static const Color greenSuccess = Color(0xFF10B981);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successText = Color(0xFF065F46);
  static const Color percentageValidBg = Color(0xFFD4F1A8);

  static const Color redError = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color errorText = Color(0xFF991B1B);
  static const Color inputErrorBorder = Color(0xFFF56565);

  // Card & Surface Accents
  static const Color cardBorder = Color(0x33445C3C); // rgba(68, 92, 60, 0.2)
  static const Color cardShadow = Color(0x26445C3C); // rgba(68, 92, 60, 0.15)
  static const Color headerShadow = Color(0x26445C3C);
  static const Color canvasTintEnd = Color(0xFFF0F7E8);
  static const Color softTintStart = Color(0xFFF1F6E8);
  static const Color softTintEnd = Color(0xFFE8F5C8);
  static const Color subtleSurfaceStart = Color(0xFFF9FCF4);

  // Dark Mode Tokens
  static const Color darkCanvasStart = Color(0xFF0F172A);
  static const Color darkCanvasEnd = Color(0xFF132017);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceElevated = Color(0xFF263344);
  static const Color darkInputFill = Color(0xFF162032);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkCardBorder = Color(0x4DA8C842);
  static const Color darkCardShadow = Color(0x55000000);
  static const Color darkSoftTintStart = Color(0xFF22301E);
  static const Color darkSoftTintEnd = Color(0xFF2A3D24);
  static const Color darkSubtleSurface = Color(0xFF1A251B);
  static const Color darkOliveAccent = Color(0xFFA8C842);
  static const Color darkHeadingAccent = Color(0xFFB8D957);
  static const Color darkPercentageValidBg = Color(0xFF23381B);
  static const Color darkWarningBg = Color(0xFF3B2B12);
  static const Color darkWarningText = Color(0xFFFCD34D);
  static const Color darkErrorBg = Color(0xFF3F1A1D);
  static const Color darkErrorText = Color(0xFFFCA5A5);
  static const Color darkSuccessBg = Color(0xFF133829);
  static const Color darkSuccessText = Color(0xFF6EE7B7);

  // Brand Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryOlive, primaryOliveHover],
  );

  static const LinearGradient brandHeadingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forestGreen, primaryOlive],
  );

  static const LinearGradient darkBrandHeadingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkOliveAccent, darkHeadingAccent],
  );

  static const LinearGradient canvasGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [slate50, canvasTintEnd],
  );

  static const LinearGradient darkCanvasGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkCanvasStart, darkCanvasEnd],
  );

  static const LinearGradient softTintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softTintStart, softTintEnd],
  );

  static const LinearGradient darkSoftTintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSoftTintStart, darkSoftTintEnd],
  );

  static const LinearGradient subtleSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [subtleSurfaceStart, softTintStart],
  );

  // Brightness-aware helpers
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static LinearGradient canvasGradientFor(BuildContext context) =>
      isDark(context) ? darkCanvasGradient : canvasGradient;

  static LinearGradient headingGradientFor(BuildContext context) =>
      isDark(context) ? darkBrandHeadingGradient : brandHeadingGradient;

  static LinearGradient softTintGradientFor(BuildContext context) =>
      isDark(context) ? darkSoftTintGradient : softTintGradient;

  static Color cardColorFor(BuildContext context) =>
      isDark(context) ? darkSurface : Colors.white;

  static Color elevatedSurfaceFor(BuildContext context) =>
      isDark(context) ? darkSurfaceElevated : slate50;

  static Color subtleSurfaceFor(BuildContext context) =>
      isDark(context) ? darkSubtleSurface : subtleSurfaceStart;

  static Color softTintColorFor(BuildContext context) =>
      isDark(context) ? darkSoftTintStart : softTintStart;

  static Color cardBorderFor(BuildContext context) =>
      isDark(context) ? darkCardBorder : cardBorder;

  static Color borderFor(BuildContext context) =>
      isDark(context) ? darkBorder : slate200;

  static Color headingColorFor(BuildContext context) =>
      isDark(context) ? darkHeadingAccent : forestGreen;

  static Color primaryTextFor(BuildContext context) =>
      isDark(context) ? slate100 : slate800;

  static Color secondaryTextFor(BuildContext context) =>
      isDark(context) ? slate300 : slate600;

  static Color mutedTextFor(BuildContext context) =>
      isDark(context) ? slate400 : slate500;

  static Color errorBgFor(BuildContext context) =>
      isDark(context) ? darkErrorBg : errorBg;

  static Color errorTextFor(BuildContext context) =>
      isDark(context) ? darkErrorText : errorText;

  static Color warningBgFor(BuildContext context) =>
      isDark(context) ? darkWarningBg : warningBg;

  static Color warningTextFor(BuildContext context) =>
      isDark(context) ? darkWarningText : warningText;

  static Color successBgFor(BuildContext context) =>
      isDark(context) ? darkSuccessBg : successBg;

  static Color successTextFor(BuildContext context) =>
      isDark(context) ? darkSuccessText : successText;

  static const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
    },
  );

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryOlive,
      primary: forestGreen,
      secondary: primaryOlive,
      surface: Colors.white,
      error: redError,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      pageTransitionsTheme: _pageTransitionsTheme,
      scaffoldBackgroundColor: slate50,
      fontFamily: null,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: slate800,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: slate800,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: cardBorder, width: 2),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderInput, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: borderInput, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: forestGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: inputErrorBorder, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: inputErrorBorder, width: 2),
        ),
        labelStyle: const TextStyle(color: textLabel, fontSize: 14),
        hintStyle: const TextStyle(color: textMeta, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOlive,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: primaryOlive),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: forestGreen,
          backgroundColor: softTintStart,
          side: BorderSide(color: primaryOlive.withValues(alpha: 0.35)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: forestGreen,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryOlive,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryOlive,
        inactiveTrackColor: slate200,
        thumbColor: primaryOlive,
        overlayColor: primaryOlive.withValues(alpha: 0.2),
        valueIndicatorColor: forestGreen,
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: softTintEnd,
        secondarySelectedColor: softTintEnd,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: slate600,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          color: forestGreen,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: slate200),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: forestGreen,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: softTintEnd,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: primaryOlive.withValues(alpha: 0.45)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: slate200,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryOlive,
      primary: darkOliveAccent,
      secondary: darkHeadingAccent,
      surface: darkSurface,
      error: darkErrorText,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      pageTransitionsTheme: _pageTransitionsTheme,
      scaffoldBackgroundColor: darkCanvasStart,
      fontFamily: null,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: slate100,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: slate100,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkCardBorder, width: 2),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: darkOliveAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: inputErrorBorder, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: inputErrorBorder, width: 2),
        ),
        labelStyle: const TextStyle(color: slate300, fontSize: 14),
        hintStyle: const TextStyle(color: slate400, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOlive,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: primaryOlive),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkHeadingAccent,
          backgroundColor: darkSoftTintStart,
          side: BorderSide(color: darkOliveAccent.withValues(alpha: 0.45)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkHeadingAccent,
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryOlive,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: darkOliveAccent,
        inactiveTrackColor: darkBorder,
        thumbColor: darkOliveAccent,
        overlayColor: darkOliveAccent.withValues(alpha: 0.2),
        valueIndicatorColor: forestGreen,
        trackHeight: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: darkSurfaceElevated,
        selectedColor: darkSoftTintEnd,
        secondarySelectedColor: darkSoftTintEnd,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: slate300,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          color: darkHeadingAccent,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: darkSoftTintEnd,
          selectedForegroundColor: darkHeadingAccent,
          foregroundColor: slate300,
          side: const BorderSide(color: darkBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkSoftTintEnd,
        contentTextStyle: const TextStyle(
          color: slate100,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: darkHeadingAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: darkOliveAccent.withValues(alpha: 0.45)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
