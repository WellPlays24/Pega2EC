import 'package:flutter/material.dart';

class AppTheme {
  static const _seedColor = Color(0xFF7A2EFF);
  static const _surfaceTint = Color(0xFFFFE0F2);
  static const _darkText = Color(0xFF18112B);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF7F5FF),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          color: _darkText,
          height: 1.05,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _darkText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: Color(0xFF4B4560),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceTint,
        selectedColor: colorScheme.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      useMaterial3: true,
    );
  }
}
