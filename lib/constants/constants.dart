import 'package:flutter/material.dart';

BoxDecoration kMainColor = const BoxDecoration(
  gradient: LinearGradient(
    colors: [Color(0xff417D7A), Color(0xffEDE6DB)],
    begin: FractionalOffset(0.0, 0.0),
    end: FractionalOffset(1.0, 0.0),
    stops: [0.0, 1.0],
    tileMode: TileMode.clamp,
  ),
);

TextStyle kTitleTextStyle = const TextStyle(
    letterSpacing: 3, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic);
TextStyle kHeading = const TextStyle(fontWeight: FontWeight.w500);
