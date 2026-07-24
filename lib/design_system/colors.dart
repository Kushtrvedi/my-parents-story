import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFFFFFFF);
  static const card = Color(0xFFFDF4DB);
  static const primary = Color(0xFFDA9B49);
  static const accent = Color(0xFFDFAB58);
  static const amberGold = Color(0xFFD9A05B);
  static const secondaryMed = Color(0xFFEBCC75);
  static const parchment = Color(0xFFFDF4DB);
  static const parchmentBorder = Color(0xFFEBCC75);
  static const text = Color(0xFF2C2926);
  static const textLight = Color(0xFF6B7280);
  static const divider = Color(0xFFEBCC75);
  static const error = Color(0xFFC0392B);
  static const success = Color(0xFF2C4A3E);
  static const warmWhite = Color(0xFFFFFFFF);
  static const shadow = Color(0x12DA9B49);
  static const link = Color(0xFFD4A33A);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFDA9B49), Color(0xFFF3E38A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const headingGradient = LinearGradient(
    colors: [Color(0xFF9F6218), Color(0xFFF3E38A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
