import 'package:flutter/material.dart';

class AppTheme {
  static const _cream = Color(0xFFFAFAE6);
  static const _card = Color(0xFFF1F5D8);
  static const _olive = Color(0xFFC9C3A3);
  static const _brown = Color(0xFF7A4A2B);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: _brown, surface: _cream);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: _cream,
        foregroundColor: _brown,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: _brown,
        ),
      ),
      cardTheme: CardThemeData(
        color: _card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: _olive),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _olive),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _olive),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _olive,
        indicatorColor: _cream,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _brown,
        foregroundColor: Colors.white,
      ),
    );
  }
}
