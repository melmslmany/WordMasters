import 'package:flutter/material.dart';

import '../data/progression_data.dart';
import '../models/daily_task.dart';
import '../models/player_rank.dart';
import '../models/player_stats.dart';
import '../services/storage_service.dart';

class ProgressionProvider extends ChangeNotifier {
  ProgressionProvider(this._storage);

  final StorageService _storage;

  PlayerStats stats = const PlayerStats();
  List<DailyTaskProgress> dailyTasks = [];

  Future<void> load() async {
    stats = _storage.getPlayerStats();
    _ensureDailyTasks();
    notifyListeners();
  }

  void _ensureDailyTasks() {
    dailyTasks = _storage.getDailyTasks();
    if (dailyTasks.length != DailyTasksData.tasks.length) {
      dailyTasks = DailyTasksData.tasks
          .map((t) => DailyTaskProgress(taskId: t.id, progress: 0, claimed: false))
          .toList();
      _storage.saveDailyTasks(dailyTasks);
    }
  }

  PlayerRank get currentRank => RanksData.currentRank(stats.totalWordsFound);

  PlayerRank? get nextRank => RanksData.nextRank(stats.totalWordsFound);

  double get rankProgress => RanksData.progressToNext(stats.totalWordsFound);

  DailyTaskProgress? _taskProgress(String id) {
    try {
      return dailyTasks.firstWhere((t) => t.taskId == id);
    } catch (_) {
      return null;
    }
  }

  int progressFor(DailyTaskDefinition task) =>
      _taskProgress(task.id)?.progress ?? 0;

  bool isTaskClaimed(String id) => _taskProgress(id)?.claimed ?? false;

  bool isTaskComplete(DailyTaskDefinition task) =>
      progressFor(task) >= task.target;

  bool canClaim(DailyTaskDefinition task) =>
      isTaskComplete(task) && !isTaskClaimed(task.id);

  Future<void> onWordFound() async {
    stats = stats.copyWith(
      totalWordsFound: stats.totalWordsFound + 1,
      todayWordsFound: stats.todayWordsFound + 1,
    );
    await _updateTaskProgress(DailyTaskType.findWords, stats.todayWordsFound);
    await _storage.savePlayerStats(stats);
    notifyListeners();
  }

  Future<void> onLevelCompleted({required bool usedHints}) async {
    stats = stats.copyWith(
      totalLevelsCompleted: stats.totalLevelsCompleted + 1,
      todayLevelsCompleted: stats.todayLevelsCompleted + 1,
      todayNoHintLevels:
          usedHints ? stats.todayNoHintLevels : stats.todayNoHintLevels + 1,
      consecutiveNoHintLevels: usedHints
          ? 0
          : stats.consecutiveNoHintLevels + 1,
      hintsUsedThisLevel: 0,
      resetHintsThisLevel: true,
    );
    await _updateTaskProgress(
      DailyTaskType.completeLevels,
      stats.todayLevelsCompleted,
    );
    if (!usedHints) {
      await _updateTaskProgress(
        DailyTaskType.noHintLevels,
        stats.todayNoHintLevels,
      );
    }
    await _storage.savePlayerStats(stats);
    notifyListeners();
  }

  Future<void> onCategoryPlayed(String categoryId) async {
    final count = await _storage.addPlayedCategoryToday(categoryId);
    await _updateTaskProgress(DailyTaskType.playCategories, count);
    notifyListeners();
  }

  Future<void> onEndlessStage(int stage) async {
    if (stage <= stats.todayEndlessStage) return;
    stats = stats.copyWith(
      todayEndlessStage: stage,
      endlessBestStage:
          stage > stats.endlessBestStage ? stage : stats.endlessBestStage,
    );
    await _updateTaskProgress(DailyTaskType.endlessStage, stage);
    await _storage.savePlayerStats(stats);
    notifyListeners();
  }

  Future<void> onLetterHintUsed() async {
    stats = stats.copyWith(
      letterHintsUsed: stats.letterHintsUsed + 1,
      todayLetterHints: stats.todayLetterHints + 1,
      hintsUsedThisLevel: stats.hintsUsedThisLevel + 1,
    );
    await _updateTaskProgress(
      DailyTaskType.useLetterHints,
      stats.todayLetterHints,
    );
    await _storage.savePlayerStats(stats);
    notifyListeners();
  }

  Future<void> onWordHintUsed() async {
    stats = stats.copyWith(
      wordHintsUsed: stats.wordHintsUsed + 1,
      todayWordHints: stats.todayWordHints + 1,
      hintsUsedThisLevel: stats.hintsUsedThisLevel + 1,
    );
    await _updateTaskProgress(
      DailyTaskType.useWordHints,
      stats.todayWordHints,
    );
    await _storage.savePlayerStats(stats);
    notifyListeners();
  }

  Future<void> onBackgroundPurchased() async {
    await _storage.incrementBackgroundsPurchasedToday();
    await _updateTaskProgress(
      DailyTaskType.buyBackground,
      _storage.backgroundsPurchasedToday,
    );
    notifyListeners();
  }

  Future<void> onDailyLogin() async {
    await _updateTaskProgress(DailyTaskType.loginStreak, 1);
    notifyListeners();
  }

  Future<int?> claimTask(DailyTaskDefinition task) async {
    if (!canClaim(task)) return null;

    final idx = dailyTasks.indexWhere((t) => t.taskId == task.id);
    if (idx < 0) return null;

    dailyTasks[idx] = dailyTasks[idx].copyWith(claimed: true);
    await _storage.saveDailyTasks(dailyTasks);

    if (task.type == DailyTaskType.loginStreak) {
      await _storage.markLoginRewardClaimed();
    }

    notifyListeners();
    return task.reward;
  }

  Future<void> _updateTaskProgress(DailyTaskType type, int value) async {
    for (final def in DailyTasksData.tasks) {
      if (def.type != type) continue;
      final idx = dailyTasks.indexWhere((t) => t.taskId == def.id);
      if (idx < 0) continue;
      dailyTasks[idx] =
          dailyTasks[idx].copyWith(progress: value.clamp(0, def.target));
    }
    await _storage.saveDailyTasks(dailyTasks);
  }
}
