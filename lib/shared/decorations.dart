import 'package:flutter/material.dart';

InputDecoration formFieldDecoration = InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(10),
    ),
    filled: true,
    fillColor: Colors.white,
    isDense: true
);

InputDecoration searchFieldDecoration = InputDecoration(
    isDense: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(100),
    ),
    filled: true,
    fillColor: Colors.white,
    hintText: 'Search'
);