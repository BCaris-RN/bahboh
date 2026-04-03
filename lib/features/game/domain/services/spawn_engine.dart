import '../models/board_state.dart';
import '../models/bubble_entity.dart';
import '../models/round_definition.dart';
import 'lock_resolution_engine.dart';

class SpawnAttempt {
  const SpawnAttempt({
    required this.nextSpawnIndex,
    this.bubble,
    this.spawnBlocked = false,
  });

  final BubbleEntity? bubble;
  final int nextSpawnIndex;
  final bool spawnBlocked;
}

class SpawnEngine {
  const SpawnEngine({this.lockResolutionEngine = const LockResolutionEngine()});

  final LockResolutionEngine lockResolutionEngine;

  SpawnAttempt spawn({
    required RoundDefinition round,
    required BoardState boardState,
    required int spawnIndex,
    required int bubbleId,
  }) {
    final SpawnToken token =
        round.spawnSequence[spawnIndex % round.spawnSequence.length];
    final double radius = token.size.radiusUnits;
    final double spawnX = round.resolvedSpawnOriginXUnits;
    final double spawnY = round.spawnOriginYUnits < radius
        ? radius
        : round.spawnOriginYUnits;

    final bool canSpawn = lockResolutionEngine.canSpawn(
      boardState: boardState,
      xUnits: spawnX,
      yUnits: spawnY,
      radiusUnits: radius,
    );

    if (!canSpawn) {
      return SpawnAttempt(nextSpawnIndex: spawnIndex, spawnBlocked: true);
    }

    return SpawnAttempt(
      nextSpawnIndex: spawnIndex + 1,
      bubble: BubbleEntity(
        id: bubbleId,
        color: token.color,
        size: token.size,
        xUnits: spawnX,
        yUnits: spawnY,
      ),
    );
  }
}
