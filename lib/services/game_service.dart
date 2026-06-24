import 'dart:math';

import '../core/utils/grid_generator.dart';
import '../data/words_repository.dart';
import '../models/difficulty.dart';
import '../models/game_state.dart';
import '../models/word_language.dart';

class GameService {
  ActiveGameState createGame({
    required String categoryId,
    required int level,
    required WordLanguage language,
    required bool isProgressMode,
    bool isEndlessMode = false,
    int endlessStage = 1,
    Difficulty difficulty = Difficulty.medium,
  }) {
    final allWords = WordsRepository.getWords(categoryId, language);
    final rng = Random();
    final shuffled = List<String>.from(allWords)..shuffle(rng);

    final wordCount = isProgressMode
        ? min(8 + (level ~/ 2), 15)
        : isEndlessMode
            ? min(7 + (endlessStage ~/ 3), 16)
            : difficulty.wordCount;
    final gridSize = isProgressMode
        ? min(11 + (level ~/ 3), 15)
        : isEndlessMode
            ? min(11 + (endlessStage ~/ 4), 16)
            : difficulty.gridSize;

    final seen = <String>{};
    final selected = <String>[];
    for (final w in shuffled) {
      if (w.length > gridSize) continue;
      if (!seen.add(w)) continue;
      selected.add(w);
      if (selected.length >= wordCount) break;
    }

    final result = GridGenerator.generate(
      words: selected,
      size: gridSize,
      language: language,
    );

    return ActiveGameState(
      categoryId: categoryId,
      level: level,
      grid: result.grid,
      words: result.placements.map((p) => p.word).toList(),
      placements: result.placements,
      foundPlacementIndices: {},
      isProgressMode: isProgressMode,
      isEndlessMode: isEndlessMode,
      endlessStage: endlessStage,
      difficulty: difficulty,
    );
  }
}
