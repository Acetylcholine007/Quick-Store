import 'package:flutter/material.dart';

class CellItem extends StatelessWidget {
  final String content;
  final TextStyle style;
  final TextAlign align;
  final EdgeInsets padding;
  const CellItem({
    Key key,
    this.content,
    this.style,
    this.align,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 8)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(content, textAlign: align, style: style, overflow: TextOverflow.ellipsis),
    );
  }
}
