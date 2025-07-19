import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'grid_layout.dart';

/// Animation request for smooth transitions.
class AnimationRequest {
  /// Creates a new animation request.
  const AnimationRequest({
    required this.targetPosition,
    required this.duration,
    required this.curve,
  });

  /// The target position to animate to.
  final Offset targetPosition;

  /// The duration of the animation.
  final Duration duration;

  /// The curve to use for the animation.
  final Curve curve;
}

/// Controller for programmatic control of the infinite grid.
///
/// Provides methods for jumping to specific positions, animating to items,
/// and managing the grid's current state.
class InfiniteGridController extends ChangeNotifier {
  /// Creates a new infinite grid controller.
  ///
  /// The [initialPosition] determines where the grid starts. By default,
  /// the grid starts at the origin (0, 0) which is positioned at the center
  /// of the viewport.
  ///
  /// The [layout] parameter is optional. If provided, it will be stored
  /// and used for item-based operations. If not provided, you must pass
  /// the layout explicitly to item-based methods.
  InfiniteGridController({
    Offset initialPosition = const Offset(0, 0),
    GridLayout? layout,
  }) : _currentPosition = initialPosition,
       _layout = layout;

  /// Creates a controller starting at a specific item index.
  ///
  /// The initial position is calculated automatically based on the item index
  /// using the provided layout configuration.
  factory InfiniteGridController.fromItem({
    required int initialItem,
    required GridLayout layout,
  }) {
    final initialPosition = layout.calculateItemWorldPosition(initialItem);
    return InfiniteGridController(
      initialPosition: initialPosition,
      layout: layout,
    );
  }

  /// The current position of the grid.
  Offset _currentPosition;

  /// The current position of the grid.
  Offset get currentPosition => _currentPosition;

  /// The stored layout configuration for item-based operations.
  GridLayout? _layout;

  /// The current layout configuration, if set.
  GridLayout? get layout => _layout;

  /// Sets the layout configuration for item-based operations.
  set layout(GridLayout? layout) {
    if (_layout != layout) {
      _layout = layout;
      notifyListeners();
    }
  }

  /// Updates the layout configuration for item-based operations.
  ///
  /// This method is a convenient way to update the layout and notify listeners.
  void updateLayout(GridLayout? layout) {
    this.layout = layout;
  }

  /// Whether the controller is attached to a widget.
  bool get hasClients => hasListeners;

  /// Pending animation request, if any.
  AnimationRequest? _pendingAnimation;

  /// Takes and clears any pending animation request.
  AnimationRequest? takePendingAnimation() {
    final request = _pendingAnimation;
    _pendingAnimation = null;
    return request;
  }

  /// Updates the current position and notifies listeners.
  void updatePosition(Offset position) {
    if (_currentPosition != position) {
      _currentPosition = position;
      notifyListeners();
    }
  }

  /// Instantly moves to the specified position.
  void jumpTo(Offset position) {
    updatePosition(position);
  }

  /// Animates to the specified position.
  void animateTo(
    Offset position, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    _pendingAnimation = AnimationRequest(
      targetPosition: position,
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// Moves by the specified delta.
  void moveBy(Offset delta) {
    updatePosition(_currentPosition + delta);
  }

  /// Animates by the specified delta.
  void animateBy(
    Offset delta, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    animateTo(_currentPosition + delta, duration: duration, curve: curve);
  }

  /// Resets the grid to the origin (0, 0).
  void reset() {
    jumpTo(const Offset(0, 0));
  }

  /// Instantly moves to the specified item index.
  ///
  /// Requires a layout to be set on the controller using [updateLayout].
  void jumpToItem(int itemIndex) {
    if (_layout == null) {
      throw StateError(
        'GridLayout must be set on the controller before using item-aware methods. '
        'Call controller.updateLayout(GridLayout(cellSize: ..., spacing: ...)) first.',
      );
    }

    final gridPos = _layout!.itemIndexToGridPosition(itemIndex);
    final columnOffset = calculateColumnOffset(gridPos.x);
    final basePosition = calculateBaseGridPosition(gridPos.x, gridPos.y);
    final compensatedPosition = compensateForVisualCenter(
      basePosition,
      columnOffset,
    );

    jumpTo(compensatedPosition);
  }

  /// Animates to the specified item index.
  ///
  /// Requires a layout to be set on the controller using [updateLayout].
  void animateToItem(
    int itemIndex, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    if (_layout == null) {
      throw StateError(
        'GridLayout must be set on the controller before using item-aware methods. '
        'Call controller.updateLayout(GridLayout(cellSize: ..., spacing: ...)) first.',
      );
    }

    final gridPos = _layout!.itemIndexToGridPosition(itemIndex);
    final columnOffset = calculateColumnOffset(gridPos.x);
    final basePosition = calculateBaseGridPosition(gridPos.x, gridPos.y);
    final compensatedPosition = compensateForVisualCenter(
      basePosition,
      columnOffset,
    );

    animateTo(compensatedPosition, duration: duration, curve: curve);
  }

  /// Gets the current center item index.
  ///
  /// Requires a layout to be set on the controller using [updateLayout].
  int getCurrentCenterItemIndex() {
    if (_layout == null) {
      throw StateError(
        'GridLayout must be set on the controller before using item-aware methods. '
        'Call controller.updateLayout(GridLayout(cellSize: ..., spacing: ...)) first.',
      );
    }

    final gridX = (_currentPosition.dx / _layout!.effectiveCellWidth).round();
    final columnOffset = calculateColumnOffset(gridX);
    final adjustedY = _currentPosition.dy + columnOffset;
    final gridY = (adjustedY / _layout!.effectiveCellHeight).round();

    return _layout!.gridPositionToItemIndex(math.Point<int>(gridX, gridY));
  }

  @override
  void dispose() {
    _pendingAnimation = null;
    super.dispose();
  }

  /// Calculates the column offset for the given grid X coordinate.
  ///
  /// Odd columns move up, even columns move down.
  /// This creates a staggered effect where adjacent columns are offset
  /// in opposite directions.
  ///
  /// [gridX] - The grid X coordinate (column number)
  ///
  /// Returns the Y offset for the column (positive for even columns, negative for odd columns)
  double calculateColumnOffset(int gridX) {
    final isOddColumn = gridX.abs() % 2 == 1;
    final offset = _layout!.gridOffset * _layout!.cellHeight / 4;

    return isOddColumn
        ? -offset // Odd columns move up
        : offset; // Even columns move down
  }

  /// Calculates the base grid position without any offset compensation.
  ///
  /// Converts grid coordinates to world coordinates without applying
  /// any column offset adjustments.
  ///
  /// [gridX] - The grid X coordinate
  /// [gridY] - The grid Y coordinate
  ///
  /// Returns the base world position for the grid coordinates
  Offset calculateBaseGridPosition(int gridX, int gridY) {
    return Offset(
      gridX * _layout!.effectiveCellWidth,
      gridY * _layout!.effectiveCellHeight,
    );
  }

  /// Compensates the base position for visual center offset.
  ///
  /// This ensures items appear centered in the viewport by accounting
  /// for the staggered column effect. The compensation is the inverse
  /// of the column offset.
  ///
  /// [basePosition] - The base grid position
  /// [columnOffset] - The column offset to compensate for
  ///
  /// Returns the compensated position that centers the item in the viewport
  Offset compensateForVisualCenter(Offset basePosition, double columnOffset) {
    return Offset(basePosition.dx, basePosition.dy - columnOffset);
  }
}
