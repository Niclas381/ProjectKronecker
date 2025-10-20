import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _kTodos = 'todos_v1';
  static const _kExpenses = 'expenses_v1';

  Future<void> saveTodos(String json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTodos, json);
  }

  Future<String?> loadTodos() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kTodos);
  }

  Future<void> saveExpenses(String json) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kExpenses, json);
  }

  Future<String?> loadExpenses() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kExpenses);
  }
}
