class ScoringProfile {
  const ScoringProfile({
    required this.okBasePointsPerBubble,
    required this.annihilationPointsPerBubble,
    required this.cleanupComboStepMultiplier,
    required this.leftoverDangerPenaltyPerBubble,
    required this.roundClearBonus,
    required this.failurePenalty,
    required this.timeRemainingBonusFactor,
  });

  final int okBasePointsPerBubble;
  final int annihilationPointsPerBubble;
  final double cleanupComboStepMultiplier;
  final int leftoverDangerPenaltyPerBubble;
  final int roundClearBonus;
  final int failurePenalty;
  final double timeRemainingBonusFactor;
}
