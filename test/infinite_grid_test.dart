import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_grid/infinite_grid.dart';
import 'dart:math' as math;

void main() {
  // Helper function to create a simple test widget
  Widget createTestWidget(InfiniteGridController controller) {
    return MaterialApp(
      home: InfiniteGrid<int>(
        controller: controller,
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
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(createTestWidget(controller));
      expect(find.byType(InfiniteGrid<int>), findsOneWidget);
    });

    testWidgets('can jump and animate to items', (tester) async {
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

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
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

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
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<String>(
            controller: controller,
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
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      final items = [
        {'name': 'Apple', 'color': Colors.red},
        {'name': 'Banana', 'color': Colors.yellow},
        {'name': 'Cherry', 'color': Colors.red},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<Map<String, dynamic>>(
            controller: controller,
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
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<String>(
            controller: controller,
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
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InfiniteGrid<String>(
            controller: controller,
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
  });

  group('InfiniteGrid.builder', () {
    testWidgets('creates grid with builder pattern', (tester) async {
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteGrid.builder(
              controller: controller,
              itemCount: 10,
              itemBuilder: (context, index) => Container(
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
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InfiniteGrid.builder(
              controller: controller,
              itemCount: 0,
              itemBuilder: (context, index) =>
                  Container(child: Text('Item $index')),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.help_outline), findsAtLeastNWidgets(1));
    });
  });

  group('GridLayout', () {
    test('calculates effective cell size', () {
      expect(
        const GridLayout(cellSize: 100, spacing: 0).effectiveCellSize,
        100.0,
      );
      expect(
        const GridLayout(cellSize: 100, spacing: 10).effectiveCellSize,
        110.0,
      );
    });

    test('spiral indexing follows continuous pattern', () {
      final controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );

      // Test that the spiral continues from where the previous ring ended
      // Ring 1 ends at (1,1) with index 8
      // Ring 2 should start at (2,1) with index 9
      expect(
        controller.layout!.gridPositionToItemIndex(const math.Point(1, 1)),
        8,
      );
      expect(
        controller.layout!.gridPositionToItemIndex(const math.Point(2, 1)),
        9,
      );

      // Test a few more positions in ring 2
      expect(
        controller.layout!.gridPositionToItemIndex(const math.Point(2, 0)),
        10,
      );
      expect(
        controller.layout!.gridPositionToItemIndex(const math.Point(2, -1)),
        11,
      );
      expect(
        controller.layout!.gridPositionToItemIndex(const math.Point(2, -2)),
        12,
      );

      controller.dispose();
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
  });

  group('InfiniteGridController', () {
    late InfiniteGridController controller;

    setUp(() {
      controller = InfiniteGridController(
        layout: const GridLayout(cellSize: 100, spacing: 0),
      );
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
      // Test jumping to items
      controller.jumpToItem(129);
      expect(controller.getCurrentCenterItemIndex(), 129);

      // Test position updates
      controller.jumpTo(const Offset(200, 150));
      expect(controller.currentPosition, const Offset(200, 150));

      // Test layout updates
      const newLayout = GridLayout(cellSize: 50, spacing: 5);
      controller.layout = newLayout;
      expect(controller.layout, newLayout);
    });

    test('requires layout for item operations', () {
      final controllerWithoutLayout = InfiniteGridController();
      expect(
        () => controllerWithoutLayout.jumpToItem(0),
        throwsA(isA<StateError>()),
      );
      controllerWithoutLayout.dispose();
    });
  });
}
