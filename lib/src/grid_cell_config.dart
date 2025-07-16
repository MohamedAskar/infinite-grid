import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Configuration for a grid cell containing position and state information.
class GridCellConfig {
  /// Creates a new grid cell configuration.
  const GridCellConfig({
    required this.gridIndex,
    required this.position,
    required this.cellSize,
    required this.globalPosition,
  });

  /// The unique index of this cell in the grid.
  final int gridIndex;

  /// The position of this cell in the grid coordinate system.
  final math.Point<int> position;

  /// The size of each cell in logical pixels.
  final double cellSize;

  /// The global position of this cell in the widget coordinate system.
  final Offset globalPosition;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridCellConfig &&
        other.gridIndex == gridIndex &&
        other.position == position &&
        other.cellSize == cellSize &&
        other.globalPosition == globalPosition;
  }

  @override
  int get hashCode =>
      Object.hash(gridIndex, position, cellSize, globalPosition);
}
