import 'package:bahboh/app/bahboh_router.dart';
import 'package:bahboh/app/bahboh_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _RouteObserver extends NavigatorObserver {
  Route<dynamic>? lastNewRoute;
  Route<dynamic>? lastOldRoute;

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    lastNewRoute = newRoute;
    lastOldRoute = oldRoute;
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

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

  testWidgets('tapping the splash gif enters the game', (
    WidgetTester tester,
  ) async {
    final _RouteObserver observer = _RouteObserver();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: BahbohRouter.onGenerateRoute,
        initialRoute: BahbohRouter.splashRoute,
        navigatorObservers: <NavigatorObserver>[observer],
      ),
    );
    await tester.pump();

    await tester.tap(find.bySemanticsLabel('Enter Bahboh'));
    await tester.pump();

    expect(observer.lastNewRoute?.settings.name, BahbohRouter.gameRoute);
  });
}
