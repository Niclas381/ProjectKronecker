import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../state/todo_controller.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});
  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(todoListProvider);

    List todosForDay(DateTime day) {
      final wd = day.weekday;
      return todos.where((t) => t.weekday == wd).toList();
    }

    final list = todosForDay(_selected ?? _focused);

    return Scaffold(
      body: SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Kalender', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2040, 12, 31),
              focusedDay: _focused,
              selectedDayPredicate: (d) => _selected != null && isSameDay(d, _selected),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selected = selectedDay;
                  _focused = focusedDay;
                });
              },
              calendarStyle: const CalendarStyle(
                outsideDaysVisible: false,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: list.isEmpty
                  ? const Center(child: Text('Keine To-Dos für diesen Tag'))
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final t = list[i];
                        return Card(
                          child: ListTile(
                            title: Text(t.title),
                            subtitle: Text('Geplant am: ${_weekdayLabel(t.weekday)}'),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    ));
  }

  String _weekdayLabel(int? wd) {
    switch (wd) {
      case 1:
        return 'Montag';
      case 2:
        return 'Dienstag';
      case 3:
        return 'Mittwoch';
      case 4:
        return 'Donnerstag';
      case 5:
        return 'Freitag';
      case 6:
        return 'Samstag';
      case 7:
        return 'Sonntag';
      default:
        return '—';
    }
  }
}
