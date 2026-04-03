class BoardCell {
  const BoardCell({required this.column, required this.row});

  final int column;
  final int row;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is BoardCell && other.column == column && other.row == row;
  }

  @override
  int get hashCode => Object.hash(column, row);

  @override
  String toString() => 'BoardCell(column: $column, row: $row)';
}
