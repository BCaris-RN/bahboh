import '../models/board_state.dart';
import '../models/bubble_entity.dart';
import '../../../../core/constants/bahboh_scoring.dart';

enum RoundEndStatus { none, success, failure }

class RoundEndDecision {
  const RoundEndDecision({
    required this.status,
    this.reason,
    this.failurePenalty = 0,
  });

  final RoundEndStatus status;
  final String? reason;
  final int failurePenalty;
}

class RoundEndEngine {
  const RoundEndEngine();

  RoundEndDecision evaluate({
    required BoardState boardState,
    required BubbleEntity? activeBubble,
    required int timerRemainingMs,
    bool spawnBlocked = false,
  }) {
    if (boardState.isOverflowing) {
      return const RoundEndDecision(
        status: RoundEndStatus.failure,
        reason: 'The stack overflowed above the top boundary.',
        failurePenalty: BahbohScoring.boardOverflowFailPenalty,
      );
    }
    if (spawnBlocked) {
      return const RoundEndDecision(
        status: RoundEndStatus.failure,
        reason: 'The spawn origin is blocked.',
        failurePenalty: BahbohScoring.boardOverflowFailPenalty,
      );
    }
    if (timerRemainingMs <= 0 && activeBubble == null) {
      return const RoundEndDecision(status: RoundEndStatus.success);
    }
    return const RoundEndDecision(status: RoundEndStatus.none);
  }
}
