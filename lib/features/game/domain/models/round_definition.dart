import 'bubble_color.dart';
import 'bubble_size.dart';
import 'motion_profile.dart';
import 'scoring_profile.dart';

enum RoundSourceType { handcrafted, generated }

enum DifficultyTier { tutorial, easy, standard, hard, expert }

enum OkCountRule { exact, atLeast }

class SpawnToken {
  const SpawnToken({required this.color, required this.size});

  final BubbleColor color;
  final BubbleSize size;
}

class OkSetDefinition {
  const OkSetDefinition({
    required this.id,
    required this.color,
    required this.targetCount,
    required this.countRule,
    required this.scoreMultiplier,
  });

  final String id;
  final BubbleColor color;
  final int targetCount;
  final OkCountRule countRule;
  final double scoreMultiplier;

  bool matches(int count) {
    return switch (countRule) {
      OkCountRule.exact => count == targetCount,
      OkCountRule.atLeast => count >= targetCount,
    };
  }

  String describe() {
    final String countText = switch (countRule) {
      OkCountRule.exact => 'exactly $targetCount',
      OkCountRule.atLeast => 'at least $targetCount',
    };
    return '$countText ${color.label.toLowerCase()}';
  }
}

class RoundDefinition {
  const RoundDefinition({
    required this.id,
    required this.sourceType,
    required this.timerMs,
    required this.boardColumns,
    required this.boardRows,
    required this.allowedSizes,
    required this.okSets,
    required this.notOkSet,
    required this.difficultyTier,
    required this.scoringProfile,
    required this.spawnSequence,
    required this.motionProfile,
    this.tickMs = 16,
    this.spawnOriginXUnits,
    this.spawnOriginYUnits = 0.9,
  });

  final String id;
  final RoundSourceType sourceType;
  final int timerMs;
  final int boardColumns;
  final int boardRows;
  final List<BubbleSize> allowedSizes;
  final List<OkSetDefinition> okSets;
  final Set<BubbleColor> notOkSet;
  final DifficultyTier difficultyTier;
  final ScoringProfile scoringProfile;
  final List<SpawnToken> spawnSequence;
  final MotionProfile motionProfile;
  final int tickMs;
  final double? spawnOriginXUnits;
  final double spawnOriginYUnits;

  double get resolvedSpawnOriginXUnits => spawnOriginXUnits ?? boardColumns / 2;
  int get spawnIntervalMs => motionProfile.spawnIntervalMs;
  int get lockDelayMs => motionProfile.lockDelayMs;
  double get gravityPerTick => motionProfile.gravityPerTick(tickMs: tickMs);
  double get dragCoefficient => motionProfile.dragCoefficient;
  double get terminalVelocity => motionProfile.terminalVelocity;
  double get horizontalDriftStrength => motionProfile.horizontalDriftStrength;
}
