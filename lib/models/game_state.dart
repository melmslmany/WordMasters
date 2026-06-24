import 'cell_position.dart';
import 'difficulty.dart';
import 'word_placement.dart';

class ActiveGameState {
  const ActiveGameState({
    required this.categoryId,
    required this.level,
    required this.grid,
    required this.words,
    required this.placements,
    required this.foundPlacementIndices,
    required this.isProgressMode,
    this.isEndlessMode = false,
    this.endlessStage = 1,
    this.difficulty = Difficulty.medium,
    this.highlightedPlacementIndex,
    this.highlightedLetters = const {},
  });

  final String categoryId;
  final int level;
  final List<List<String>> grid;
  final List<String> words;
  final List<WordPlacement> placements;
  final Set<int> foundPlacementIndices;
  final bool isProgressMode;
  final bool isEndlessMode;
  final int endlessStage;
  final Difficulty difficulty;
  final int? highlightedPlacementIndex;
  final Set<CellPosition> highlightedLetters;

  bool get isComplete => foundPlacementIndices.length == placements.length;

  int get foundCount => foundPlacementIndices.length;

  bool isPlacementFound(int index) => foundPlacementIndices.contains(index);

  ActiveGameState copyWith({
    Set<int>? foundPlacementIndices,
    int? highlightedPlacementIndex,
    Set<CellPosition>? highlightedLetters,
    bool clearHighlight = false,
  }) {
    return ActiveGameState(
      categoryId: categoryId,
      level: level,
      grid: grid,
      words: words,
      placements: placements,
      foundPlacementIndices:
          foundPlacementIndices ?? this.foundPlacementIndices,
      isProgressMode: isProgressMode,
      isEndlessMode: isEndlessMode,
      endlessStage: endlessStage,
      difficulty: difficulty,
      highlightedPlacementIndex: clearHighlight
          ? null
          : (highlightedPlacementIndex ?? this.highlightedPlacementIndex),
      highlightedLetters: highlightedLetters ?? this.highlightedLetters,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'level': level,
        'grid': grid,
        'words': words,
        'placements': placements
            .map((p) => {
                  'word': p.word,
                  'cells': p.cells.map((c) => [c.row, c.col]).toList(),
                  'colorIndex': p.colorIndex,
                })
            .toList(),
        'foundPlacementIndices': foundPlacementIndices.toList(),
        'isProgressMode': isProgressMode,
        'isEndlessMode': isEndlessMode,
        'endlessStage': endlessStage,
        'difficulty': difficulty.name,
      };

  factory ActiveGameState.fromJson(Map<String, dynamic> json) {
    final placements = (json['placements'] as List).map((p) {
      final map = p as Map<String, dynamic>;
      return WordPlacement(
        word: map['word'] as String,
        cells: (map['cells'] as List)
            .map((c) => CellPosition((c as List)[0] as int, c[1] as int))
            .toList(),
        colorIndex: map['colorIndex'] as int,
      );
    }).toList();

    Set<int> foundIndices;
    if (json['foundPlacementIndices'] != null) {
      foundIndices =
          (json['foundPlacementIndices'] as List).map((i) => i as int).toSet();
    } else {
      final legacyFound =
          (json['foundWords'] as List?)?.map((w) => w as String).toList() ??
              [];
      foundIndices = <int>{};
      final used = <int>{};
      for (final word in legacyFound) {
        for (var i = 0; i < placements.length; i++) {
          if (!used.contains(i) && placements[i].word == word) {
            foundIndices.add(i);
            used.add(i);
            break;
          }
        }
      }
    }

    return ActiveGameState(
      categoryId: json['categoryId'] as String,
      level: json['level'] as int,
      grid: (json['grid'] as List)
          .map((row) => (row as List).map((c) => c as String).toList())
          .toList(),
      words: (json['words'] as List).map((w) => w as String).toList(),
      placements: placements,
      foundPlacementIndices: foundIndices,
      isProgressMode: json['isProgressMode'] as bool? ?? true,
      isEndlessMode: json['isEndlessMode'] as bool? ?? false,
      endlessStage: json['endlessStage'] as int? ?? 1,
      difficulty: _parseDifficulty(json['difficulty'] as String?),
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
