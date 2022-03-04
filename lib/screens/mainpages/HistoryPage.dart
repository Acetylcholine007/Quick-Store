import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';

import 'DailyTallyPage.dart';

class HistoryPage extends StatefulWidget {
  final StoreBloc bloc;
  final LocalDBDataPack data;

  const HistoryPage({Key key, this.bloc, this.data}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History Page'),
      ),
      body: DailyTallyPage(bloc: widget.bloc, data: widget.data, isAll: true),
    );
  }
}
