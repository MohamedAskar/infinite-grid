import 'package:flutter/material.dart';
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
      home: const MyHomePage(title: 'Infinite Grid Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final InfiniteGridController _controller;
  String _currentPosition = '0.0, 0.0';

  @override
  void initState() {
    super.initState();
    _controller = InfiniteGridController(
      layout: const GridLayout(cellSize: 100, spacing: 4),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Generate items for the grid
    final items = List.generate(10000, (index) => index);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Infinite Grid',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Drag to scroll. Use buttons to jump to specific positions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Position: $_currentPosition',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _controller.animateToItem(0);
                      },
                      child: const Text('Go to Origin'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _controller.jumpToItem(129);
                      },
                      child: const Text('Jump to Item 129'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _controller.animateToItem(25);
                      },
                      child: const Text('Animate to Item 25'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: InfiniteGrid<int>(
              controller: _controller,
              items: items,
              cellBuilder: (_, config, item) =>
                  SimpleNumberCell(config: config, item: item),
              onPositionChanged: (position) {
                setState(() {
                  _currentPosition =
                      '${position.dx.toStringAsFixed(1)}, ${position.dy.toStringAsFixed(1)}';
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SimpleNumberCell extends StatelessWidget {
  const SimpleNumberCell({super.key, required this.config, required this.item});

  final GridCellConfig config;
  final int item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.blue.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.blue.shade700, size: 24),
            const SizedBox(height: 4),
            Text(
              '$item',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text('${config.gridIndex}'),
            Text('${config.position}'),
          ],
        ),
      ),
    );
  }
}
