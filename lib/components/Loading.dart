import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  final String title;

  Loading(this.title);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 80,
              child: CircularProgressIndicator(
                  color: theme.primaryColorDark,
                  strokeWidth: 12
              ),
            ),
            SizedBox(height: 50),
            Text(title, style: theme.textTheme.headline6),
          ],
        ),
      ),
    );
  }
}