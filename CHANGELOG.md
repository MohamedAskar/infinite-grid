# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.3] 

### Fixed
  - Fixed CHANGELOG.md file

## [1.2.2] 

### Fixed
- **pub.dev Compatibility**: Fixed README assets display issues
  - Replaced GitHub user-attachments URLs with local assets
  - Added assets folder with demo images and GIFs
  - Fixed image loading on pub.dev package page
  - Improved README display across all platforms

## [1.2.1] 

### Added
- **GitHub Actions CI/CD**: Automated pull request validation
  - Automated code analysis, testing, and formatting checks
  - Branch protection rules for code quality
  - Repository owner-only merge permissions

### Improved
- **Documentation**: Enhanced README with status badges and demo sections
  - Added pub package, codecov, and style analysis badges
  - Updated demo section with side-by-side comparisons
  - Better showcase of grid offset and scrolling features

## [1.2.0] 

### Added
- **Grid Offset Feature**: Staggered column effects for masonry-style layouts
  - `gridOffset` parameter in `GridLayout` (0.0 to 1.0, default: 0.0)
  - `withGridOffset()` method for easy offset updates
  - Interactive grid offset slider in example app

### Changed
- **Staggered Grid Behavior**: Odd columns move up, even columns move down
  - Maximum shift: quarter cell height per direction (total max: half cell height)
  - Creates balanced and visually appealing staggered effect

### Fixed
- **Item Centering**: Fixed positioning issues when grid offset is applied
  - `jumpToItem()` and `animateToItem()` now correctly center items
  - `getCurrentCenterItemIndex()` accounts for staggered column offsets
  - Proper coordinate system compensation for visual center

### Improved
- **Code Architecture**: Centralized grid calculations in controller
  - Single source of truth for all offset and position calculations
  - Widget delegates to controller: `_controller.calculateColumnOffset(x)`
  - Cleaner separation of concerns and better maintainability
- **API Design**: Enhanced method signatures with named parameters
  - Improved readability for methods with multiple arguments
  - Self-documenting method calls eliminate parameter confusion

**First public release on pub.dev.**

> _Note: Earlier versions were not published to pub.dev. This release includes all features and improvements listed below._

## [1.1.1] 

- Added a demo section to the README.

## [1.1.0] 

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
- Removed deprecated `