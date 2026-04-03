import '../models/board_state.dart';
import '../models/bubble_color.dart';
import '../models/bubble_entity.dart';
import 'lock_resolution_engine.dart';

class AnnihilationPair {
  const AnnihilationPair({required this.first, required this.second});

  final BubbleEntity first;
  final BubbleEntity second;

  double get centerXUnits => (first.xUnits + second.xUnits) / 2;
  double get centerYUnits => (first.yUnits + second.yUnits) / 2;
}

class AnnihilationStep {
  const AnnihilationStep({required this.boardState, required this.pair});

  final BoardState boardState;
  final AnnihilationPair pair;
}

class AnnihilationEngine {
  const AnnihilationEngine({
    this.lockResolutionEngine = const LockResolutionEngine(),
  });

  final LockResolutionEngine lockResolutionEngine;

  AnnihilationStep? resolveFirst({
    required BoardState boardState,
    required Set<BubbleColor> notOkSet,
  }) {
    final List<AnnihilationPair> candidates = <AnnihilationPair>[];
    for (
      int firstIndex = 0;
      firstIndex < boardState.lockedBubbles.length;
      firstIndex += 1
    ) {
      final BubbleEntity first = boardState.lockedBubbles[firstIndex];
      if (!notOkSet.contains(first.color)) {
        continue;
      }
      for (
        int secondIndex = firstIndex + 1;
        secondIndex < boardState.lockedBubbles.length;
        secondIndex += 1
      ) {
        final BubbleEntity second = boardState.lockedBubbles[secondIndex];
        if (!notOkSet.contains(second.color) ||
            !lockResolutionEngine.isContact(first, second)) {
          continue;
        }
        final BubbleEntity orderedFirst = first.id <= second.id
            ? first
            : second;
        final BubbleEntity orderedSecond = first.id <= second.id
            ? second
            : first;
        candidates.add(
          AnnihilationPair(first: orderedFirst, second: orderedSecond),
        );
      }
    }

    if (candidates.isEmpty) {
      return null;
    }

    candidates.sort((AnnihilationPair left, AnnihilationPair right) {
      final int yCompare = left.centerYUnits.compareTo(right.centerYUnits);
      if (yCompare != 0) {
        return yCompare;
      }
      final int xCompare = left.centerXUnits.compareTo(right.centerXUnits);
      if (xCompare != 0) {
        return xCompare;
      }
      final int firstIdCompare = left.first.id.compareTo(right.first.id);
      if (firstIdCompare != 0) {
        return firstIdCompare;
      }
      return left.second.id.compareTo(right.second.id);
    });

    final AnnihilationPair selected = candidates.first;
    final BoardState nextBoard = boardState.copyWith(
      lockedBubbles: boardState.lockedBubbles
          .where(
            (BubbleEntity bubble) =>
                bubble.id != selected.first.id &&
                bubble.id != selected.second.id,
          )
          .toList(growable: false),
    );

    return AnnihilationStep(
      boardState: lockResolutionEngine.settle(nextBoard),
      pair: selected,
    );
  }
}
