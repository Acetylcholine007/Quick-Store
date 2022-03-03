import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';

class DailyTallyPage extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;

  const DailyTallyPage({Key key, this.bloc, this.data}) : super(key: key);

  @override
  _DailyTallyPageState createState() => _DailyTallyPageState();
}

class _DailyTallyPageState extends State<DailyTallyPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Text('Daily Tally', style: theme.textTheme.headline6)
          ),
          Expanded(
            flex: 10,
            child: SingleChildScrollView(
              child: Text('Grid Here'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(DateTime.now().toString()),
                Text('Total = ')
              ],
            ),
          )
        ],
      ),
    );
  }
}
