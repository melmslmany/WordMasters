import 'dart:math';

import 'package:flutter/material.dart';

import '../data/categories_data.dart';
import '../models/difficulty.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../models/game_style.dart';
import '../models/word_guess_state.dart';
import '../models/word_language.dart';
import '../models/word_placement.dart';
import '../services/game_service.dart';
import '../services/word_guess_service.dart';
import '../services/storage_service.dart';
import 'progression_provider.dart';

class GameProvider extends ChangeNotifier {
  GameProvider(this._storage, this._gameService);

  final StorageService _storage;
  final GameService _gameService;
  final WordGuessService _wordGuessService = WordGuessService();
  ProgressionProvider? _progression;

  void bindProgression(ProgressionProvider progression) {
    _progression = progression;
  }
  final _rng = Random();

  int coins = 100;
  int keys = 0;
  WordLanguage wordLanguage = WordLanguage.english;
  GameStyle gameStyle = GameStyle.classic;
  Set<String> unlockedCategories = {};
  Map<String, int> categoryProgress = {};
  ActiveGameState? activeGame;
  WordGuessState? activeWordGuess;
  int dailyStreak = 0;
  int levelsPerCategory = 20;
  int hintsUsedThisLevel = 0;

  static const highlightWordCost = 50;
  static const highlightLetterCost = 25;
  static const levelCompleteReward = 25;
  static const endlessStageReward = 10;
  static const categoryCompleteKeyReward = 1;

  Future<void> load() async {
    coins = _storage.coins;
    keys = _storage.keys;
    wordLanguage = _storage.wordLanguage;
    gameStyle = _storage.gameStyle;
    unlockedCategories = _storage.getUnlockedCategories();
    categoryProgress = _storage.getCategoryProgress();
    dailyStreak = _storage.dailyStreak;
    levelsPerCategory = _storage.levelsPerCategory;
    activeGame = _storage.getActiveGame();
    activeWordGuess = _storage.getActiveWordGuess();
    notifyListeners();
  }

  Future<void> setGameStyle(GameStyle style) async {
    gameStyle = style;
    await _storage.setGameStyle(style);
    notifyListeners();
  }

  void syncLevelsPerCategory(int count) {
    levelsPerCategory = count;
  }

  bool isCategoryUnlocked(String id) {
    final cat = CategoriesData.byId(id);
    if (cat == null) return false;
    if (!cat.isLocked) return true;
    return unlockedCategories.contains(id);
  }

  int getCategoryLevel(String id) => categoryProgress[id] ?? 0;

  int getCategoryCompletedLevels(String id) => getCategoryLevel(id);

  Future<void> setWordLanguage(WordLanguage lang) async {
    wordLanguage = lang;
    await _storage.setWordLanguage(lang);
    notifyListeners();
  }

  Future<void> addCoins(int amount) async {
    coins += amount;
    await _storage.setCoins(coins);
    notifyListeners();
  }

  Future<bool> spendCoins(int amount) async {
    if (coins < amount) return false;
    coins -= amount;
    await _storage.setCoins(coins);
    notifyListeners();
    return true;
  }

  Future<void> unlockCategory(String id, {bool useKey = true}) async {
    final cat = CategoriesData.byId(id);
    if (cat == null) return;

    if (useKey && keys >= cat.unlockCostKeys) {
      keys -= cat.unlockCostKeys;
      await _storage.setKeys(keys);
    } else if (coins >= cat.unlockCostCoins) {
      coins -= cat.unlockCostCoins;
      await _storage.setCoins(coins);
    } else {
      return;
    }

    unlockedCategories.add(id);
    await _storage.unlockCategory(id);
    notifyListeners();
  }

  ActiveGameState startGame({
    required String categoryId,
    required GameMode mode,
    Difficulty difficulty = Difficulty.medium,
    int? endlessStage,
  }) {
    final level = switch (mode) {
      GameMode.progress => getCategoryLevel(categoryId) + 1,
      GameMode.endless => endlessStage ?? 1,
      GameMode.casual => 1,
    };

    final pickedDifficulty = mode == GameMode.endless
        ? Difficulty.values[_rng.nextInt(Difficulty.values.length)]
        : difficulty;

    final game = _gameService.createGame(
      categoryId: categoryId,
      level: level,
      language: wordLanguage,
      isProgressMode: mode == GameMode.progress,
      isEndlessMode: mode == GameMode.endless,
      endlessStage: mode == GameMode.endless ? level : 1,
      difficulty: pickedDifficulty,
    );

    activeGame = game;
    activeWordGuess = null;
    hintsUsedThisLevel = 0;
    _storage.saveActiveGame(game);
    _storage.saveActiveWordGuess(null);
    _storage.updateDailyStreak();
    _progression?.onDailyLogin();
    _progression?.onCategoryPlayed(categoryId);
    notifyListeners();
    return game;
  }

  Future<void> markPlacementFound(int placementIndex) async {
    if (activeGame == null) return;
    if (activeGame!.foundPlacementIndices.contains(placementIndex)) return;

    final updated = activeGame!.copyWith(
      foundPlacementIndices: {
        ...activeGame!.foundPlacementIndices,
        placementIndex,
      },
      clearHighlight: true,
    );
    activeGame = updated;
    await _storage.saveActiveGame(updated);
    await _progression?.onWordFound();
    notifyListeners();
  }

  Future<int> completeLevel() async {
    if (activeGame == null) return 0;

    var reward = levelCompleteReward;
    if (activeGame!.isEndlessMode) {
      reward = endlessStageReward;
    } else if (activeGame!.isProgressMode) {
      final catId = activeGame!.categoryId;
      final currentLevel = getCategoryLevel(catId);
      if (activeGame!.level > currentLevel) {
        await _storage.setCategoryLevel(catId, activeGame!.level);
        categoryProgress[catId] = activeGame!.level;
      }

      if (activeGame!.level >= levelsPerCategory) {
        keys += categoryCompleteKeyReward;
        await _storage.setKeys(keys);
        reward += 50;
      }
    }

    coins += reward;
    await _storage.setCoins(coins);

    if (activeGame!.isEndlessMode) {
      await _progression?.onEndlessStage(activeGame!.endlessStage);
    } else {
      await _progression?.onLevelCompleted(
        usedHints: hintsUsedThisLevel > 0,
      );
    }

    activeGame = null;
    hintsUsedThisLevel = 0;
    await _storage.saveActiveGame(null);
    notifyListeners();
    return reward;
  }

  Future<int> advanceEndlessStage() async {
    if (activeGame == null || !activeGame!.isEndlessMode) return 0;

    final completedStage = activeGame!.endlessStage;
    await _progression?.onEndlessStage(completedStage);
    await _progression?.onLevelCompleted(
      usedHints: hintsUsedThisLevel > 0,
    );
    hintsUsedThisLevel = 0;

    coins += endlessStageReward;
    await _storage.setCoins(coins);

    final nextStage = activeGame!.endlessStage + 1;
    final categoryId = activeGame!.categoryId;
    final difficulty =
        Difficulty.values[_rng.nextInt(Difficulty.values.length)];

    final game = _gameService.createGame(
      categoryId: categoryId,
      level: nextStage,
      language: wordLanguage,
      isProgressMode: false,
      isEndlessMode: true,
      endlessStage: nextStage,
      difficulty: difficulty,
    );

    activeGame = game;
    await _storage.saveActiveGame(game);
    notifyListeners();
    return endlessStageReward;
  }

  Future<bool> useHighlightWordHint() async {
    if (activeGame == null || coins < highlightWordCost) return false;

    final remaining = <int>[];
    for (var i = 0; i < activeGame!.placements.length; i++) {
      if (!activeGame!.foundPlacementIndices.contains(i)) remaining.add(i);
    }
    if (remaining.isEmpty) return false;

    remaining.shuffle();
    activeGame = activeGame!.copyWith(
      highlightedPlacementIndex: remaining.first,
    );
    coins -= highlightWordCost;
    await _storage.setCoins(coins);
    hintsUsedThisLevel++;
    await _progression?.onWordHintUsed();
    await _storage.saveActiveGame(activeGame);
    notifyListeners();
    return true;
  }

  Future<bool> useHighlightLetterHint() async {
    if (activeGame == null || coins < highlightLetterCost) return false;

    final remaining = <WordPlacement>[];
    for (var i = 0; i < activeGame!.placements.length; i++) {
      if (!activeGame!.foundPlacementIndices.contains(i)) {
        remaining.add(activeGame!.placements[i]);
      }
    }
    if (remaining.isEmpty) return false;

    remaining.shuffle();
    final cell = remaining.first.cells.first;
    final updated = activeGame!.copyWith(
      highlightedLetters: {...activeGame!.highlightedLetters, cell},
    );
    activeGame = updated;
    coins -= highlightLetterCost;
    await _storage.setCoins(coins);
    hintsUsedThisLevel++;
    await _progression?.onLetterHintUsed();
    await _storage.saveActiveGame(updated);
    notifyListeners();
    return true;
  }

  Future<void> clearActiveGame() async {
    activeGame = null;
    await _storage.saveActiveGame(null);
    notifyListeners();
  }

  bool hasSavedProgress(String categoryId) =>
      activeGame?.categoryId == categoryId && activeGame!.isProgressMode;

  // ----- Word Guess mode -----

  WordGuessState startWordGuess({
    required String categoryId,
    required GameMode mode,
    Difficulty difficulty = Difficulty.medium,
    int? endlessStage,
  }) {
    final level = switch (mode) {
      GameMode.progress => getCategoryLevel(categoryId) + 1,
      GameMode.endless => endlessStage ?? 1,
      GameMode.casual => 1,
    };

    final pickedDifficulty = mode == GameMode.endless
        ? Difficulty.values[_rng.nextInt(Difficulty.values.length)]
        : difficulty;

    final game = _wordGuessService.createLevel(
      categoryId: categoryId,
      level: level,
      language: wordLanguage,
      isProgressMode: mode == GameMode.progress,
      isEndlessMode: mode == GameMode.endless,
      endlessStage: mode == GameMode.endless ? level : 1,
      difficulty: pickedDifficulty,
    );

    activeWordGuess = game;
    activeGame = null;
    hintsUsedThisLevel = 0;
    _storage.saveActiveWordGuess(game);
    _storage.saveActiveGame(null);
    _storage.updateDailyStreak();
    _progression?.onDailyLogin();
    _progression?.onCategoryPlayed(categoryId);
    notifyListeners();
    return game;
  }

  Future<void> solveWordGuessTarget(
    int targetIndex,
    List<int> letterIndices,
  ) async {
    final game = activeWordGuess;
    if (game == null) return;
    if (game.solvedTargets.contains(targetIndex)) return;

    game.solvedTargets.add(targetIndex);
    game.usedLetters.addAll(letterIndices);
    await _storage.saveActiveWordGuess(game);
    await _progression?.onWordFound();
    notifyListeners();
  }

  /// Auto-solves one remaining word using free (unused) tiles. Returns false if
  /// the player cannot afford it or there is nothing left to solve.
  Future<bool> useWordGuessHint() async {
    final game = activeWordGuess;
    if (game == null || coins < highlightWordCost) return false;

    int? targetIndex;
    for (var i = 0; i < game.targets.length; i++) {
      if (!game.solvedTargets.contains(i)) {
        targetIndex = i;
        break;
      }
    }
    if (targetIndex == null) return false;

    final word = game.targets[targetIndex];
    final available = <int>[];
    for (var i = 0; i < game.letters.length; i++) {
      if (!game.usedLetters.contains(i)) available.add(i);
    }

    final picked = <int>[];
    for (final ch in word.split('')) {
      int? match;
      for (final idx in available) {
        if (picked.contains(idx)) continue;
        if (game.letters[idx] == ch) {
          match = idx;
          break;
        }
      }
      if (match == null) return false; // pool can't form it (shouldn't happen)
      picked.add(match);
    }

    coins -= highlightWordCost;
    await _storage.setCoins(coins);
    hintsUsedThisLevel++;
    await _progression?.onWordHintUsed();
    await solveWordGuessTarget(targetIndex, picked);
    return true;
  }

  Future<int> completeWordGuess() async {
    final game = activeWordGuess;
    if (game == null) return 0;

    var reward = levelCompleteReward;
    if (game.isEndlessMode) {
      reward = endlessStageReward;
    } else if (game.isProgressMode) {
      final catId = game.categoryId;
      final currentLevel = getCategoryLevel(catId);
      if (game.level > currentLevel) {
        await _storage.setCategoryLevel(catId, game.level);
        categoryProgress[catId] = game.level;
      }
      if (game.level >= levelsPerCategory) {
        keys += categoryCompleteKeyReward;
        await _storage.setKeys(keys);
        reward += 50;
      }
    }

    coins += reward;
    await _storage.setCoins(coins);

    if (game.isEndlessMode) {
      await _progression?.onEndlessStage(game.endlessStage);
    } else {
      await _progression?.onLevelCompleted(usedHints: hintsUsedThisLevel > 0);
    }

    activeWordGuess = null;
    hintsUsedThisLevel = 0;
    await _storage.saveActiveWordGuess(null);
    notifyListeners();
    return reward;
  }

  Future<void> clearWordGuess() async {
    activeWordGuess = null;
    await _storage.saveActiveWordGuess(null);
    notifyListeners();
  }
}
