import 'package:flutter/material.dart';

enum BubbleColor {
  red(
    code: 'R',
    label: 'Red',
    fill: Color(0xFFFF5E6E),
    glow: Color(0xFFFFA0AF),
    symbol: 'R',
  ),
  orange(
    code: 'O',
    label: 'Orange',
    fill: Color(0xFFFFA24F),
    glow: Color(0xFFFFD4A8),
    symbol: 'O',
  ),
  yellow(
    code: 'Y',
    label: 'Yellow',
    fill: Color(0xFFFFE26C),
    glow: Color(0xFFFFF4C0),
    symbol: 'Y',
  ),
  green(
    code: 'G',
    label: 'Green',
    fill: Color(0xFF63F0A2),
    glow: Color(0xFFC7FFE1),
    symbol: 'G',
  ),
  blue(
    code: 'B',
    label: 'Blue',
    fill: Color(0xFF5CB8FF),
    glow: Color(0xFFCBE8FF),
    symbol: 'B',
  ),
  indigo(
    code: 'I',
    label: 'Indigo',
    fill: Color(0xFF797BFF),
    glow: Color(0xFFD8D9FF),
    symbol: 'I',
  ),
  violet(
    code: 'V',
    label: 'Violet',
    fill: Color(0xFFD778FF),
    glow: Color(0xFFF0D3FF),
    symbol: 'V',
  );

  const BubbleColor({
    required this.code,
    required this.label,
    required this.fill,
    required this.glow,
    required this.symbol,
  });

  final String code;
  final String label;
  final Color fill;
  final Color glow;
  final String symbol;
}
