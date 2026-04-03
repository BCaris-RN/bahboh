import 'package:bahboh/core/constants/bahboh_scoring.dart';
import 'package:bahboh/features/game/domain/models/board_state.dart';
import 'package:bahboh/features/game/domain/models/bubble_color.dart';
import 'package:bahboh/features/game/domain/models/bubble_entity.dart';
import 'package:bahboh/features/game/domain/models/bubble_size.dart';
import 'package:bahboh/features/game/domain/services/round_end_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('board overflow triggers fail', () {
    const RoundEndEngine engine = RoundEndEngine();
    final RoundEndDecision decision = engine.evaluate(
      boardState: BoardState(
        columns: 6,
        rows: 6,
        lockedBubbles: const <BubbleEntity>[
          BubbleEntity(
            id: 1,
            color: BubbleColor.red,
            size: BubbleSize.small,
            xUnits: 3,
            yUnits: 0.2,
          ),
        ],
      ),
      activeBubble: null,
      timerRemainingMs: 1000,
    );

    expect(decision.status, RoundEndStatus.failure);
    expect(decision.failurePenalty, BahbohScoring.boardOverflowFailPenalty);
  });
}
