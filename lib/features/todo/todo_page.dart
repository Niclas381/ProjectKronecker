import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/todo_controller.dart';
import '../../utils/date_utils.dart' as du;

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final total = todos.length;
    final done = todos.where((t) => t.done).length;
    final progress = total == 0 ? 0.0 : done / total;

    final sorted = [...todos]..sort((a, b) => a.sortIndex.compareTo(b.sortIndex));

    return Scaffold(
      body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('To-Dos', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Neues To-Do',
                      onPressed: () => _showAddDialog(context, ref),
                      icon: const Icon(Icons.add),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(value: progress, minHeight: 10),
                ),
                const SizedBox(height: 6),
                Text('$done von $total erledigt'),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: sorted.length,
              onReorder: (o, n) => ref.read(todoListProvider.notifier).reorder(o, n),
              itemBuilder: (context, index) {
                final t = sorted[index];
                return Card(
                  key: ValueKey(t.id),
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator),
                    ),
                    title: Text(t.title),
                    subtitle: t.weekday == null
                        ? const Text('Kein Wochentag')
                        : Text('Wochentag: ${du.weekdayLabel(t.weekday!)}'),
                    trailing: Checkbox(
                      value: t.done,
                      onChanged: (v) => ref.read(todoListProvider.notifier).toggleDone(t.id, v ?? false),
                    ),
                    onTap: () => _showEditBottomSheet(context, ref, t.id, t.title, t.weekday),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    int? weekday;
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Neues To-Do'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Titel'),
                onSubmitted: (_) {},
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: weekday,
                items: du.weekdayDropdownItems(),
                onChanged: (v) => weekday = v,
                decoration: const InputDecoration(labelText: 'Wochentag (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () {
                final text = ctrl.text.trim();
                if (text.isNotEmpty) {
                  ref.read(todoListProvider.notifier).add(text, weekday: weekday);
                }
                Navigator.pop(context);
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  void _showEditBottomSheet(BuildContext context, WidgetRef ref, String id, String title, int? currentWeekday) {
    final ctrl = TextEditingController(text: title);
    int? weekday = currentWeekday;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ctrl,
                decoration: const InputDecoration(labelText: 'Titel'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                initialValue: weekday,
                items: du.weekdayDropdownItems(),
                onChanged: (v) => weekday = v,
                decoration: const InputDecoration(labelText: 'Wochentag'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      ref.read(todoListProvider.notifier).remove(id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Löschen'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () {
                      final list = ref.read(todoListProvider);
                      final idx = list.indexWhere((e) => e.id == id);
                      if (idx != -1) {
                        final t = list[idx];
                        list[idx]
                          .title = ctrl.text.trim().isEmpty ? t.title : ctrl.text.trim();
                        ref.read(todoListProvider.notifier).updateWeekday(id, weekday);
                      }
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Speichern'),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
