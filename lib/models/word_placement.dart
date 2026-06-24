import 'cell_position.dart';

class WordPlacement {
  const WordPlacement({
    required this.word,
    required this.cells,
    required this.colorIndex,
  });

  final String word;
  final List<CellPosition> cells;
  final int colorIndex;
}
