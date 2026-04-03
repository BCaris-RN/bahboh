import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/bahboh_theme.dart';
import '../../domain/models/board_state.dart';
import '../../domain/models/bubble_color.dart';
import '../../domain/models/bubble_entity.dart';
import '../../domain/models/bubble_fx_burst.dart';

class BoardAtmospherePainter extends CustomPainter {
  const BoardAtmospherePainter({
    required this.boardState,
    required this.activeBubble,
    required this.urgencyStrength,
    required this.visualTick,
    required this.fxBursts,
  });

  final BoardState boardState;
  final BubbleEntity? activeBubble;
  final double urgencyStrength;
  final int visualTick;
  final List<BubbleFxBurst> fxBursts;

  static const int _farBubbleCount = 44;
  static const int _midBubbleCount = 18;
  static const int _ghostBubbleCount = 6;

  @override
  void paint(Canvas canvas, Size size) {
    _paintFarMicroBubbles(canvas, size);
    _paintMidLayerGlows(canvas, size);
    _paintGhostMembranes(canvas, size);
    _paintGameplayEchoes(canvas, size);
    _paintResidueMemory(canvas, size);

    final Paint urgencyWashPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.1),
        radius: 1.12,
        colors: <Color>[
          BahbohPalette.highlight.withValues(
            alpha: 0.008 + urgencyStrength * 0.025,
          ),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, urgencyWashPaint);
  }

  void _paintFarMicroBubbles(Canvas canvas, Size size) {
    final double boardScale = size.shortestSide;
    for (int index = 0; index < _farBubbleCount; index += 1) {
      final BubbleColor color =
          BubbleColor.values[index % BubbleColor.values.length];
      final double drift = visualTick * (0.0012 + (index % 5) * 0.00018);
      final double xFactor =
          (_noise(index * 17 + 3) + math.sin(drift * 8 + index) * 0.02).clamp(
            0.02,
            0.98,
          );
      final double yFactor =
          (_noise(index * 37 + 9) + math.cos(drift * 6 + index * 0.6) * 0.03)
              .clamp(0.04, 0.96);
      final Offset center = Offset(size.width * xFactor, size.height * yFactor);
      final double radius =
          boardScale * (0.004 + _noise(index * 53 + 11) * 0.006);

      final Paint glowPaint = Paint()
        ..color = color.glow.withValues(alpha: 0.045 + (index % 3) * 0.01)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, radius * 2.8, glowPaint);

      final Paint bodyPaint = Paint()
        ..color = color.fill.withValues(alpha: 0.05);
      canvas.drawCircle(center, radius, bodyPaint);

      if (index.isEven) {
        final Paint rimPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.06)
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.6, radius * 0.32);
        canvas.drawCircle(center, radius * 1.04, rimPaint);
      }
    }
  }

  void _paintMidLayerGlows(Canvas canvas, Size size) {
    final double boardScale = size.shortestSide;
    for (int index = 0; index < _midBubbleCount; index += 1) {
      final BubbleColor color =
          BubbleColor.values[(index * 2) % BubbleColor.values.length];
      final double phase = visualTick * (0.004 + index * 0.0002);
      final double xFactor =
          (_noise(index * 23 + 5) + math.sin(phase + index * 0.7) * 0.025)
              .clamp(0.06, 0.94);
      final double yFactor =
          (_noise(index * 41 + 7) + math.cos(phase * 0.8 + index) * 0.02).clamp(
            0.08,
            0.92,
          );
      final Offset center = Offset(size.width * xFactor, size.height * yFactor);
      final double radius =
          boardScale * (0.022 + _noise(index * 61 + 13) * 0.018);

      final Paint bloomPaint = Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            color.fill.withValues(alpha: 0.05),
            color.glow.withValues(alpha: 0.035),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.42, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 2.8));
      canvas.drawCircle(center, radius * 2.6, bloomPaint);
    }
  }

  void _paintGhostMembranes(Canvas canvas, Size size) {
    final double boardScale = size.shortestSide;
    for (int index = 0; index < _ghostBubbleCount; index += 1) {
      final BubbleColor color =
          BubbleColor.values[(index * 3) % BubbleColor.values.length];
      final double phase = visualTick * (0.0022 + index * 0.00016);
      final double xFactor =
          (_noise(index * 67 + 19) + math.sin(phase + index * 0.9) * 0.018)
              .clamp(0.12, 0.88);
      final double yFactor =
          (_noise(index * 79 + 23) + math.cos(phase * 0.7 + index) * 0.026)
              .clamp(0.12, 0.88);
      final Offset center = Offset(size.width * xFactor, size.height * yFactor);
      final double radius =
          boardScale * (0.072 + _noise(index * 83 + 29) * 0.030);

      final Paint haloPaint = Paint()
        ..color = color.glow.withValues(alpha: 0.028)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
      canvas.drawCircle(center, radius * 1.35, haloPaint);

      final Paint rimPaint = Paint()
        ..shader = SweepGradient(
          colors: <Color>[
            Colors.white.withValues(alpha: 0.10),
            color.glow.withValues(alpha: 0.06),
            Colors.transparent,
            color.fill.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.08),
          ],
          stops: const <double>[0.0, 0.18, 0.44, 0.78, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, radius * 0.06);
      canvas.drawCircle(center, radius, rimPaint);
    }
  }

  void _paintGameplayEchoes(Canvas canvas, Size size) {
    final Iterable<BubbleEntity> echoBubbles = activeBubble == null
        ? boardState.lockedBubbles
        : <BubbleEntity>[...boardState.lockedBubbles, activeBubble!];
    final double cellWidth = size.width / boardState.columns;
    final double cellHeight = size.height / boardState.rows;

    for (final BubbleEntity bubble in echoBubbles) {
      final Offset center = Offset(
        bubble.xUnits * cellWidth,
        bubble.yUnits * cellHeight,
      );
      final double radius = bubble.radiusUnits * (cellWidth + cellHeight) / 2;
      final Paint echoPaint = Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            bubble.color.fill.withValues(alpha: 0.04),
            bubble.color.glow.withValues(alpha: 0.025),
            Colors.transparent,
          ],
          stops: const <double>[0.0, 0.48, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 2.6));
      canvas.drawCircle(center, radius * 2.5, echoPaint);
    }
  }

  void _paintResidueMemory(Canvas canvas, Size size) {
    final double cellWidth = size.width / boardState.columns;
    final double cellHeight = size.height / boardState.rows;

    for (final BubbleFxBurst burst in fxBursts) {
      final Offset center = Offset(
        burst.xUnits * cellWidth,
        burst.yUnits * cellHeight,
      );
      final double residueProgress = burst.progress.clamp(0.0, 1.0);
      final Color residueColor =
          Color.lerp(burst.primaryColor.glow, burst.secondaryColor.glow, 0.5) ??
          burst.primaryColor.glow;
      final Color residueFill =
          Color.lerp(burst.primaryColor.fill, burst.secondaryColor.fill, 0.5) ??
          burst.primaryColor.fill;
      final double residueRadius =
          size.shortestSide *
          (0.13 + burst.energy * 0.045 + residueProgress * 0.12);

      final Paint cloudPaint = Paint()
        ..shader =
            RadialGradient(
              colors: <Color>[
                residueFill.withValues(alpha: (1 - residueProgress) * 0.085),
                residueColor.withValues(alpha: (1 - residueProgress) * 0.05),
                Colors.transparent,
              ],
              stops: const <double>[0.0, 0.42, 1.0],
            ).createShader(
              Rect.fromCircle(center: center, radius: residueRadius * 1.2),
            );
      canvas.drawOval(
        Rect.fromCenter(
          center: center.translate(residueRadius * 0.08, -residueRadius * 0.04),
          width: residueRadius * 2.2,
          height: residueRadius * 1.52,
        ),
        cloudPaint,
      );

      final Paint haloPaint = Paint()
        ..color = residueColor.withValues(
          alpha: (1 - residueProgress) * 0.12 * burst.energy,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 34);
      canvas.drawCircle(center, residueRadius, haloPaint);

      for (int fragment = 0; fragment < 3; fragment += 1) {
        final double startAngle =
            burst.id * 0.21 + fragment * 1.84 + residueProgress * 1.6;
        final Paint fragmentPaint = Paint()
          ..color = residueColor.withValues(
            alpha: (1 - residueProgress) * (0.12 - fragment * 0.02),
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.1, residueRadius * 0.04);
        canvas.drawArc(
          Rect.fromCircle(
            center: center,
            radius: residueRadius * (0.58 + fragment * 0.16),
          ),
          startAngle,
          0.72,
          false,
          fragmentPaint,
        );
      }

      for (int dust = 0; dust < 8; dust += 1) {
        final double angle = burst.id * 0.47 + dust * (math.pi / 4);
        final double drift = 0.45 + residueProgress * 1.5;
        final Offset moteCenter =
            center +
            Offset(math.cos(angle), math.sin(angle * 1.12)) *
                residueRadius *
                drift;
        final Paint dustPaint = Paint()
          ..color = residueColor.withValues(
            alpha: (1 - residueProgress) * 0.16,
          );
        canvas.drawCircle(
          moteCenter,
          math.max(0.8, residueRadius * (0.03 - residueProgress * 0.01)),
          dustPaint,
        );
      }
    }
  }

  double _noise(int seed) {
    final double value = math.sin(seed * 12.9898 + 78.233) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant BoardAtmospherePainter oldDelegate) {
    return oldDelegate.boardState != boardState ||
        oldDelegate.activeBubble != activeBubble ||
        oldDelegate.urgencyStrength != urgencyStrength ||
        oldDelegate.visualTick != visualTick ||
        oldDelegate.fxBursts != fxBursts;
  }
}
