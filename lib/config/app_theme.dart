import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFFFFBF5);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF555555);
  static const accent = Color(0xFFB8860B);
  static const accentLight = Color(0xFFFDF5E6);
  static const cardBg = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE5E0D5);
  static const success = Color(0xFF2E7D32);
  static const error = Color(0xFFC62828);
  static const warmWhite = Color(0xFFFFF8F0);
  static const shadow = Color(0x0D000000);
}

class AppTheme {
  static const double _baseFontSize = 24;

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        surface: AppColors.background,
        onSurface: AppColors.primaryText,
      ),
      textTheme: GoogleFonts.loraTextTheme(
        TextTheme(
          headlineLarge: TextStyle(
            fontSize: _baseFontSize + 8,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
            letterSpacing: -0.5,
            height: 1.3,
          ),
          headlineMedium: TextStyle(
            fontSize: _baseFontSize + 2,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
            letterSpacing: -0.3,
          ),
          headlineSmall: TextStyle(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          titleLarge: TextStyle(
            fontSize: _baseFontSize - 2,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
          titleMedium: TextStyle(
            fontSize: _baseFontSize - 4,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryText,
          ),
          bodyLarge: TextStyle(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryText,
            height: 1.7,
          ),
          bodyMedium: TextStyle(
            fontSize: _baseFontSize - 2,
            fontWeight: FontWeight.w400,
            color: AppColors.primaryText,
            height: 1.6,
          ),
          bodySmall: TextStyle(
            fontSize: _baseFontSize - 6,
            fontWeight: FontWeight.w400,
            color: AppColors.secondaryText,
            height: 1.5,
          ),
          labelLarge: TextStyle(
            fontSize: _baseFontSize - 4,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.lora(
          fontSize: _baseFontSize - 2,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          textStyle: GoogleFonts.lora(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryText,
          minimumSize: const Size(double.infinity, 70),
          side: const BorderSide(color: AppColors.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.lora(
            fontSize: _baseFontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.divider, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        hintStyle: GoogleFonts.lora(
          color: AppColors.secondaryText,
          fontSize: _baseFontSize - 4,
        ),
      ),
    );
  }
}
