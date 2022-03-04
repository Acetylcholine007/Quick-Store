import 'package:flutter/material.dart';
import 'package:quick_store/screens/mainpages/FrontPage.dart';

import 'package:quick_store/wrappers/AuthWrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Map<int, Color> getSwatch(Color color) {
    final hslColor = HSLColor.fromColor(color);
    final lightness = hslColor.lightness;

    final lowDivisor = 6;
    final highDivisor = 5;

    final lowStep = (1.0 - lightness) / lowDivisor;
    final highStep = lightness / highDivisor;

    return {
      50: (hslColor.withLightness(lightness + (lowStep * 5))).toColor(),
      100: (hslColor.withLightness(lightness + (lowStep * 4))).toColor(),
      200: (hslColor.withLightness(lightness + (lowStep * 3))).toColor(),
      300: (hslColor.withLightness(lightness + (lowStep * 2))).toColor(),
      400: (hslColor.withLightness(lightness + lowStep)).toColor(),
      500: (hslColor.withLightness(lightness)).toColor(),
      600: (hslColor.withLightness(lightness - highStep)).toColor(),
      700: (hslColor.withLightness(lightness - (highStep * 2))).toColor(),
      800: (hslColor.withLightness(lightness - (highStep * 3))).toColor(),
      900: (hslColor.withLightness(lightness - (highStep * 4))).toColor(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Store',
      theme: ThemeData(
        fontFamily: 'Poppins',
        // primarySwatch: MaterialColor(0xFFFFFBFB, getSwatch(Color(0xFFFFFBFB))),
        primarySwatch: Colors.grey,
        primaryTextTheme: Typography().black,
        textTheme: Typography().black.copyWith(bodyText1: TextStyle(fontSize: 16)),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
      ),
      // home: AuthWrapper()
      home: FrontPage(),
    );
  }
}