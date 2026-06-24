import 'package:flutter/material.dart';

enum RankTier { bronze, silver, gold, platinum, diamond }

class PlayerRank {
  const PlayerRank({
    required this.id,
    required this.tier,
    required this.level,
    required this.requiredWords,
    required this.nameEn,
    required this.nameAr,
    required this.color,
  });

  final String id;
  final RankTier tier;
  final int level;
  final int requiredWords;
  final String nameEn;
  final String nameAr;
  final Color color;

  String name(bool isArabic) => isArabic ? nameAr : nameEn;

  IconData get icon => switch (tier) {
        RankTier.bronze => Icons.workspace_premium_rounded,
        RankTier.silver => Icons.military_tech_rounded,
        RankTier.gold => Icons.emoji_events_rounded,
        RankTier.platinum => Icons.diamond_rounded,
        RankTier.diamond => Icons.auto_awesome_rounded,
      };
}
