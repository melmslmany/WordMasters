/// The way a level is played.
///
/// - [classic]: the original word-search grid (drag to connect letters).
/// - [wordGuess]: arrange a pool of letters into the hidden words.
enum GameStyle {
  classic('classic'),
  wordGuess('word_guess');

  const GameStyle(this.code);

  final String code;

  static GameStyle fromCode(String? code) {
    return GameStyle.values.firstWhere(
      (s) => s.code == code,
      orElse: () => GameStyle.classic,
    );
  }
}
