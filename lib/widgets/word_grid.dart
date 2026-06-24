import 'package:flutter/material.dart';

import '../core/utils/grid_generator.dart';
import '../core/constants/app_colors.dart';
import '../models/cell_position.dart';
import '../models/word_placement.dart';

class WordGrid extends StatefulWidget {
  const WordGrid({
    super.key,
    required this.grid,
    required this.placements,
    required this.foundPlacementIndices,
    this.highlightedPlacementIndex,
    required this.highlightedLetters,
    required this.onPlacementFound,
    this.isArabic = false,
    this.fontFamily,
  });

  final List<List<String>> grid;
  final List<WordPlacement> placements;
  final Set<int> foundPlacementIndices;
  final int? highlightedPlacementIndex;
  final Set<CellPosition> highlightedLetters;
  final Future<void> Function(int placementIndex, List<CellPosition> cells)
      onPlacementFound;
  final bool isArabic;
  final String? fontFamily;

  @override
  State<WordGrid> createState() => _WordGridState();
}

class _WordGridState extends State<WordGrid> {
  final GlobalKey _gridKey = GlobalKey();

  CellPosition? _startCell;
  List<CellPosition> _selectedCells = [];
  bool _isDragging = false;

  int get _size => widget.grid.length;

  CellPosition? _cellAt(Offset globalPosition) {
    final box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;

    final local = box.globalToLocal(globalPosition);
    final side = box.size.width;
    if (local.dx < 0 ||
        local.dy < 0 ||
        local.dx >= side ||
        local.dy >= side) {
      return null;
    }

    final cellSize = side / _size;
    final col = (local.dx / cellSize).floor().clamp(0, _size - 1);
    final row = (local.dy / cellSize).floor().clamp(0, _size - 1);
    return CellPosition(row, col);
  }

  void _onDragStart(Offset globalPosition) {
    final cell = _cellAt(globalPosition);
    if (cell == null) return;
    _isDragging = true;
    setState(() {
      _startCell = cell;
      _selectedCells = [cell];
    });
  }

  void _onDragUpdate(Offset globalPosition) {
    if (!_isDragging || _startCell == null) return;
    final cell = _cellAt(globalPosition);
    if (cell == null) return;

    final cells = _getCellsBetween(_startCell!, cell);
    if (cells.isNotEmpty) {
      setState(() => _selectedCells = cells);
    }
  }

  void _clearSelection() {
    _isDragging = false;
    setState(() {
      _selectedCells = [];
      _startCell = null;
    });
  }

  Future<void> _onDragEnd() async {
    if (!_isDragging) return;
    _isDragging = false;

    if (_selectedCells.length < 2) {
      _clearSelection();
      return;
    }

    final matchedIndex = GridGenerator.matchPlacement(
      _selectedCells,
      widget.placements,
      widget.foundPlacementIndices,
    );

    if (matchedIndex != null) {
      await widget.onPlacementFound(matchedIndex, _selectedCells);
    }

    _clearSelection();
  }

  List<CellPosition> _getCellsBetween(CellPosition start, CellPosition end) {
    final dr = end.row - start.row;
    final dc = end.col - start.col;

    if (dr == 0 && dc == 0) return [start];

    final steps = [dr.abs(), dc.abs()].reduce((a, b) => a > b ? a : b);
    final stepR = dr == 0 ? 0 : dr ~/ dr.abs();
    final stepC = dc == 0 ? 0 : dc ~/ dc.abs();

    if (dr.abs() != dc.abs() && dr != 0 && dc != 0) return [];

    return List.generate(
      steps + 1,
      (i) => CellPosition(start.row + stepR * i, start.col + stepC * i),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final gridSide = side.clamp(260.0, 400.0);

        return Center(
          child: SelectionContainer.disabled(
            child: Container(
              width: gridSide,
              height: gridSide,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.neonPurple.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [AppColors.neonGlow(AppColors.neonBlue, blur: 18)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Listener(
                  onPointerDown: (e) => _onDragStart(e.position),
                  onPointerMove: (e) {
                    if (_isDragging) _onDragUpdate(e.position);
                  },
                  onPointerUp: (_) => _onDragEnd(),
                  onPointerCancel: (_) => _clearSelection(),
                  child: CustomPaint(
                    key: _gridKey,
                    size: Size.square(gridSide),
                    painter: _WordGridPainter(
                      grid: widget.grid,
                      gridCount: _size,
                      placements: widget.placements,
                      foundPlacementIndices: widget.foundPlacementIndices,
                      selectedCells: _selectedCells,
                      highlightedPlacementIndex:
                          widget.highlightedPlacementIndex,
                      highlightedLetters: widget.highlightedLetters,
                      isArabic: widget.isArabic,
                      fontFamily: widget.fontFamily,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WordGridPainter extends CustomPainter {
  _WordGridPainter({
    required this.grid,
    required this.gridCount,
    required this.placements,
    required this.foundPlacementIndices,
    required this.selectedCells,
    required this.highlightedLetters,
    this.highlightedPlacementIndex,
    this.isArabic = false,
    this.fontFamily,
  });

  final List<List<String>> grid;
  final int gridCount;
  final List<WordPlacement> placements;
  final Set<int> foundPlacementIndices;
  final List<CellPosition> selectedCells;
  final Set<CellPosition> highlightedLetters;
  final int? highlightedPlacementIndex;
  final bool isArabic;
  final String? fontFamily;

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / gridCount;
    final bgPaint = Paint()..color = const Color(0xFF0F1528);
    canvas.drawRect(Offset.zero & size, bgPaint);

    _drawGridLines(canvas, size, cellSize);

    for (var i = 0; i < placements.length; i++) {
      if (!foundPlacementIndices.contains(i)) continue;
      _drawCapsule(
        canvas,
        placements[i].cells,
        cellSize,
        AppColors.highlightColors[placements[i].colorIndex % 10]
            .withValues(alpha: 0.55),
      );
    }

    if (highlightedPlacementIndex != null &&
        highlightedPlacementIndex! < placements.length) {
      _drawCapsule(
        canvas,
        placements[highlightedPlacementIndex!].cells,
        cellSize,
        AppColors.accentGold.withValues(alpha: 0.35),
      );
    }

    if (selectedCells.isNotEmpty) {
      _drawCapsule(
        canvas,
        selectedCells,
        cellSize,
        AppColors.neonPurple.withValues(alpha: 0.55),
      );
    }

    for (final cell in highlightedLetters) {
      _drawHintRing(canvas, cell, cellSize);
    }

    for (var row = 0; row < gridCount; row++) {
      for (var col = 0; col < gridCount; col++) {
        final cell = CellPosition(row, col);
        final isSelected = selectedCells.contains(cell);
        _drawLetter(
          canvas,
          grid[row][col],
          row,
          col,
          cellSize,
          isSelected ? AppColors.neonCyan : AppColors.textPrimary,
        );
      }
    }
  }

  void _drawGridLines(Canvas canvas, Size size, double cellSize) {
    final paint = Paint()
      ..color = AppColors.neonBlue.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    for (var i = 1; i < gridCount; i++) {
      final pos = i * cellSize;
      canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), paint);
      canvas.drawLine(Offset(0, pos), Offset(size.width, pos), paint);
    }
  }

  void _drawHintRing(Canvas canvas, CellPosition cell, double cellSize) {
    final center = _cellCenter(cell, cellSize);
    final paint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, cellSize * 0.36, paint);
  }

  void _drawCapsule(
    Canvas canvas,
    List<CellPosition> cells,
    double cellSize,
    Color color,
  ) {
    if (cells.isEmpty) return;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final radius = cellSize * 0.38;

    for (final cell in cells) {
      canvas.drawCircle(_cellCenter(cell, cellSize), radius, fill);
    }

    if (cells.length >= 2) {
      final line = Paint()
        ..color = color
        ..strokeWidth = radius * 1.8
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        _cellCenter(cells.first, cellSize),
        _cellCenter(cells.last, cellSize),
        line,
      );
    }
  }

  void _drawLetter(
    Canvas canvas,
    String letter,
    int row,
    int col,
    double cellSize,
    Color color,
  ) {
    final painter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: isArabic ? cellSize * 0.46 : cellSize * 0.52,
          fontWeight: FontWeight.w700,
          color: color,
          height: 1,
        ),
      ),
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: cellSize);

    final center = _cellCenter(CellPosition(row, col), cellSize);
    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width / 2,
        center.dy - painter.height / 2,
      ),
    );
  }

  Offset _cellCenter(CellPosition cell, double cellSize) => Offset(
        (cell.col + 0.5) * cellSize,
        (cell.row + 0.5) * cellSize,
      );

  @override
  bool shouldRepaint(covariant _WordGridPainter oldDelegate) => true;
}
