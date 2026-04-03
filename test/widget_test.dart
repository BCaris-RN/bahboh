import 'package:bahboh/app/bahboh_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots into the pre-round overlay', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BahbohApp());
    await tester.pump();

    expect(find.text('Bahboh'), findsOneWidget);
    expect(find.text('Start Round'), findsOneWidget);
  });
}
