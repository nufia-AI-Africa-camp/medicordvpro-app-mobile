import 'package:flutter/material.dart';

/// Central place to configure the visual identity of the app.
ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color(0xFF0066CC),
      secondary: const Color(0xFF00A8A8),
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F8FB),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
  );
}


