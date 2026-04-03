import 'dart:math' as math;

import 'bubble_entity.dart';
import 'board_cell.dart';

class BoardState {
  const BoardState({
    required this.columns,
    required this.rows,
    required this.lockedBubbles,
  });

  final int columns;
  final int rows;
  final List<BubbleEntity> lockedBubbles;

  factory BoardState.empty({required int columns, required int rows}) {
    return BoardState(columns: columns, rows: rows, lockedBubbles: const []);
  }

  BoardState copyWith({
    int? columns,
    int? rows,
    List<BubbleEntity>? lockedBubbles,
  }) {
    return BoardState(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      lockedBubbles: lockedBubbles ?? this.lockedBubbles,
    );
  }

  bool get isOverflowing => lockedBubbles.any(
    (BubbleEntity bubble) => bubble.yUnits - bubble.radiusUnits < 0,
  );

  BoardCell nearestCellFor(BubbleEntity bubble) {
    final int column =
        bubble.xUnits.floor().clamp(0, math.max(columns - 1, 0)) as int;
    final int row =
        bubble.yUnits.floor().clamp(0, math.max(rows - 1, 0)) as int;
    return BoardCell(column: column, row: row);
  }
}
