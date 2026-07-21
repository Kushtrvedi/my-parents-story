import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTypography {
  static TextStyle get display => GoogleFonts.lora(
    fontSize: 38,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.4,
    letterSpacing: -0.3,
  );

  static TextStyle get heading => GoogleFonts.lora(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.4,
  );

  static TextStyle get question => GoogleFonts.lora(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    height: 1.4,
  );

  static TextStyle get body => GoogleFonts.lora(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.7,
  );

  static TextStyle get button => GoogleFonts.lora(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );

  static TextStyle get caption => GoogleFonts.lora(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.textLight,
    height: 1.5,
  );
}
