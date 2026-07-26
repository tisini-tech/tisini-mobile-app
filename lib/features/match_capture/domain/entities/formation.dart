/// Defines a formation by name and number of players per row (GK row first).
/// E.g. 1-4-3-3 → one GK, then 4, 3, 3 outfield.
class Formation {
  final String name;
  final List<int> columnsPerRow;
  final List<int>? lineupOrder;

  const Formation({
    required this.name,
    required this.columnsPerRow,
    this.lineupOrder,
  });

  int get rows => columnsPerRow.length;

  int get totalCells =>
      columnsPerRow.fold<int>(0, (sum, cols) => sum + cols);

  int displayPositionAt(int linearIndex) {
    final order = lineupOrder;
    if (order != null && linearIndex >= 0 && linearIndex < order.length) {
      return order[linearIndex];
    }
    return linearIndex + 1;
  }
}
