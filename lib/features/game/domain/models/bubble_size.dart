enum BubbleSize {
  small(radiusUnits: 0.40, scoreMultiplier: 1.0, label: 'Small'),
  medium(radiusUnits: 0.56, scoreMultiplier: 1.25, label: 'Medium'),
  large(radiusUnits: 0.76, scoreMultiplier: 1.5, label: 'Large');

  const BubbleSize({
    required this.radiusUnits,
    required this.scoreMultiplier,
    required this.label,
  });

  final double radiusUnits;
  final double scoreMultiplier;
  final String label;

  double get diameterUnits => radiusUnits * 2;
}
