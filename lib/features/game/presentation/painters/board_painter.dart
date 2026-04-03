import 'package:flutter/material.dart';

import '../../../../core/theme/bahboh_theme.dart';
import '../../domain/models/board_state.dart';

class BoardPainter extends CustomPainter {
  const BoardPainter({required this.boardState, required this.urgencyStrength});

  final BoardState boardState;
  final double urgencyStrength;

  @override
  void paint(Canvas canvas, Size size) {
    final RRect boardShape = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(28),
    );

    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          BahbohPalette.abyss,
          BahbohPalette.ink,
          BahbohPalette.night,
        ],
        stops: <double>[0.0, 0.54, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(boardShape, fillPaint);

    final Paint centerShadePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.88,
        colors: <Color>[
          Colors.black.withValues(alpha: 0.22),
          Colors.black.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const <double>[0.0, 0.48, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(boardShape, centerShadePaint);

    final Paint cyanFogPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.72, -0.74),
        radius: 1.02,
        colors: <Color>[
          BahbohPalette.highlight.withValues(alpha: 0.09),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(boardShape, cyanFogPaint);

    final Paint violetFogPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.96, -0.32),
        radius: 0.94,
        colors: <Color>[
          const Color(0xFFA567FF).withValues(alpha: 0.065),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(boardShape, violetFogPaint);

    final Paint seaFogPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.42, 1.10),
        radius: 1.06,
        colors: <Color>[
          BahbohPalette.sea.withValues(alpha: 0.13),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(boardShape, seaFogPaint);

    final Paint reactorFogPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.08, -0.08),
        radius: 1.08,
        colors: <Color>[
          BahbohPalette.danger.withValues(alpha: 0.03 + urgencyStrength * 0.03),
          Colors.transparent,
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(boardShape, reactorFogPaint);

    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.016)
      ..strokeWidth = 1;
    for (int column = 1; column < boardState.columns; column += 1) {
      final double x = size.width * column / boardState.columns;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (int row = 1; row < boardState.rows; row += 1) {
      final double y = size.height * row / boardState.rows;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Paint borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.085 + urgencyStrength * 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(boardShape, borderPaint);
  }

  @override
  bool shouldRepaint(covariant BoardPainter oldDelegate) {
    return oldDelegate.boardState != boardState ||
        oldDelegate.urgencyStrength != urgencyStrength;
  }
}
