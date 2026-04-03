import 'package:bahboh/app/bahboh_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots into the splash screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BahbohApp());
    await tester.pump();

    expect(find.text('BAHBOH'), findsOneWidget);
    expect(find.text('ENTER BAHBOH'), findsOneWidget);
    expect(find.text('DISCOVER'), findsOneWidget);
  });
}
