import 'package:flutter/material.dart';

import '../../../../core/constants/bahboh_constants.dart';
import '../../application/game_controller.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: BahbohConstants.overlayMaxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Paused',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  'The timer, gravity, and spawn cadence are frozen. Resume to continue from the exact same deterministic state.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Row(
                  children: <Widget>[
                    FilledButton(
                      onPressed: controller.togglePause,
                      child: const Text('Resume'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: controller.restartRound,
                      child: const Text('Restart Round'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
