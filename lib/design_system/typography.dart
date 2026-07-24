import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle get display => GoogleFonts.kanit(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9F6218),
        height: 1.4,
        letterSpacing: -0.3,
      );

  static TextStyle get heading => GoogleFonts.kanit(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9F6218),
        height: 1.4,
      );

  static TextStyle get question => GoogleFonts.kanit(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF9F6218),
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.gelasio(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        height: 1.7,
      );

  static TextStyle get button => GoogleFonts.kanit(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
        letterSpacing: 0.3,
      );

  static TextStyle get caption => GoogleFonts.gelasio(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textLight,
        height: 1.5,
      );
}
