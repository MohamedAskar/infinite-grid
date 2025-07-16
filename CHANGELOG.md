# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

**First public release on pub.dev.**

> _Note: Earlier versions were not published to pub.dev. This release includes all features and improvements listed below._

## [1.1.0] - 2025-07-17

### Added
- **NEW**: Support for rectangular cells with `GridLayout.rectangular()` constructor
- **NEW**: `cellWidth` and `cellHeight` properties in `GridCellConfig` for rectangular cells
- **NEW**: `effectiveCellWidth` and `effectiveCellHeight` properties in `GridLayout`
- **NEW**: Helper methods for rectangular cells: `withCellDimensions()` and `withRectangularConfiguration()`
- **NEW**: `GridCellConfig.rectangular()` constructor for rectangular cell configurations

### Changed
- **BREAKING**: `InfiniteGrid` now requires a `List<T> items` parameter - no more optional items
- **BREAKING**: `cellBuilder` function signature changed to `(GridCellConfig config, T item)` - item is now required and non-nullable  
- **BREAKING**: Removed `InfiniteGrid.builder()` constructor - use the main constructor instead
- **BREAKING**: Made `InfiniteGrid` class generic (`InfiniteGrid<T>`) to provide type safety for items
- **BREAKING**: All grids now cycle through items infinitely - no more dual-mode behavior
- Improved API consistency by having a single constructor that always works with items
- Enhanced type safety by requiring items and providing strongly-typed access in cellBuilder
- **BREAKING**: Removed deprecated `cellSize` and `effectiveCellSize` properties from `GridLayout`
- **BREAKING**: Removed deprecated `cellSize` property from `GridCellConfig`

> _Note: Earlier versions were not published to pub.dev. This release includes all features and improvements listed below._

### Added
- Support for rectangular cells with `GridLayout.rectangular()` constructor
- `cellWidth` and `cellHeight` properties in `GridCellConfig` for rectangular cells
- `effectiveCellWidth` and `effectiveCellHeight` properties in `GridLayout`
- Helper methods for rectangular cells: `withCellDimensions()` and `withRectangularConfiguration()`
- `GridCellConfig.rectangular()` constructor for rectangular cell configurations
- Core `InfiniteGrid` widget with high-performance rendering
- `InfiniteGridController` for programmatic control
- `InfiniteGridController.fromItem()` factory constructor for starting at specific items
- Custom momentum scrolling with `GridPhysics`
- Configurable cell spacing with `spacing` parameter
- Configurable cell preloading with `preloadCells` parameter
- Ring-based spiral indexing for grid cells starting from center (0,0)
- Centered grid layout with origin (0,0) positioned at viewport center
- Support for iOS, Android, Web, and Desktop platforms
- Comprehensive test suite
- Example app demonstrating various use cases

### Changed
- `InfiniteGrid` now requires a `List<T> items` parameter - no more optional items
- `cellBuilder` function signature changed to `(GridCellConfig config, T item)` - item is now required and non-nullable
- Made `InfiniteGrid` class generic (`InfiniteGrid<T>`) to provide type safety for items
- All grids now cycle through items infinitely - no more dual-mode behavior
- Improved API consistency by having a single constructor that always works with items
- Enhanced type safety by requiring items and providing strongly-typed access in cellBuilder
- Removed deprecated `cellSize` and `effectiveCellSize` properties from `GridLayout`
- Removed deprecated `cellSize` property from `GridCellConfig`
- Default `enableMomentumScrolling` is now `false` for direct drag control
- Implemented ring-based counter-clockwise spiral indexing pattern for grid cells
- Optimized rendering with viewport-based cell culling
- Efficient memory management with automatic cell recycling
- Cross-platform touch and mouse support
- Customizable physics for momentum scrolling
- Programmatic navigation with animation support
- Fixed duplicate key issue in grid rendering with proper spiral indexing algorithm
- Ensured all grid cells have unique keys for proper Flutter widget management

### Removed
- Removed `InfiniteGrid.builder()` constructor
- Removed optional `items` parameter from main constructor
- Removed nullable `T?` item parameter from cellBuilder
- Removed dual-mode logic for handling grids with and without items
- Removed `cellSize` and `spacing` parameters from `InfiniteGrid` widget constructor
- Repetitive `cellSize` and `spacing` parameters from controller methods by using `GridLayout` approach

### Improved
- Clean API: Item-aware methods require no parameters (use internal layout)
- Immutable design: GridLayout is immutable and stateless
- Better separation: Controller handles positions, layout handles item calculations
- Type safety: Uses proper Point<int> types from dart:math
- Flexible usage: Layout can be used independently or with controller
- Single source of truth: Controller's layout defines all cell and spacing configuration
- Flutter-native API: Animation methods now work exactly like ScrollController (no manual vsync parameter required)
- Proper architecture: Controller provides interface, widget handles implementation (follows Flutter patterns)
- Items are indexed in a spiral pattern starting from center (0, 0)
- Spiral follows: right → down → left → up → expanding outward
- Layout is immutable and can be reused across multiple controllers
- All methods properly account for cell size and spacing internally
- Round-trip conversions between indices and positions are guaranteed
- No auto-sync or state management complexity
- High-performance rendering with only visible cells
- Infinite scrolling with constant memory usage
- Smooth touch interactions with momentum
- Customizable physics for scroll behavior
- Programmatic control with animations
- Position tracking callbacks
- Viewport margin configuration
- Cell recycling for optimal performance
- Comprehensive README with examples
- API documentation for all classes
- Performance optimization guidelines
- Platform-specific considerations
- Usage examples and best practices
