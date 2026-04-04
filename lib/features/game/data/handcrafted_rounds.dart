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
    shieldActivationProgress: 0.80,
    warningCountdownMs: 30000,
  ),
  RoundDefinition(
    id: 'round_002_helix',
    sourceType: RoundSourceType.handcrafted,
    timerMs: 60000,
    boardColumns: 10,
    boardRows: 14,
    allowedSizes: <BubbleSize>[
      BubbleSize.small,
      BubbleSize.medium,
      BubbleSize.large,
    ],
    okSets: <OkSetDefinition>[
      OkSetDefinition(
        id: 'ok_green_doublet',
        color: BubbleColor.green,
        targetCount: 2,
        countRule: OkCountRule.exact,
        scoreMultiplier: 1.35,
      ),
    ],
    notOkSet: <BubbleColor>{
      BubbleColor.red,
      BubbleColor.blue,
      BubbleColor.orange,
      BubbleColor.yellow,
      BubbleColor.indigo,
      BubbleColor.violet,
    },
    difficultyTier: DifficultyTier.easy,
    scoringProfile: ScoringProfile(
      okBasePointsPerBubble: BahbohScoring.okFormationPoints,
      annihilationPointsPerBubble: BahbohScoring.annihilationPairPoints,
      cleanupComboStepMultiplier: 0.2,
      leftoverDangerPenaltyPerBubble:
          BahbohScoring.leftoverNotOkPenaltyPerBubble,
      roundClearBonus: BahbohScoring.cleanBoardBonus * 2,
      failurePenalty: BahbohScoring.boardOverflowFailPenalty,
      timeRemainingBonusFactor: BahbohScoring.timeRemainingBonusFactor,
    ),
    motionProfile: MotionProfile.easy,
    spawnSequence: <SpawnToken>[
      SpawnToken(color: BubbleColor.green, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.blue, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.green, size: BubbleSize.medium),
      SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.green, size: BubbleSize.large),
      SpawnToken(color: BubbleColor.yellow, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.green, size: BubbleSize.small),
      SpawnToken(color: BubbleColor.violet, size: BubbleSize.medium),
      SpawnToken(color: BubbleColor.green, size: BubbleSize.small),
    ],
    shieldActivationProgress: 0.80,
    warningCountdownMs: 30000,
  ),
];
