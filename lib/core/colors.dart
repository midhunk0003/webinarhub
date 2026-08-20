import 'dart:ui';
import 'package:flutter/material.dart';

class AppColor {
  static const Color primaryText = Color(0xFFFFFFFF);

  // Dark Gradient
  static const Color gradientStart = Color(0xFF0D0E12);
  static const Color gradientMiddle = Color(0xFF15181E);
  static const Color gradientEnd = Color(0xFF0D0E12);

  // Light Colors
  static const Color lightgray = Color(0xFFC0C2D1);
  static const Color ghostwhite = Color(0xFFF2F4F8);

  // ✅ Primary Green Colors
  static const Color primaryGreenDark = Color(0xFF45A679);
  static const Color primaryGreenLight = Color(0xFF76C6A1);

  // ✅ Primary Blue Colors
  static const Color primaryBlueDark = Color(0xFF004B70);
  static const Color primaryBlueMid = Color(0xFF005885);
  static const Color primaryBlueLight = Color(0xFF006699);

  // ✅ FIXED form gradient colors
  static const Color formPrimaryColor = Color(0xFF37414D);
  static const Color formSecondaryColor = Color(0xFF495565);
  static const Color formBorderColor = Color(0xFF495565);
  static const Color formTextColor = Color(0xFF9CA4B8);

  // ── App Colors (add to your AppColor class) ─────────────────────────
  static const Color primaryGlassColor = Color(0xFF37414D);
  static const Color secondaryGlassColor = Color(0xFF495565);
  static const Color borderGlassColor = Color(0xFF37414E);
  static const Color glassHighlight = Color(0xFFFFFFFF);
  // static const Color accentGlow = Color(0xFF6366F1);

  //blue grey
  static const Color blueGrey = Color(0xFF9CA4B8);

  // Reusable dark gradient
  static const List<Color> darkGradient = [
    gradientStart,
    gradientMiddle,
    gradientEnd,
  ];

  // ✅ Reusable primary blue gradient
  static const List<Color> primaryBlueGradient = [
    primaryBlueDark,
    primaryBlueMid,
    primaryBlueLight,
    primaryBlueDark,
  ];

  // ✅ Reusable glass effect gradient
  static const List<Color> glassGradient = [
    primaryGlassColor,
    secondaryGlassColor,
  ];

  // ✅ Reusable primary green gradient
  static const List<Color> primaryGreenGradient = [
    primaryGreenDark,
    primaryGreenLight,
    primaryGreenDark,
  ];
}
