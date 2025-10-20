import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import '../services/storage.dart';

final expenseStorageProvider = Provider<StorageService>((ref) => StorageService());

final expenseListProvider =
    StateNotifierProvider<ExpenseController, List<ExpenseItem>>((ref) {
  return ExpenseController(ref);
});

class ExpenseController extends StateNotifier<List<ExpenseItem>> {
  final Ref _ref;
  ExpenseController(this._ref) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final raw = await _ref.read(expenseStorageProvider).loadExpenses();
    if (raw != null) state = ExpenseItem.decodeList(raw);
  }

  Future<void> _persist() async {
    await _ref.read(expenseStorageProvider).saveExpenses(ExpenseItem.encodeList(state));
  }

  void add({required double amount, required String reason, required DateTime date, String? receiptPath}) {
    state = [
      ...state,
      ExpenseItem(
        id: const Uuid().v4(),
        amount: amount,
        reason: reason,
        date: date,
        receiptPath: receiptPath,
      )
    ];
    _persist();
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
    _persist();
  }
}
