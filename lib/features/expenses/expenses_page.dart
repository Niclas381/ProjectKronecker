// lib/features/expenses/expenses_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'receipt_scanner.dart';
import '../../state/expense_controller.dart';

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expenseListProvider);
    final total = expenses.fold<double>(0.0, (a, b) => a + b.amount);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Ausgaben',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Neue Ausgabe',
                    onPressed: () => _showAddExpense(context, ref),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            // Sum card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: ListTile(
                  title: const Text('Summe'),
                  trailing: Text('${total.toStringAsFixed(2)} €'),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: expenses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final e = expenses[i];
                  final hasReceipt = e.receiptPath != null && e.receiptPath!.isNotEmpty;

                  return Card(
                    child: ListTile(
                      onTap: hasReceipt
                          ? () => _openReceipt(context, e.receiptPath!)
                          : null,
                      leading: hasReceipt
                          ? GestureDetector(
                              onTap: () => _openReceipt(context, e.receiptPath!),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(e.receiptPath!),
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.receipt_long),
                                ),
                              ),
                            )
                          : const Icon(Icons.receipt_long),
                      title: Text(e.reason),
                      subtitle: Text(
                        e.date.toLocal().toString().split(' ').first,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasReceipt)
                            IconButton(
                              tooltip: 'Beleg ansehen',
                              onPressed: () =>
                                  _openReceipt(context, e.receiptPath!),
                              icon: const Icon(Icons.fullscreen),
                            ),
                          IconButton(
                            tooltip: 'Löschen',
                            onPressed: () => ref
                                .read(expenseListProvider.notifier)
                                .remove(e.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                          const SizedBox(width: 4),
                          Text('${e.amount.toStringAsFixed(2)} €'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddExpense(BuildContext context, WidgetRef ref) async {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    DateTime date = DateTime.now();
    String? path;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Neue Ausgabe'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Betrag (€)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(labelText: 'Grund'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Datum:'),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2040),
                            );
                            if (!context.mounted) return;
                            if (picked != null) setState(() => date = picked);
                          },
                          child: Text(
                            date.toLocal().toString().split(' ').first,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Buttons für Kassenbon – Wrap verhindert Overflows
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          final src = await ImagePicker().pickImage(
                            source: ImageSource.camera,
                            imageQuality: 85,
                          );
                          if (src != null) {
                            final saved = await _saveReceipt(src);
                            setState(() => path = saved);
                          }
                        },
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('Kassenbon fotografieren'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final src = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (src != null) {
                            final saved = await _saveReceipt(src);
                            setState(() => path = saved);
                          }
                        },
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Aus Galerie'),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          final data = await ReceiptScanner.scan(camera: true); // oder camera:false für Galerie
                          if (data != null) {
                            // Bild übernehmen
                            path = data.imagePath;

                            // Felder vorbefüllen
                            if (data.total != null) {
                              amountCtrl.text = data.total!.toStringAsFixed(2);
                            }
                            if (data.merchant != null && reasonCtrl.text.trim().isEmpty) {
                              reasonCtrl.text = data.merchant!;
                            }
                            if (data.date != null) {
                              setState(() => date = data.date!);
                            }

                            // Optional: Items-Vorschau unter dem Bild anzeigen
                            if (context.mounted) setState(() {});
                          }
                        },
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: const Text('Beleg scannen (Beta)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (path != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(path!),
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Abbrechen'),
              ),
              FilledButton(
                onPressed: () {
                  final amount = double.tryParse(
                    amountCtrl.text.replaceAll(',', '.'),
                  );
                  final reason = reasonCtrl.text.trim();
                  if (amount != null && reason.isNotEmpty) {
                    ref.read(expenseListProvider.notifier).add(
                          amount: amount,
                          reason: reason,
                          date: date,
                          receiptPath: path,
                        );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Speichern'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<String> _saveReceipt(XFile file) async {
    final dir = await getApplicationDocumentsDirectory();
    final receipts = Directory('${dir.path}/receipts');
    if (!await receipts.exists()) {
      await receipts.create(recursive: true);
    }
    final name = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final dest = File('${receipts.path}/$name');
    final bytes = await file.readAsBytes();
    await dest.writeAsBytes(bytes);
    return dest.path;
  }

  void _openReceipt(BuildContext context, String path) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Center(
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Bild konnte nicht geladen werden.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Schließen',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
