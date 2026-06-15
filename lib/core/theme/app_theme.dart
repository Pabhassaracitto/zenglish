import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // Core palette
  static const Color cream = Color(0xFFF5F0E8);
  static const Color creamDark = Color(0xFFEDE5D0);
  static const Color creamLight = Color(0xFFFAF7F2);

  static const Color earthBrown = Color(0xFF5C3D2E);
  static const Color earthLight = Color(0xFF8B6347);
  static const Color earthDark = Color(0xFF3A2318);
  static const Color warmTaupe = Color(0xFFB8A99A);

  static const Color saffron = Color(0xFFE8A020);
  static const Color saffronLight = Color(0xFFF5C842);
  static const Color saffronGlow = Color(0xFFFFF3D0);

  static const Color forestGreen = Color(0xFF4A6741);
  static const Color mossGreen = Color(0xFF7A9E7E);
  static const Color sageLight = Color(0xFFD4E6D5);

  static const Color textPrimary = Color(0xFF2C1A0E);
  static const Color textSecond = Color(0xFF6B4F3A);
  static const Color textSecondary = Color(0xFF6B5D4A);
  static const Color textHint = Color(0xFFAA8F7F);
  static const Color textMuted = Color(0xFFAA9E8F);
  static const Color divider = Color(0xFFDDD0C0);

  static const Color success = Color(0xFF4A6741);
  static const Color warning = Color(0xFFE8A020);
  static const Color error = Color(0xFFC0392B);
  static const Color errorSoft = Color(0xFFEF5350);

  // Presentation palette aliases
  static const Color surface = Color(0xFFFAF8F3);
  static const Color surfaceVariant = Color(0xFFF2EFE8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF5C4A32);
  static const Color secondary = Color(0xFF4A6741);
  static const Color accent = Color(0xFFB8860B);
  static const Color paliColor = Color(0xFF6B5B8B);
  static const Color silentModeActive = Color(0xFF8B7355);
}

class AppTheme {
  AppTheme._();

  // Font
  static const String fontFamily = 'Merriweather';

  // Spacing
  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // Radius
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 24;

  // Color shortcuts
  static const Color surface = AppColors.surface;
  static const Color surfaceVariant = AppColors.surfaceVariant;
  static const Color cardBackground = AppColors.cardBackground;
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color accent = AppColors.accent;
  static const Color paliColor = AppColors.paliColor;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = AppColors.textMuted;
  static const Color divider = AppColors.divider;
  static const Color silentModeActive = AppColors.silentModeActive;
  static const Color errorSoft = AppColors.errorSoft;

  // Text styles
  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
  );

  static const TextStyle paliText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.paliColor,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static const TextStyle monasteryNote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.7,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.8,
  );

  // Shadows
  // QUAN TRỌNG: giữ dạng getter để code cũ `AppTheme.cardShadow` vẫn chạy
  static List<BoxShadow> get cardShadow => const [
        BoxShadow(
          color: Color(0x0F2C1A0E),
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get subtleShadow => const [
        BoxShadow(
          color: Color(0x0A2C1A0E),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.earthBrown,
        onPrimary: AppColors.creamLight,
        primaryContainer: AppColors.creamDark,
        onPrimaryContainer: AppColors.earthDark,
        secondary: AppColors.saffron,
        onSecondary: AppColors.earthDark,
        secondaryContainer: AppColors.saffronGlow,
        onSecondaryContainer: AppColors.earthBrown,
        tertiary: AppColors.forestGreen,
        onTertiary: AppColors.creamLight,
        tertiaryContainer: AppColors.sageLight,
        onTertiaryContainer: AppColors.forestGreen,
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: Color(0xFFFFF0EE),
        onErrorContainer: AppColors.error,
        background: AppColors.creamLight,
        onBackground: AppColors.textPrimary,
        surface: AppColors.cream,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.creamDark,
        onSurfaceVariant: AppColors.textSecond,
        outline: AppColors.warmTaupe,
        outlineVariant: AppColors.divider,
        shadow: Color(0x143A2318),
        scrim: Color(0x523A2318),
        inverseSurface: AppColors.earthDark,
        onInverseSurface: AppColors.cream,
        inversePrimary: AppColors.saffronLight,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.creamLight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.earthBrown,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.earthDark.withOpacity(0.1),
        centerTitle: true,
        titleTextStyle: GoogleFonts.merriweather(
          color: AppColors.earthBrown,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.earthBrown),
      ),
      textTheme: GoogleFonts.latoTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.merriweather(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
        ),
        displayMedium: GoogleFonts.merriweather(
          color: AppColors.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.merriweather(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.merriweather(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.lato(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.lato(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.lato(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.lato(
          color: AppColors.textSecond,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.lato(
          color: AppColors.textHint,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.lato(
          color: AppColors.earthBrown,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.earthBrown,
          foregroundColor: AppColors.creamLight,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.lato(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.earthBrown,
          side: const BorderSide(color: AppColors.earthBrown, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.earthDark,
        contentTextStyle: GoogleFonts.lato(
          color: AppColors.creamLight,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get theme => light;
}