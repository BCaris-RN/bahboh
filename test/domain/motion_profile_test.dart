import 'package:bahboh/features/game/domain/models/motion_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('tutorial motion profile resolves to gentle normalized gravity', () {
    expect(
      MotionProfile.tutorial.gravityPerTick(tickMs: 16),
      closeTo(0.002304, 0.000001),
    );
    expect(MotionProfile.tutorial.dragCoefficient, greaterThan(0.09));
    expect(MotionProfile.tutorial.terminalVelocity, lessThan(0.03));
    expect(MotionProfile.tutorial.lockDelayMs, greaterThanOrEqualTo(560));
  });

  test('difficulty presets get progressively faster and less forgiving', () {
    expect(
      MotionProfile.easy.gravityScale,
      greaterThan(MotionProfile.tutorial.gravityScale),
    );
    expect(
      MotionProfile.standard.terminalVelocity,
      greaterThan(MotionProfile.easy.terminalVelocity),
    );
    expect(
      MotionProfile.hard.dragCoefficient,
      lessThan(MotionProfile.standard.dragCoefficient),
    );
    expect(
      MotionProfile.expert.spawnIntervalMs,
      lessThan(MotionProfile.hard.spawnIntervalMs),
    );
  });
}
