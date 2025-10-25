import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF1F7B78);
  static const Color primaryDark = Color(0xFF0E403F);
  static const Color primaryLight = Color(0xFF00B7C2);
  static const Color gradientStart = Color(0xFF0E403F);
  static const Color gradientMiddle = Color(0xFF1F7B78);
  static const Color gradientEnd = Color(0xFF00B7C2);
  static const Color background = Color(0xFF0E403F);
  static const Color surface = Color(0xFF112B2A);
  static const Color surfaceLight = Color(0xFF1A3F3E);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textHint = Color(0xFF808080);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.orangeAccent;
  static const Color info = Color(0xFF00B7C2);
  static const Color controlActive = Colors.white;
  static const Color controlInactive = Colors.redAccent;
  static const Color controlBackground = Color(0x26FFFFFF);
  static const Color border = Color(0x3DFFFFFF);
  static const Color borderFocused = Color(0xFF00B7C2);
  static const Color shadow = Color(0x40000000);
  static const Color shadowLight = Color(0x1A000000);
  static const Color overlay = Color(0x4D000000);
  static const Color overlayLight = Color(0x1A000000);
  static const Color buttonPrimary = Color(0xFF00B7C2);
  static const Color buttonSecondary = Color(0xFF1F7B78);
  static const Color buttonDanger = Colors.redAccent;
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color busy = Colors.orangeAccent;
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [gradientStart, gradientMiddle, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static LinearGradient overlayGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
  );
  static const Color backgroundDark = Color(0xFF0E403F);
  static const Color textWhite = Colors.white;
  static const Color textMuted = Colors.white70;
  static const List<Color> gradient = [backgroundDark, primaryDark, primary];
}
