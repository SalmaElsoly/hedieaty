import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFA390F5), // Soft Purple
  scaffoldBackgroundColor: const Color(0xFFE2E2EB),
  cardColor: const Color(0xFFFFFFFF), // White for card backgrounds
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Color(0xFF2C2C2C)), // Dark Charcoal for primary text
    bodyMedium: TextStyle(color: Color(0xFF787878)), // Medium Gray for secondary text
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFFA390F5), // Primary button color
    textTheme: ButtonTextTheme.normal, // Text on buttons will use the primary color
  ),
  iconButtonTheme: const IconButtonThemeData(
    style: ButtonStyle(
      iconColor: WidgetStatePropertyAll<Color?>(Colors.white), // White icon color
      iconSize: WidgetStatePropertyAll<double>(34),
    ),
  ),
  appBarTheme: const AppBarTheme(
    color: Color(0xFFA390F5), // Soft Purple for the AppBar
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 25), // AppBar title color
    shadowColor: Color(0xFF0A0A1B), // Shadow color for the AppBar
  ),
  iconTheme: const IconThemeData(color: Colors.white), // Icon color in the AppBar
  hoverColor: const Color(0xFFBFAAF8), // Lighter Muted Lavender for hover
  focusColor: const Color(0xFFFFD966),
  highlightColor: const Color(0xFFFFD966),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFA390F5), // Soft Purple
    secondary: Color(0xFFBFAAF8), // Violet Blue
    surface: Color(0xFFFFFFFF), // White for surfaces like cards
    onPrimary: Color(0xFFFFFFFF), // White text on primary color
    onSecondary: Color(0xFFFFFFFF), // White text on secondary color
    onSurface: Color(0xFF2C2C2C), // Medium Gray for secondary text
  ),
);


ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF7D5BC5), // Deep Purple
  scaffoldBackgroundColor: const Color(0xFF1B1B22), // Dark Charcoal
  cardColor: const Color(0xFF2C2C2C), // Slightly lighter for cards
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Color(0xFFE5E5E5)), // Light Gray for primary text
    bodyMedium: TextStyle(color: Color(0xFFC1B5F4)), // Soft Lavender for secondary text
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF7D5BC5), // Deep Purple for buttons
    textTheme: ButtonTextTheme.primary, // Text on buttons will use the primary color
  ),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF7D5BC5), // Deep Purple for the AppBar
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 20), // AppBar title color
  ),
  iconTheme: const IconThemeData(color: Color(0xFF6A4DAE)), // Violet Blue for icons
  hoverColor: const Color(0xFF6A4DAE), // Violet Blue for hover
  focusColor: const Color(0xFFFFA43A), // Soft Orange for focus
  highlightColor: const Color(0xFFFFA43A), // Soft Orange for highlights
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF7D5BC5), // Deep Purple
    secondary: Color(0xFF6A4DAE), // Violet Blue
    surface: Color(0xFF2C2C2C), // Slightly lighter for surfaces like cards
    onPrimary: Color(0xFFFFFFFF), // White text on primary color
    onSecondary: Color(0xFFFFFFFF), // White text on secondary color
    onSurface: Color(0xFFE5E5E5), // Soft Lavender for secondary text
  ),
);