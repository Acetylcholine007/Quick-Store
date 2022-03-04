import 'package:flutter/material.dart';

class CellItem extends StatelessWidget {
  final String content;
  final TextStyle style;
  final TextAlign align;
  const CellItem({Key key, this.content, this.style, this.align}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Center(
        child: Text(content, textAlign: align, style: style),
      ),
    );
  }
}
