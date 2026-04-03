import 'bubble_color.dart';

class BubbleFxBurst {
  const BubbleFxBurst({
    required this.id,
    required this.xUnits,
    required this.yUnits,
    required this.primaryColor,
    required this.secondaryColor,
    required this.energy,
    this.ageTicks = 0,
    this.lifespanTicks = 96,
  });

  final int id;
  final double xUnits;
  final double yUnits;
  final BubbleColor primaryColor;
  final BubbleColor secondaryColor;
  final double energy;
  final int ageTicks;
  final int lifespanTicks;

  double get progress => ageTicks / lifespanTicks;
  bool get isAlive => ageTicks < lifespanTicks;

  BubbleFxBurst advance() {
    return copyWith(ageTicks: ageTicks + 1);
  }

  BubbleFxBurst copyWith({
    int? id,
    double? xUnits,
    double? yUnits,
    BubbleColor? primaryColor,
    BubbleColor? secondaryColor,
    double? energy,
    int? ageTicks,
    int? lifespanTicks,
  }) {
    return BubbleFxBurst(
      id: id ?? this.id,
      xUnits: xUnits ?? this.xUnits,
      yUnits: yUnits ?? this.yUnits,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      energy: energy ?? this.energy,
      ageTicks: ageTicks ?? this.ageTicks,
      lifespanTicks: lifespanTicks ?? this.lifespanTicks,
    );
  }
}
