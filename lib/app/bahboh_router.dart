import 'package:flutter/material.dart';

import '../features/game/presentation/screens/game_screen.dart';
import '../features/game/presentation/screens/splash_screen.dart';

class BahbohRouter {
  const BahbohRouter._();

  static const String splashRoute = '/';
  static const String gameRoute = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    if (settings.name == gameRoute) {
      return MaterialPageRoute<void>(
        builder: (_) => const GameScreen(),
        settings: settings,
      );
    }

    return MaterialPageRoute<void>(
      builder: (_) => const SplashScreen(),
      settings: settings,
    );
  }
}
