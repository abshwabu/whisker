import 'package:flutter/material.dart';

class AppTheme {
  // Warm Pastel Theme Colors
  static const Color peach = Color(0xFFFFB5A7);
  static const Color softPink = Color(0xFFFCD5CE);
  static const Color creamBackground = Color(0xFFF8EDEB);
  static const Color lightCream = Color(0xFFFFF9F8);
  static const Color textDark = Color(0xFF4A3E3D);
  static const Color accentPink = Color(0xFFF5CAC3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: peach,
        onPrimary: textDark,
        secondary: softPink,
        onSecondary: textDark,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: creamBackground,
        onSurface: textDark,
      ),
      scaffoldBackgroundColor: creamBackground,
      cardTheme: const CardThemeData(
        color: lightCream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: peach,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: textDark),
        bodyMedium: TextStyle(color: textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: softPink,
          foregroundColor: textDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
