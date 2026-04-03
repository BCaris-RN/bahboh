import 'package:flutter/material.dart';

class BahbohPalette {
  const BahbohPalette._();

  static const Color abyss = Color(0xFF020611);
  static const Color ink = Color(0xFF081220);
  static const Color night = Color(0xFF10263F);
  static const Color sea = Color(0xFF103B57);
  static const Color mist = Color(0xFFEAF4FF);
  static const Color glass = Color(0xCC143354);
  static const Color outline = Color(0x33FFFFFF);
  static const Color highlight = Color(0xFF9DE9FF);
  static const Color success = Color(0xFF89F3B4);
  static const Color danger = Color(0xFFFF8DA1);
}

ThemeData buildBahbohTheme() {
  final ColorScheme colorScheme =
      ColorScheme.fromSeed(
        seedColor: BahbohPalette.highlight,
        brightness: Brightness.dark,
      ).copyWith(
        primary: BahbohPalette.highlight,
        secondary: BahbohPalette.success,
        surface: BahbohPalette.glass,
        error: BahbohPalette.danger,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: BahbohPalette.ink,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
        height: 0.95,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
      ),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4),
    ),
    cardTheme: const CardThemeData(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
  );
}
