import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/todo.dart';
import '../services/storage.dart';
import '../utils/date_utils.dart';

final storageProvider = Provider<StorageService>((ref) => StorageService());

final todoListProvider =
    StateNotifierProvider<TodoController, List<TodoItem>>((ref) {
  return TodoController(ref);
});

class TodoController extends StateNotifier<List<TodoItem>> {
  final Ref _ref;
  TodoController(this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _ref.read(storageProvider).loadTodos();
    if (raw != null) {
      state = TodoItem.decodeList(raw);
      _autoResetForToday();
    }
  }

  Future<void> _persist() async {
    await _ref.read(storageProvider).saveTodos(TodoItem.encodeList(state));
  }

  // Weekly auto-reset: if an item has weekday == today and lastResetOn != today
  void _autoResetForToday() {
    final today = dateOnly(DateTime.now());
    final wd = today.weekday;
    bool changed = false;
    final updated = state.map((t) {
      if (t.weekday == wd) {
        final last = t.lastResetOn == null ? null : dateOnly(t.lastResetOn!);
        if (last == null || last.isBefore(today)) {
          changed = true;
          return TodoItem(
            id: t.id,
            title: t.title,
            done: false,
            weekday: t.weekday,
            lastResetOn: today,
            sortIndex: t.sortIndex,
          );
        }
      }
      return t;
    }).toList();
    if (changed) {
      state = updated;
      _persist();
    }
  }

  void add(String title, {int? weekday}) {
    final id = const Uuid().v4();
    final maxIndex = state.isEmpty ? 0 : state.map((e) => e.sortIndex).reduce((a, b) => a > b ? a : b);
    state = [
      ...state,
      TodoItem(
        id: id,
        title: title,
        weekday: weekday,
        sortIndex: maxIndex + 1,
      ),
    ];
    _persist();
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }

  void toggleDone(String id, bool value) {
    state = state.map((e) => e.id == id ? TodoItem(
      id: e.id,
      title: e.title,
      done: value,
      weekday: e.weekday,
      lastResetOn: e.lastResetOn,
      sortIndex: e.sortIndex,
    ) : e).toList();
    _persist();
  }

  void updateWeekday(String id, int? weekday) {
    state = state.map((e) => e.id == id ? TodoItem(
      id: e.id,
      title: e.title,
      done: e.done,
      weekday: weekday,
      lastResetOn: e.lastResetOn,
      sortIndex: e.sortIndex,
    ) : e).toList();
    _persist();
  }

  void reorder(int oldIndex, int newIndex) {
    final items = [...state]..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex, moved);
    for (var i = 0; i < items.length; i++) {
      items[i] = TodoItem(
        id: items[i].id,
        title: items[i].title,
        done: items[i].done,
        weekday: items[i].weekday,
        lastResetOn: items[i].lastResetOn,
        sortIndex: i,
      );
    }
    state = items;
    _persist();
  }
}
