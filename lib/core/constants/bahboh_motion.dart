class BahbohMotion {
  const BahbohMotion._();

  static const int referenceTickMs = 16;
  static const double referenceTickSeconds = referenceTickMs / 1000.0;

  // Bahboh uses normalized board-space units instead of physical meters.
  // This mapping keeps early-round motion close to a gentle 0.5 m/s^2 feel:
  // 1 board unit ~= 1 / 18 meter, so 0.5 m/s^2 becomes
  // 0.5 * 18 * 0.016^2 = 0.002304 board units / tick^2 at 60 Hz.
  static const double boardUnitsPerMeter = 18.0;
  static const double baselineGravityMetersPerSecondSquared = 0.5;
  static const double baselineGravityUnitsPerTickSquared =
      baselineGravityMetersPerSecondSquared *
      boardUnitsPerMeter *
      referenceTickSeconds *
      referenceTickSeconds;

  static const double softDropGravityMultiplier = 3.4;
  static const double softDropTerminalVelocityMultiplier = 2.5;
}
