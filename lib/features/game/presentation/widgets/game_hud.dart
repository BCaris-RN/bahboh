import 'package:flutter/material.dart';

import '../../../../core/utils/time_utils.dart';
import '../../application/game_controller.dart';
import '../../domain/models/game_phase.dart';

class GameHud extends StatelessWidget {
  const GameHud({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool disablePause =
        controller.phase == GamePhase.preRound || controller.phase.isTerminal;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _HudMetric(
                label: 'Round',
                value: controller.activeRound.id.toUpperCase(),
                accent: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HudMetric(
                label: 'Timer',
                value: formatClock(controller.timerRemainingMs),
                valueStyle: theme.textTheme.displaySmall?.copyWith(
                  color: controller.timerRemainingMs <= 10000
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  fontFeatures: const <FontFeature>[
                    FontFeature.tabularFigures(),
                  ],
                ),
                accent: controller.timerRemainingMs <= 10000
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _HudMetric(
                label: 'Score',
                value: controller.currentScore.toString(),
                accent: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 16),
            FilledButton.tonalIcon(
              onPressed: disablePause ? null : controller.togglePause,
              icon: Icon(
                controller.isPaused
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
              ),
              label: Text(controller.isPaused ? 'Resume' : 'Pause'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                _RuleChip(
                  label: 'OK',
                  value: controller.okRuleSummary,
                  accent: theme.colorScheme.secondary,
                  icon: Icons.auto_awesome_rounded,
                ),
                _RuleChip(
                  label: 'Not OK',
                  value: controller.notOkRuleSummary,
                  accent: theme.colorScheme.error,
                  icon: Icons.warning_amber_rounded,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HudMetric extends StatelessWidget {
  const _HudMetric({
    required this.label,
    required this.value,
    required this.accent,
    this.valueStyle,
  });

  final String label;
  final String value;
  final Color accent;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style:
                  valueStyle ??
                  theme.textTheme.headlineMedium?.copyWith(color: accent),
            ),
          ],
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
    required this.icon,
  });

  final String label;
  final String value;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 17, color: accent),
            const SizedBox(width: 8),
            Text(
              '$label: ',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.78),
                fontWeight: FontWeight.w700,
              ),
            ),
            Flexible(
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
