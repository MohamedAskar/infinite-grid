import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'grid_cell_config.dart';
import 'grid_physics.dart';
import 'infinite_grid_controller.dart';

typedef InfiniteGridItemBuilder<T> =
    Widget Function(BuildContext context, GridCellConfig config, T item);

/// A high-performance infinite scrolling grid widget with momentum-based scrolling.
///
/// The grid cycles through the provided items infinitely, repeating them when
/// reaching the end of the list.
class InfiniteGrid<T> extends StatefulWidget {
  /// Creates a new infinite grid with the specified items.
  ///
  /// The [items] list will be cycled through infinitely as the user scrolls.
  /// The [cellBuilder] function receives the grid configuration and the actual
  /// item for each cell.
  const InfiniteGrid({
    super.key,
    required this.controller,
    this.items = const [],
    required this.cellBuilder,
    this.gridPhysics,
    this.onPositionChanged,
    this.enableMomentumScrolling = false,
    this.preloadCells = 2,
  });

  /// Creates a new infinite grid using a builder pattern.
  ///
  /// Similar to [ListView.builder], this constructor takes an [itemCount] and
  /// a [cellBuilder] function that creates widgets for each index.
  /// The grid will cycle through indices 0 to [itemCount-1] infinitely.
  static InfiniteGrid builder({
    Key? key,
    required InfiniteGridController controller,
    required int itemCount,
    required InfiniteGridItemBuilder<int> cellBuilder,
    GridPhysics? gridPhysics,
    void Function(Offset position)? onPositionChanged,
    bool enableMomentumScrolling = false,
    int preloadCells = 2,
  }) {
    return InfiniteGrid<int>(
      key: key,
      controller: controller,
      items: List.generate(itemCount, (index) => index),
      cellBuilder: cellBuilder,
      gridPhysics: gridPhysics,
      onPositionChanged: onPositionChanged,
      enableMomentumScrolling: enableMomentumScrolling,
      preloadCells: preloadCells,
    );
  }

  /// List of items to display in the grid.
  /// Items will repeat infinitely as the user scrolls.
  final List<T> items;

  /// Builder function for creating cell widgets.
  ///
  /// Receives the grid cell configuration and the actual item for this cell.
  final InfiniteGridItemBuilder<T> cellBuilder;

  /// Controller for programmatic control and layout configuration.
  final InfiniteGridController controller;

  /// Custom physics for scrolling behavior.
  final GridPhysics? gridPhysics;

  /// Callback called when the grid position changes.
  final void Function(Offset position)? onPositionChanged;

  /// Whether to enable momentum scrolling.
  final bool enableMomentumScrolling;

  /// The number of extra cells to preload around the visible area for smooth scrolling.
  final int preloadCells;

  @override
  State<InfiniteGrid<T>> createState() => _InfiniteGridState<T>();
}

class _InfiniteGridState<T> extends State<InfiniteGrid<T>>
    with TickerProviderStateMixin {
  late final InfiniteGridController _controller;
  late final GridPhysics _physics;
  late final VelocityTracker _velocityTracker;

  Offset _currentPosition = Offset.zero;
  bool _isScrolling = false;
  Timer? _scrollingTimer;
  AnimationController? _momentumController;
  MomentumScrollSimulation? _momentumSimulation;

  @override
  void initState() {
    super.initState();

    // Initialize controller and physics
    _controller = widget.controller;
    _physics = widget.gridPhysics ?? const GridPhysics();
    _velocityTracker = VelocityTracker();
    _currentPosition = _controller.currentPosition;

    // Subscribe to controller changes
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(InfiniteGrid<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _scrollingTimer?.cancel();
    _momentumController?.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    // Check for pending animation requests
    final animationRequest = _controller.takePendingAnimation();
    if (animationRequest != null) {
      _handleAnimationRequest(animationRequest);
    }

    // Handle position changes
    if (_controller.currentPosition != _currentPosition) {
      setState(() {
        _currentPosition = _controller.currentPosition;
      });
      widget.onPositionChanged?.call(_currentPosition);
    }
  }

  void _handleAnimationRequest(AnimationRequest request) {
    // Stop any existing animation
    _momentumController?.stop();
    _momentumController?.dispose();

    // Create new animation controller
    _momentumController = AnimationController(
      duration: request.duration,
      vsync: this,
    );

    // Create animation
    final animation =
        Tween<Offset>(
          begin: _currentPosition,
          end: request.targetPosition,
        ).animate(
          CurvedAnimation(parent: _momentumController!, curve: request.curve),
        );

    // Listen for animation updates
    animation.addListener(() {
      _controller.updatePosition(animation.value);
    });

    // Start the animation
    _momentumController!.forward();
  }

  void _handlePanStart(DragStartDetails details) {
    // Stop any ongoing momentum scrolling
    _momentumController?.stop();
    _momentumController?.dispose();
    _momentumController = null;

    _velocityTracker.clear();
    _velocityTracker.addSample(
      details.globalPosition,
      DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(0)),
    );

    _setScrolling(true);
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final newPosition = _currentPosition + details.delta;
    _controller.updatePosition(newPosition);

    _velocityTracker.addSample(
      details.globalPosition,
      DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(0)),
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    _setScrolling(false);

    if (!widget.enableMomentumScrolling) return;

    final velocity = _velocityTracker.getVelocity();
    final clampedVelocity = _physics.clampVelocity(velocity);

    if (_physics.isVelocitySignificant(clampedVelocity)) {
      _startMomentumScrolling(clampedVelocity);
    }
  }

  void _startMomentumScrolling(Offset velocity) {
    _momentumSimulation = _physics.createMomentumScrollSimulation(
      initialVelocity: velocity,
      initialPosition: _currentPosition,
    );

    _momentumController = AnimationController.unbounded(vsync: this);

    _momentumController!.addListener(() {
      if (_momentumSimulation != null) {
        final time = _momentumController!.value;
        if (_momentumSimulation!.shouldStopImmediately(time)) {
          // Stop immediately if velocity is too low
          _momentumController!.stop();
        } else if (!_momentumSimulation!.isDone(time)) {
          final position = _momentumSimulation!.positionAt(time);
          _controller.updatePosition(position);
        } else {
          _momentumController!.stop();
        }
      }
    });

    final duration = _momentumSimulation!.getEstimatedDuration();
    _momentumController!.animateTo(
      duration,
      duration: Duration(milliseconds: (duration * 1000).round()),
      curve: Curves.linear,
    );
  }

  void _setScrolling(bool isScrolling) {
    if (_isScrolling != isScrolling) {
      setState(() {
        _isScrolling = isScrolling;
      });

      _scrollingTimer?.cancel();
      if (isScrolling) {
        _scrollingTimer = Timer(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {
              _isScrolling = false;
            });
          }
        });
      }
    }
  }

  /// Calculates which cells should be visible in the current viewport.
  List<GridCellConfig> _calculateVisibleCells(Size viewportSize) {
    final visibleCells = <GridCellConfig>[];
    final layout = widget.controller.layout;

    if (layout == null) {
      throw StateError(
        'GridLayout must be set on the controller before using the grid. '
        'Set controller.layout = GridLayout(cellSize: ..., spacing: ...) or GridLayout.rectangular(cellWidth: ..., cellHeight: ..., spacing: ...)',
      );
    }

    final effectiveCellWidth = layout.effectiveCellWidth;
    final effectiveCellHeight = layout.effectiveCellHeight;

    // Calculate how many cells fit in the viewport (with buffer for smooth scrolling)
    final cellsX =
        (viewportSize.width / effectiveCellWidth).ceil() +
        (widget.preloadCells * 2);
    final cellsY =
        (viewportSize.height / effectiveCellHeight).ceil() +
        (widget.preloadCells * 2);

    // Calculate the starting cell position based on current grid position
    // Account for cell size by considering that cells occupy space from their position
    // to position + cellSize, so we need to offset by half the cell size
    final startX =
        ((-_currentPosition.dx - (viewportSize.width / 2)) / effectiveCellWidth)
            .floor() -
        widget.preloadCells;
    final startY =
        ((-_currentPosition.dy - (viewportSize.height / 2)) /
                effectiveCellHeight)
            .floor() -
        widget.preloadCells;

    // Generate cells in a grid pattern around the viewport
    for (int x = startX; x < startX + cellsX; x++) {
      for (int y = startY; y < startY + cellsY; y++) {
        final gridIndex = _calculateGridIndex(x, y);
        final position = math.Point<int>(x, y);
        final globalPosition = Offset(
          x * effectiveCellWidth +
              _currentPosition.dx +
              (viewportSize.width / 2) -
              (layout.cellWidth / 2),
          y * effectiveCellHeight +
              _currentPosition.dy +
              (viewportSize.height / 2) -
              (layout.cellHeight / 2),
        );

        // Only add cells that are actually visible (with some buffer)
        if (_isCellVisible(globalPosition, viewportSize)) {
          visibleCells.add(
            GridCellConfig.rectangular(
              gridIndex: gridIndex,
              position: position,
              cellWidth: layout.cellWidth,
              cellHeight: layout.cellHeight,
              globalPosition: globalPosition,
            ),
          );
        }
      }
    }

    return visibleCells;
  }

  /// Calculates a unique grid index for the given grid coordinates using a true spiral pattern.
  ///
  /// The spiral starts at the center (0,0) with index 0, then moves outward in a continuous
  /// clockwise spiral pattern. Each ring continues from where the previous ring ended.
  ///
  /// The algorithm ensures unique indices for all coordinates in the infinite grid.
  int _calculateGridIndex(int x, int y) {
    // Special case for center
    if (x == 0 && y == 0) return 0;

    // Determine which layer of the spiral we're in
    final layer = math.max(x.abs(), y.abs());

    // Calculate the size of all inner layers
    final innerLayersSize = math.pow(2 * layer - 1, 2);

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

    return (innerLayersSize + positionInLayer).toInt();
  }

  /// Checks if a cell at the given position is visible in the viewport.
  bool _isCellVisible(Offset cellPosition, Size viewportSize) {
    final layout = widget.controller.layout;
    if (layout == null) return false;

    final marginX = widget.preloadCells * layout.effectiveCellWidth;
    final marginY = widget.preloadCells * layout.effectiveCellHeight;
    return cellPosition.dx + layout.cellWidth >= -marginX &&
        cellPosition.dx <= viewportSize.width + marginX &&
        cellPosition.dy + layout.cellHeight >= -marginY &&
        cellPosition.dy <= viewportSize.height + marginY;
  }

  /// Creates a cell builder function that cycles through the provided items.
  Widget Function(GridCellConfig) _createCellBuilder(GridCellConfig config) {
    return (GridCellConfig config) {
      final items = widget.items;
      final itemCount = items.length;

      if (itemCount == 0) return const SizedBox.shrink();

      // Calculate the actual item index
      final gridIndex = config.gridIndex;

      // Handle negative indices (can happen in spiral pattern)
      int actualIndex;
      if (gridIndex < 0) {
        // For negative indices, we need to map them to positive range
        actualIndex =
            (itemCount - ((-gridIndex - 1) % itemCount + 1)) % itemCount;
      } else {
        actualIndex = gridIndex % itemCount;
      }

      return widget.cellBuilder(context, config, items[actualIndex]);
    };
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
        final visibleCells = _calculateVisibleCells(viewportSize);

        return GestureDetector(
          onPanStart: _handlePanStart,
          onPanUpdate: _handlePanUpdate,
          onPanEnd: _handlePanEnd,
          child: ClipRect(
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: Stack(
                children: visibleCells.map((config) {
                  return _GridCellWidget(
                    key: ValueKey(config.gridIndex),
                    config: config,
                    builder: _createCellBuilder(config),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Widget that renders individual grid cells.
class _GridCellWidget extends StatelessWidget {
  /// Creates a new grid cell widget.
  const _GridCellWidget({
    super.key,
    required this.config,
    required this.builder,
  });

  /// The configuration for this cell.
  final GridCellConfig config;

  /// The builder function for creating the cell content.
  final Widget Function(GridCellConfig config) builder;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: config.globalPosition.dx,
      top: config.globalPosition.dy,
      width: config.cellWidth,
      height: config.cellHeight,
      child: RepaintBoundary(child: builder(config)),
    );
  }
}
