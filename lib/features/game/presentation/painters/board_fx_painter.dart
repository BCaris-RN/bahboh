import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/models/board_state.dart';
import '../../domain/models/bubble_entity.dart';
import '../../domain/models/bubble_fx_burst.dart';

class BoardFxPainter extends CustomPainter {
  const BoardFxPainter({
    required this.boardState,
    required this.activeBubble,
    required this.visualTick,
    required this.fxBursts,
  });

  final BoardState boardState;
  final BubbleEntity? activeBubble;
  final int visualTick;
  final List<BubbleFxBurst> fxBursts;

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / boardState.columns;
    final double cellHeight = size.height / boardState.rows;

    if (activeBubble != null) {
      final Offset activeCenter = Offset(
        activeBubble!.xUnits * cellWidth,
        activeBubble!.yUnits * cellHeight,
      );
      final double activeRadius =
          activeBubble!.radiusUnits * (cellWidth + cellHeight) / 2;
      final Color activeGlow = activeBubble!.color.glow;

      final Paint fieldPaint = Paint()
        ..shader =
            RadialGradient(
              colors: <Color>[
                activeGlow.withValues(alpha: 0.18),
                activeGlow.withValues(alpha: 0.06),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.38, 1.0],
            ).createShader(
              Rect.fromCircle(center: activeCenter, radius: activeRadius * 2.1),
            );
      canvas.drawCircle(activeCenter, activeRadius * 1.92, fieldPaint);

      final Paint orbitPaint = Paint()
        ..color = activeGlow.withValues(alpha: 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(activeCenter, activeRadius * 1.42, orbitPaint);

      final double orbitAngle = visualTick * 0.06 + activeBubble!.id * 0.73;
      final Paint orbitRingPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.1, activeRadius * 0.04);
      canvas.drawArc(
        Rect.fromCircle(center: activeCenter, radius: activeRadius * 1.22),
        orbitAngle,
        0.94,
        false,
        orbitRingPaint,
      );

      for (int index = 0; index < 5; index += 1) {
        final double angle =
            activeBubble!.ageTicks * 0.08 +
            activeBubble!.id * 0.73 +
            index * 1.28;
        final Offset moteCenter =
            activeCenter +
            Offset(math.cos(angle), math.sin(angle * 1.14)) *
                activeRadius *
                (0.94 + index * 0.10);
        final Paint motePaint = Paint()
          ..color = activeGlow.withValues(alpha: 0.24 - index * 0.035)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(
          moteCenter,
          math.max(1.0, activeRadius * (0.082 - index * 0.010)),
          motePaint,
        );
      }
    }

    for (final BubbleFxBurst burst in fxBursts) {
      final Offset center = Offset(
        burst.xUnits * cellWidth,
        burst.yUnits * cellHeight,
      );
      final double progress = burst.progress.clamp(0.0, 1.0);
      final double burstStrength = (1 - progress).clamp(0.0, 1.0);
      final Color mixedGlow =
          Color.lerp(burst.primaryColor.glow, burst.secondaryColor.glow, 0.5) ??
          burst.primaryColor.glow;
      final Color mixedFill =
          Color.lerp(burst.primaryColor.fill, burst.secondaryColor.fill, 0.5) ??
          burst.primaryColor.fill;
      final double baseRadius =
          size.shortestSide * (0.038 + burst.energy * 0.030);

      final Paint flarePaint = Paint()
        ..shader =
            RadialGradient(
              colors: <Color>[
                Colors.white.withValues(alpha: burstStrength * 0.40),
                mixedGlow.withValues(alpha: burstStrength * 0.26),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.30, 1.0],
            ).createShader(
              Rect.fromCircle(center: center, radius: baseRadius * 2.2),
            );
      canvas.drawCircle(
        center,
        baseRadius * (1.2 + progress * 0.5),
        flarePaint,
      );

      final double ringRadius = baseRadius * (0.85 + progress * 2.4);
      final Paint ringPaint = Paint()
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.82 - progress * 0.54),
            mixedGlow.withValues(alpha: 0.64 - progress * 0.36),
            mixedFill.withValues(alpha: 0.42 - progress * 0.24),
            Colors.white.withValues(alpha: 0.68 - progress * 0.42),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: ringRadius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.6, baseRadius * (0.17 - progress * 0.05));
      canvas.drawCircle(center, ringRadius, ringPaint);

      for (int fragment = 0; fragment < 4; fragment += 1) {
        final double startAngle =
            burst.id * 0.31 + fragment * 1.42 + progress * 1.8;
        final Paint fragmentPaint = Paint()
          ..color = mixedGlow.withValues(alpha: burstStrength * 0.34)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, baseRadius * 0.07);
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: ringRadius * (0.74 + fragment * 0.10),
          ),
          startAngle,
          0.48,
          false,
          fragmentPaint,
        );
      }

      for (int spark = 0; spark < 10; spark += 1) {
        final double angle = burst.id * 0.51 + spark * (math.pi / 5);
        final Offset sparkCenter =
            center +
            Offset(math.cos(angle), math.sin(angle)) *
                baseRadius *
                (0.9 + progress * 3.1);
        final Paint sparkPaint = Paint()
          ..color = mixedGlow.withValues(alpha: burstStrength * 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        canvas.drawCircle(
          sparkCenter,
          math.max(1.0, baseRadius * (0.075 - progress * 0.024)),
          sparkPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BoardFxPainter oldDelegate) {
    return oldDelegate.boardState != boardState ||
        oldDelegate.activeBubble != activeBubble ||
        oldDelegate.visualTick != visualTick ||
        oldDelegate.fxBursts != fxBursts;
  }
}
