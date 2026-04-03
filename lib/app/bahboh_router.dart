import 'package:flutter/material.dart';

import '../features/game/presentation/screens/game_screen.dart';

class BahbohRouter {
  const BahbohRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const GameScreen(),
      settings: settings,
    );
  }
}
