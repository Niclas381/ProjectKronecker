import 'package:flutter/material.dart';
import 'features/home/home_page.dart';
import 'features/todo/todo_page.dart';
import 'features/calendar/calendar_page.dart';
import 'features/expenses/expenses_page.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _page(const HomePage());
      case '/todo':
        return _page(const TodoPage());
      case '/calendar':
        return _page(const CalendarPage());
      case '/expenses':
        return _page(const ExpensesPage());
      default:
        return _page(const HomePage());
    }
  }

  static PageRoute _page(Widget child) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}
