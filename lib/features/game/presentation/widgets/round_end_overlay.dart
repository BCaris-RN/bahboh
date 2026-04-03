import 'package:flutter/material.dart';

import '../../../../core/constants/bahboh_constants.dart';
import '../../application/game_controller.dart';
import '../../domain/models/game_phase.dart';

class RoundEndOverlay extends StatelessWidget {
  const RoundEndOverlay({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final bool success = controller.phase == GamePhase.success;
    final ThemeData theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: BahbohConstants.overlayMaxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.62),
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
                  success ? 'Round Complete' : 'Round Failed',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: success
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  controller.gameResult?.summary ?? controller.statusMessage,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _SummaryChip(
                      label: 'Final score',
                      value: controller.currentScore.toString(),
                      accent: theme.colorScheme.secondary,
                    ),
                    _SummaryChip(
                      label: 'Remaining Not OK',
                      value: controller.remainingNotOkCount.toString(),
                      accent: theme.colorScheme.error,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: controller.restartRound,
                  child: const Text('Restart Round'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '$label: ',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
