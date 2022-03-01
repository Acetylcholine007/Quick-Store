import 'package:flutter/material.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key key}) : super(key: key);

  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('Scan QR Code', style: theme.textTheme.headline4),
          Column(
            children: [
              IconButton(
                iconSize: 80,
                icon: Icon(Icons.radio_button_checked_rounded),
                onPressed: () {},
              ),
              Text('CAPTURE', style: theme.textTheme.bodyText1)
            ],
          )
        ],
      ),
    );
  }
}
