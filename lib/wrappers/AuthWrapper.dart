import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/Loading.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/wrappers/MainWrapper.dart';

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  StoreBloc bloc;

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bloc = StoreBloc();

    return StreamBuilder<LocalDBDataPack>(
      stream: bloc.store,
      builder: (BuildContext context, AsyncSnapshot<LocalDBDataPack> snapshot) {
        if(snapshot.hasData) {
          print(snapshot.data.products);
          return MainWrapper(bloc: bloc, data: snapshot.data);
        } else {
          return Loading('Loading Store Database');
        }
      },
    );
  }
}

