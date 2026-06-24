enum Difficulty {
  easy(gridSize: 8, wordCount: 6, labelKey: 'easy'),
  medium(gridSize: 11, wordCount: 10, labelKey: 'medium'),
  hard(gridSize: 14, wordCount: 14, labelKey: 'hard');

  const Difficulty({
    required this.gridSize,
    required this.wordCount,
    required this.labelKey,
  });

  final int gridSize;
  final int wordCount;
  final String labelKey;
}
