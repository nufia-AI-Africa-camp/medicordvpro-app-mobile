import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MedicroApp()));
}

/// Root widget of the Medicro Patient application.
class MedicroApp extends ConsumerWidget {
  const MedicroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createAppRouter(ref);

    return MaterialApp.router(
      title: 'Medicro RDV',
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      routerConfig: router,
    );
  }
}
