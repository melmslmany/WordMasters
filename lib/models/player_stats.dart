class PlayerStats {
  const PlayerStats({
    this.totalWordsFound = 0,
    this.totalLevelsCompleted = 0,
    this.letterHintsUsed = 0,
    this.wordHintsUsed = 0,
    this.endlessBestStage = 0,
    this.consecutiveNoHintLevels = 0,
    this.todayLevelsCompleted = 0,
    this.todayWordsFound = 0,
    this.todayLetterHints = 0,
    this.todayWordHints = 0,
    this.todayEndlessStage = 0,
    this.todayNoHintLevels = 0,
    this.hintsUsedThisLevel = 0,
  });

  final int totalWordsFound;
  final int totalLevelsCompleted;
  final int letterHintsUsed;
  final int wordHintsUsed;
  final int endlessBestStage;
  final int consecutiveNoHintLevels;
  final int todayLevelsCompleted;
  final int todayWordsFound;
  final int todayLetterHints;
  final int todayWordHints;
  final int todayEndlessStage;
  final int todayNoHintLevels;
  final int hintsUsedThisLevel;

  PlayerStats copyWith({
    int? totalWordsFound,
    int? totalLevelsCompleted,
    int? letterHintsUsed,
    int? wordHintsUsed,
    int? endlessBestStage,
    int? consecutiveNoHintLevels,
    int? todayLevelsCompleted,
    int? todayWordsFound,
    int? todayLetterHints,
    int? todayWordHints,
    int? todayEndlessStage,
    int? todayNoHintLevels,
    int? hintsUsedThisLevel,
    bool resetHintsThisLevel = false,
  }) {
    return PlayerStats(
      totalWordsFound: totalWordsFound ?? this.totalWordsFound,
      totalLevelsCompleted:
          totalLevelsCompleted ?? this.totalLevelsCompleted,
      letterHintsUsed: letterHintsUsed ?? this.letterHintsUsed,
      wordHintsUsed: wordHintsUsed ?? this.wordHintsUsed,
      endlessBestStage: endlessBestStage ?? this.endlessBestStage,
      consecutiveNoHintLevels:
          consecutiveNoHintLevels ?? this.consecutiveNoHintLevels,
      todayLevelsCompleted:
          todayLevelsCompleted ?? this.todayLevelsCompleted,
      todayWordsFound: todayWordsFound ?? this.todayWordsFound,
      todayLetterHints: todayLetterHints ?? this.todayLetterHints,
      todayWordHints: todayWordHints ?? this.todayWordHints,
      todayEndlessStage: todayEndlessStage ?? this.todayEndlessStage,
      todayNoHintLevels: todayNoHintLevels ?? this.todayNoHintLevels,
      hintsUsedThisLevel: resetHintsThisLevel
          ? 0
          : (hintsUsedThisLevel ?? this.hintsUsedThisLevel),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalWordsFound': totalWordsFound,
        'totalLevelsCompleted': totalLevelsCompleted,
        'letterHintsUsed': letterHintsUsed,
        'wordHintsUsed': wordHintsUsed,
        'endlessBestStage': endlessBestStage,
        'consecutiveNoHintLevels': consecutiveNoHintLevels,
        'todayLevelsCompleted': todayLevelsCompleted,
        'todayWordsFound': todayWordsFound,
        'todayLetterHints': todayLetterHints,
        'todayWordHints': todayWordHints,
        'todayEndlessStage': todayEndlessStage,
        'todayNoHintLevels': todayNoHintLevels,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      totalWordsFound: json['totalWordsFound'] as int? ?? 0,
      totalLevelsCompleted: json['totalLevelsCompleted'] as int? ?? 0,
      letterHintsUsed: json['letterHintsUsed'] as int? ?? 0,
      wordHintsUsed: json['wordHintsUsed'] as int? ?? 0,
      endlessBestStage: json['endlessBestStage'] as int? ?? 0,
      consecutiveNoHintLevels: json['consecutiveNoHintLevels'] as int? ?? 0,
      todayLevelsCompleted: json['todayLevelsCompleted'] as int? ?? 0,
      todayWordsFound: json['todayWordsFound'] as int? ?? 0,
      todayLetterHints: json['todayLetterHints'] as int? ?? 0,
      todayWordHints: json['todayWordHints'] as int? ?? 0,
      todayEndlessStage: json['todayEndlessStage'] as int? ?? 0,
      todayNoHintLevels: json['todayNoHintLevels'] as int? ?? 0,
    );
  }
}
