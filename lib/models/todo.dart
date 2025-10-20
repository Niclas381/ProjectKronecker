import 'dart:convert';

class TodoItem {
  final String id;
  String title;
  bool done;
  /// 1=Mon .. 7=Sun as in DateTime.weekday; null = unscheduled
  int? weekday;
  DateTime? lastResetOn; // last date when it auto-reset (yyyy-mm-dd)
  int sortIndex; // lower means higher priority (shown higher)

  TodoItem({
    required this.id,
    required this.title,
    this.done = false,
    this.weekday,
    this.lastResetOn,
    required this.sortIndex,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        done: json['done'] as bool? ?? false,
        weekday: json['weekday'] as int?,
        lastResetOn: json['lastResetOn'] == null
            ? null
            : DateTime.parse(json['lastResetOn'] as String),
        sortIndex: (json['sortIndex'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'weekday': weekday,
        'lastResetOn': lastResetOn?.toIso8601String().substring(0, 10),
        'sortIndex': sortIndex,
      };

  static String encodeList(List<TodoItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
  static List<TodoItem> decodeList(String raw) =>
      (jsonDecode(raw) as List).map((e) => TodoItem.fromJson(e)).toList();
}
