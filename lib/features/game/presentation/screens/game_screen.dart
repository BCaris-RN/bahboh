import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/bahboh_constants.dart';
import '../../../../core/theme/bahboh_theme.dart';
import '../../application/game_controller.dart';
import '../../domain/models/game_phase.dart';
import '../widgets/game_board.dart';
import '../widgets/game_hud.dart';
import '../widgets/pause_overlay.dart';
import '../widgets/pre_round_overlay.dart';
import '../widgets/round_end_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late final GameController _controller;
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _controller = GameController()..boot();
    _ticker = createTicker((Duration elapsed) {
      if (_controller.phase != GamePhase.playing) {
        _lastElapsed = elapsed;
        return;
      }
      final Duration delta = elapsed - _lastElapsed;
      _lastElapsed = elapsed;
      _controller.tick(delta);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Focus(
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Scaffold(
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    BahbohPalette.ink,
                    BahbohPalette.night,
                    BahbohPalette.sea,
                  ],
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: -120,
                    right: -40,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: BahbohPalette.highlight.withValues(
                                alpha: 0.18,
                              ),
                              blurRadius: 120,
                              spreadRadius: 40,
                            ),
                          ],
                        ),
                        child: const SizedBox(width: 260, height: 260),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(
                        BahbohConstants.boardPadding,
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 12),
                          GameHud(controller: _controller),
                          const SizedBox(height: 24),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  BahbohConstants.boardBorderRadius + 10,
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    Colors.white.withValues(alpha: 0.05),
                                    Colors.white.withValues(alpha: 0.015),
                                  ],
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.24),
                                    blurRadius: 30,
                                    offset: const Offset(0, 18),
                                  ),
                                  BoxShadow(
                                    color: BahbohPalette.highlight.withValues(
                                      alpha: 0.06,
                                    ),
                                    blurRadius: 48,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: GameBoard(controller: _controller),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _controller.statusMessage,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  if (_controller.phase == GamePhase.preRound)
                    PreRoundOverlay(controller: _controller),
                  if (_controller.phase == GamePhase.paused)
                    PauseOverlay(controller: _controller),
                  if (_controller.phase == GamePhase.success ||
                      _controller.phase == GamePhase.failure)
                    RoundEndOverlay(controller: _controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    final bool isSoftDropKey =
        event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.keyS;
    if (!isSoftDropKey) {
      return KeyEventResult.ignored;
    }

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _controller.setSoftDrop(true);
      return KeyEventResult.handled;
    }
    if (event is KeyUpEvent) {
      _controller.setSoftDrop(false);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}
