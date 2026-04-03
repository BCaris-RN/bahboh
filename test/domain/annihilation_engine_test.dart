import 'package:bahboh/features/game/domain/models/board_state.dart';
import 'package:bahboh/features/game/domain/models/bubble_color.dart';
import 'package:bahboh/features/game/domain/models/bubble_entity.dart';
import 'package:bahboh/features/game/domain/models/bubble_size.dart';
import 'package:bahboh/features/game/domain/services/annihilation_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chain annihilation rescans until no valid contacts remain', () {
    const AnnihilationEngine engine = AnnihilationEngine();
    const Set<BubbleColor> notOkSet = <BubbleColor>{
      BubbleColor.blue,
      BubbleColor.indigo,
    };

    BoardState boardState = const BoardState(
      columns: 6,
      rows: 6,
      lockedBubbles: <BubbleEntity>[
        BubbleEntity(
          id: 1,
          color: BubbleColor.blue,
          size: BubbleSize.small,
          xUnits: 2,
          yUnits: 0.40,
        ),
        BubbleEntity(
          id: 2,
          color: BubbleColor.indigo,
          size: BubbleSize.small,
          xUnits: 2,
          yUnits: 1.20,
        ),
        BubbleEntity(
          id: 3,
          color: BubbleColor.blue,
          size: BubbleSize.small,
          xUnits: 2,
          yUnits: 2.00,
        ),
        BubbleEntity(
          id: 4,
          color: BubbleColor.indigo,
          size: BubbleSize.small,
          xUnits: 2,
          yUnits: 2.80,
        ),
      ],
    );

    int removalCount = 0;
    while (true) {
      final AnnihilationStep? step = engine.resolveFirst(
        boardState: boardState,
        notOkSet: notOkSet,
      );
      if (step == null) {
        break;
      }
      removalCount += 1;
      boardState = step.boardState;
    }

    expect(removalCount, 2);
    expect(boardState.lockedBubbles, isEmpty);
  });
}
