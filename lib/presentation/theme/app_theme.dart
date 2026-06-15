import 'package:flutter/material.dart';

/// Design System — Vip Buddhism Language App
/// Nguyên tắc: Minimalist, bình an, không gamification
/// Cảm hứng: Thiền viện, giấy thủ công, mực truyền thống
class AppTheme {
  AppTheme._();

  // ─── Palette ────────────────────────────────

  /// Nền chính — kem nhạt, như giấy cũ
  static const Color surface = Color(0xFFFAF8F3);

  /// Nền thứ cấp — trắng ngà
  static const Color surfaceVariant = Color(0xFFF2EFE8);

  /// Nền card
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Màu chính — nâu đất ấm
  static const Color primary = Color(0xFF5C4A32);

  /// Màu phụ — xanh rêu trầm
  static const Color secondary = Color(0xFF4A6741);

  /// Màu accent nhẹ — vàng đất
  static const Color accent = Color(0xFFB8860B);

  /// Màu Pāḷi — tím nhẹ trầm
  static const Color paliColor = Color(0xFF6B5B8B);

  /// Text chính
  static const Color textPrimary = Color(0xFF2C2416);

  /// Text phụ
  static const Color textSecondary = Color(0xFF6B5D4A);

  /// Text mờ
  static const Color textMuted = Color(0xFFAA9E8F);

  /// Đường kẻ phân cách
  static const Color divider = Color(0xFFE0D8CC);

  /// Màu khi silent mode bật
  static const Color silentModeActive = Color(0xFF8B7355);

  /// Error nhẹ — không chói
  static const Color errorSoft = Color(0xFFC0392B);

  // ─── Typography ─────────────────────────────

  static const String fontFamily = 'NotoSerif';

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
    letterSpacing: -0.3,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
  );

  static const TextStyle paliText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: paliColor,
    height: 1.5,
    letterSpacing: 0.2,
  );

  static const TextStyle monasteryNote = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.7,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
    letterSpacing: 0.8,
  );

  // ─── Spacing ────────────────────────────────

  static const double spaceXS = 4;
  static const double spaceSM = 8;
  static const double spaceMD = 16;
  static const double spaceLG = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;

  // ─── Border Radius ──────────────────────────

  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 24;

  // ─── Shadows ────────────────────────────────

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: textPrimary.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: textPrimary.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ─── MaterialTheme ──────────────────────────

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: surface,
        background: surface,
        primary: primary,
        secondary: secondary,
        error: errorSoft,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surface,
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          side: BorderSide(color: divider, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: headingMedium,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}
