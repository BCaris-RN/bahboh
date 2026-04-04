import 'dart:ui';

import 'package:bahboh/main.dart' as live_app;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('iphone-sized splash button enters the live game', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const live_app.BahbohApp());
    await tester.pump();

    expect(find.text('ENTER BAHBOH'), findsOneWidget);

    await tester.tap(find.text('ENTER BAHBOH'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(live_app.EndlessBahbohScreen), findsOneWidget);
  });

  testWidgets('iphone-sized splash gif enters the live game', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const live_app.BahbohApp());
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Enter Bahboh'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(live_app.EndlessBahbohScreen), findsOneWidget);
  });
}
