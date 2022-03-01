import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:quick_store/wrappers/AuthWrapper.dart';
import 'package:quick_store/wrappers/MainWrapper.dart';
import 'package:quick_store/models/Account.dart';
import 'package:quick_store/services/AuthService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      MultiProvider(
          providers: [
            // StreamProvider<Account>.value(initialData: null, value: AuthService().user),
          ],
          child: MyApp()
      )
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MainWrapper();
  }
}

ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
);