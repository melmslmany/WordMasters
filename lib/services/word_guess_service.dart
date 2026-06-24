import 'dart:math';

import '../data/words_repository.dart';
import '../models/difficulty.dart';
import '../models/word_guess_state.dart';
import '../models/word_language.dart';

class WordGuessService {
  /// Builds a Word Guess level: picks a few category words and merges their
  /// letters into one shuffled pool. Solving every word consumes the pool.
  WordGuessState createLevel({
    required String categoryId,
    required int level,
    required WordLanguage language,
    required bool isProgressMode,
    bool isEndlessMode = false,
    int endlessStage = 1,
    Difficulty difficulty = Difficulty.medium,
  }) {
    final rng = Random();
    final all = WordsRepository.getWords(categoryId, language)
        .map((w) => w.toUpperCase())
        .toSet()
        .toList();

    final params = _params(
      isProgressMode: isProgressMode,
      isEndlessMode: isEndlessMode,
      level: level,
      endlessStage: endlessStage,
      difficulty: difficulty,
    );

    final candidates = all
        .where((w) =>
            w.length >= params.minLen && w.length <= params.maxLen)
        .toList()
      ..shuffle(rng);

    final chosen = <String>[];
    var tiles = 0;
    for (final w in candidates) {
      if (chosen.contains(w)) continue;
      if (tiles + w.length > params.tileCap) continue;
      chosen.add(w);
      tiles += w.length;
      if (chosen.length >= params.wordCount) break;
    }

    // Fallbacks: guarantee at least one playable word.
    if (chosen.isEmpty) {
      final sorted = all.toList()
        ..sort((a, b) => a.length.compareTo(b.length));
      if (sorted.isNotEmpty) {
        chosen.add(sorted.first);
      } else {
        chosen.add('WORD');
      }
    }

    final letters = chosen.expand((w) => w.split('')).toList()..shuffle(rng);
    chosen.sort((a, b) => a.length.compareTo(b.length));

    return WordGuessState(
      categoryId: categoryId,
      level: level,
      letters: letters,
      targets: chosen,
      isProgressMode: isProgressMode,
      isEndlessMode: isEndlessMode,
      endlessStage: endlessStage,
      difficulty: difficulty,
    );
  }

  _GuessParams _params({
    required bool isProgressMode,
    required bool isEndlessMode,
    required int level,
    required int endlessStage,
    required Difficulty difficulty,
  }) {
    if (isProgressMode) {
      final wordCount = min(2 + (level ~/ 3), 5);
      final maxLen = min(4 + (level ~/ 4), 7);
      return _GuessParams(
        minLen: 3,
        maxLen: maxLen,
        wordCount: wordCount,
        tileCap: min(6 + (level ~/ 2), 12),
      );
    }
    if (isEndlessMode) {
      final wordCount = min(2 + (endlessStage ~/ 3), 5);
      final maxLen = min(4 + (endlessStage ~/ 4), 7);
      return _GuessParams(
        minLen: 3,
        maxLen: maxLen,
        wordCount: wordCount,
        tileCap: min(6 + (endlessStage ~/ 2), 12),
      );
    }
    // Casual: sized by difficulty.
    return switch (difficulty) {
      Difficulty.easy =>
        const _GuessParams(minLen: 3, maxLen: 4, wordCount: 2, tileCap: 6),
      Difficulty.medium =>
        const _GuessParams(minLen: 3, maxLen: 5, wordCount: 3, tileCap: 9),
      Difficulty.hard =>
        const _GuessParams(minLen: 3, maxLen: 6, wordCount: 4, tileCap: 12),
    };
  }
}

class _GuessParams {
  const _GuessParams({
    required this.minLen,
    required this.maxLen,
    required this.wordCount,
    required this.tileCap,
  });

  final int minLen;
  final int maxLen;
  final int wordCount;
  final int tileCap;
}
