import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. Pass SUPABASE_URL and SUPABASE_ANON_KEY '
      'with --dart-define.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

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
      // Localisations pour DatePicker et autres widgets Material
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // Français
        Locale('en', 'US'), // Anglais (fallback)
      ],
      locale: const Locale('fr', 'FR'),
    );
  }
}
