import 'package:flutter/material.dart';

class GameCategory {
  const GameCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.icon,
    required this.color,
    required this.gradient,
    this.isLocked = false,
    this.unlockCostCoins = 200,
    this.unlockCostKeys = 1,
    this.totalLevels = 20,
  });

  final String id;
  final String nameEn;
  final String nameAr;
  final IconData icon;
  final Color color;
  final List<Color> gradient;
  final bool isLocked;
  final int unlockCostCoins;
  final int unlockCostKeys;
  final int totalLevels;

  String name(bool isArabicUi) => isArabicUi ? nameAr : nameEn;
}
