import 'package:flutter/material.dart';
import 'package:quick_store/BLoCs/StoreBloc.dart';
import 'package:quick_store/components/Loading.dart';
import 'package:quick_store/models/Account.dart';
import 'package:quick_store/models/LocalDBDataPack.dart';
import 'package:quick_store/screens/mainpages/LoginPage.dart';
import 'package:quick_store/wrappers/MainWrapper.dart';

class AuthWrapper extends StatefulWidget {
  final Account account;

  AuthWrapper({this.account});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  StoreBloc bloc;
  Account account;

  void setAccount (Account dbAccount) {
    setState(() {
      account = dbAccount;
    });
  }

  void logoutHandler () {
    setState(() {
      account = null;
    });
  }

  @override
  void initState() {
    super.initState();
    account = widget.account;
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bloc = StoreBloc();
    if(account == null) {
      return LoginPage(setAccount: setAccount);
    }
    return StreamBuilder<LocalDBDataPack>(
      stream: bloc.store,
      builder: (BuildContext context, AsyncSnapshot<LocalDBDataPack> snapshot) {
        if(snapshot.hasData) {
          return MainWrapper(bloc: bloc, data: snapshot.data, logoutHandler: logoutHandler, account: account);
        } else {
          return Loading('Loading Store Database');
        }
      },
    );
  }
}

