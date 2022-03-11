import 'package:flutter/material.dart';

InputDecoration formFieldDecoration = InputDecoration(
    isDense: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    ),
    fillColor: Colors.white,
);

InputDecoration searchFieldDecoration = InputDecoration(
    isDense: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    ),
    fillColor: Colors.white,
    hintText: 'Search',
);

InputDecoration dropdownDecoration = InputDecoration(
  contentPadding: EdgeInsets.all(10),
  filled: true,
  isDense: true,
  border: OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(100),
  ),
  // fillColor: Colors.white,
  hintText: 'Search',
);

BoxDecoration labelFieldDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(10)
);

ShapeDecoration fieldContainerDecoration = ShapeDecoration(
  gradient: LinearGradient(
    colors: [Color(0xffdce6d8), Color(0xffe6f7dc)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.4],
    tileMode: TileMode.clamp,
  ),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);

ButtonStyle formButtonDecoration = ButtonStyle(
    elevation: MaterialStateProperty.all(6),
    textStyle: MaterialStateProperty.all(TextStyle(
      fontSize: 20
    )),
    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 8, horizontal: 20)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      )
    )
);

ButtonStyle appButtonDecoration = ButtonStyle(
    elevation: MaterialStateProperty.all(6),
    textStyle: MaterialStateProperty.all(TextStyle(
        fontSize: 24
    )),
    padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 8, horizontal: 20)),
    // foregroundColor: MaterialStateProperty.all(Colors.white),
    // backgroundColor: MaterialStateProperty.all(Color(0xFF459A7C)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        )
    )
);