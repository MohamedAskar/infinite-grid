import 'package:flutter/material.dart';

class ImageCell extends StatelessWidget {
  const ImageCell({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: NetworkImage('https://picsum.photos/400/400?random=$index'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 0)),
        ],
      ),
    );
  }
}
