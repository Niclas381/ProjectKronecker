import 'dart:convert';

class ExpenseItem {
  final String id;
  final double amount;
  final String reason;
  final DateTime date;
  final String? receiptPath; // local file path to stored copy

  ExpenseItem({
    required this.id,
    required this.amount,
    required this.reason,
    required this.date,
    this.receiptPath,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        reason: json['reason'] as String,
        date: DateTime.parse(json['date'] as String),
        receiptPath: json['receiptPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'reason': reason,
    'date': date.toIso8601String(),
    'receiptPath': receiptPath,
  };

  static String encodeList(List<ExpenseItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
  static List<ExpenseItem> decodeList(String raw) =>
      (jsonDecode(raw) as List).map((e) => ExpenseItem.fromJson(e)).toList();
}
