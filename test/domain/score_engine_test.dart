import 'package:bahboh/core/constants/bahboh_scoring.dart';
import 'package:bahboh/features/game/domain/models/board_state.dart';
import 'package:bahboh/features/game/domain/models/bubble_color.dart';
import 'package:bahboh/features/game/domain/models/bubble_entity.dart';
import 'package:bahboh/features/game/domain/models/bubble_size.dart';
import 'package:bahboh/features/game/domain/models/round_definition.dart';
import 'package:bahboh/features/game/domain/models/scoring_profile.dart';
import 'package:bahboh/features/game/domain/services/annihilation_engine.dart';
import 'package:bahboh/features/game/domain/services/score_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ScoreEngine scoreEngine = ScoreEngine();
  const ScoringProfile scoringProfile = ScoringProfile(
    okBasePointsPerBubble: BahbohScoring.okFormationPoints,
    annihilationPointsPerBubble: BahbohScoring.annihilationPairPoints,
    cleanupComboStepMultiplier: 0.25,
    leftoverDangerPenaltyPerBubble: BahbohScoring.leftoverNotOkPenaltyPerBubble,
    roundClearBonus: BahbohScoring.cleanBoardBonus,
    failurePenalty: BahbohScoring.boardOverflowFailPenalty,
    timeRemainingBonusFactor: BahbohScoring.timeRemainingBonusFactor,
  );

  test('OK formations score as the primary driver', () {
    final OkSetDefinition rule = OkSetDefinition(
      id: 'ok_red_pair',
      color: BubbleColor.red,
      targetCount: 2,
      countRule: OkCountRule.exact,
      scoreMultiplier: 1.0,
    );

    final OkGroupMatch match = OkGroupMatch(
      rule: rule,
      bubbles: const <BubbleEntity>[
        BubbleEntity(
          id: 1,
          color: BubbleColor.red,
          size: BubbleSize.small,
          xUnits: 1,
          yUnits: 1,
        ),
        BubbleEntity(
          id: 2,
          color: BubbleColor.red,
          size: BubbleSize.small,
          xUnits: 2,
          yUnits: 1,
        ),
      ],
    );

    expect(
      scoreEngine.scoreOkGroup(match: match, scoringProfile: scoringProfile),
      BahbohScoring.okFormationPoints,
    );
  });

  test('annihilation cleanup stays modest', () {
    final AnnihilationPair pair = AnnihilationPair(
      first: const BubbleEntity(
        id: 1,
        color: BubbleColor.blue,
        size: BubbleSize.small,
        xUnits: 1,
        yUnits: 1,
      ),
      second: const BubbleEntity(
        id: 2,
        color: BubbleColor.indigo,
        size: BubbleSize.small,
        xUnits: 1,
        yUnits: 1.5,
      ),
    );

    expect(
      scoreEngine.scoreAnnihilationPair(
        pair: pair,
        scoringProfile: scoringProfile,
        comboIndex: 0,
        qualityImproved: true,
      ),
      BahbohScoring.annihilationPairPoints,
    );
  });

  test('round-end penalty calculation is deterministic', () {
    final BoardState boardState = BoardState(
      columns: 6,
      rows: 6,
      lockedBubbles: const <BubbleEntity>[
        BubbleEntity(
          id: 1,
          color: BubbleColor.blue,
          size: BubbleSize.small,
          xUnits: 1,
          yUnits: 1,
        ),
        BubbleEntity(
          id: 2,
          color: BubbleColor.indigo,
          size: BubbleSize.small,
          xUnits: 2,
          yUnits: 1,
        ),
      ],
    );

    expect(
      scoreEngine.leftoverDangerPenalty(
        boardState: boardState,
        notOkSet: const <BubbleColor>{BubbleColor.blue, BubbleColor.indigo},
        activeBubble: const BubbleEntity(
          id: 3,
          color: BubbleColor.blue,
          size: BubbleSize.small,
          xUnits: 3,
          yUnits: 1,
        ),
        scoringProfile: scoringProfile,
      ),
      45,
    );
    expect(
      scoreEngine.cleanBoardBonus(remainingNotOkCount: 0),
      BahbohScoring.cleanBoardBonus,
    );
    expect(
      scoreEngine.timeRemainingBonus(
        timerRemainingMs: 5000,
        scoringProfile: scoringProfile,
      ),
      500,
    );
    expect(
      scoreEngine.successBonus(
        remainingNotOkCount: 0,
        timerRemainingMs: 5000,
        scoringProfile: scoringProfile,
      ),
      575,
    );
    expect(scoreEngine.failurePenalty(remainingNotOkCount: 3), 195);
  });
}
