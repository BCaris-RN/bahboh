import '../domain/models/bubble_color.dart';
import '../domain/models/bubble_size.dart';
import '../domain/models/motion_profile.dart';
import '../domain/models/round_definition.dart';
import '../domain/models/scoring_profile.dart';
import '../../../core/constants/bahboh_scoring.dart';

// TODO(v8): Materialize seeded generated rounds through the same RoundDefinition contract.
const List<RoundDefinition> handcraftedRounds = <RoundDefinition>[
  RoundDefinition(
    id: 'round_001_intro',
    sourceType: RoundSourceType.handcrafted,
    timerMs: 45000,
    boardColumns: 8,
    boardRows: 12,
    allowedSizes: <BubbleSize>[
      BubbleSize.small,
      BubbleSize.medium,
      BubbleSize.large,
    ],
    okSets: <OkSetDefinition>[
      OkSetDefinition(
        id: 'ok_red_triplet',
        color: BubbleColor.red,
        targetCount: 3,
        countRule: OkCountRule.exact,
        scoreMultiplier: 1.0,
      ),
    ],
    notOkSet: <BubbleColor>{BubbleColor.blue, BubbleColor.indigo},
    difficultyTier: DifficultyTier.tutorial,
    scoringProfile: ScoringProfile(
      okBasePointsPerBubble: BahbohScoring.okFormationPoints,
      annihilationPointsPerBubble: BahbohScoring.annihilationPairPoints,
      cleanupComboStepMultiplier: 0.25,
      leftoverDangerPenaltyPerBubble:
          BahbohScoring.leftoverNotOkPenaltyPerBubble,
      roundClearBonus: BahbohScoring.cleanBoardBonus,
      failurePenalty: BahbohScoring.boardOverflowFailPenalty,
      timeRemainingBonusFactor: BahbohScoring.timeRemainingBonusFactor,
    ),
    motionProfile: MotionProfile.tutorial,
    spawnSequence: <SpawnToken>[
      SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.blue, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.indigo, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.orange, size: BubbleSize.medium),
      SpawnToken(color: BubbleColor.yellow, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.green, size: BubbleSize.medium),
      SpawnToken(color: BubbleColor.violet, size: BubbleSize.small),
    ],
  ),
];
