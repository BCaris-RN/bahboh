import 'package:bahboh/core/constants/bahboh_scoring.dart';
import 'package:bahboh/features/game/application/game_controller.dart';
import 'package:bahboh/features/game/domain/models/bubble_entity.dart';
import 'package:bahboh/features/game/domain/models/bubble_color.dart';
import 'package:bahboh/features/game/domain/models/bubble_size.dart';
import 'package:bahboh/features/game/domain/models/game_phase.dart';
import 'package:bahboh/features/game/domain/models/motion_profile.dart';
import 'package:bahboh/features/game/domain/models/round_definition.dart';
import 'package:bahboh/features/game/domain/models/scoring_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('controller exposes boot then preRound', () {
    final GameController controller = GameController();

    expect(controller.phase, GamePhase.boot);

    controller.boot();

    expect(controller.phase, GamePhase.preRound);
  });

  test('active bubble drag clamps within board bounds', () {
    final GameController controller = GameController(
      roundDefinition: _controlRound(
        id: 'drag_bounds',
        spawnSequence: const <SpawnToken>[
          SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
        ],
      ),
    )..boot();

    controller.startRound();
    controller.updateDragPosition(-100);
    controller.tick(const Duration(milliseconds: 16));

    expect(controller.activeBubble, isNotNull);
    expect(
      controller.activeBubble!.xUnits,
      closeTo(controller.activeBubble!.radiusUnits, 0.0001),
    );

    controller.updateDragPosition(100);
    controller.tick(const Duration(milliseconds: 16));

    expect(
      controller.activeBubble!.xUnits,
      closeTo(
        controller.boardState.columns - controller.activeBubble!.radiusUnits,
        0.0001,
      ),
    );
  });

  test('bubble locks on floor', () {
    final GameController controller = GameController(
      roundDefinition: _controlRound(
        id: 'floor_lock',
        spawnSequence: const <SpawnToken>[
          SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
        ],
      ),
    )..boot();

    controller.startRound();
    _pumpUntil(
      controller,
      () =>
          controller.phase == GamePhase.playing &&
          controller.activeBubble == null &&
          controller.boardState.lockedBubbles.length == 1,
    );

    expect(controller.boardState.lockedBubbles, hasLength(1));
    final BubbleEntity lockedBubble =
        controller.boardState.lockedBubbles.single;
    expect(
      lockedBubble.yUnits,
      closeTo(controller.boardState.rows - lockedBubble.radiusUnits, 0.01),
    );
  });

  test('bubble locks on an existing stack', () {
    final GameController controller = GameController(
      roundDefinition: _controlRound(
        id: 'stack_lock',
        spawnSequence: const <SpawnToken>[
          SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
          SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
        ],
      ),
    )..boot();

    controller.startRound();
    _pumpUntil(
      controller,
      () =>
          controller.phase == GamePhase.playing &&
          controller.activeBubble == null &&
          controller.boardState.lockedBubbles.length == 2,
    );

    expect(controller.boardState.lockedBubbles, hasLength(2));
    final List<double> lockedYs = controller.boardState.lockedBubbles
        .map((bubble) => bubble.yUnits)
        .toList(growable: false);
    expect(lockedYs[0], greaterThan(lockedYs[1]));
  });

  test('any Not OK plus any Not OK annihilates deterministically', () {
    final GameController controller = GameController(
      roundDefinition: _controlRound(
        id: 'danger_pair',
        spawnSequence: const <SpawnToken>[
          SpawnToken(color: BubbleColor.blue, size: BubbleSize.small),
          SpawnToken(color: BubbleColor.indigo, size: BubbleSize.small),
        ],
      ),
    )..boot();

    controller.startRound();
    _pumpUntil(
      controller,
      () =>
          controller.phase == GamePhase.playing &&
          controller.activeBubble == null &&
          controller.remainingNotOkCount == 0,
    );

    expect(controller.remainingNotOkCount, 0);
    expect(controller.boardState.lockedBubbles, isEmpty);
    expect(controller.currentScore, 20);
    expect(controller.fxBursts, isNotEmpty);
  });

  test('repeated chain annihilation scan clears the board', () {
    final GameController controller = GameController(
      roundDefinition: _controlRound(
        id: 'danger_chain',
        spawnSequence: const <SpawnToken>[
          SpawnToken(color: BubbleColor.blue, size: BubbleSize.small),
          SpawnToken(color: BubbleColor.indigo, size: BubbleSize.small),
          SpawnToken(color: BubbleColor.blue, size: BubbleSize.small),
          SpawnToken(color: BubbleColor.indigo, size: BubbleSize.small),
        ],
      ),
    )..boot();

    controller.startRound();
    _pumpUntil(
      controller,
      () =>
          controller.phase == GamePhase.playing &&
          controller.activeBubble == null &&
          controller.remainingNotOkCount == 0 &&
          controller.boardState.lockedBubbles.isEmpty,
    );

    expect(controller.remainingNotOkCount, 0);
    expect(controller.boardState.lockedBubbles, isEmpty);
    expect(controller.currentScore, 20);
  });

  test('pause freezes timer, gravity, and lock progression until resume', () {
    final GameController controller = GameController(
      roundDefinition: _controlRound(
        id: 'pause_freeze',
        spawnSequence: const <SpawnToken>[
          SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
        ],
      ),
    )..boot();

    controller.startRound();
    controller.tick(const Duration(milliseconds: 32));
    final int timerBeforePause = controller.timerRemainingMs;
    final double yBeforePause = controller.activeBubble!.yUnits;

    controller.togglePause();
    controller.tick(const Duration(milliseconds: 320));

    expect(controller.timerRemainingMs, timerBeforePause);
    expect(controller.activeBubble!.yUnits, yBeforePause);

    controller.togglePause();
    controller.tick(const Duration(milliseconds: 16));

    expect(controller.timerRemainingMs, lessThan(timerBeforePause));
    expect(controller.activeBubble!.yUnits, greaterThan(yBeforePause));
  });

  test('soft drop accelerates descent while held', () {
    final RoundDefinition round = _controlRound(
      id: 'soft_drop_compare',
      spawnSequence: const <SpawnToken>[
        SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
      ],
    );
    final GameController baselineController = GameController(
      roundDefinition: round,
    )..boot();
    final GameController softDropController = GameController(
      roundDefinition: round,
    )..boot();

    baselineController.startRound();
    softDropController.startRound();
    final double baselineStartY = baselineController.activeBubble!.yUnits;
    final double softDropStartY = softDropController.activeBubble!.yUnits;

    baselineController.tick(const Duration(milliseconds: 16));
    softDropController.setSoftDrop(true);
    softDropController.tick(const Duration(milliseconds: 16));

    final double baselineDelta =
        baselineController.activeBubble!.yUnits - baselineStartY;
    final double softDropDelta =
        softDropController.activeBubble!.yUnits - softDropStartY;

    expect(softDropController.isSoftDropping, isTrue);
    expect(softDropDelta, greaterThan(baselineDelta));
  });

  test('timer expiry ends the round after the current deterministic step', () {
    final GameController controller = GameController(
      roundDefinition: _shortTimerRound(),
    )..boot();

    controller.startRound();
    controller.tick(const Duration(milliseconds: 4000));

    expect(controller.phase, GamePhase.success);
    expect(controller.gameResult, isNotNull);
    expect(controller.currentScore, 75);
  });

  test('restart returns to a clean initial state', () {
    final GameController controller = GameController(
      roundDefinition: _shortTimerRound(),
    )..boot();

    controller.startRound();
    controller.tick(const Duration(milliseconds: 4000));
    expect(controller.phase, GamePhase.success);

    controller.restartRound();

    expect(controller.phase, GamePhase.playing);
    expect(controller.activeBubble, isNotNull);
    expect(controller.currentScore, 0);
    expect(controller.timerRemainingMs, controller.activeRound.timerMs);
    expect(controller.boardState.lockedBubbles, isEmpty);
    expect(controller.gameResult, isNull);
    expect(controller.isPaused, isFalse);
    expect(controller.isSoftDropping, isFalse);
    expect(controller.fxBursts, isEmpty);
    expect(controller.visualTick, 0);
  });
}

void _pumpUntil(
  GameController controller,
  bool Function() predicate, {
  int maxTicks = 1000,
}) {
  for (int tick = 0; tick < maxTicks; tick += 1) {
    if (predicate()) {
      return;
    }
    controller.tick(const Duration(milliseconds: 16));
  }

  fail('Controller did not reach the requested state within $maxTicks ticks.');
}

RoundDefinition _controlRound({
  required String id,
  required List<SpawnToken> spawnSequence,
}) {
  return RoundDefinition(
    id: id,
    sourceType: RoundSourceType.handcrafted,
    timerMs: 8000,
    boardColumns: 6,
    boardRows: 6,
    allowedSizes: const <BubbleSize>[BubbleSize.small],
    okSets: const <OkSetDefinition>[
      OkSetDefinition(
        id: 'ok_green_pair',
        color: BubbleColor.green,
        targetCount: 2,
        countRule: OkCountRule.exact,
        scoreMultiplier: 1.0,
      ),
    ],
    notOkSet: const <BubbleColor>{BubbleColor.blue, BubbleColor.indigo},
    difficultyTier: DifficultyTier.tutorial,
    scoringProfile: const ScoringProfile(
      okBasePointsPerBubble: BahbohScoring.okFormationPoints,
      annihilationPointsPerBubble: BahbohScoring.annihilationPairPoints,
      cleanupComboStepMultiplier: 0.25,
      leftoverDangerPenaltyPerBubble:
          BahbohScoring.leftoverNotOkPenaltyPerBubble,
      roundClearBonus: BahbohScoring.cleanBoardBonus,
      failurePenalty: BahbohScoring.boardOverflowFailPenalty,
      timeRemainingBonusFactor: BahbohScoring.timeRemainingBonusFactor,
    ),
    motionProfile: _testMotionProfile,
    spawnSequence: spawnSequence,
  );
}

RoundDefinition _shortTimerRound() {
  return RoundDefinition(
    id: 'round_test_short_timer',
    sourceType: RoundSourceType.handcrafted,
    timerMs: 250,
    boardColumns: 6,
    boardRows: 6,
    allowedSizes: const <BubbleSize>[BubbleSize.small],
    okSets: const <OkSetDefinition>[
      OkSetDefinition(
        id: 'ok_green_pair',
        color: BubbleColor.green,
        targetCount: 2,
        countRule: OkCountRule.exact,
        scoreMultiplier: 1.0,
      ),
    ],
    notOkSet: const <BubbleColor>{BubbleColor.blue, BubbleColor.indigo},
    difficultyTier: DifficultyTier.tutorial,
    scoringProfile: const ScoringProfile(
      okBasePointsPerBubble: BahbohScoring.okFormationPoints,
      annihilationPointsPerBubble: BahbohScoring.annihilationPairPoints,
      cleanupComboStepMultiplier: 0.25,
      leftoverDangerPenaltyPerBubble:
          BahbohScoring.leftoverNotOkPenaltyPerBubble,
      roundClearBonus: BahbohScoring.cleanBoardBonus,
      failurePenalty: BahbohScoring.boardOverflowFailPenalty,
      timeRemainingBonusFactor: BahbohScoring.timeRemainingBonusFactor,
    ),
    motionProfile: const MotionProfile(
      gravityScale: 9.0,
      dragCoefficient: 0.02,
      terminalVelocity: 0.30,
      spawnIntervalMs: 120,
      horizontalDriftStrength: 0,
      lockDelayMs: 32,
    ),
    spawnSequence: const <SpawnToken>[
      SpawnToken(color: BubbleColor.red, size: BubbleSize.small),
    ],
  );
}

const MotionProfile _testMotionProfile = MotionProfile(
  gravityScale: 7.5,
  dragCoefficient: 0.03,
  terminalVelocity: 0.24,
  spawnIntervalMs: 180,
  horizontalDriftStrength: 0,
  lockDelayMs: 32,
);
