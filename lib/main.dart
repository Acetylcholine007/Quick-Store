import 'package:flutter/material.dart';
import 'package:quick_store/screens/mainpages/FrontPage.dart';
import 'package:quick_store/services/NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final theme = ThemeData(
      fontFamily: 'Poppins',
      primarySwatch: Colors.green,
      textTheme: Typography().black.copyWith(bodyText1: TextStyle(fontSize: 16)),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Store',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(secondary: Colors.lime),
      ),
      // home: AuthWrapper()
      home: FrontPage(),
    );
  }
}