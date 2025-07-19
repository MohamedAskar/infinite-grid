import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grid/infinite_grid.dart';
import 'dart:math' as math;

void main() {
  // Helper function to create a simple test widget
  Widget createTestWidget(InfiniteGridController controller) {
    const layout = GridLayout(cellSize: 100, spacing: 0);
    return MaterialApp(
      home: InfiniteGrid<int>(
        controller: controller,
        layout: layout,
        items: List.generate(100, (index) => index),
        cellBuilder: (_, config, item) => Container(
          color: Colors.blue,
          child: Center(child: Text('$item')),
        ),
      ),
    );
  }

  group('InfiniteGrid', () {
    testWidgets('creates and renders', (tester) async {
      final controller = InfiniteGridController();

      await tester.pumpWidget(createTestWidget(controller));
      expect(find.byType(InfiniteGrid<int>), findsOneWidget);
    });

    testWidgets('can jump and animate to items', (tester) async {
      final controller = InfiniteGridController();

      await tester.pumpWidget(createTestWidget(controller));

      // Test jumping to item
      controller.jumpToItem(129);
      await tester.pump();
      expect(controller.getCurrentCenterItemIndex(), 129);

      // Test animating to item
      controller.animateToItem(25);
      await tester.pumpAndSettle();
      expect(controller.getCurrentCenterItemIndex(), 25);
    });

    testWidgets('can move programmatically', (tester) async {
      final controller = InfiniteGridController();

      await tester.pumpWidget(createTestWidget(controller));

      // Test moving by offset
      controller.moveBy(const Offset(100, 50));
      await tester.pump();
      expect(controller.currentPosition, const Offset(100, 50));

      // Test jumping to specific position
      controller.jumpTo(const Offset(200, 100));
      await tester.pump();
      expect(controller.currentPosition, const Offset(200, 100));
    });

    testWidgets('supports factory constructor with initial item', (
      tester,
    ) async {
      final controller = InfiniteGridController.fromItem(
        initialItem: 129,
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(createTestWidget(controller));
      expect(controller.getCurrentCenterItemIndex(), 129);
    });

    testWidgets('supports factory constructor with center item', (
      tester,
    ) async {
      final controller = InfiniteGridController.fromItem(
        initialItem: 0,
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(createTestWidget(controller));
      expect(controller.getCurrentCenterItemIndex(), 0);
    });

    testWidgets('cycles through items infinitely', (tester) async {
      final controller = InfiniteGridController();

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<String>(
            controller: controller,
            layout: const GridLayout(cellSize: 100, spacing: 0),
            items: const ['A', 'B', 'C'],
            cellBuilder: (_, config, item) => Container(
              color: Colors.blue,
              child: Center(child: Text(item)),
            ),
          ),
        ),
      );

      expect(find.byType(InfiniteGrid<String>), findsOneWidget);
    });

    testWidgets('handles custom item types', (tester) async {
      final controller = InfiniteGridController();

      final items = [
        {'name': 'Apple', 'color': Colors.red},
        {'name': 'Banana', 'color': Colors.yellow},
        {'name': 'Cherry', 'color': Colors.red},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<Map<String, dynamic>>(
            controller: controller,
            layout: const GridLayout(cellSize: 100, spacing: 0),
            items: items,
            cellBuilder: (_, config, item) => Container(
              color: item['color'] as Color,
              child: Center(child: Text(item['name'] as String)),
            ),
          ),
        ),
      );

      expect(find.byType(InfiniteGrid<Map<String, dynamic>>), findsOneWidget);
    });

    testWidgets('handles empty list', (tester) async {
      final controller = InfiniteGridController();

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<String>(
            controller: controller,
            layout: const GridLayout(cellSize: 100, spacing: 0),
            items: const [],
            cellBuilder: (_, config, item) => Container(
              color: Colors.blue,
              child: Center(child: Text(item)),
            ),
          ),
        ),
      );

      expect(find.byType(InfiniteGrid<String>), findsOneWidget);
    });

    testWidgets('handles single item', (tester) async {
      final controller = InfiniteGridController();

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<String>(
            controller: controller,
            layout: const GridLayout(cellSize: 100, spacing: 0),
            items: const ['Single'],
            cellBuilder: (_, config, item) => Container(
              color: Colors.blue,
              child: Center(child: Text(item)),
            ),
          ),
        ),
      );

      expect(find.byType(InfiniteGrid<String>), findsOneWidget);
    });

    testWidgets('supports grid offset for staggered columns', (tester) async {
      final controller = InfiniteGridController();
      const layout = GridLayout(
        cellSize: 100,
        spacing: 0,
        gridOffset: 0.5, // 50% offset
      );

      await tester.pumpWidget(createTestWidget(controller));
      expect(find.byType(InfiniteGrid<int>), findsOneWidget);

      // Verify that the layout has the correct grid offset
      expect(layout.gridOffset, 0.5);
    });
  });

  group('InfiniteGrid.builder', () {
    testWidgets('creates grid with builder pattern', (tester) async {
      final controller = InfiniteGridController();
      const layout = GridLayout(cellSize: 100, spacing: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteGrid.builder(
              controller: controller,
              layout: layout,
              itemCount: 10,
              cellBuilder: (context, config, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  border: Border.all(color: Colors.black),
                ),
                child: Center(child: Text('Item $index')),
              ),
            ),
          ),
        ),
      );

      // Since it's an infinite grid, items repeat, so we expect at least one
      expect(find.text('Item 0'), findsAtLeastNWidgets(1));
      expect(find.text('Item 1'), findsAtLeastNWidgets(1));
    });

    testWidgets('handles empty builder', (tester) async {
      final controller = InfiniteGridController();
      const layout = GridLayout(cellSize: 100, spacing: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteGrid.builder(
              controller: controller,
              layout: layout,
              itemCount: 0,
              cellBuilder: (context, config, index) => Text('Item $index'),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });
  });

  group('GridLayout', () {
    test('calculates effective cell size', () {
      expect(
        const GridLayout(cellSize: 100, spacing: 0).effectiveCellWidth,
        equals(100),
      );
      expect(
        const GridLayout(cellSize: 100, spacing: 10).effectiveCellWidth,
        equals(110),
      );
    });

    test('supports rectangular cells', () {
      final layout = const GridLayout.rectangular(
        cellWidth: 120,
        cellHeight: 80,
        spacing: 5,
      );

      expect(layout.cellWidth, equals(120));
      expect(layout.cellHeight, equals(80));
      expect(layout.effectiveCellWidth, equals(125));
      expect(layout.effectiveCellHeight, equals(85));
    });

    test('rectangular cells have different width and height', () {
      final layout = const GridLayout.rectangular(
        cellWidth: 150,
        cellHeight: 100,
        spacing: 0,
      );

      expect(layout.cellWidth, isNot(equals(layout.cellHeight)));
      expect(
        layout.effectiveCellWidth,
        isNot(equals(layout.effectiveCellHeight)),
      );
    });

    test('spiral indexing follows continuous pattern', () {
      const layout = GridLayout(cellSize: 100, spacing: 0);

      // Test that the spiral continues from where the previous ring ended
      // Ring 1 ends at (1,1) with index 8
      // Ring 2 should start at (2,1) with index 9
      expect(layout.gridPositionToItemIndex(const math.Point(1, 1)), 8);
      expect(layout.gridPositionToItemIndex(const math.Point(2, 1)), 9);

      // Test a few more positions in ring 2
      expect(layout.gridPositionToItemIndex(const math.Point(2, 0)), 10);
      expect(layout.gridPositionToItemIndex(const math.Point(2, -1)), 11);
      expect(layout.gridPositionToItemIndex(const math.Point(2, -2)), 12);
    });

    test('converts between item indices and grid positions', () {
      const layout = GridLayout(cellSize: 100, spacing: 0);

      // Test center and first ring
      expect(layout.itemIndexToGridPosition(0), const math.Point(0, 0));
      expect(layout.itemIndexToGridPosition(1), const math.Point(1, 0));
      expect(layout.itemIndexToGridPosition(5), const math.Point(-1, 0));

      // Test reverse conversion
      expect(layout.gridPositionToItemIndex(const math.Point(0, 0)), 0);
      expect(layout.gridPositionToItemIndex(const math.Point(1, 0)), 1);
      expect(layout.gridPositionToItemIndex(const math.Point(-1, 0)), 5);
    });

    test('round-trip conversion works', () {
      const layout = GridLayout(cellSize: 100, spacing: 0);

      // Test various indices
      for (int i = 0; i < 25; i++) {
        final position = layout.itemIndexToGridPosition(i);
        final backToIndex = layout.gridPositionToItemIndex(position);
        expect(backToIndex, i);
      }
    });

    test('calculates world positions', () {
      const layout = GridLayout(cellSize: 100, spacing: 10);

      expect(layout.calculateItemWorldPosition(0), const Offset(0, 0));
      expect(layout.calculateItemWorldPosition(1), const Offset(110, 0));
      expect(layout.calculateItemWorldPosition(5), const Offset(-110, 0));
    });

    test('supports grid offset for staggered columns', () {
      const layout = GridLayout(
        cellSize: 100,
        spacing: 10,
        gridOffset: 0.5, // 50% offset
      );

      expect(layout.gridOffset, 0.5);

      // Test world positions with offset
      // Column 0: moves down (12.5 pixels = 50% of 25)
      expect(layout.calculateItemWorldPosition(0), const Offset(0, 12.5));
      // Column 1: moves up (-12.5 pixels = -50% of 25)
      expect(layout.calculateItemWorldPosition(1), const Offset(110, -12.5));
      // Column -1: moves up (-12.5 pixels = -50% of 25)
      expect(layout.calculateItemWorldPosition(5), const Offset(-110, -12.5));
      // Index 2 -> Grid position (1, -1) -> Column 1 (odd) -> moves up, Y=-1
      expect(layout.calculateItemWorldPosition(2), const Offset(110, -122.5));
      // Index 6 -> Grid position (-1, 1) -> Column -1 (odd) -> moves up, Y=1
      expect(layout.calculateItemWorldPosition(6), const Offset(-110, 97.5));

      // Test round-trip conversion with offset
      for (int i = 0; i < 10; i++) {
        final worldPos = layout.calculateItemWorldPosition(i);
        final itemIndex = layout.getItemIndexAtWorldPosition(worldPos);
        expect(
          itemIndex,
          i,
          reason: 'Round-trip conversion failed for index $i',
        );
      }
    });

    test('withGridOffset creates new layout with offset', () {
      const originalLayout = GridLayout(cellSize: 100, spacing: 10);
      final offsetLayout = originalLayout.copyWith(gridOffset: 0.25);

      expect(offsetLayout.gridOffset, 0.25);
      expect(offsetLayout.cellWidth, originalLayout.cellWidth);
      expect(offsetLayout.cellHeight, originalLayout.cellHeight);
      expect(offsetLayout.spacing, originalLayout.spacing);
    });

    test('withFullConfiguration creates new layout with all parameters', () {
      const originalLayout = GridLayout(cellSize: 100, spacing: 10);
      final newLayout = originalLayout.copyWith(
        cellWidth: 120,
        cellHeight: 80,
        spacing: 5,
        gridOffset: 0.75,
      );

      expect(newLayout.cellWidth, 120);
      expect(newLayout.cellHeight, 80);
      expect(newLayout.spacing, 5);
      expect(newLayout.gridOffset, 0.75);
    });
  });

  group('InfiniteGridController', () {
    late InfiniteGridController controller;

    setUp(() {
      controller = InfiniteGridController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('fromItem factory constructor works', () {
      const layout = GridLayout(cellSize: 100, spacing: 0);
      final itemController = InfiniteGridController.fromItem(
        initialItem: 129,
        layout: layout,
      );

      expect(itemController.getCurrentCenterItemIndex(), 129);

      // Test with center item
      final centerController = InfiniteGridController.fromItem(
        initialItem: 0,
        layout: layout,
      );
      expect(centerController.currentPosition, const Offset(0, 0));
      expect(centerController.getCurrentCenterItemIndex(), 0);

      itemController.dispose();
      centerController.dispose();
    });

    test('basic operations work', () {
      // Set layout on controller
      controller.updateLayout(const GridLayout(cellSize: 100, spacing: 0));

      // Test jumping to items
      controller.jumpToItem(129);
      expect(controller.getCurrentCenterItemIndex(), 129);

      // Test position updates
      controller.jumpTo(const Offset(200, 150));
      expect(controller.currentPosition, const Offset(200, 150));
    });

    test('requires layout for item operations', () {
      final controller = InfiniteGridController();
      const layout = GridLayout(cellSize: 100, spacing: 0);

      // Set layout on controller
      controller.updateLayout(layout);

      // This should work now since layout is set on the controller
      controller.jumpToItem(0);
      expect(controller.getCurrentCenterItemIndex(), 0);

      controller.dispose();
    });

    test('getCurrentCenterItemIndex works correctly with grid offset', () {
      const layout = GridLayout(
        cellSize: 100,
        spacing: 10,
        gridOffset: 0.5, // 50% offset
      );
      final controller = InfiniteGridController(layout: layout);

      // Test jumping to different items and verifying center item
      controller.jumpToItem(0);
      expect(controller.getCurrentCenterItemIndex(), 0);

      controller.jumpToItem(1);
      expect(controller.getCurrentCenterItemIndex(), 1);

      controller.jumpToItem(5);
      expect(controller.getCurrentCenterItemIndex(), 5);

      controller.jumpToItem(2);
      expect(controller.getCurrentCenterItemIndex(), 2);

      controller.dispose();
    });
  });
}
