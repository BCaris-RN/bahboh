import 'package:flutter/material.dart';

import '../../../../core/constants/bahboh_constants.dart';
import '../../application/game_controller.dart';
import '../painters/board_atmosphere_painter.dart';
import '../painters/board_fx_painter.dart';
import '../painters/board_painter.dart';
import '../painters/bubble_field_painter.dart';

class GameBoard extends StatelessWidget {
  const GameBoard({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double aspectRatio =
            controller.boardState.columns / controller.boardState.rows;
        final double urgencyStrength = controller.timerRemainingMs <= 10000
            ? 1 - (controller.timerRemainingMs / 10000)
            : 0;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (DragDownDetails details) {
            controller.setSoftDrop(false);
            _updateDrag(details.localPosition.dx, constraints.maxWidth);
          },
          onPanUpdate: (DragUpdateDetails details) {
            controller.setSoftDrop(details.delta.dy > 1.5);
            _updateDrag(details.localPosition.dx, constraints.maxWidth);
          },
          onPanEnd: (_) => controller.setSoftDrop(false),
          onPanCancel: () => controller.setSoftDrop(false),
          child: AspectRatio(
            aspectRatio: aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                BahbohConstants.boardBorderRadius,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CustomPaint(
                    painter: BoardPainter(
                      boardState: controller.boardState,
                      urgencyStrength: urgencyStrength,
                    ),
                  ),
                  CustomPaint(
                    painter: BoardAtmospherePainter(
                      boardState: controller.boardState,
                      activeBubble: controller.activeBubble,
                      urgencyStrength: urgencyStrength,
                      visualTick: controller.visualTick,
                      fxBursts: controller.fxBursts,
                    ),
                  ),
                  CustomPaint(
                    painter: BubbleFieldPainter(
                      boardState: controller.boardState,
                      activeBubble: controller.activeBubble,
                      urgencyStrength: urgencyStrength,
                      shieldActive: controller.shieldActive,
                    ),
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      painter: BoardFxPainter(
                        boardState: controller.boardState,
                        activeBubble: controller.activeBubble,
                        visualTick: controller.visualTick,
                        fxBursts: controller.fxBursts,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _updateDrag(double localDx, double width) {
    if (width <= 0) {
      return;
    }
    final double xUnits = (localDx / width) * controller.boardState.columns;
    controller.updateDragPosition(xUnits);
  }
}
