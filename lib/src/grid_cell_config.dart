import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Configuration for a grid cell containing position and state information.
class GridCellConfig {
  /// Creates a new grid cell configuration.
  const GridCellConfig({
    required this.gridIndex,
    required this.position,
    required double cellSize,
    required this.globalPosition,
  }) : cellWidth = cellSize,
       cellHeight = cellSize;

  /// Creates a new grid cell configuration with rectangular cells.
  const GridCellConfig.rectangular({
    required this.gridIndex,
    required this.position,
    required this.cellWidth,
    required this.cellHeight,
    required this.globalPosition,
  });

  /// The unique index of this cell in the grid.
  final int gridIndex;

  /// The position of this cell in the grid coordinate system.
  final math.Point<int> position;

  /// The width of this cell in logical pixels.
  final double cellWidth;

  /// The height of this cell in logical pixels.
  final double cellHeight;

  /// The global position of this cell in the widget coordinate system.
  final Offset globalPosition;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GridCellConfig &&
        other.gridIndex == gridIndex &&
        other.position == position &&
        other.cellWidth == cellWidth &&
        other.cellHeight == cellHeight &&
        other.globalPosition == globalPosition;
  }

  @override
  int get hashCode =>
      Object.hash(gridIndex, position, cellWidth, cellHeight, globalPosition);
}
