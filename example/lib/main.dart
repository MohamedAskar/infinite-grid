import 'dart:math';

import 'package:flutter/material.dart';
import 'package:infinite_grid/infinite_grid.dart';

import 'widgets/edit_grid_controls.dart';
import 'widgets/image_cell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinite Grid Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final InfiniteGridController _controller;

  double _gridOffset = 0.5;
  double _spacing = 12.0;
  bool _enableMomentumScrolling = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = InfiniteGridController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _updateGridOffset(double value) {
    setState(() {
      _gridOffset = value;
    });
  }

  void _updateSpacing(double value) {
    setState(() {
      _spacing = value;
    });
  }

  void _toggleMomentumScrolling(bool value) {
    setState(() {
      _enableMomentumScrolling = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = min(width, 360);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              if (_isEditing) {
                _toggleEditMode();
              }
            },
            child: InfiniteGrid.builder(
              controller: _controller,
              layout: GridLayout.rectangular(
                cellWidth: 240,
                cellHeight: 360,
                spacing: _spacing,
                gridOffset: _gridOffset,
              ),
              itemCount: 10000,
              enableMomentumScrolling: _enableMomentumScrolling,
              cellBuilder: (context, config, index) {
                return ImageCell(key: ValueKey(index), index: index);
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: maxWidth.toDouble()),
              child: Builder(
                builder: (context) {
                  if (_isEditing) {
                    return EditGridControls(
                      gridOffset: _gridOffset,
                      spacing: _spacing,
                      enableMomentumScrolling: _enableMomentumScrolling,
                      onMomentumScrollingChanged: _toggleMomentumScrolling,
                      onGridOffsetChanged: _updateGridOffset,
                      onSpacingChanged: _updateSpacing,
                      onDonePressed: _toggleEditMode,
                      onCenterPressed: () => _controller.animateToItem(0),
                      onSubmitted: (value) {
                        _controller.animateToItem(int.tryParse(value) ?? 0);
                      },
                    );
                  } else {
                    return CustomButton(
                      onPressed: _toggleEditMode,
                      label: 'Edit Grid',
                      icon: const Icon(Icons.tune),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
