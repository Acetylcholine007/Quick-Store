import 'package:flutter/material.dart';
import 'package:quick_store/screens/mainpages/FrontPage.dart';
import 'package:quick_store/services/NotificationService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Store',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.grey,
        primaryTextTheme: Typography().black,
        textTheme: Typography().black.copyWith(bodyText1: TextStyle(fontSize: 16)),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
          textButtonTheme: TextButtonThemeData(// Background color (orange in my case).
            style: TextButton.styleFrom(
              primary: Color(0xFF459A7C),
            ),// Text color
          )
      ),
      // home: AuthWrapper()
      home: FrontPage(),
    );
  }
}