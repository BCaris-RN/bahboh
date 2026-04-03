import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../../core/constants/bahboh_scoring.dart';
import '../data/handcrafted_rounds.dart';
import 'game_feedback_dispatcher.dart';
import '../domain/models/board_state.dart';
import '../domain/models/bubble_entity.dart';
import '../domain/models/bubble_color.dart';
import '../domain/models/bubble_fx_burst.dart';
import '../domain/models/game_phase.dart';
import '../domain/models/game_result.dart';
import '../domain/models/round_definition.dart';
import '../domain/services/annihilation_engine.dart';
import '../domain/services/lock_resolution_engine.dart';
import '../domain/services/round_end_engine.dart';
import '../domain/services/round_validator.dart';
import '../domain/services/score_engine.dart';
import '../domain/services/spawn_engine.dart';

class GameController extends ChangeNotifier {
  static const int _maxFxBursts = 12;

  GameController({
    RoundDefinition? roundDefinition,
    RoundValidator roundValidator = const RoundValidator(),
    SpawnEngine spawnEngine = const SpawnEngine(),
    LockResolutionEngine lockResolutionEngine = const LockResolutionEngine(),
    AnnihilationEngine annihilationEngine = const AnnihilationEngine(),
    ScoreEngine scoreEngine = const ScoreEngine(),
    RoundEndEngine roundEndEngine = const RoundEndEngine(),
    GameFeedbackDispatcher feedbackDispatcher = const GameFeedbackDispatcher(),
  }) : _roundValidator = roundValidator,
       _spawnEngine = spawnEngine,
       _lockResolutionEngine = lockResolutionEngine,
       _annihilationEngine = annihilationEngine,
       _scoreEngine = scoreEngine,
       _roundEndEngine = roundEndEngine,
       _feedbackDispatcher = feedbackDispatcher,
       _activeRound = roundDefinition ?? handcraftedRounds.first,
       _boardState = BoardState.empty(
         columns: (roundDefinition ?? handcraftedRounds.first).boardColumns,
         rows: (roundDefinition ?? handcraftedRounds.first).boardRows,
       ) {
    _applyRoundContract();
  }

  final RoundValidator _roundValidator;
  final SpawnEngine _spawnEngine;
  final LockResolutionEngine _lockResolutionEngine;
  final AnnihilationEngine _annihilationEngine;
  final ScoreEngine _scoreEngine;
  final RoundEndEngine _roundEndEngine;
  final GameFeedbackDispatcher _feedbackDispatcher;

  final RoundDefinition _activeRound;
  late BoardState _boardState;
  BubbleEntity? _activeBubble;
  GamePhase _phase = GamePhase.boot;
  GameResult? _gameResult;
  String _statusMessage = 'Booting round contract.';
  int _timerRemainingMs = 0;
  int _currentScore = 0;
  int _spawnCountdownMs = 0;
  int _spawnSequenceIndex = 0;
  int _nextBubbleId = 1;
  int _supportFrames = 0;
  int _carryMs = 0;
  double _dragTargetXUnits = 0;
  bool _isPaused = false;
  bool _isSoftDropping = false;
  bool _timerExpired = false;
  int _nextFxBurstId = 1;
  int _visualTick = 0;
  List<BubbleFxBurst> _fxBursts = const <BubbleFxBurst>[];

  RoundDefinition get activeRound => _activeRound;
  BoardState get boardState => _boardState;
  BubbleEntity? get activeBubble => _activeBubble;
  int get timerRemainingMs => _timerRemainingMs;
  int get currentScore => _currentScore;
  GamePhase get phase => _phase;
  bool get isPaused => _isPaused;
  bool get isSoftDropping => _isSoftDropping;
  GameResult? get gameResult => _gameResult;
  String get statusMessage => _statusMessage;
  List<BubbleFxBurst> get fxBursts =>
      List<BubbleFxBurst>.unmodifiable(_fxBursts);
  int get visualTick => _visualTick;
  int get remainingNotOkCount =>
      _countDangerBubbles(_boardState.lockedBubbles) +
      _countDangerBubbles(
        _activeBubble == null
            ? const <BubbleEntity>[]
            : <BubbleEntity>[_activeBubble!],
      );
  String get okRuleSummary => _activeRound.okSets
      .map((OkSetDefinition rule) => rule.describe())
      .join(', ');
  String get notOkRuleSummary =>
      'any ${_activeRound.notOkSet.map((BubbleColor color) => color.label.toLowerCase()).join(' / ')} contact';
  String get roundGoal =>
      'Survive until the timer ends while building OK groups and keeping danger colors apart.';

  void boot() {
    if (_phase != GamePhase.boot) {
      return;
    }
    _resetToPreRound();
    notifyListeners();
  }

  void startRound() {
    _resetForActiveRound();
    _phase = GamePhase.playing;
    _statusMessage = 'Round live. Drag the active bubble before lock.';
    _feedbackDispatcher.onRoundStart();
    _spawnIfReady();
    notifyListeners();
  }

  void restartRound() {
    startRound();
  }

  void togglePause() {
    if (_phase == GamePhase.playing) {
      _phase = GamePhase.paused;
      _isPaused = true;
      _isSoftDropping = false;
      _statusMessage = 'Paused. Timer and spawn cadence are frozen.';
    } else if (_phase == GamePhase.paused) {
      _phase = GamePhase.playing;
      _isPaused = false;
      _statusMessage = 'Round resumed.';
    }
    notifyListeners();
  }

  void updateDragPosition(double xUnits) {
    if (_phase != GamePhase.playing || _activeBubble == null) {
      return;
    }
    _dragTargetXUnits = xUnits;
    notifyListeners();
  }

  void setSoftDrop(bool enabled) {
    final bool nextValue =
        enabled && _phase == GamePhase.playing && _activeBubble != null;
    if (_isSoftDropping == nextValue) {
      return;
    }
    _isSoftDropping = nextValue;
    notifyListeners();
  }

  void tick(Duration delta) {
    if (_phase == GamePhase.boot ||
        _phase == GamePhase.preRound ||
        _phase == GamePhase.paused ||
        _phase.isTerminal) {
      return;
    }

    _carryMs += delta.inMilliseconds;
    while (_carryMs >= _activeRound.tickMs) {
      if (_phase.isTerminal) {
        _carryMs = 0;
        break;
      }
      _carryMs -= _activeRound.tickMs;
      _logicTick();
      if (_phase.isTerminal) {
        _carryMs = 0;
        break;
      }
    }
    notifyListeners();
  }

  void _applyRoundContract() {
    final List<RoundValidationIssue> issues = _roundValidator.validate(
      _activeRound,
    );
    if (issues.isNotEmpty) {
      throw ArgumentError.value(
        issues.map((RoundValidationIssue issue) => issue.message).join(' | '),
        'roundDefinition',
        'Invalid Bahboh round contract',
      );
    }
    _resetForActiveRound();
    _phase = GamePhase.boot;
    _statusMessage = 'Booting round contract.';
  }

  void _resetToPreRound() {
    _phase = GamePhase.preRound;
    _resetForActiveRound();
    _statusMessage =
        'Build ${_activeRound.okSets.first.describe()}, avoid ${_activeRound.notOkSet.map((color) => color.label.toLowerCase()).join(' / ')} contact.';
  }

  void _resetForActiveRound() {
    _boardState = BoardState.empty(
      columns: _activeRound.boardColumns,
      rows: _activeRound.boardRows,
    );
    _activeBubble = null;
    _gameResult = null;
    _timerRemainingMs = _activeRound.timerMs;
    _currentScore = 0;
    _spawnCountdownMs = 0;
    _spawnSequenceIndex = 0;
    _nextBubbleId = 1;
    _supportFrames = 0;
    _carryMs = 0;
    _dragTargetXUnits = _activeRound.resolvedSpawnOriginXUnits;
    _isPaused = false;
    _isSoftDropping = false;
    _timerExpired = false;
    _nextFxBurstId = 1;
    _visualTick = 0;
    _fxBursts = const <BubbleFxBurst>[];
  }

  void _logicTick() {
    _visualTick += 1;
    _boardState = _lockResolutionEngine.decayVisualState(_boardState);
    _fxBursts = _fxBursts
        .map((BubbleFxBurst burst) => burst.advance())
        .where((BubbleFxBurst burst) => burst.isAlive)
        .toList(growable: false);

    if (!_timerExpired) {
      _timerRemainingMs = math.max(0, _timerRemainingMs - _activeRound.tickMs);
      if (_timerRemainingMs == 0) {
        _timerExpired = true;
      }
    }

    if (_activeBubble != null) {
      _advanceActiveBubble();
      return;
    }

    if (_timerExpired) {
      _finishSuccess();
      return;
    }

    if (_spawnCountdownMs > 0) {
      _spawnCountdownMs = math.max(0, _spawnCountdownMs - _activeRound.tickMs);
      return;
    }

    _spawnIfReady();
  }

  void _advanceActiveBubble() {
    final GravityStepResult step = _lockResolutionEngine.advanceActiveBubble(
      activeBubble: _activeBubble!,
      boardState: _boardState,
      round: _activeRound,
      targetXUnits: _dragTargetXUnits,
      currentSupportFrames: _supportFrames,
      isSoftDropping: _isSoftDropping,
    );
    _activeBubble = step.bubble;
    _supportFrames = step.supportFrames;

    if (!step.shouldLock) {
      return;
    }

    _boardState = _lockResolutionEngine.lockBubble(
      boardState: _boardState,
      bubble: _activeBubble!,
    );
    _feedbackDispatcher.onLock();
    _activeBubble = null;
    _supportFrames = 0;
    _isSoftDropping = false;
    _phase = GamePhase.resolving;
    _statusMessage = 'Lock resolved. Checking OK and Not OK rules.';
    _resolveBoard();
  }

  void _spawnIfReady() {
    final SpawnAttempt attempt = _spawnEngine.spawn(
      round: _activeRound,
      boardState: _boardState,
      spawnIndex: _spawnSequenceIndex,
      bubbleId: _nextBubbleId,
    );

    if (attempt.spawnBlocked) {
      _finishFailure(
        'Spawn origin blocked.',
        failurePenalty: BahbohScoring.boardOverflowFailPenalty,
      );
      return;
    }

    _spawnSequenceIndex = attempt.nextSpawnIndex;
    _nextBubbleId += 1;
    _activeBubble = attempt.bubble;
    _dragTargetXUnits = _activeBubble!.xUnits;
    _statusMessage =
        'Guide the ${_activeBubble!.color.label.toLowerCase()} bubble into position.';
  }

  void _resolveBoard() {
    int cleanupComboIndex = 0;

    while (true) {
      final double qualityBefore = _scoreEngine.okStateQuality(
        boardState: _boardState,
        okSets: _activeRound.okSets,
      );
      final AnnihilationStep? annihilation = _annihilationEngine.resolveFirst(
        boardState: _boardState,
        notOkSet: _activeRound.notOkSet,
      );
      if (annihilation != null) {
        _boardState = annihilation.boardState;
        _registerAnnihilationBurst(annihilation.pair);
        final double qualityAfter = _scoreEngine.okStateQuality(
          boardState: _boardState,
          okSets: _activeRound.okSets,
        );
        final bool qualityImproved = qualityAfter > qualityBefore + 0.0001;
        final int scoreDelta = _scoreEngine.scoreAnnihilationPair(
          pair: annihilation.pair,
          scoringProfile: _activeRound.scoringProfile,
          comboIndex: cleanupComboIndex,
          qualityImproved: qualityImproved,
        );
        _currentScore += scoreDelta;
        cleanupComboIndex = qualityImproved ? cleanupComboIndex + 1 : 0;
        _statusMessage = qualityImproved
            ? 'Danger contact annihilated. +$scoreDelta cleanup.'
            : 'Danger contact annihilated. +$scoreDelta.';
        _feedbackDispatcher.onAnnihilation();
        continue;
      }

      final OkResolution okResolution = _scoreEngine.resolveOkGroups(
        boardState: _boardState,
        okSets: _activeRound.okSets,
        scoringProfile: _activeRound.scoringProfile,
      );
      if (okResolution.matches.isNotEmpty) {
        _boardState = okResolution.boardState;
        _currentScore += okResolution.scoreDelta;
        cleanupComboIndex = 0;
        _statusMessage = 'OK contract satisfied. +${okResolution.scoreDelta}.';
        continue;
      }
      break;
    }

    final RoundEndDecision decision = _roundEndEngine.evaluate(
      boardState: _boardState,
      activeBubble: _activeBubble,
      timerRemainingMs: _timerRemainingMs,
    );

    switch (decision.status) {
      case RoundEndStatus.failure:
        _finishFailure(
          decision.reason ?? 'Round failed.',
          failurePenalty: decision.failurePenalty,
        );
        return;
      case RoundEndStatus.success:
        _finishSuccess();
        return;
      case RoundEndStatus.none:
        _phase = GamePhase.playing;
        if (!_timerExpired) {
          _spawnCountdownMs = _activeRound.spawnIntervalMs;
        }
        return;
    }
  }

  void _finishSuccess() {
    final int leftoverPenalty = _scoreEngine.leftoverDangerPenalty(
      boardState: _boardState,
      notOkSet: _activeRound.notOkSet,
      activeBubble: _activeBubble,
      scoringProfile: _activeRound.scoringProfile,
    );
    final int completionBonus = _scoreEngine.successBonus(
      remainingNotOkCount: remainingNotOkCount,
      timerRemainingMs: _timerRemainingMs,
      scoringProfile: _activeRound.scoringProfile,
    );
    final int finalScore = math.max(
      0,
      _currentScore + completionBonus - leftoverPenalty,
    );
    _currentScore = finalScore;
    _phase = GamePhase.success;
    _gameResult = GameResult(
      didClearRound: true,
      finalScore: finalScore,
      summary:
          'Round clear. Bonus $completionBonus, leftover penalty $leftoverPenalty.',
    );
    _statusMessage = _gameResult!.summary;
    _isSoftDropping = false;
    _feedbackDispatcher.onRoundEnd(success: true);
  }

  void _finishFailure(String reason, {required int failurePenalty}) {
    final int leftoverPenalty = _scoreEngine.leftoverDangerPenalty(
      boardState: _boardState,
      notOkSet: _activeRound.notOkSet,
      activeBubble: _activeBubble,
      scoringProfile: _activeRound.scoringProfile,
    );
    final int finalScore = math.max(
      0,
      _currentScore - failurePenalty - leftoverPenalty,
    );
    _currentScore = finalScore;
    _phase = GamePhase.failure;
    _gameResult = GameResult(
      didClearRound: false,
      finalScore: finalScore,
      summary:
          '$reason Failure penalty $failurePenalty, leftover penalty $leftoverPenalty.',
    );
    _statusMessage = _gameResult!.summary;
    _isSoftDropping = false;
    _feedbackDispatcher.onRoundEnd(success: false);
  }

  void _registerAnnihilationBurst(AnnihilationPair pair) {
    final double averageRadius =
        (pair.first.radiusUnits + pair.second.radiusUnits) / 2;
    final double normalizedEnergy = (averageRadius / 0.56).clamp(0.82, 1.35);
    final List<BubbleFxBurst> nextBursts = <BubbleFxBurst>[
      ..._fxBursts,
      BubbleFxBurst(
        id: _nextFxBurstId,
        xUnits: pair.centerXUnits,
        yUnits: pair.centerYUnits,
        primaryColor: pair.first.color,
        secondaryColor: pair.second.color,
        energy: normalizedEnergy,
      ),
    ];
    _fxBursts = nextBursts.length <= _maxFxBursts
        ? nextBursts
        : nextBursts.sublist(nextBursts.length - _maxFxBursts);
    _nextFxBurstId += 1;
  }

  int _countDangerBubbles(Iterable<BubbleEntity> bubbles) {
    return bubbles.where((BubbleEntity bubble) {
      return _activeRound.notOkSet.contains(bubble.color);
    }).length;
  }
}
