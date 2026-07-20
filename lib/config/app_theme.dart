import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFFAF8F5);
  static const card = Color(0xFFFFFFFF);
  static const primary = Color(0xFF3A5A40);
  static const accent = Color(0xFFD4A373);
  static const text = Color(0xFF1F2937);
  static const textLight = Color(0xFF6B7280);
  static const divider = Color(0xFFE5E2DC);
  static const error = Color(0xFFC0392B);
  static const success = Color(0xFF3A5A40);
  static const warmWhite = Color(0xFFFFFDF9);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.card,
        onSurface: AppColors.text,
      ),
      textTheme: GoogleFonts.loraTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
            height: 1.4,
            letterSpacing: -0.3,
          ),
          headlineMedium: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            height: 1.4,
          ),
          headlineSmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            height: 1.4,
          ),
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
            height: 1.4,
          ),
          titleMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
            height: 1.4,
          ),
          bodyLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppColors.text,
            height: 1.7,
          ),
          bodyMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: AppColors.text,
            height: 1.6,
          ),
          bodySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: AppColors.textLight,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lora(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 76),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 22),
          textStyle: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size(double.infinity, 76),
          side: const BorderSide(color: AppColors.divider, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: GoogleFonts.lora(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.divider, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.divider, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        hintStyle: GoogleFonts.lora(
          color: AppColors.textLight,
          fontSize: 22,
        ),
      ),
    );
  }
}
