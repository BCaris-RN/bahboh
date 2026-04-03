import '../models/round_definition.dart';

class RoundValidationIssue {
  const RoundValidationIssue(this.message);

  final String message;

  @override
  String toString() => message;
}

class RoundValidator {
  const RoundValidator();

  List<RoundValidationIssue> validate(RoundDefinition round) {
    final List<RoundValidationIssue> issues = <RoundValidationIssue>[];

    if (round.id.trim().isEmpty) {
      issues.add(const RoundValidationIssue('Round id must not be empty.'));
    }
    if (round.timerMs <= 0) {
      issues.add(const RoundValidationIssue('Round timer must be positive.'));
    }
    if (round.boardColumns < 4 || round.boardRows < 6) {
      issues.add(
        const RoundValidationIssue(
          'Board dimensions must allow a playable field.',
        ),
      );
    }
    if (round.allowedSizes.isEmpty) {
      issues.add(
        const RoundValidationIssue(
          'Round must allow at least one bubble size.',
        ),
      );
    }
    if (round.okSets.isEmpty) {
      issues.add(
        const RoundValidationIssue('Round must define at least one OK set.'),
      );
    }
    if (round.notOkSet.length < 2) {
      issues.add(
        const RoundValidationIssue(
          'Round notOkSet must contain at least two danger colors.',
        ),
      );
    }
    if (round.spawnIntervalMs <= 0) {
      issues.add(
        const RoundValidationIssue('Round spawn interval must be positive.'),
      );
    }
    if (round.motionProfile.gravityScale <= 0) {
      issues.add(
        const RoundValidationIssue('Round gravityScale must be positive.'),
      );
    }
    if (round.motionProfile.dragCoefficient < 0 ||
        round.motionProfile.dragCoefficient >= 1) {
      issues.add(
        const RoundValidationIssue(
          'Round dragCoefficient must be within [0, 1).',
        ),
      );
    }
    if (round.motionProfile.terminalVelocity <= 0) {
      issues.add(
        const RoundValidationIssue('Round terminalVelocity must be positive.'),
      );
    }
    if (round.motionProfile.horizontalDriftStrength < 0) {
      issues.add(
        const RoundValidationIssue(
          'Round horizontalDriftStrength must not be negative.',
        ),
      );
    }
    if (round.lockDelayMs <= 0) {
      issues.add(
        const RoundValidationIssue('Round lock delay must be positive.'),
      );
    }
    if (round.spawnSequence.isEmpty) {
      issues.add(
        const RoundValidationIssue(
          'Round must provide at least one handcrafted spawn token.',
        ),
      );
    }

    for (final OkSetDefinition okSet in round.okSets) {
      if (okSet.id.trim().isEmpty) {
        issues.add(const RoundValidationIssue('OK set id must not be empty.'));
      }
      if (okSet.targetCount < 2) {
        issues.add(
          RoundValidationIssue(
            'OK set ${okSet.id} must target at least two bubbles.',
          ),
        );
      }
      if (okSet.scoreMultiplier <= 0) {
        issues.add(
          RoundValidationIssue(
            'OK set ${okSet.id} must use a positive score multiplier.',
          ),
        );
      }
    }

    for (final SpawnToken token in round.spawnSequence) {
      if (!round.allowedSizes.contains(token.size)) {
        issues.add(
          RoundValidationIssue(
            'Spawn sequence contains size ${token.size.name} that is not allowed.',
          ),
        );
      }
    }

    return issues;
  }
}
