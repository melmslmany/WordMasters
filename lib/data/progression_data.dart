import 'dart:math';

import 'package:flutter/material.dart';

import '../models/daily_task.dart';
import '../models/player_rank.dart';

abstract final class RanksData {
  static const ranks = [
    PlayerRank(
      id: 'bronze_1',
      tier: RankTier.bronze,
      level: 1,
      requiredWords: 0,
      nameEn: 'Bronze I',
      nameAr: 'برونزي I',
      color: Color(0xFFCD7F32),
    ),
    PlayerRank(
      id: 'bronze_2',
      tier: RankTier.bronze,
      level: 2,
      requiredWords: 100,
      nameEn: 'Bronze II',
      nameAr: 'برونزي II',
      color: Color(0xFFCD7F32),
    ),
    PlayerRank(
      id: 'bronze_3',
      tier: RankTier.bronze,
      level: 3,
      requiredWords: 250,
      nameEn: 'Bronze III',
      nameAr: 'برونزي III',
      color: Color(0xFFCD7F32),
    ),
    PlayerRank(
      id: 'silver_1',
      tier: RankTier.silver,
      level: 1,
      requiredWords: 450,
      nameEn: 'Silver I',
      nameAr: 'فضي I',
      color: Color(0xFFC0C0C0),
    ),
    PlayerRank(
      id: 'silver_2',
      tier: RankTier.silver,
      level: 2,
      requiredWords: 700,
      nameEn: 'Silver II',
      nameAr: 'فضي II',
      color: Color(0xFFC0C0C0),
    ),
    PlayerRank(
      id: 'silver_3',
      tier: RankTier.silver,
      level: 3,
      requiredWords: 1000,
      nameEn: 'Silver III',
      nameAr: 'فضي III',
      color: Color(0xFFC0C0C0),
    ),
    PlayerRank(
      id: 'gold_1',
      tier: RankTier.gold,
      level: 1,
      requiredWords: 1500,
      nameEn: 'Gold I',
      nameAr: 'ذهبي I',
      color: Color(0xFFFFD700),
    ),
    PlayerRank(
      id: 'gold_2',
      tier: RankTier.gold,
      level: 2,
      requiredWords: 2200,
      nameEn: 'Gold II',
      nameAr: 'ذهبي II',
      color: Color(0xFFFFD700),
    ),
    PlayerRank(
      id: 'gold_3',
      tier: RankTier.gold,
      level: 3,
      requiredWords: 3000,
      nameEn: 'Gold III',
      nameAr: 'ذهبي III',
      color: Color(0xFFFFD700),
    ),
    PlayerRank(
      id: 'platinum_1',
      tier: RankTier.platinum,
      level: 1,
      requiredWords: 4000,
      nameEn: 'Platinum I',
      nameAr: 'بلاتيني I',
      color: Color(0xFF00E5FF),
    ),
    PlayerRank(
      id: 'diamond_1',
      tier: RankTier.diamond,
      level: 1,
      requiredWords: 5500,
      nameEn: 'Diamond',
      nameAr: 'ماسي',
      color: Color(0xFFB44BFF),
    ),
  ];

  static PlayerRank currentRank(int totalWords) {
    var current = ranks.first;
    for (final rank in ranks) {
      if (totalWords >= rank.requiredWords) current = rank;
    }
    return current;
  }

  static PlayerRank? nextRank(int totalWords) {
    for (final rank in ranks) {
      if (totalWords < rank.requiredWords) return rank;
    }
    return null;
  }

  static double progressToNext(int totalWords) {
    final next = nextRank(totalWords);
    if (next == null) return 1;
    final current = currentRank(totalWords);
    final range = next.requiredWords - current.requiredWords;
    if (range <= 0) return 1;
    return ((totalWords - current.requiredWords) / range).clamp(0.0, 1.0);
  }
}

abstract final class DailyTasksData {
  /// Number of daily tasks shown to the player each day.
  static const dailyCount = 6;

  /// Full pool of possible tasks. A varied subset rotates daily.
  static const pool = [
    DailyTaskDefinition(
      id: 'levels_3',
      type: DailyTaskType.completeLevels,
      target: 3,
      reward: 50,
      titleEn: 'Complete 3 levels',
      titleAr: 'أكمل 3 مستويات',
      icon: '🎯',
    ),
    DailyTaskDefinition(
      id: 'levels_5',
      type: DailyTaskType.completeLevels,
      target: 5,
      reward: 100,
      titleEn: 'Complete 5 levels',
      titleAr: 'أكمل 5 مستويات',
      icon: '🏁',
    ),
    DailyTaskDefinition(
      id: 'levels_8',
      type: DailyTaskType.completeLevels,
      target: 8,
      reward: 170,
      titleEn: 'Complete 8 levels',
      titleAr: 'أكمل 8 مستويات',
      icon: '🚩',
    ),
    DailyTaskDefinition(
      id: 'words_20',
      type: DailyTaskType.findWords,
      target: 20,
      reward: 75,
      titleEn: 'Find 20 words',
      titleAr: 'اعثر على 20 كلمة',
      icon: '🔤',
    ),
    DailyTaskDefinition(
      id: 'words_40',
      type: DailyTaskType.findWords,
      target: 40,
      reward: 130,
      titleEn: 'Find 40 words',
      titleAr: 'اعثر على 40 كلمة',
      icon: '📖',
    ),
    DailyTaskDefinition(
      id: 'words_70',
      type: DailyTaskType.findWords,
      target: 70,
      reward: 220,
      titleEn: 'Find 70 words',
      titleAr: 'اعثر على 70 كلمة',
      icon: '📚',
    ),
    DailyTaskDefinition(
      id: 'letter_hint_3',
      type: DailyTaskType.useLetterHints,
      target: 3,
      reward: 90,
      titleEn: 'Use letter hint 3 times',
      titleAr: 'استخدم كشف الحرف 3 مرات',
      icon: '💡',
    ),
    DailyTaskDefinition(
      id: 'word_hint_2',
      type: DailyTaskType.useWordHints,
      target: 2,
      reward: 90,
      titleEn: 'Use word hint 2 times',
      titleAr: 'استخدم كشف الكلمة مرتين',
      icon: '🔍',
    ),
    DailyTaskDefinition(
      id: 'endless_5',
      type: DailyTaskType.endlessStage,
      target: 5,
      reward: 120,
      titleEn: 'Reach stage 5 in Endless',
      titleAr: 'وصل للمرحلة 5 في المفتوح',
      icon: '♾️',
    ),
    DailyTaskDefinition(
      id: 'endless_10',
      type: DailyTaskType.endlessStage,
      target: 10,
      reward: 200,
      titleEn: 'Reach stage 10 in Endless',
      titleAr: 'وصل للمرحلة 10 في المفتوح',
      icon: '🌌',
    ),
    DailyTaskDefinition(
      id: 'no_hint_levels',
      type: DailyTaskType.noHintLevels,
      target: 3,
      reward: 140,
      titleEn: 'Finish 3 levels without hints',
      titleAr: 'أنهِ 3 مستويات بدون مساعدة',
      icon: '🧠',
    ),
    DailyTaskDefinition(
      id: 'play_categories',
      type: DailyTaskType.playCategories,
      target: 3,
      reward: 110,
      titleEn: 'Play in 3 categories',
      titleAr: 'العب في 3 فئات مختلفة',
      icon: '🗂️',
    ),
    DailyTaskDefinition(
      id: 'background_buy',
      type: DailyTaskType.buyBackground,
      target: 1,
      reward: 60,
      titleEn: 'Get a new background',
      titleAr: 'احصل على خلفية جديدة',
      icon: '🎨',
    ),
    DailyTaskDefinition(
      id: 'login',
      type: DailyTaskType.loginStreak,
      target: 1,
      reward: 150,
      titleEn: 'Daily login reward',
      titleAr: 'مكافأة الدخول اليومي',
      icon: '🎁',
    ),
  ];

  /// Deterministic daily selection: stable for a given calendar day,
  /// rotates the next day. The login reward is always included.
  static List<DailyTaskDefinition> get tasks {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final rng = Random(seed);

    final login = pool.firstWhere((t) => t.type == DailyTaskType.loginStreak);
    final rest = pool
        .where((t) => t.type != DailyTaskType.loginStreak)
        .toList()
      ..shuffle(rng);

    final selected = rest.take(dailyCount - 1).toList()..add(login);
    return selected;
  }
}
