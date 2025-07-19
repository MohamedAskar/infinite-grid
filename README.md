# Infinite Grid

[![pub package](https://img.shields.io/pub/v/infinite_grid.svg)](https://pub.dev/packages/infinite_grid)

A high-performance Flutter package that implements an infinite scrolling grid UI with direct drag control, optional momentum scrolling, and automatic viewport optimization.

## Demo

### Layout Comparison
|                                                 Default Layout                                                    |                                                  Grid Offset Layout                                                   |
| :---------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------: |
| ![Default Layout](assets/default.png) | ![Grid Offset Layout](assets/offset.png) |




### Scrolling Comparison
|                                             Normal Scrolling                                                        |                                                 Momentum Scrolling                                                    |
| :-----------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------: |
| ![Normal Scrolling](assets/normal-scrolling.gif) | ![Momentum Scrolling](assets/momentum-scrolling.gif) |



### Live Demo
You can try the [live web demo](https://mohamedaskar.github.io/infinite-grid/).

## Features

- **High Performance**: Optimized rendering with cell preloading and efficient viewport culling
- **Momentum Scrolling**: Smooth inertial scrolling with customizable physics
- **Spiral Indexing**: True spiral pattern starting from center (0,0)
- **Programmatic Control**: Navigate to specific positions or items
- **Type-Safe Items**: Strongly typed item support with automatic cycling
- **Flexible Layout**: Configurable cell size and spacing
- **Grid Offset**: Staggered column effect with configurable offset
- **Rectangular Cells**: Support for both square and rectangular cell dimensions
- **Cross-Platform**: Works on iOS, Android, Web, and Desktop

## Quick Start

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  infinite_grid: ^1.1.0
```

Basic usage:

```dart
import 'package:infinite_grid/infinite_grid.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Create controller
    final controller = InfiniteGridController();
    
    // Create layouts
    final squareLayout = const GridLayout(cellSize: 100, spacing: 4);
    final rectangularLayout = const GridLayout.rectangular(
      cellWidth: 120,
      cellHeight: 80,
      spacing: 4,
    );
    final offsetLayout = const GridLayout(
      cellSize: 100,
      spacing: 4,
      gridOffset: 0.5, // 50% offset
    );
    
    final items = List.generate(50, (index) => 'Item $index');

    return InfiniteGrid<String>(
      controller: controller,
      layout: squareLayout,
      items: items,
      cellBuilder: (context, config, item) => Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(child: Text(item)),
      ),
    );
  }
}
```

## Usage Examples

```dart
// Create controller and layout
final controller = InfiniteGridController();
final layout = GridLayout(cellSize: 100, spacing: 4);

// Set layout on controller
controller.updateLayout(layout);

// Use item-based methods
controller.jumpToItem(100);
controller.animateToItem(200);
final currentItem = controller.getCurrentCenterItemIndex();
```

## API Reference

### Spiral Indexing

The grid uses a true spiral indexing pattern starting from center:

```
Layer 1 (around center):
   4  3  2
   5  0  1
   6  7  8
```

### InfiniteGrid

Creates a grid that cycles through the provided items infinitely.

```dart
InfiniteGrid<T>({
  required InfiniteGridController controller,
  required GridLayout layout,
  required List<T> items,
  required Widget Function(BuildContext, GridCellConfig, T) cellBuilder,
  GridPhysics? gridPhysics,
  void Function(Offset)? onPositionChanged,
  bool enableMomentumScrolling = false,
  int preloadCells = 2,
})
```

### InfiniteGrid.builder

Creates a grid using a builder pattern, similar to ListView.builder.

```dart
InfiniteGrid.builder({
  required InfiniteGridController controller,
  required GridLayout layout,
  required int itemCount,
  required Widget Function(BuildContext, GridCellConfig, int) cellBuilder,
  GridPhysics? gridPhysics,
  void Function(Offset)? onPositionChanged,
  bool enableMomentumScrolling = false,
  int preloadCells = 2,
})
```

**Example:**
```dart
InfiniteGrid.builder(
  controller: controller,
  layout: layout,
  itemCount: 100,
  cellBuilder: (context, config, index) => Container(
    decoration: BoxDecoration(
      color: Colors.blue.shade100,
      border: Border.all(color: Colors.blue),
    ),
    child: Center(child: Text('Item $index')),
  ),
)
```

#### Properties

- **`controller`**: Controller for programmatic control
- **`layout`**: Grid layout configuration (required)
- **`items`**: List of items to display in the grid (required)
- **`cellBuilder`**: Builder function for creating cell widgets (receives context, config, and item)
- **`gridPhysics`**: Custom physics for scrolling behavior
- **`onPositionChanged`**: Callback when grid position changes
- **`enableMomentumScrolling`**: Enable/disable momentum scrolling (disabled by default)
- **`preloadCells`**: Number of extra cells to preload around the visible area for smooth scrolling (default: 2)

### GridCellConfig

Configuration object passed to the cell builder.

```dart
class GridCellConfig {
  final int gridIndex;        // Unique cell index
  final Point<int> position;  // Grid coordinates
  final double cellWidth;     // Width of the cell
  final double cellHeight;    // Height of the cell
  final Offset globalPosition; // Global position in widget
}
```

### InfiniteGridController

The controller provides methods for programmatic control of the grid. It supports a hybrid approach for layout management:

#### Layout Management

The controller uses a stored layout approach for item-based operations:

```dart
final controller = InfiniteGridController();
controller.updateLayout(GridLayout(cellSize: 100, spacing: 4));

// Now you can use item methods without passing layout
controller.jumpToItem(100);
controller.animateToItem(200);
final currentItem = controller.getCurrentCenterItemIndex();
```

The widget automatically sets the layout on the controller for convenience.

```dart
InfiniteGridController({
  Offset initialPosition = const Offset(0, 0),
  GridLayout? layout,
})
```

- **`initialPosition`**: Starting position of the grid (default: origin at viewport center)
- **`layout`**: Optional grid layout configuration. If provided, it will be stored and used for item-based operations

#### Factory Constructor

```dart
InfiniteGridController.fromItem({
  required int initialItem,
  required GridLayout layout,
})
```

Creates a controller starting at a specific item index. The initial position is calculated automatically based on the item index using the provided layout configuration.

- **`initialItem`**: The item index to start at (uses spiral indexing)
- **`layout`**: Required grid layout configuration for position calculation

#### Position-Based Methods
- `jumpTo(Offset position)` - Instantly move to a specific position
- `animateTo(Offset position, ...)` - Animate to a specific position
- `moveBy(Offset delta)` - Move by a relative offset
- `animateBy(Offset delta, ...)` - Animate by a relative offset
- `reset()` - Return to the origin (0, 0)

#### Layout Management
- `updateLayout(GridLayout? layout)` - Update the stored layout configuration

#### Item-Based Methods
- `jumpToItem(int itemIndex)` - Instantly move to a specific item
- `animateToItem(int itemIndex, {...})` - Animate to a specific item
- `getCurrentCenterItemIndex()` - Get the current center item index

#### Properties
- `currentPosition` - Current position as Offset
- `layout` - Current grid layout configuration (can be set)
- `hasClients` - Whether the controller is attached to a widget

### GridLayout

Layout configuration for the grid:

```dart
// Square cells
const GridLayout({
  required double cellSize,
  double spacing = 0.0,
  double gridOffset = 0.0,
})

// Rectangular cells
const GridLayout.rectangular({
  required double cellWidth,
  required double cellHeight,
  double spacing = 0.0,
  double gridOffset = 0.0,
})
```

- **`cellSize`**: Size of each cell in logical pixels (for square cells)
- **`cellWidth`**: Width of each cell in logical pixels (for rectangular cells)
- **`cellHeight`**: Height of each cell in logical pixels (for rectangular cells)
- **`spacing`**: Space between cells in logical pixels
- **`gridOffset`**: Grid offset for staggered column effect (0.0 to 1.0, default: 0.0)
  - 0.0: No offset (normal grid)
  - 1.0: Quarter cell height offset per direction (total max: half cell height)
  - Odd columns move up, even columns (including 0) move down by `gridOffset * (cellHeight / 4)`

### Grid Offset

The grid offset feature creates a staggered column effect where columns move in opposite directions. This creates a visually interesting layout similar to masonry grids.

```dart
// No offset (normal grid)
const GridLayout(cellSize: 100, spacing: 4, gridOffset: 0.0)

// 25% offset
const GridLayout(cellSize: 100, spacing: 4, gridOffset: 0.25)

// 50% offset (quarter cell height per direction)
const GridLayout(cellSize: 100, spacing: 4, gridOffset: 0.5)

// Full offset (quarter cell height per direction)
const GridLayout(cellSize: 100, spacing: 4, gridOffset: 1.0)
```

The offset creates a balanced staggered effect:
- Column 0: Moves down by `gridOffset * (cellHeight / 4)`
- Column 1: Moves up by `gridOffset * (cellHeight / 4)`
- Column -1: Moves up by `gridOffset * (cellHeight / 4)`
- Column 2: Moves down by `gridOffset * (cellHeight / 4)`
- Column -2: Moves down by `gridOffset * (cellHeight / 4)`
- Column 3: Moves up by `gridOffset * (cellHeight / 4)`
- Column -3: Moves up by `gridOffset * (cellHeight / 4)`
- And so on...

### GridPhysics

Custom physics for momentum scrolling:

```dart
const GridPhysics({
  double friction = 0.015,
  double minVelocity = 50.0,
  double maxVelocity = 3000.0,
  double decelerationRate = 0.85,
})
```
## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:infinite_grid/infinite_grid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Grid Demo',
      home: InfiniteGridDemo(),
    );
  }
}

class InfiniteGridDemo extends StatefulWidget {
  @override
  _InfiniteGridDemoState createState() => _InfiniteGridDemoState();
}

class _InfiniteGridDemoState extends State<InfiniteGridDemo> {
  late final InfiniteGridController _controller;
  late final GridLayout _layout;
  
  @override
  void initState() {
    super.initState();
    _controller = InfiniteGridController();
    _layout = const GridLayout(cellSize: 100, spacing: 4);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final items = List.generate(1000, (index) => 'Item $index');
    
    return Scaffold(
      appBar: AppBar(title: Text('Infinite Grid Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.jumpTo(Offset.zero),
                  child: Text('Go to Origin'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.animateToItem(100),
                  child: Text('Go to Item 100'),
                ),
              ],
            ),
          ),
          Expanded(
            child: InfiniteGrid<String>(
              controller: _controller,
              layout: _layout,
              items: items,
              cellBuilder: (context, config, item) => Container(
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(item),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Performance Tips

1. **Use `const` constructors** wherever possible for better performance
2. **Optimize cell builders** - avoid heavy computations in the builder
3. **Adjust preload cells** based on your needs (more = smoother, less = memory efficient)
4. **Use appropriate cell sizes** for your content to minimize overdraw


## License

MIT License. See LICENSE file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for details about changes in each version.

## Support

- 📖 [Documentation](https://pub.dev/documentation/infinite_grid/latest/)
- 🐛 [Issue Tracker](https://github.com/MohamedAskar/infinite-grid/issues)

## Inspiration

This package was inspired by the [ThiingsGrid](https://github.com/charlieclark/thiings-grid) React component, adapted for Flutter's widget system and performance characteristics.
