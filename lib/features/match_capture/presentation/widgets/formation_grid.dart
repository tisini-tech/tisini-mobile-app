import 'package:flutter/material.dart';

/// A reusable grid that displays a formation shape: each row has a given number of columns.
/// E.g. 1-4-3-3 → [1, 4, 3, 3], 1-4-2-3-1 → [1, 4, 2, 3, 1].
class FormationGrid extends StatelessWidget {
  /// Number of columns per row (length = number of rows).
  /// E.g. [1, 4, 3, 3] for 4 rows with 1, 4, 3, 3 cells.
  final List<int> columnsPerRow;

  /// Builds the widget for cell at (row, col). Linear index = sum(columnsPerRow[0..row-1]) + col.
  final Widget? Function(BuildContext context, int row, int col)? cellBuilder;

  final double rowSpacing;
  final double colSpacing;

  const FormationGrid({
    super.key,
    required this.columnsPerRow,
    this.cellBuilder,
    this.rowSpacing = 8,
    this.colSpacing = 8,
  });

  /// Total number of cells in the formation.
  int get totalCells =>
      columnsPerRow.fold<int>(0, (sum, cols) => sum + cols);

  @override
  Widget build(BuildContext context) {
    if (columnsPerRow.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(columnsPerRow.length, (row) {
        final cols = columnsPerRow[row];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: row < columnsPerRow.length - 1 ? rowSpacing : 0,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var col = 0; col < cols; col++) ...[
                  if (col > 0) SizedBox(width: colSpacing),
                  Expanded(
                    child: cellBuilder != null
                        ? (cellBuilder!(context, row, col) ??
                              const SizedBox.shrink())
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
}
