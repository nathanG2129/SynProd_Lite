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

  static const LinearGradient canvasGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [slate50, canvasTintEnd],
  );

  static const LinearGradient softTintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softTintStart, softTintEnd],
  );

  static const LinearGradient subtleSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [subtleSurfaceStart, softTintStart],
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
      dividerTheme: const DividerThemeData(
        color: slate200,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
