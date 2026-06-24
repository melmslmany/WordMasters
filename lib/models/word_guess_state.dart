import 'difficulty.dart';

/// State for a "Word Guess" level: a shuffled pool of letters that must be
/// arranged into a set of hidden target words.
class WordGuessState {
  WordGuessState({
    required this.categoryId,
    required this.level,
    required this.letters,
    required this.targets,
    required this.isProgressMode,
    this.isEndlessMode = false,
    this.endlessStage = 1,
    this.difficulty = Difficulty.medium,
    Set<int>? solvedTargets,
    Set<int>? usedLetters,
  })  : solvedTargets = solvedTargets ?? <int>{},
        usedLetters = usedLetters ?? <int>{};

  final String categoryId;
  final int level;

  /// The shuffled letter pool (one entry per tile, duplicates allowed).
  final List<String> letters;

  /// The target words to discover, sorted shortest-first for display.
  final List<String> targets;

  final bool isProgressMode;
  final bool isEndlessMode;
  final int endlessStage;
  final Difficulty difficulty;

  /// Indices into [targets] that have been solved.
  final Set<int> solvedTargets;

  /// Indices into [letters] that have been consumed by solved words.
  final Set<int> usedLetters;

  bool get isComplete => solvedTargets.length == targets.length;
  int get solvedCount => solvedTargets.length;
  bool isSolved(int targetIndex) => solvedTargets.contains(targetIndex);
  bool isUsed(int letterIndex) => usedLetters.contains(letterIndex);

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'level': level,
        'letters': letters,
        'targets': targets,
        'isProgressMode': isProgressMode,
        'isEndlessMode': isEndlessMode,
        'endlessStage': endlessStage,
        'difficulty': difficulty.name,
        'solvedTargets': solvedTargets.toList(),
        'usedLetters': usedLetters.toList(),
      };

  factory WordGuessState.fromJson(Map<String, dynamic> json) {
    return WordGuessState(
      categoryId: json['categoryId'] as String,
      level: json['level'] as int,
      letters:
          (json['letters'] as List).map((e) => e as String).toList(),
      targets:
          (json['targets'] as List).map((e) => e as String).toList(),
      isProgressMode: json['isProgressMode'] as bool? ?? true,
      isEndlessMode: json['isEndlessMode'] as bool? ?? false,
      endlessStage: json['endlessStage'] as int? ?? 1,
      difficulty: _parseDifficulty(json['difficulty'] as String?),
      solvedTargets:
          (json['solvedTargets'] as List?)?.map((e) => e as int).toSet(),
      usedLetters:
          (json['usedLetters'] as List?)?.map((e) => e as int).toSet(),
    );
  }

  static Difficulty _parseDifficulty(String? name) {
    if (name == null) return Difficulty.medium;
    return Difficulty.values.firstWhere(
      (d) => d.name == name,
      orElse: () => Difficulty.medium,
    );
  }
}
