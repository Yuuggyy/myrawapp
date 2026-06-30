import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // RawBank — Noir & Doré
  static const Color primary = Color(0xFFB8953F);      // Or RawBank
  static const Color primaryDark = Color(0xFF8B6914);  // Or foncé
  static const Color primaryLight = Color(0xFFD4AF37); // Or brillant
  static const Color black = Color(0xFF0A0A0A);        // Noir profond
  static const Color blackCard = Color(0xFF141414);    // Noir carte
  static const Color blackSurface = Color(0xFF1E1E1E); // Noir surface
  static const Color background = Color(0xFF0F0F0F);   // Fond noir
  static const Color cardBg = Color(0xFF1A1A1A);       // Carte noir
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFD4AF37);
  static const Color textGrey = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFF666666);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFE53935);
  static const Color divider = Color(0xFF2A2A2A);
  static const Color textDark = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.cardBg,
        onPrimary: AppColors.black,
        onSurface: AppColors.textWhite,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.textGold,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          color: AppColors.textGold, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blackSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textGrey),
        hintStyle: const TextStyle(color: AppColors.textLight),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.black,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: AppColors.divider,
    );
  }
}
