import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7C3AED); // Púrpura/Violeta
  static const Color darkBackground = Color(0xFF121212); // Carbón/Slate

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        surface: darkBackground,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: primaryColor,
      ),
    );
  }
}

