import 'package:flutter/material.dart';

class AppColors {
  // Primary Monochrome Palette
  static const Color black = Color(0xFF000000);
  static const Color deepGrey = Color(0xFF0F0F0F);
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color midGrey = Color(0xFF2A2A2A);
  static const Color grey = Color(0xFF666666);
  static const Color lightGrey = Color(0xFF999999);
  static const Color silver = Color(0xFFCCCCCC);
  static const Color white = Color(0xFFFFFFFF);

  // Accent Color
  static const Color accentRed = Color(0xFFFF4444);

  // Legacy aliases (for backward compatibility during migration)
  static const Color primary = white;
  static const Color secondary = grey;
  static const Color accent = lightGrey;
  static const Color background = deepGrey;
  static const Color surface = darkGrey;
  static const Color textPrimary = white;
  static const Color textSecondary = lightGrey;
  static const Color error = accentRed;
  static const Color cardShadow = Color(0x4D000000);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepGrey, darkGrey],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [white, silver],
  );

  static const LinearGradient imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x99000000)],
  );
}
