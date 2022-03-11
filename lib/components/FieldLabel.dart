import 'package:flutter/material.dart';
import 'package:quick_store/shared/decorations.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final Widget child;
  final bool sunken;
  const FieldLabel({Key key, this.label, this.child, this.sunken = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: theme.textTheme.bodyText1),
          Container(
              decoration: sunken ? fieldContainerDecoration : null,
              child: child)
        ],
      ),
    );
  }
}
