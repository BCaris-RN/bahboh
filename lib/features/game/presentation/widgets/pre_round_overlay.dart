import 'package:flutter/material.dart';

import '../../../../core/constants/bahboh_constants.dart';
import '../../../../core/utils/time_utils.dart';
import '../../application/game_controller.dart';

class PreRoundOverlay extends StatelessWidget {
  const PreRoundOverlay({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: BahbohConstants.overlayMaxWidth,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Bahboh', style: theme.textTheme.displayLarge),
                const SizedBox(height: 16),
                Text(controller.roundGoal, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _RuleChip(
                      label: 'Timer',
                      value: formatClock(controller.activeRound.timerMs),
                      accent: theme.colorScheme.primary,
                    ),
                    _RuleChip(
                      label: 'OK',
                      value: controller.okRuleSummary,
                      accent: theme.colorScheme.secondary,
                    ),
                    _RuleChip(
                      label: 'Not OK',
                      value: controller.notOkRuleSummary,
                      accent: theme.colorScheme.error,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Primary goal: build valid OK formations. Danger colors can clear each other, but that only pays modest cleanup value.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: controller.startRound,
                  child: const Text('Start Round'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({
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
        child: Text(
          '$label: $value',
          style: theme.textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.92),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
