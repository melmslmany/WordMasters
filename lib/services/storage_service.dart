import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_task.dart';
import '../models/game_state.dart';
import '../models/game_style.dart';
import '../models/player_stats.dart';
import '../models/word_guess_state.dart';
import '../models/word_language.dart';

class StorageService {
  static const _coinsKey = 'coins';
  static const _keysKey = 'keys';
  static const _wordLanguageKey = 'word_language';
  static const _uiLanguageKey = 'ui_language';
  static const _musicKey = 'music';
  static const _soundsKey = 'sounds';
  static const _unlockedCategoriesKey = 'unlocked_categories';
  static const _categoryProgressKey = 'category_progress';
  static const _activeGameKey = 'active_game';
  static const _activeWordGuessKey = 'active_word_guess';
  static const _gameStyleKey = 'game_style';
  static const _dailyStreakKey = 'daily_streak';
  static const _lastPlayedKey = 'last_played';
  static const _levelsPerCategoryKey = 'levels_per_category';
  static const _playerStatsKey = 'player_stats';
  static const _dailyTasksKey = 'daily_tasks';
  static const _dailyTasksDateKey = 'daily_tasks_date';
  static const _lastLoginRewardKey = 'last_login_reward';
  static const _statsDateKey = 'player_stats_date';
  static const _selectedBackgroundKey = 'selected_background';
  static const _ownedBackgroundsKey = 'owned_backgrounds';
  static const _backgroundsPurchasedTodayKey = 'backgrounds_purchased_today';
  static const _customBackgroundPathKey = 'custom_background_path';
  static const _playedCategoriesTodayKey = 'played_categories_today';
  static const _removeAdsKey = 'remove_ads';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get coins => _prefs.getInt(_coinsKey) ?? 100;
  int get keys => _prefs.getInt(_keysKey) ?? 0;
  WordLanguage get wordLanguage =>
      WordLanguage.fromCode(_prefs.getString(_wordLanguageKey) ?? 'en');
  String get uiLanguage => _prefs.getString(_uiLanguageKey) ?? 'en';
  bool get musicEnabled => _prefs.getBool(_musicKey) ?? true;
  bool get soundsEnabled => _prefs.getBool(_soundsKey) ?? true;
  int get dailyStreak => _prefs.getInt(_dailyStreakKey) ?? 0;
  int get levelsPerCategory => _prefs.getInt(_levelsPerCategoryKey) ?? 20;

  Future<void> setCoins(int value) => _prefs.setInt(_coinsKey, value);
  Future<void> setKeys(int value) => _prefs.setInt(_keysKey, value);
  Future<void> setWordLanguage(WordLanguage lang) =>
      _prefs.setString(_wordLanguageKey, lang.code);
  Future<void> setUiLanguage(String code) =>
      _prefs.setString(_uiLanguageKey, code);
  Future<void> setMusicEnabled(bool value) => _prefs.setBool(_musicKey, value);
  Future<void> setSoundsEnabled(bool value) =>
      _prefs.setBool(_soundsKey, value);
  Future<void> setLevelsPerCategory(int value) =>
      _prefs.setInt(_levelsPerCategoryKey, value);

  Set<String> getUnlockedCategories() =>
      _prefs.getStringList(_unlockedCategoriesKey)?.toSet() ?? <String>{};

  Future<void> unlockCategory(String id) async {
    final set = getUnlockedCategories()..add(id);
    await _prefs.setStringList(_unlockedCategoriesKey, set.toList());
  }

  Map<String, int> getCategoryProgress() {
    final raw = _prefs.getString(_categoryProgressKey);
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as int));
  }

  Future<void> setCategoryLevel(String categoryId, int level) async {
    final progress = getCategoryProgress();
    progress[categoryId] = level;
    await _prefs.setString(_categoryProgressKey, jsonEncode(progress));
  }

  ActiveGameState? getActiveGame() {
    final raw = _prefs.getString(_activeGameKey);
    if (raw == null) return null;
    return ActiveGameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveActiveGame(ActiveGameState? game) async {
    if (game == null) {
      await _prefs.remove(_activeGameKey);
    } else {
      await _prefs.setString(_activeGameKey, jsonEncode(game.toJson()));
    }
  }

  WordGuessState? getActiveWordGuess() {
    final raw = _prefs.getString(_activeWordGuessKey);
    if (raw == null) return null;
    return WordGuessState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveActiveWordGuess(WordGuessState? game) async {
    if (game == null) {
      await _prefs.remove(_activeWordGuessKey);
    } else {
      await _prefs.setString(_activeWordGuessKey, jsonEncode(game.toJson()));
    }
  }

  GameStyle get gameStyle =>
      GameStyle.fromCode(_prefs.getString(_gameStyleKey));

  Future<void> setGameStyle(GameStyle style) =>
      _prefs.setString(_gameStyleKey, style.code);

  Future<void> updateDailyStreak() async {
    final today = DateTime.now();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    final lastPlayed = _prefs.getString(_lastPlayedKey);
    var streak = dailyStreak;

    if (lastPlayed == todayStr) return;

    if (lastPlayed != null) {
      final last = DateTime.parse(lastPlayed);
      final diff = today.difference(last).inDays;
      streak = diff == 1 ? streak + 1 : 1;
    } else {
      streak = 1;
    }

    await _prefs.setInt(_dailyStreakKey, streak);
    await _prefs.setString(_lastPlayedKey, todayStr);
  }

  String _todayStr() {
    final today = DateTime.now();
    return '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
  }

  PlayerStats getPlayerStats() {
    _resetDailyStatsIfNeeded();
    final raw = _prefs.getString(_playerStatsKey);
    if (raw == null) return const PlayerStats();
    return PlayerStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  void _resetDailyStatsIfNeeded() {
    final today = _todayStr();
    if (_prefs.getString(_statsDateKey) == today) return;
    _prefs.setString(_statsDateKey, today);
    _prefs.setInt(_backgroundsPurchasedTodayKey, 0);
    _prefs.remove(_playedCategoriesTodayKey);

    final raw = _prefs.getString(_playerStatsKey);
    if (raw == null) return;

    final stats = PlayerStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    final reset = stats.copyWith(
      todayLevelsCompleted: 0,
      todayWordsFound: 0,
      todayLetterHints: 0,
      todayWordHints: 0,
      todayEndlessStage: 0,
      todayNoHintLevels: 0,
    );
    _prefs.setString(_playerStatsKey, jsonEncode(reset.toJson()));
  }

  List<String> getPlayedCategoriesToday() {
    _resetDailyStatsIfNeeded();
    return _prefs.getStringList(_playedCategoriesTodayKey) ?? <String>[];
  }

  Future<int> addPlayedCategoryToday(String categoryId) async {
    final set = getPlayedCategoriesToday().toSet()..add(categoryId);
    await _prefs.setStringList(_playedCategoriesTodayKey, set.toList());
    return set.length;
  }

  String? get customBackgroundPath =>
      _prefs.getString(_customBackgroundPathKey);

  Future<void> setCustomBackgroundPath(String path) =>
      _prefs.setString(_customBackgroundPathKey, path);

  bool get removeAds => _prefs.getBool(_removeAdsKey) ?? false;

  Future<void> setRemoveAds(bool value) =>
      _prefs.setBool(_removeAdsKey, value);

  Future<void> savePlayerStats(PlayerStats stats) =>
      _prefs.setString(_playerStatsKey, jsonEncode(stats.toJson()));

  List<DailyTaskProgress> getDailyTasks() {
    _resetDailyTasksIfNeeded();
    final raw = _prefs.getString(_dailyTasksKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => DailyTaskProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDailyTasks(List<DailyTaskProgress> tasks) =>
      _prefs.setString(
        _dailyTasksKey,
        jsonEncode(tasks.map((t) => t.toJson()).toList()),
      );

  void _resetDailyTasksIfNeeded() {
    final today = _todayStr();
    if (_prefs.getString(_dailyTasksDateKey) == today) return;
    _prefs.setString(_dailyTasksDateKey, today);
    _prefs.remove(_dailyTasksKey);
  }

  bool get claimedLoginRewardToday =>
      _prefs.getString(_lastLoginRewardKey) == _todayStr();

  Future<void> markLoginRewardClaimed() =>
      _prefs.setString(_lastLoginRewardKey, _todayStr());

  String get selectedBackgroundId =>
      _prefs.getString(_selectedBackgroundKey) ?? 'default';

  Set<String> getOwnedBackgrounds() =>
      _prefs.getStringList(_ownedBackgroundsKey)?.toSet() ?? {'default'};

  Future<void> setSelectedBackground(String id) =>
      _prefs.setString(_selectedBackgroundKey, id);

  Future<void> ownBackground(String id) async {
    final owned = getOwnedBackgrounds()..add(id);
    await _prefs.setStringList(_ownedBackgroundsKey, owned.toList());
  }

  int get backgroundsPurchasedToday =>
      _prefs.getInt(_backgroundsPurchasedTodayKey) ?? 0;

  Future<void> incrementBackgroundsPurchasedToday() async {
    _resetDailyStatsIfNeeded();
    final count = backgroundsPurchasedToday + 1;
    await _prefs.setInt(_backgroundsPurchasedTodayKey, count);
  }

  Map<String, dynamic> exportSnapshot() => {
        'coins': coins,
        'keys': keys,
        'wordLanguage': wordLanguage.code,
        'uiLanguage': uiLanguage,
        'musicEnabled': musicEnabled,
        'soundsEnabled': soundsEnabled,
        'dailyStreak': dailyStreak,
        'levelsPerCategory': levelsPerCategory,
        'unlockedCategories': getUnlockedCategories().toList(),
        'categoryProgress': getCategoryProgress(),
        'playerStats': getPlayerStats().toJson(),
        'dailyTasks': getDailyTasks().map((t) => t.toJson()).toList(),
        'selectedBackground': selectedBackgroundId,
        'ownedBackgrounds': getOwnedBackgrounds().toList(),
        'removeAds': removeAds,
        if (customBackgroundPath != null)
          'customBackgroundPath': customBackgroundPath,
      };

  Future<void> importSnapshot(Map<String, dynamic> data) async {
    if (data['coins'] != null) await setCoins(data['coins'] as int);
    if (data['keys'] != null) await setKeys(data['keys'] as int);
    if (data['wordLanguage'] != null) {
      await setWordLanguage(
        WordLanguage.fromCode(data['wordLanguage'] as String),
      );
    }
    if (data['uiLanguage'] != null) {
      await setUiLanguage(data['uiLanguage'] as String);
    }
    if (data['musicEnabled'] != null) {
      await setMusicEnabled(data['musicEnabled'] as bool);
    }
    if (data['soundsEnabled'] != null) {
      await setSoundsEnabled(data['soundsEnabled'] as bool);
    }
    if (data['levelsPerCategory'] != null) {
      await setLevelsPerCategory(data['levelsPerCategory'] as int);
    }
    if (data['unlockedCategories'] is List) {
      await _prefs.setStringList(
        _unlockedCategoriesKey,
        (data['unlockedCategories'] as List).cast<String>(),
      );
    }
    if (data['categoryProgress'] is Map) {
      await _prefs.setString(
        _categoryProgressKey,
        jsonEncode(data['categoryProgress']),
      );
    }
    if (data['playerStats'] is Map) {
      await savePlayerStats(
        PlayerStats.fromJson(data['playerStats'] as Map<String, dynamic>),
      );
    }
    if (data['dailyTasks'] is List) {
      final tasks = (data['dailyTasks'] as List)
          .map((e) => DailyTaskProgress.fromJson(e as Map<String, dynamic>))
          .toList();
      await saveDailyTasks(tasks);
    }
    if (data['selectedBackground'] != null) {
      await setSelectedBackground(data['selectedBackground'] as String);
    }
    if (data['ownedBackgrounds'] is List) {
      await _prefs.setStringList(
        _ownedBackgroundsKey,
        (data['ownedBackgrounds'] as List).cast<String>(),
      );
    }
    if (data['customBackgroundPath'] is String) {
      await setCustomBackgroundPath(data['customBackgroundPath'] as String);
    }
    if (data['removeAds'] is bool) {
      await setRemoveAds(data['removeAds'] as bool);
    }
  }
}
