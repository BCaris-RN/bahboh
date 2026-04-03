import '../../../../core/constants/bahboh_motion.dart';

class MotionProfile {
  const MotionProfile({
    required this.gravityScale,
    required this.dragCoefficient,
    required this.terminalVelocity,
    required this.spawnIntervalMs,
    required this.horizontalDriftStrength,
    required this.lockDelayMs,
  });

  static const MotionProfile tutorial = MotionProfile(
    gravityScale: 1.0,
    dragCoefficient: 0.11,
    terminalVelocity: 0.028,
    spawnIntervalMs: 1350,
    horizontalDriftStrength: 0.026,
    lockDelayMs: 560,
  );

  static const MotionProfile easy = MotionProfile(
    gravityScale: 1.35,
    dragCoefficient: 0.095,
    terminalVelocity: 0.036,
    spawnIntervalMs: 1200,
    horizontalDriftStrength: 0.030,
    lockDelayMs: 500,
  );

  static const MotionProfile standard = MotionProfile(
    gravityScale: 1.8,
    dragCoefficient: 0.075,
    terminalVelocity: 0.048,
    spawnIntervalMs: 1020,
    horizontalDriftStrength: 0.034,
    lockDelayMs: 430,
  );

  static const MotionProfile hard = MotionProfile(
    gravityScale: 2.2,
    dragCoefficient: 0.060,
    terminalVelocity: 0.060,
    spawnIntervalMs: 900,
    horizontalDriftStrength: 0.038,
    lockDelayMs: 380,
  );

  static const MotionProfile expert = MotionProfile(
    gravityScale: 2.7,
    dragCoefficient: 0.045,
    terminalVelocity: 0.074,
    spawnIntervalMs: 760,
    horizontalDriftStrength: 0.042,
    lockDelayMs: 320,
  );

  final double gravityScale;
  final double dragCoefficient;
  final double terminalVelocity;
  final int spawnIntervalMs;
  final double horizontalDriftStrength;
  final int lockDelayMs;

  double gravityPerTick({required int tickMs}) {
    final double tickRatio = tickMs / BahbohMotion.referenceTickMs;
    return BahbohMotion.baselineGravityUnitsPerTickSquared *
        gravityScale *
        tickRatio *
        tickRatio;
  }
}
