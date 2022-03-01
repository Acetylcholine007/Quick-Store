import 'package:flutter/material.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({Key key}) : super(key: key);

  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Column(
            children: [

            ],
          ),
          ElevatedButton(
            onPressed: () {},
            child: Text('Get Started')
          )
        ],
      ),
    );
  }
}
