import 'bubble_color.dart';
import 'bubble_size.dart';

class BubbleEntity {
  const BubbleEntity({
    required this.id,
    required this.color,
    required this.size,
    required this.xUnits,
    required this.yUnits,
    this.verticalVelocityUnits = 0,
    this.ageTicks = 0,
    this.settleEnergy = 0,
  });

  final int id;
  final BubbleColor color;
  final BubbleSize size;
  final double xUnits;
  final double yUnits;
  final double verticalVelocityUnits;
  final int ageTicks;
  final double settleEnergy;

  double get radiusUnits => size.radiusUnits;

  BubbleEntity copyWith({
    int? id,
    BubbleColor? color,
    BubbleSize? size,
    double? xUnits,
    double? yUnits,
    double? verticalVelocityUnits,
    int? ageTicks,
    double? settleEnergy,
  }) {
    return BubbleEntity(
      id: id ?? this.id,
      color: color ?? this.color,
      size: size ?? this.size,
      xUnits: xUnits ?? this.xUnits,
      yUnits: yUnits ?? this.yUnits,
      verticalVelocityUnits:
          verticalVelocityUnits ?? this.verticalVelocityUnits,
      ageTicks: ageTicks ?? this.ageTicks,
      settleEnergy: settleEnergy ?? this.settleEnergy,
    );
  }
}
