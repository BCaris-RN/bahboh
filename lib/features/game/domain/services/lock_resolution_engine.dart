import 'dart:math' as math;

import '../../../../core/constants/bahboh_motion.dart';
import '../models/board_state.dart';
import '../models/bubble_entity.dart';
import '../models/round_definition.dart';

class GravityStepResult {
  const GravityStepResult({
    required this.bubble,
    required this.supportFrames,
    required this.didContact,
    required this.shouldLock,
  });

  final BubbleEntity bubble;
  final int supportFrames;
  final bool didContact;
  final bool shouldLock;
}

class LockResolutionEngine {
  const LockResolutionEngine();

  GravityStepResult advanceActiveBubble({
    required BubbleEntity activeBubble,
    required BoardState boardState,
    required RoundDefinition round,
    required double targetXUnits,
    required int currentSupportFrames,
    required bool isSoftDropping,
  }) {
    final double radius = activeBubble.radiusUnits;
    final double driftOffset =
        math.sin(activeBubble.id * 0.73 + activeBubble.ageTicks * 0.11) *
        round.horizontalDriftStrength;
    final double nextX = (targetXUnits + driftOffset).clamp(
      radius,
      round.boardColumns - radius,
    );
    final double dragFactor = (1 - round.dragCoefficient).clamp(0.0, 0.999);
    final double gravityPerTick =
        round.gravityPerTick *
        (isSoftDropping ? BahbohMotion.softDropGravityMultiplier : 1.0);
    final double terminalVelocity =
        round.terminalVelocity *
        (isSoftDropping
            ? BahbohMotion.softDropTerminalVelocityMultiplier
            : 1.0);
    final double nextVelocity =
        ((activeBubble.verticalVelocityUnits + gravityPerTick) * dragFactor)
            .clamp(0.0, terminalVelocity);
    final double candidateY = activeBubble.yUnits + nextVelocity;
    final double settledY = maxAllowedY(
      xUnits: nextX,
      radiusUnits: radius,
      boardState: boardState,
    );

    if (candidateY >= settledY - 0.001) {
      final int supportFrames = currentSupportFrames + 1;
      final int requiredSupportFrames = (round.lockDelayMs / round.tickMs)
          .ceil()
          .clamp(1, 9999);
      final double impactEnergy = math
          .max(activeBubble.settleEnergy * 0.88, nextVelocity * 3.8)
          .clamp(0.0, 0.22);
      return GravityStepResult(
        bubble: activeBubble.copyWith(
          xUnits: nextX,
          yUnits: settledY,
          verticalVelocityUnits: 0,
          ageTicks: activeBubble.ageTicks + 1,
          settleEnergy: impactEnergy,
        ),
        supportFrames: supportFrames,
        didContact: (activeBubble.yUnits - settledY).abs() > 0.02,
        shouldLock: supportFrames >= requiredSupportFrames,
      );
    }

    return GravityStepResult(
      bubble: activeBubble.copyWith(
        xUnits: nextX,
        yUnits: candidateY,
        verticalVelocityUnits: nextVelocity,
        ageTicks: activeBubble.ageTicks + 1,
        settleEnergy: activeBubble.settleEnergy * 0.88,
      ),
      supportFrames: 0,
      didContact: false,
      shouldLock: false,
    );
  }

  BoardState lockBubble({
    required BoardState boardState,
    required BubbleEntity bubble,
  }) {
    final List<BubbleEntity> next = <BubbleEntity>[
      ...boardState.lockedBubbles,
      bubble.copyWith(
        verticalVelocityUnits: 0,
        settleEnergy: math.max(bubble.settleEnergy, 0.08),
      ),
    ];
    return boardState.copyWith(lockedBubbles: next);
  }

  BoardState settle(BoardState boardState) {
    final List<BubbleEntity> sorted =
        List<BubbleEntity>.of(boardState.lockedBubbles)
          ..sort((BubbleEntity left, BubbleEntity right) {
            final int yCompare = right.yUnits.compareTo(left.yUnits);
            if (yCompare != 0) {
              return yCompare;
            }
            return left.xUnits.compareTo(right.xUnits);
          });

    final List<BubbleEntity> settled = <BubbleEntity>[];
    for (final BubbleEntity bubble in sorted) {
      final double settledY = maxAllowedY(
        xUnits: bubble.xUnits,
        radiusUnits: bubble.radiusUnits,
        boardState: BoardState(
          columns: boardState.columns,
          rows: boardState.rows,
          lockedBubbles: settled,
        ),
      );
      final double displacement = (settledY - bubble.yUnits).abs();
      settled.add(
        bubble.copyWith(
          yUnits: settledY,
          verticalVelocityUnits: 0,
          ageTicks: bubble.ageTicks + 1,
          settleEnergy: math.max(
            bubble.settleEnergy * 0.82,
            displacement > 0.02 ? math.min(0.18, displacement * 0.28) : 0,
          ),
        ),
      );
    }

    return boardState.copyWith(lockedBubbles: settled);
  }

  BoardState decayVisualState(BoardState boardState) {
    return boardState.copyWith(
      lockedBubbles: boardState.lockedBubbles
          .map(
            (BubbleEntity bubble) => bubble.copyWith(
              ageTicks: bubble.ageTicks + 1,
              settleEnergy: bubble.settleEnergy * 0.86,
            ),
          )
          .toList(growable: false),
    );
  }

  bool canSpawn({
    required BoardState boardState,
    required double xUnits,
    required double yUnits,
    required double radiusUnits,
  }) {
    if (xUnits - radiusUnits < 0 ||
        xUnits + radiusUnits > boardState.columns ||
        yUnits - radiusUnits < 0 ||
        yUnits + radiusUnits > boardState.rows) {
      return false;
    }
    for (final BubbleEntity bubble in boardState.lockedBubbles) {
      if (distanceBetweenCenters(
            ax: xUnits,
            ay: yUnits,
            bx: bubble.xUnits,
            by: bubble.yUnits,
          ) <
          radiusUnits + bubble.radiusUnits - 0.001) {
        return false;
      }
    }
    return true;
  }

  bool isContact(BubbleEntity first, BubbleEntity second) {
    return distanceBetween(first, second) <=
        first.radiusUnits + second.radiusUnits + 0.001;
  }

  double maxAllowedY({
    required double xUnits,
    required double radiusUnits,
    required BoardState boardState,
  }) {
    double maxY = boardState.rows - radiusUnits;
    for (final BubbleEntity other in boardState.lockedBubbles) {
      final double combinedRadius = radiusUnits + other.radiusUnits;
      final double horizontalDistance = (xUnits - other.xUnits).abs();
      if (horizontalDistance >= combinedRadius) {
        continue;
      }
      final double verticalDistance = math.sqrt(
        math.max(
          (combinedRadius * combinedRadius) -
              (horizontalDistance * horizontalDistance),
          0,
        ),
      );
      maxY = math.min(maxY, other.yUnits - verticalDistance);
    }
    return maxY;
  }

  double distanceBetween(BubbleEntity first, BubbleEntity second) {
    return distanceBetweenCenters(
      ax: first.xUnits,
      ay: first.yUnits,
      bx: second.xUnits,
      by: second.yUnits,
    );
  }

  double distanceBetweenCenters({
    required double ax,
    required double ay,
    required double bx,
    required double by,
  }) {
    final double dx = ax - bx;
    final double dy = ay - by;
    return math.sqrt((dx * dx) + (dy * dy));
  }
}
