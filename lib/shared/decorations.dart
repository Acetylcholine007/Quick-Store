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

BoxDecoration labelFieldDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(10)
);