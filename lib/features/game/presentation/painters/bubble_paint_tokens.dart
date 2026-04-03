import 'package:flutter/material.dart';

import '../../domain/models/bubble_color.dart';

class BubblePaintToken {
  const BubblePaintToken({
    required this.baseCore,
    required this.glowColor,
    required this.rimColor,
    required this.innerReflectionColor,
    required this.highlightTint,
  });

  final Color baseCore;
  final Color glowColor;
  final Color rimColor;
  final Color innerReflectionColor;
  final Color highlightTint;
}

BubblePaintToken bubblePaintTokenFor(BubbleColor color) {
  return switch (color) {
    BubbleColor.red => const BubblePaintToken(
      baseCore: Color(0xFFFF4C8B),
      glowColor: Color(0xFFFF4F7A),
      rimColor: Color(0xFFFFC2DD),
      innerReflectionColor: Color(0xFFFF85F0),
      highlightTint: Color(0xFFF1FBFF),
    ),
    BubbleColor.orange => const BubblePaintToken(
      baseCore: Color(0xFFFFB13B),
      glowColor: Color(0xFFFF9D2B),
      rimColor: Color(0xFFFFE1A8),
      innerReflectionColor: Color(0xFFFFD987),
      highlightTint: Color(0xFFF7FCFF),
    ),
    BubbleColor.yellow => const BubblePaintToken(
      baseCore: Color(0xFFF2FF43),
      glowColor: Color(0xFFE8FF2E),
      rimColor: Color(0xFFFFFFC8),
      innerReflectionColor: Color(0xFFCAFFC5),
      highlightTint: Color(0xFFF9FDFF),
    ),
    BubbleColor.green => const BubblePaintToken(
      baseCore: Color(0xFF4FFF86),
      glowColor: Color(0xFF34FF79),
      rimColor: Color(0xFFCFFFE1),
      innerReflectionColor: Color(0xFF8BFFE9),
      highlightTint: Color(0xFFF2FDFF),
    ),
    BubbleColor.blue => const BubblePaintToken(
      baseCore: Color(0xFF32D7FF),
      glowColor: Color(0xFF33BFFF),
      rimColor: Color(0xFFC9F3FF),
      innerReflectionColor: Color(0xFF82F1FF),
      highlightTint: Color(0xFFF3FBFF),
    ),
    BubbleColor.indigo => const BubblePaintToken(
      baseCore: Color(0xFF7C73FF),
      glowColor: Color(0xFF6A66FF),
      rimColor: Color(0xFFD5D7FF),
      innerReflectionColor: Color(0xFF9AA4FF),
      highlightTint: Color(0xFFF4F7FF),
    ),
    BubbleColor.violet => const BubblePaintToken(
      baseCore: Color(0xFFC65BFF),
      glowColor: Color(0xFFB64AFF),
      rimColor: Color(0xFFF0CCFF),
      innerReflectionColor: Color(0xFFFF8FF8),
      highlightTint: Color(0xFFF7F3FF),
    ),
  };
}
