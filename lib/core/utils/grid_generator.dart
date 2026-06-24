import 'dart:math';

import '../../models/cell_position.dart';
import '../../models/word_placement.dart';
import '../../models/word_language.dart';

class GridGenerator {
  GridGenerator._();

  static const _englishLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _arabicLetters =
      'ابتثجحخدذرزسشصضطظعغفقكلمنهوي';
  static const _cyrillicLetters =
      'АБВГДЕЖЗИЙКЛМНОПРСТУФХЦЧШЩЫЭЮЯ';

  static String _fillLettersFor(LetterScript script) {
    switch (script) {
      case LetterScript.arabic:
        return _arabicLetters;
      case LetterScript.cyrillic:
        return _cyrillicLetters;
      case LetterScript.latin:
        return _englishLetters;
    }
  }

  static final _directions = [
    (0, 1), // horizontal
    (1, 0), // vertical
    (1, 1), // diagonal down-right
    (-1, 1), // diagonal up-right
  ];

  static ({List<List<String>> grid, List<WordPlacement> placements}) generate({
    required List<String> words,
    required int size,
    required WordLanguage language,
  }) {
    final rng = Random();
    final sortedWords = words.map((w) => w.toUpperCase()).toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    final grid = List.generate(size, (_) => List.filled(size, ''));
    final placements = <WordPlacement>[];
    var colorIndex = 0;

    for (final word in sortedWords) {
      var placed = false;
      for (var attempt = 0; attempt < 200 && !placed; attempt++) {
        final dir = _directions[rng.nextInt(_directions.length)];
        final startRow = rng.nextInt(size);
        final startCol = rng.nextInt(size);

        final cells = <CellPosition>[];
        var valid = true;

        for (var i = 0; i < word.length; i++) {
          final row = startRow + dir.$1 * i;
          final col = startCol + dir.$2 * i;
          if (row < 0 || row >= size || col < 0 || col >= size) {
            valid = false;
            break;
          }
          final existing = grid[row][col];
          if (existing.isNotEmpty && existing != word[i]) {
            valid = false;
            break;
          }
          cells.add(CellPosition(row, col));
        }

        if (valid && cells.length == word.length) {
          for (var i = 0; i < word.length; i++) {
            grid[cells[i].row][cells[i].col] = word[i];
          }
          placements.add(WordPlacement(
            word: word,
            cells: cells,
            colorIndex: colorIndex % 10,
          ));
          colorIndex++;
          placed = true;
        }
      }
    }

    final letters = _fillLettersFor(language.script);
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (grid[r][c].isEmpty) {
          grid[r][c] = letters[rng.nextInt(letters.length)];
        }
      }
    }

    return (grid: grid, placements: placements);
  }

  static bool isValidSelection(List<CellPosition> cells) {
    if (cells.length < 2) return false;
    final dr = cells[1].row - cells[0].row;
    final dc = cells[1].col - cells[0].col;
    if (dr == 0 && dc == 0) return false;

    for (var i = 2; i < cells.length; i++) {
      final expectedDr = dr.sign * (i);
      final expectedDc = dc.sign * (i);
      if (cells[i].row - cells[0].row != expectedDr ||
          cells[i].col - cells[0].col != expectedDc) {
        return false;
      }
    }
    return true;
  }

  static String getSelectedWord(
    List<List<String>> grid,
    List<CellPosition> cells,
  ) {
    return cells.map((c) => grid[c.row][c.col]).join();
  }

  static int? matchPlacement(
    List<CellPosition> selected,
    List<WordPlacement> placements,
    Set<int> foundIndices,
  ) {
    if (selected.length < 2) return null;

    final selectedSet = selected.toSet();
    if (selectedSet.length != selected.length) return null;

    for (var i = 0; i < placements.length; i++) {
      if (foundIndices.contains(i)) continue;
      final placementSet = placements[i].cells.toSet();
      if (placementSet.length == selectedSet.length &&
          placementSet.containsAll(selectedSet)) {
        return i;
      }
    }
    return null;
  }

  @Deprecated('Use matchPlacement')
  static String? matchWord(
    String selected,
    List<String> words,
    Set<String> foundWords,
  ) {
    final upper = selected.toUpperCase();
    final reversed = upper.split('').reversed.join();

    for (final word in words) {
      if (foundWords.contains(word)) continue;
      if (word == upper || word == reversed) return word;
    }
    return null;
  }
}
