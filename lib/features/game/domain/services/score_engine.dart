import 'dart:math' as math;

import '../../../../core/constants/bahboh_scoring.dart';
import '../models/board_state.dart';
import '../models/bubble_color.dart';
import '../models/bubble_entity.dart';
import '../models/round_definition.dart';
import '../models/scoring_profile.dart';
import 'annihilation_engine.dart';
import 'lock_resolution_engine.dart';

class OkGroupMatch {
  const OkGroupMatch({required this.rule, required this.bubbles});

  final OkSetDefinition rule;
  final List<BubbleEntity> bubbles;
}

class OkResolution {
  const OkResolution({
    required this.boardState,
    required this.matches,
    required this.scoreDelta,
  });

  final BoardState boardState;
  final List<OkGroupMatch> matches;
  final int scoreDelta;
}

class ScoreEngine {
  const ScoreEngine({this.lockResolutionEngine = const LockResolutionEngine()});

  final LockResolutionEngine lockResolutionEngine;

  OkResolution resolveOkGroups({
    required BoardState boardState,
    required List<OkSetDefinition> okSets,
    required ScoringProfile scoringProfile,
  }) {
    final List<_ColorComponent> components = _buildComponents(boardState);
    final Set<int> claimedIds = <int>{};
    final List<OkGroupMatch> matches = <OkGroupMatch>[];

    for (final OkSetDefinition rule in okSets) {
      for (final _ColorComponent component in components) {
        if (component.color != rule.color) {
          continue;
        }
        if (component.bubbles.any(
          (BubbleEntity bubble) => claimedIds.contains(bubble.id),
        )) {
          continue;
        }
        if (!rule.matches(component.bubbles.length)) {
          continue;
        }
        claimedIds.addAll(
          component.bubbles.map((BubbleEntity bubble) => bubble.id),
        );
        matches.add(OkGroupMatch(rule: rule, bubbles: component.bubbles));
      }
    }

    if (matches.isEmpty) {
      return OkResolution(
        boardState: boardState,
        matches: const [],
        scoreDelta: 0,
      );
    }

    int scoreDelta = 0;
    final Set<int> removedIds = <int>{};
    for (final OkGroupMatch match in matches) {
      scoreDelta += scoreOkGroup(match: match, scoringProfile: scoringProfile);
      removedIds.addAll(match.bubbles.map((BubbleEntity bubble) => bubble.id));
    }

    final BoardState reducedBoard = boardState.copyWith(
      lockedBubbles: boardState.lockedBubbles
          .where((BubbleEntity bubble) => !removedIds.contains(bubble.id))
          .toList(growable: false),
    );

    return OkResolution(
      boardState: lockResolutionEngine.settle(reducedBoard),
      matches: matches,
      scoreDelta: scoreDelta,
    );
  }

  int scoreOkGroup({
    required OkGroupMatch match,
    required ScoringProfile scoringProfile,
  }) {
    return (scoringProfile.okBasePointsPerBubble * match.rule.scoreMultiplier)
        .round();
  }

  int scoreAnnihilationPair({
    required AnnihilationPair pair,
    required ScoringProfile scoringProfile,
    required int comboIndex,
    required bool qualityImproved,
  }) {
    final int baseScore = scoringProfile.annihilationPointsPerBubble;
    if (!qualityImproved || comboIndex == 0) {
      return baseScore;
    }
    return baseScore +
        (baseScore * comboIndex * scoringProfile.cleanupComboStepMultiplier)
            .round();
  }

  double okStateQuality({
    required BoardState boardState,
    required List<OkSetDefinition> okSets,
  }) {
    final List<_ColorComponent> components = _buildComponents(boardState);
    double total = 0;
    for (final OkSetDefinition rule in okSets) {
      int largest = 0;
      for (final _ColorComponent component in components) {
        if (component.color != rule.color) {
          continue;
        }
        largest = math.max(largest, component.bubbles.length);
      }
      total +=
          (math.min(largest, rule.targetCount) / rule.targetCount) *
          rule.scoreMultiplier;
    }
    return total;
  }

  int leftoverDangerPenalty({
    required BoardState boardState,
    required Set<BubbleColor> notOkSet,
    BubbleEntity? activeBubble,
    required ScoringProfile scoringProfile,
  }) {
    final List<BubbleEntity> remaining = <BubbleEntity>[
      ...boardState.lockedBubbles,
    ];
    if (activeBubble != null) {
      remaining.add(activeBubble);
    }

    int total = 0;
    for (final BubbleEntity bubble in remaining) {
      if (!notOkSet.contains(bubble.color)) {
        continue;
      }
      total += scoringProfile.leftoverDangerPenaltyPerBubble;
    }
    return total;
  }

  int cleanBoardBonus({required int remainingNotOkCount}) {
    return remainingNotOkCount == 0 ? BahbohScoring.cleanBoardBonus : 0;
  }

  int timeRemainingBonus({
    required int timerRemainingMs,
    required ScoringProfile scoringProfile,
  }) {
    return (timerRemainingMs * scoringProfile.timeRemainingBonusFactor).round();
  }

  int successBonus({
    required int remainingNotOkCount,
    required int timerRemainingMs,
    required ScoringProfile scoringProfile,
  }) {
    return cleanBoardBonus(remainingNotOkCount: remainingNotOkCount) +
        timeRemainingBonus(
          timerRemainingMs: timerRemainingMs,
          scoringProfile: scoringProfile,
        );
  }

  int failurePenalty({required int remainingNotOkCount}) {
    return BahbohScoring.boardOverflowFailPenalty +
        (remainingNotOkCount * BahbohScoring.leftoverNotOkPenaltyPerBubble);
  }

  List<_ColorComponent> _buildComponents(BoardState boardState) {
    final Set<int> visited = <int>{};
    final List<_ColorComponent> components = <_ColorComponent>[];

    for (final BubbleEntity bubble in boardState.lockedBubbles) {
      if (visited.contains(bubble.id)) {
        continue;
      }
      final List<BubbleEntity> stack = <BubbleEntity>[bubble];
      final List<BubbleEntity> component = <BubbleEntity>[];
      visited.add(bubble.id);

      while (stack.isNotEmpty) {
        final BubbleEntity current = stack.removeLast();
        component.add(current);

        for (final BubbleEntity other in boardState.lockedBubbles) {
          if (visited.contains(other.id) || other.color != current.color) {
            continue;
          }
          if (!lockResolutionEngine.isContact(current, other)) {
            continue;
          }
          visited.add(other.id);
          stack.add(other);
        }
      }

      components.add(_ColorComponent(color: bubble.color, bubbles: component));
    }

    return components;
  }
}

class _ColorComponent {
  const _ColorComponent({required this.color, required this.bubbles});

  final BubbleColor color;
  final List<BubbleEntity> bubbles;
}
