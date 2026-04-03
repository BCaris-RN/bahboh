import 'package:bahboh/features/game/domain/models/bubble_size.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bubble sizes keep the mandated visible ratios', () {
    expect(
      BubbleSize.medium.radiusUnits / BubbleSize.small.radiusUnits,
      closeTo(1.4, 0.00001),
    );
    expect(
      BubbleSize.large.radiusUnits / BubbleSize.small.radiusUnits,
      closeTo(1.9, 0.00001),
    );
    expect(
      BubbleSize.large.diameterUnits,
      greaterThan(BubbleSize.medium.diameterUnits),
    );
  });
}
