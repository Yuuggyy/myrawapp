import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldSoft = Color(0xFFF5E6A3);

  // Dark — riche et profond
  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color darkCard = Color(0xFF15151E);
  static const Color darkCardAlt = Color(0xFF1C1C28);
  static const Color darkSurface = Color(0xFF22222F);
  static const Color darkDivider = Color(0xFF2A2A38);
  static const Color darkTextPrimary = Color(0xFFF0F0F5);
  static const Color darkTextSecondary = Color(0xFF8888A0);

  // Light — blanc pur, épuré
  static const Color lightBg = Color(0xFFF5F5F7);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardAlt = Color(0xFFF0F0F5);
  static const Color lightSurface = Color(0xFFEEEEF3);
  static const Color lightDivider = Color(0xFFE0E0EA);
  static const Color lightTextPrimary = Color(0xFF0A0A0F);
  static const Color lightTextSecondary = Color(0xFF777788);

  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);
}

ThemeData buildTheme(bool dark) {
  final bg = dark ? AppColors.darkBg : AppColors.lightBg;
  final card = dark ? AppColors.darkCard : AppColors.lightCard;
  final surface = dark ? AppColors.darkSurface : AppColors.lightSurface;
  final divider = dark ? AppColors.darkDivider : AppColors.lightDivider;
  final textPrimary = dark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  final textSecondary = dark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: dark
      ? ColorScheme.dark(primary: AppColors.gold, onPrimary: AppColors.darkBg,
          surface: card, onSurface: textPrimary, secondary: AppColors.gold)
      : ColorScheme.light(primary: AppColors.gold, onPrimary: Colors.white,
          surface: card, onSurface: textPrimary, secondary: AppColors.gold),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.poppinsTextTheme(dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppins(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: card, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: dark ? AppColors.darkBg : Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.gold, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: divider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: divider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
      labelStyle: TextStyle(color: textSecondary, fontSize: 14),
      hintStyle: TextStyle(color: textSecondary, fontSize: 14),
    ),
    dividerColor: divider,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: dark ? AppColors.darkCard : AppColors.lightCard,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.gold,
      unselectedLabelColor: textSecondary,
      indicatorColor: AppColors.gold,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: divider,
      labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
    ),
  );
}

class AppTheme {
  static ThemeData get dark => buildTheme(true);
  static ThemeData get light => buildTheme(false);
}
