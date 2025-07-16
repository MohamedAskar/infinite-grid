import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_grid/infinite_grid.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = InfiniteGridController(
      layout: const GridLayout(cellSize: 120, spacing: 2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final maxWidth = min(width, 360);

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: InfiniteGrid.builder(
              controller: _controller,
              itemCount: 10000,
              cellBuilder: (context, config, index) {
                return ImageCell(key: ValueKey(index), index: index);
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: BoxConstraints(maxWidth: maxWidth.toDouble()),
              child: ItemNavigator(
                onSubmitted: (value) {
                  _controller.animateToItem(int.tryParse(value) ?? 0);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImageCell extends StatelessWidget {
  const ImageCell({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      'https://picsum.photos/200/200?random=$index',
      fit: BoxFit.cover,
    );
  }
}

class ItemNavigator extends StatefulWidget {
  const ItemNavigator({super.key, required this.onSubmitted});

  final ValueChanged<String> onSubmitted;

  @override
  State<ItemNavigator> createState() => _ItemNavigatorState();
}

class _ItemNavigatorState extends State<ItemNavigator> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            style: theme.textTheme.titleMedium?.copyWith(color: onSurface),
            decoration: InputDecoration(
              hintText: 'Which item do you want to see?',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: onSurface.withValues(alpha: 0.8),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onFieldSubmitted: widget.onSubmitted,
          ),
        ),
      ),
    );
  }
}
