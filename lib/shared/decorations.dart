import 'package:flutter/material.dart';

InputDecoration formFieldDecoration = InputDecoration(
    filled: true,
    isDense: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    ),
    fillColor: Colors.white,
);

InputDecoration searchFieldDecoration = InputDecoration(
    filled: true,
    isDense: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(10),
    ),
    fillColor: Colors.white,
    hintText: 'Search',
);

InputDecoration dropdownDecoration = InputDecoration(
  filled: true,
  isDense: true,
  border: OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: BorderRadius.circular(100),
  ),
  fillColor: Colors.white,
  hintText: 'Search',
);

BoxDecoration labelFieldDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(10)
);

ButtonStyle formButtonDecoration = ButtonStyle(
  backgroundColor: MaterialStateProperty.all(Colors.white),
  foregroundColor: MaterialStateProperty.all(Color(0xFF459A7C)),
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      )
  )
);