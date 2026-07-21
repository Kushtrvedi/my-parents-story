import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

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
      textTheme: TextTheme(
        headlineLarge: AppTypography.display,
        headlineMedium: AppTypography.heading,
        headlineSmall: AppTypography.question,
        bodyLarge: AppTypography.body,
        labelLarge: AppTypography.button,
        bodySmall: AppTypography.caption,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.heading.copyWith(fontSize: 22),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppTouchTargets.min + 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.l),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
          textStyle: AppTypography.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          minimumSize: const Size(double.infinity, AppTouchTargets.min + 12),
          side: const BorderSide(color: AppColors.divider, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.l),
          ),
          textStyle: AppTypography.button.copyWith(color: AppColors.text),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.divider, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.divider, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.m),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.m),
        hintStyle: AppTypography.caption.copyWith(fontSize: 22),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppTouchTargets.min, AppTouchTargets.min),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
