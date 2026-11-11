import 'package:flutter/material.dart';

class AppColor {
  // ============================================================
  // BACKGROUND
  // ============================================================

  /// Main application background
  static const Color background = Color(0xFF0E0E0E);

  // ============================================================
  // TEXT COLORS
  // ============================================================

  /// Main white text
  static const Color primaryText = Color(0xFFFFFFFF);

  /// Secondary / description text
  static const Color secondaryText = Color(0xFFCCD1D9);

  /// Light gray
  static const Color lightgray = Color(0xFFCCD1D9);

  /// Ghost white
  static const Color ghostwhite = Color(0xFFFFFFFF);

  // ============================================================
  // GOLD / CHAMPAGNE COLORS
  // ============================================================

  static const Color goldDark = Color(0xFFAF905A);
  static const Color gold = Color(0xFFCEA96A);
  static const Color goldLight = Color(0xFFDDC397);
  static const Color goldSoft = Color(0xFFD8BA88);

  // ============================================================
  // BUTTON
  // ============================================================

  /// Button text
  static const Color buttonText = Color(0xFF1B1B1B);

  /// Button gradient
  static const List<Color> buttonGradient = [
    Color(0xFFAF905A),
    Color(0xFFCEA96A),
    Color(0xFFDDC397),
    Color(0xFFD8BA88),
    Color(0xFFCEA96A),
    Color(0xFFAF905A),
  ];

  // ============================================================
  // CARD
  // ============================================================

  /// Card background
  static const Color cardBackground = Color(0xFF0E0E0E);

  /// Card border gradient
  static const List<Color> cardBorderGradient = [
    Color(0x33AF905A),
    Color(0x99CEA96A),
    Color(0xCCDDC397),
    Color(0xCCD8BA88),
    Color(0x99CEA96A),
    Color(0x33AF905A),
  ];

  // ============================================================
  // FORM
  // ============================================================

  static const Color formPrimaryColor = Color(0xFF0E0E0E);
  static const Color formSecondaryColor = Color(0xFF1B1B1B);

  static const Color formBorderColor = Color(0x66CEA96A);

  static const Color formTextColor = Color(0xFFCCD1D9);

  // ============================================================
  // GLASS
  // ============================================================

  static const Color primaryGlassColor = Color(0xFF0E0E0E);
  static const Color secondaryGlassColor = Color(0xFF1B1B1B);

  static const Color borderGlassColor = Color(0x66CEA96A);

  static const Color glassHighlight = Color(0xFFFFFFFF);

  // ============================================================
  // REUSABLE GRADIENTS
  // ============================================================

  /// Main dark background gradient
  static const List<Color> darkGradient = [
    Color(0xFF0E0E0E),
    Color(0xFF111111),
    Color(0xFF0E0E0E),
  ];

  /// Gold gradient
  static const List<Color> goldGradient = [
    goldDark,
    gold,
    goldLight,
    goldSoft,
    gold,
    goldDark,
  ];

  /// Glass gradient
  static const List<Color> glassGradient = [
    primaryGlassColor,
    secondaryGlassColor,
  ];

  // ============================================================
  // SHADOW
  // ============================================================

  static const Color shadow = Color(0x66000000);
}
