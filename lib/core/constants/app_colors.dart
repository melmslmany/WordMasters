import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background = Color(0xFF050810);
  static const backgroundLight = Color(0xFF0D1225);
  static const surface = Color(0xFF141B35);
  static const surfaceLight = Color(0xFF1C2547);
  static const primary = Color(0xFF7B5CFF);
  static const primaryLight = Color(0xFF9D7BFF);
  static const neonPurple = Color(0xFFB44BFF);
  static const neonBlue = Color(0xFF3D8BFF);
  static const neonCyan = Color(0xFF00E5FF);
  static const neonGreen = Color(0xFF00FF88);
  static const neonOrange = Color(0xFFFF8C42);
  static const neonPink = Color(0xFFFF4D9D);
  static const accent = Color(0xFF00E5A0);
  static const accentGold = Color(0xFFFFD54F);
  static const accentKey = Color(0xFFFFB347);
  static const error = Color(0xFFFF6B6B);
  static const textPrimary = Color(0xFFF0F4FF);
  static const textSecondary = Color(0xFF8B9CC7);

  static const highlightColors = [
    Color(0xFFFF8C42),
    Color(0xFF00FF88),
    Color(0xFF3D8BFF),
    Color(0xFFB44BFF),
    Color(0xFFFF4D9D),
    Color(0xFF00E5FF),
    Color(0xFFFFD54F),
    Color(0xFF7B5CFF),
    Color(0xFF34D399),
    Color(0xFFF472B6),
  ];

  static const wordFoundColors = highlightColors;

  static BoxShadow neonGlow(Color color, {double blur = 16}) => BoxShadow(
        color: color.withValues(alpha: 0.45),
        blurRadius: blur,
        spreadRadius: 0,
      );

  static BoxDecoration neonCard({
    required List<Color> gradient,
    Color glowColor = primary,
    double radius = 20,
  }) =>
      BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          neonGlow(glowColor, blur: 20),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      );
}
