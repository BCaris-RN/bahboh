import 'package:bahboh/features/game/data/handcrafted_rounds.dart';
import 'package:bahboh/features/game/domain/services/round_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('round 001 validates cleanly', () {
    const RoundValidator validator = RoundValidator();

    final issues = validator.validate(handcraftedRounds.first);

    expect(issues, isEmpty);
  });
}
