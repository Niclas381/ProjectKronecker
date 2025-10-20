import 'package:flutter/material.dart';

ThemeData buildDarkTheme() {
  const black = Color(0xFF000000);
  const charcoal = Color(0xFF0B0B0B);
  const graphite = Color(0xFF121212);
  const onyx = Color(0xFF1A1A1A);
  const white = Colors.white;
  const accent = Color(0xFF7DD3FC); // subtle cyan accent

  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: black,
    colorScheme: base.colorScheme.copyWith(
      primary: white,
      secondary: accent,
      surface: graphite,
      onSurface: white,
    ),
    cardTheme: const CardThemeData(
      color: onyx,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: onyx,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: charcoal,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white70),
      ),
    ),
    listTileTheme: const ListTileThemeData(iconColor: white, textColor: white),
    appBarTheme: const AppBarTheme(
      backgroundColor: black,
      foregroundColor: white,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 0, // effectively hides AppBars if accidentally used
    ),
    dividerColor: Colors.white12,
    splashColor: Colors.white10,
    highlightColor: Colors.white10,
  );
}
