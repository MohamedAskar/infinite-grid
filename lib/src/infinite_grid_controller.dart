import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'grid_layout.dart';

/// Controller for programmatic control of the infinite grid.
class InfiniteGridController extends ChangeNotifier {
  /// Creates a new infinite grid controller.
  InfiniteGridController({
    Offset initialPosition = const Offset(0, 0),
    GridLayout? layout,
  }) : _position = initialPosition,
       _layout = layout;

  /// Creates a new infinite grid controller starting at a specific item.
  ///
  /// The initial position is calculated automatically based on the item index
  /// using the provided layout configuration.
  factory InfiniteGridController.fromItem({
    required int initialItem,
    required GridLayout layout,
  }) {
    final worldPosition = layout.calculateItemWorldPosition(initialItem);
    return InfiniteGridController(
      initialPosition: -worldPosition,
      layout: layout,
    );
  }

  Offset _position;
  GridLayout? _layout;

  // Animation requests - the widget handles the actual animation
  AnimationRequest? _pendingAnimation;

  /// The current position of the grid.
  Offset get currentPosition => _position;

  /// The current layout being used for item-aware operations.
  GridLayout? get layout => _layout;

  /// Sets the layout for item-aware operations.
  set layout(GridLayout? layout) {
    if (_layout != layout) {
      _layout = layout;
      notifyListeners();
    }
  }

  /// Gets any pending animation request and clears it.
  AnimationRequest? takePendingAnimation() {
    final request = _pendingAnimation;
    _pendingAnimation = null;
    return request;
  }

  /// Validates that a layout is set for item-aware operations.
  void _ensureLayoutSet() {
    if (_layout == null) {
      throw StateError(
        'GridLayout must be set before using item-aware methods. '
        'Set controller.layout = GridLayout(cellSize: ..., spacing: ...)',
      );
    }
  }

  /// Updates the current position and notifies listeners.
  void updatePosition(Offset newPosition) {
    if (_position != newPosition) {
      _position = newPosition;
      notifyListeners();
    }
  }

  /// Animates the grid to the specified position.
  void animateTo(
    Offset targetPosition, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    _pendingAnimation = AnimationRequest(
      targetPosition: targetPosition,
      duration: duration,
      curve: curve,
    );
    notifyListeners();
  }

  /// Immediately jumps to the specified position without animation.
  void jumpTo(Offset targetPosition) {
    _pendingAnimation = null; // Cancel any pending animation
    updatePosition(targetPosition);
  }

  /// Resets the grid to the origin (0, 0).
  void reset() {
    jumpTo(const Offset(0, 0));
  }

  /// Moves the grid by the specified offset.
  void moveBy(Offset delta) {
    updatePosition(_position + delta);
  }

  /// Animates the grid by the specified offset.
  void animateBy(
    Offset delta, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    animateTo(_position + delta, duration: duration, curve: curve);
  }

  /// Converts a linear item index to grid coordinates (x, y).
  ///
  /// Items are arranged in a spiral pattern starting from the center (0, 0).
  /// Item 0 is at (0, 0), item 1 is at (1, 0), item 2 is at (1, -1), etc.
  ///
  /// The spiral pattern follows: right, down, left, up, expanding outward.
  math.Point<int> itemIndexToGridPosition(int itemIndex) {
    _ensureLayoutSet();
    return _layout!.itemIndexToGridPosition(itemIndex);
  }

  /// Converts grid coordinates (x, y) to a linear item index.
  ///
  /// This matches the _calculateGridIndex method in the grid widget.
  int gridPositionToItemIndex(math.Point<int> gridPosition) {
    _ensureLayoutSet();
    return _layout!.gridPositionToItemIndex(gridPosition);
  }

  /// Calculates the world position for a given item index.
  ///
  /// Uses the controller's stored cell size and spacing values.
  Offset calculateItemWorldPosition(int itemIndex) {
    _ensureLayoutSet();
    return _layout!.calculateItemWorldPosition(itemIndex);
  }

  /// Jumps to a specific item by its index.
  ///
  /// The item will be centered on the screen.
  /// Uses the controller's stored layout.
  void jumpToItem(int itemIndex) {
    final worldPosition = calculateItemWorldPosition(itemIndex);
    jumpTo(-worldPosition);
  }

  /// Animates to a specific item by its index.
  ///
  /// The item will be centered on the screen.
  /// Uses the controller's stored layout.
  void animateToItem(
    int itemIndex, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    final worldPosition = calculateItemWorldPosition(itemIndex);
    animateTo(-worldPosition, duration: duration, curve: curve);
  }

  /// Gets the currently visible item index at the center of the screen.
  ///
  /// Uses the controller's stored layout.
  /// This is useful for knowing which item is currently in focus.
  int getCurrentCenterItemIndex() {
    _ensureLayoutSet();
    return _layout!.gridPositionToItemIndex(
      math.Point<int>(
        (-_position.dx / _layout!.effectiveCellSize).round(),
        (-_position.dy / _layout!.effectiveCellSize).round(),
      ),
    );
  }

  /// Disposes of the controller and cleans up resources.
  @override
  void dispose() {
    super.dispose();
  }
}

/// Represents a pending animation request.
class AnimationRequest {
  const AnimationRequest({
    required this.targetPosition,
    required this.duration,
    required this.curve,
  });

  final Offset targetPosition;
  final Duration duration;
  final Curve curve;
}
