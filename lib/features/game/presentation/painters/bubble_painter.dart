import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../domain/models/board_state.dart';
import '../../domain/models/bubble_entity.dart';
import '../../domain/models/bubble_size.dart';
import 'bubble_paint_tokens.dart';

class BubblePainter {
  const BubblePainter();

  void paintBubble({
    required Canvas canvas,
    required Size size,
    required BoardState boardState,
    required BubbleEntity bubble,
    required double glowBoost,
  }) {
    final BubblePaintToken token = bubblePaintTokenFor(bubble.color);
    final double cellWidth = size.width / boardState.columns;
    final double cellHeight = size.height / boardState.rows;
    final Offset center = Offset(
      bubble.xUnits * cellWidth,
      bubble.yUnits * cellHeight,
    );
    final double radius = bubble.radiusUnits * (cellWidth + cellHeight) / 2;
    final double farBloomRadius = radius * 1.9;
    final double nearHaloRadius = radius * 1.35;
    final double bodyRadius = radius * 0.94;
    final double shellThickness = math.max(1.5, radius * 0.08);
    final double shimmerPhase = bubble.ageTicks * 0.12 + bubble.id * 0.74;
    final double wobble = math.sin(shimmerPhase * 1.48) * bubble.settleEnergy;
    final double fallingStretch = (bubble.verticalVelocityUnits * 3.0).clamp(
      0.0,
      0.08,
    );
    final double scaleX =
        (1 + bubble.settleEnergy * 0.22 - fallingStretch * 0.06 + wobble * 0.10)
            .clamp(0.93, 1.15);
    final double scaleY =
        (1 - bubble.settleEnergy * 0.18 + fallingStretch * 0.15 - wobble * 0.08)
            .clamp(0.91, 1.14);
    final Offset primaryHighlightCenter = center.translate(
      -radius * 0.28 + math.sin(shimmerPhase) * radius * 0.02,
      -radius * 0.32 + math.cos(shimmerPhase * 0.9) * radius * 0.015,
    );
    final Offset secondaryHighlightCenter = center.translate(
      -radius * 0.06,
      -radius * 0.12,
    );
    final int moteCount = switch (bubble.size) {
      BubbleSize.small => 0,
      BubbleSize.medium => 2,
      BubbleSize.large => 4,
    };
    final bool richReflection = bubble.size != BubbleSize.small;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(scaleX, scaleY);
    canvas.translate(-center.dx, -center.dy);

    final Paint farBloomPaint = Paint()
      ..color = token.glowColor.withValues(alpha: 0.08 + glowBoost * 0.04)
      ..maskFilter = MaskFilter.blur(
        BlurStyle.normal,
        math.max(12.0, radius * 0.42),
      );
    canvas.drawCircle(center, farBloomRadius, farBloomPaint);

    final Paint haloPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        nearHaloRadius,
        <Color>[
          token.glowColor.withValues(alpha: 0.18 + glowBoost * 0.06),
          token.baseCore.withValues(alpha: 0.07),
          Colors.transparent,
        ],
        <double>[0.0, 0.54, 1.0],
      );
    canvas.drawCircle(center, nearHaloRadius, haloPaint);

    final Rect shellRect = Rect.fromCircle(center: center, radius: radius);
    final Paint shellPaint = Paint()
      ..shader = SweepGradient(
        transform: GradientRotation(-math.pi * 0.74),
        colors: <Color>[
          token.highlightTint.withValues(alpha: 0.92),
          token.rimColor.withValues(alpha: 0.98),
          token.glowColor.withValues(alpha: 0.82),
          token.rimColor.withValues(alpha: 0.48),
          token.baseCore.withValues(alpha: 0.18),
          token.rimColor.withValues(alpha: 0.88),
          token.highlightTint.withValues(alpha: 0.90),
        ],
        stops: const <double>[0.0, 0.10, 0.28, 0.48, 0.68, 0.86, 1.0],
      ).createShader(shellRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = shellThickness;
    canvas.drawCircle(center, radius, shellPaint);

    final Paint shellAccentPaint = Paint()
      ..color = token.highlightTint.withValues(alpha: 0.26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, shellThickness * 0.52)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(
        center: center.translate(-radius * 0.02, -radius * 0.02),
        radius: radius,
      ),
      -math.pi * 0.88,
      math.pi * 0.66,
      false,
      shellAccentPaint,
    );

    final Paint bodyFillPaint = Paint()
      ..shader = ui.Gradient.radial(
        center.translate(-radius * 0.12, -radius * 0.14),
        bodyRadius,
        <Color>[
          token.highlightTint.withValues(alpha: 0.09),
          token.baseCore.withValues(alpha: 0.018),
          token.baseCore.withValues(alpha: 0.038),
          token.glowColor.withValues(alpha: 0.10),
        ],
        <double>[0.0, 0.18, 0.58, 1.0],
      );
    canvas.drawCircle(center, bodyRadius, bodyFillPaint);

    final Paint bodyVoidPaint = Paint()
      ..shader = ui.Gradient.radial(
        center.translate(radius * 0.03, radius * 0.08),
        bodyRadius * 0.92,
        <Color>[
          Colors.transparent,
          Colors.white.withValues(alpha: 0.012),
          Colors.transparent,
        ],
        <double>[0.0, 0.54, 1.0],
      );
    canvas.drawCircle(center, bodyRadius * 0.96, bodyVoidPaint);

    final Color secondaryReflectionColor =
        Color.lerp(token.innerReflectionColor, token.highlightTint, 0.55) ??
        token.highlightTint;
    final Rect primaryReflectionRect = Rect.fromCenter(
      center: center.translate(-radius * 0.05, -radius * 0.01),
      width: radius * 1.34,
      height: radius * 0.98,
    );
    final Paint primaryReflectionPaint = Paint()
      ..shader = SweepGradient(
        transform: GradientRotation(-math.pi * 0.82),
        colors: <Color>[
          Colors.transparent,
          token.innerReflectionColor.withValues(alpha: 0.22),
          secondaryReflectionColor.withValues(alpha: 0.16),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.18, 0.34, 0.54],
      ).createShader(primaryReflectionRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, radius * 0.06)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      primaryReflectionRect,
      -math.pi * 0.94,
      math.pi * 0.98,
      false,
      primaryReflectionPaint,
    );

    if (richReflection) {
      final Rect secondaryReflectionRect = Rect.fromCenter(
        center: center.translate(radius * 0.02, radius * 0.10),
        width: radius * 1.08,
        height: radius * 0.72,
      );
      final Paint secondaryReflectionPaint = Paint()
        ..shader = ui.Gradient.linear(
          secondaryReflectionRect.topLeft,
          secondaryReflectionRect.bottomRight,
          <Color>[
            token.innerReflectionColor.withValues(alpha: 0.12),
            token.highlightTint.withValues(alpha: 0.10),
            Colors.transparent,
          ],
          <double>[0.0, 0.42, 1.0],
        )
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.042)
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        secondaryReflectionRect,
        -math.pi * 0.52,
        math.pi * 0.58,
        false,
        secondaryReflectionPaint,
      );
    }

    final Rect primaryHighlightRect = Rect.fromCenter(
      center: primaryHighlightCenter,
      width: radius * 0.52,
      height: radius * 0.34,
    );
    final Paint primaryHighlightPaint = Paint()
      ..shader = ui.Gradient.radial(
        primaryHighlightCenter.translate(-radius * 0.03, -radius * 0.03),
        radius * 0.34,
        <Color>[
          token.highlightTint.withValues(alpha: 0.88),
          token.highlightTint.withValues(alpha: 0.24),
          Colors.transparent,
        ],
        <double>[0.0, 0.54, 1.0],
      );
    canvas.drawOval(primaryHighlightRect, primaryHighlightPaint);

    final Paint secondaryHighlightPaint = Paint()
      ..shader = ui.Gradient.radial(
        secondaryHighlightCenter,
        radius * 0.12,
        <Color>[
          token.highlightTint.withValues(alpha: 0.70),
          Colors.transparent,
        ],
        <double>[0.0, 1.0],
      );
    canvas.drawCircle(
      secondaryHighlightCenter,
      radius * 0.09,
      secondaryHighlightPaint,
    );

    final Paint secondaryHighlightArcPaint = Paint()
      ..color = token.highlightTint.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.9, radius * 0.028)
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: secondaryHighlightCenter, radius: radius * 0.18),
      -math.pi * 0.64,
      math.pi * 0.34,
      false,
      secondaryHighlightArcPaint,
    );

    for (int moteIndex = 0; moteIndex < moteCount; moteIndex += 1) {
      final double angle = shimmerPhase * 0.52 + moteIndex * 1.44;
      final double distance = radius * (0.88 + moteIndex * 0.08);
      final Offset moteCenter = center.translate(
        math.cos(angle) * distance,
        math.sin(angle * 1.12) * distance * 0.92,
      );
      final Paint motePaint = Paint()
        ..color = token.glowColor.withValues(alpha: 0.18 - moteIndex * 0.02)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        moteCenter,
        math.max(0.9, radius * (0.046 - moteIndex * 0.006)),
        motePaint,
      );
    }

    canvas.restore();
  }
}
