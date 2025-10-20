// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import 'features/home/home_page.dart';
import 'features/todo/todo_page.dart';
import 'features/calendar/calendar_page.dart';
import 'features/expenses/expenses_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dark Manager',
      theme: buildDarkTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/nigga': (_) => const TodoPage(),
        '/calendar': (_) => const CalendarPage(),
        '/expenses': (_) => const ExpensesPage(),
      },
    );
  }
}
