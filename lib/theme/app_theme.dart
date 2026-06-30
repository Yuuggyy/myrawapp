import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Or pur RawBank
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldDark = Color(0xFFAA8C2C);

  // Dark mode
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkCard = Color(0xFF1C1C1C);
  static const Color darkSurface = Color(0xFF252525);
  static const Color darkDivider = Color(0xFF2E2E2E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  // Light mode
  static const Color lightBg = Color(0xFFF9F9F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF2F2F2);
  static const Color lightDivider = Color(0xFFE8E8E8);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF777777);

  // Communs
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC04);
  static const Color error = Color(0xFFEA4335);
}

class AppTheme {
  static TextTheme _textTheme(Color primary, Color secondary) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(color: primary),
      bodyMedium: GoogleFonts.poppins(color: primary),
      bodySmall: GoogleFonts.poppins(color: secondary),
      titleLarge: GoogleFonts.poppins(color: primary, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.poppins(color: primary, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      onPrimary: Color(0xFF0D0D0D),
      surface: AppColors.darkCard,
      onSurface: AppColors.darkTextPrimary,
      secondary: AppColors.gold,
    ),
    scaffoldBackgroundColor: AppColors.darkBg,
    textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.darkTextPrimary, fontSize: 18, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Color(0xFF0D0D0D),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.gold),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkDivider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkDivider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
    ),
    dividerColor: AppColors.darkDivider,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBg,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.gold,
      onPrimary: Color(0xFFFFFFFF),
      surface: AppColors.lightCard,
      onSurface: AppColors.lightTextPrimary,
      secondary: AppColors.gold,
    ),
    scaffoldBackgroundColor: AppColors.lightBg,
    textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.lightBg,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.poppins(
        color: AppColors.lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.gold,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.gold,
        side: const BorderSide(color: AppColors.gold),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightDivider)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightDivider)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gold, width: 1.5)),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
    ),
    dividerColor: AppColors.lightDivider,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightCard,
      selectedItemColor: AppColors.gold,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
