import 'package:flutter/material.dart';

class NoItem extends StatelessWidget {
  final String label;
  const NoItem({Key key, this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(label, style: theme.textTheme.headline4),
    );
  }
}
