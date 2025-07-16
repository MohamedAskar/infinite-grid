import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Immutable layout calculator for grid item positioning and conversions.
class GridLayout {
  /// Creates a new grid layout with the specified cell size and spacing.
  const GridLayout({required this.cellSize, required this.spacing});

  /// The size of each cell in the grid.
  final double cellSize;

  /// The spacing between cells in the grid.
  final double spacing;

  /// The effective cell size including spacing.
  double get effectiveCellSize => cellSize + spacing;

  /// Converts a linear item index to grid coordinates (x, y).
  ///
  /// Items are arranged in a true spiral pattern starting from the center (0, 0).
  /// Item 0 is at (0, 0), item 1 is at (1, 0), item 2 is at (1, -1), etc.
  /// Each ring continues from where the previous ring ended.
  ///
  /// The spiral pattern follows: right, down, left, up, expanding outward.
  math.Point<int> itemIndexToGridPosition(int itemIndex) {
    if (itemIndex == 0) return const math.Point<int>(0, 0);

    // Find which layer this index belongs to
    int layer = 1;
    int layerStartIndex = 1;

    while (true) {
      final layerSize = 8 * layer;
      if (itemIndex < layerStartIndex + layerSize) break;
      layerStartIndex += layerSize;
      layer++;
    }

    // Position within the current layer
    final posInLayer = itemIndex - layerStartIndex;

    // For a true spiral, determine the starting position of each ring:
    // Ring 1 starts at (1,0) and ends at (1,1)
    // Ring 2 starts at (2,1) and continues the spiral
    // Ring 3 starts at (3,2) and continues the spiral
    final ringStartX = layer;
    final ringStartY = layer == 1 ? 0 : layer - 1;

    // Calculate lengths of each side
    final rightSideLength = ringStartY - (-layer);
    final bottomSideLength = layer - (-layer);
    final leftSideLength = layer - (-layer);
    final topSideLength = layer - (-layer);

    if (posInLayer < rightSideLength) {
      // Right side, moving down from start
      return math.Point<int>(ringStartX, ringStartY - posInLayer);
    } else if (posInLayer < rightSideLength + bottomSideLength) {
      // Bottom side, moving left
      final posInSide = posInLayer - rightSideLength;
      return math.Point<int>(layer - posInSide, -layer);
    } else if (posInLayer <
        rightSideLength + bottomSideLength + leftSideLength) {
      // Left side, moving up
      final posInSide = posInLayer - rightSideLength - bottomSideLength;
      return math.Point<int>(-layer, -layer + posInSide);
    } else if (posInLayer <
        rightSideLength + bottomSideLength + leftSideLength + topSideLength) {
      // Top side, moving right
      final posInSide =
          posInLayer - rightSideLength - bottomSideLength - leftSideLength;
      return math.Point<int>(-layer + posInSide, layer);
    } else {
      // Right side, top half, moving down
      final posInSide =
          posInLayer -
          rightSideLength -
          bottomSideLength -
          leftSideLength -
          topSideLength;
      return math.Point<int>(layer, layer - posInSide);
    }
  }

  /// Converts grid coordinates (x, y) to a linear item index.
  ///
  /// This matches the _calculateGridIndex method in the grid widget with true spiral indexing.
  int gridPositionToItemIndex(math.Point<int> gridPosition) {
    final x = gridPosition.x;
    final y = gridPosition.y;

    // Special case for center
    if (x == 0 && y == 0) return 0;

    // Determine which layer of the spiral we're in
    final layer = [x.abs(), y.abs()].reduce((a, b) => a > b ? a : b);

    // Calculate the size of all inner layers
    final innerLayersSize = ((2 * layer - 1) * (2 * layer - 1)).toInt();

    // For a true spiral, determine the starting position of each ring:
    // Ring 1 starts at (1,0) and ends at (1,1)
    // Ring 2 starts at (2,1) and continues the spiral
    // Ring 3 starts at (3,2) and continues the spiral
    final ringStartX = layer;
    final ringStartY = layer == 1 ? 0 : layer - 1;

    // Calculate position within current layer
    var positionInLayer = 0;

    if (y == ringStartY && x == ringStartX) {
      // Starting position of this ring
      positionInLayer = 0;
    } else if (y < ringStartY && x == layer) {
      // Right side, moving down from start
      positionInLayer = ringStartY - y;
    } else if (y == -layer && x > -layer) {
      // Bottom side, moving left
      final rightSideLength = ringStartY - (-layer);
      positionInLayer = rightSideLength + (layer - x);
    } else if (x == -layer && y < layer) {
      // Left side, moving up
      final rightSideLength = ringStartY - (-layer);
      final bottomSideLength = layer - (-layer);
      positionInLayer = rightSideLength + bottomSideLength + (layer + y);
    } else if (y == layer && x < layer) {
      // Top side, moving right
      final rightSideLength = ringStartY - (-layer);
      final bottomSideLength = layer - (-layer);
      final leftSideLength = layer - (-layer);
      positionInLayer =
          rightSideLength + bottomSideLength + leftSideLength + (layer + x);
    } else {
      // Right side, top half (y > ringStartY && x == layer)
      final rightSideLength = ringStartY - (-layer);
      final bottomSideLength = layer - (-layer);
      final leftSideLength = layer - (-layer);
      final topSideLength = layer - (-layer);
      positionInLayer =
          rightSideLength +
          bottomSideLength +
          leftSideLength +
          topSideLength +
          (layer - y);
    }

    return innerLayersSize + positionInLayer;
  }

  /// Calculates the world position for a given item index.
  Offset calculateItemWorldPosition(int itemIndex) {
    final gridPos = itemIndexToGridPosition(itemIndex);

    return Offset(gridPos.x * effectiveCellSize, gridPos.y * effectiveCellSize);
  }

  /// Gets the item index at the given world position.
  int getItemIndexAtWorldPosition(Offset worldPosition) {
    final gridX = (worldPosition.dx / effectiveCellSize).round();
    final gridY = (worldPosition.dy / effectiveCellSize).round();

    return gridPositionToItemIndex(math.Point<int>(gridX, gridY));
  }

  /// Creates a new layout with different cell size.
  GridLayout withCellSize(double cellSize) {
    return GridLayout(cellSize: cellSize, spacing: spacing);
  }

  /// Creates a new layout with different spacing.
  GridLayout withSpacing(double spacing) {
    return GridLayout(cellSize: cellSize, spacing: spacing);
  }

  /// Creates a new layout with different cell size and spacing.
  GridLayout withConfiguration(double cellSize, double spacing) {
    return GridLayout(cellSize: cellSize, spacing: spacing);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridLayout &&
          runtimeType == other.runtimeType &&
          cellSize == other.cellSize &&
          spacing == other.spacing;

  @override
  int get hashCode => cellSize.hashCode ^ spacing.hashCode;

  @override
  String toString() => 'GridLayout(cellSize: $cellSize, spacing: $spacing)';
}
