import 'package:flutter/material.dart';

import '../../domain/models/board_state.dart';
import '../../domain/models/bubble_entity.dart';
import 'bubble_painter.dart';

class BubbleFieldPainter extends CustomPainter {
  BubbleFieldPainter({
    required this.boardState,
    required this.activeBubble,
    required this.urgencyStrength,
    required this.shieldActive,
  }) : _bubblePainter = const BubblePainter();

  final BoardState boardState;
  final BubbleEntity? activeBubble;
  final double urgencyStrength;
  final bool shieldActive;
  final BubblePainter _bubblePainter;

  @override
  void paint(Canvas canvas, Size size) {
    for (final BubbleEntity bubble in boardState.lockedBubbles) {
      _bubblePainter.paintBubble(
        canvas: canvas,
        size: size,
        boardState: boardState,
        bubble: bubble,
        glowBoost: (shieldActive ? 0.34 : 0.12) + bubble.settleEnergy * 0.5,
      );
    }

    if (activeBubble != null) {
      _bubblePainter.paintBubble(
        canvas: canvas,
        size: size,
        boardState: boardState,
        bubble: activeBubble!,
        glowBoost: 0.46 + urgencyStrength * 0.18,
      );
    }
  }

  @override
  bool shouldRepaint(covariant BubbleFieldPainter oldDelegate) {
    return oldDelegate.boardState != boardState ||
        oldDelegate.activeBubble != activeBubble ||
        oldDelegate.urgencyStrength != urgencyStrength ||
        oldDelegate.shieldActive != shieldActive;
  }
}
