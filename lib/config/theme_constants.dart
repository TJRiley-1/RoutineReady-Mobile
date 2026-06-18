import 'package:flutter/material.dart';

class AppColors {
  // Canonical brand palette — see /brand (BRAND.md, brand-tokens.json).
  // Source of truth is the website (routineready.co.uk).
  static const Color brandPrimary = Color(0xFF1A7F7A); // teal
  static const Color brandPrimaryDark = Color(0xFF0F5550); // teal-dark
  static const Color brandPrimaryLight = Color(0xFF2A9E98); // teal-light
  static const Color brandAccent = Color(0xFFF59E0B); // amber
  static const Color brandAccentLight = Color(0xFFFBBF24);
  static const Color brandSuccess = Color(0xFF16A34A);
  static const Color brandError = Color(0xFFEF4444);
  static const Color brandText = Color(0xFF1C2B2A); // warm near-black
  static const Color brandTextMuted = Color(0xFF6B7280); // warm-gray
  static const Color brandBorder = Color(0xFFE8ECEB);
  static const Color brandBgSubtle = Color(0xFFFAF8F5); // cream
  static const Color brandPrimaryBg = Color(0xFFF0FAF9); // teal-faint
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.brandPrimary,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.brandBgSubtle,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.brandText,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandText,
          side: const BorderSide(color: AppColors.brandBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brandBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.brandBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: AppColors.brandPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
    );
  }
}
