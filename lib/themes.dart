import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.pink[200],
  colorScheme: ColorScheme.light(
    primary: Colors.pink[200]!,
    secondary: Colors.teal[200]!,
  ),
  scaffoldBackgroundColor: Colors.pink[50],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.pink[300],
  colorScheme: ColorScheme.dark(
    primary: Colors.pink[300]!,
    secondary: Colors.teal[300]!,
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);
