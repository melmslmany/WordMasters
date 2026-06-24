class LevelsOption {
  const LevelsOption(this.count);

  final int count;

  static const options = [20, 50, 100, 500];

  static LevelsOption fromCount(int count) {
    return LevelsOption(
      options.contains(count) ? count : options.first,
    );
  }
}
