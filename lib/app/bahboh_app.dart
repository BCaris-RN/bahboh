import 'package:flutter/material.dart';

import '../core/theme/bahboh_theme.dart';
import 'bahboh_router.dart';

class BahbohApp extends StatelessWidget {
  const BahbohApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahboh',
      debugShowCheckedModeBanner: false,
      theme: buildBahbohTheme(),
      onGenerateRoute: BahbohRouter.onGenerateRoute,
      initialRoute: BahbohRouter.splashRoute,
    );
  }
}
