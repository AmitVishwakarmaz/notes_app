import 'package:flutter/material.dart';

final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: Colors.indigo);

final ThemeData appTheme = ThemeData(
  colorScheme: colorScheme,
  useMaterial3: true,
  scaffoldBackgroundColor: colorScheme.background,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: colorScheme.primary,
    foregroundColor: Colors.white,
  ),
);
