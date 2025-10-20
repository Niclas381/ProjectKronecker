// lib/features/expenses/receipt_scanner.dart
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptItem {
  final String name;
  final double price;
  ReceiptItem({required this.name, required this.price});
}

class ReceiptData {
  final String? merchant;
  final DateTime? date;
  final double? total;
  final List<ReceiptItem> items;
  final String imagePath;
  ReceiptData({
    required this.imagePath,
    this.merchant,
    this.date,
    this.total,
    this.items = const [],
  });
}

class ReceiptScanner {
  /// 1) Bild aufnehmen/auswählen
  static Future<String?> _pickImage({required bool camera}) async {
    final src = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
    );
    if (src == null) return null;

    // in App-Verzeichnis kopieren
    final dir = await getApplicationDocumentsDirectory();
    final receipts = Directory('${dir.path}/receipts');
    if (!await receipts.exists()) await receipts.create(recursive: true);
    final dest = File('${receipts.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final bytes = await src.readAsBytes();
    await dest.writeAsBytes(bytes);
    return dest.path;
  }

  /// Öffentliche API: Startet Scan-Flow (Kamera oder Galerie)
  static Future<ReceiptData?> scan({bool camera = true}) async {
    final path = await _pickImage(camera: camera);
    if (path == null) return null;

    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognised = await textRecognizer.processImage(inputImage);
      final text = recognised.text;
      final parsed = _parse(text);
      return ReceiptData(
        imagePath: path,
        merchant: parsed.merchant,
        date: parsed.date,
        total: parsed.total,
        items: parsed.items,
      );
    } finally {
      await textRecognizer.close();
    }
  }

  /// ---------- Parser (heuristisch, DE) ----------
  static final _reAmount = RegExp(r'(?<!\d)(\d{1,4}[.,]\d{2})(?!\d)');
  static final _reDate = RegExp(
    r'(\d{2}[./-]\d{2}[./-]\d{2,4})',
    caseSensitive: false,
  );

  static _Parsed _parse(String raw) {
    final lines = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // Händler: oft erste nicht-numerische Zeile mit >= 3 Buchstaben
    String? merchant;
    for (final l in lines.take(5)) {
      final onlyLetters = l.replaceAll(RegExp(r'[^A-Za-zÄÖÜäöüß ]'), '').trim();
      if (onlyLetters.split(' ').join().length >= 3 && !l.toLowerCase().contains('kassenzettel')) {
        merchant = l;
        break;
      }
    }

    // Datum
    DateTime? date;
    for (final l in lines) {
      final m = _reDate.firstMatch(l);
      if (m != null) {
        final s = m.group(1)!;
        date = _parseDateFlexible(s);
        if (date != null) break;
      }
    }

    // Total/Summe
    double? total;
    final totalKeywords = ['summe', 'gesamt', 'total', 'endbetrag', 'zu zahlen', 'bar', 'ec', 'kartenzahlung'];
    for (final l in lines.reversed) {
      final lower = l.toLowerCase();
      if (totalKeywords.any((k) => lower.contains(k))) {
        final m = _reAmount.allMatches(l).toList().lastOrNull;
        if (m != null) {
          total = _toDouble(m.group(1)!);
          break;
        }
      }
    }
    // Fallback: höchste Zahl im Beleg als Total
    total ??= _maxAmount(lines);

    // Items: Zeilen mit Text + Preis am Ende, aber nicht die Total-Zeilen
    final List<ReceiptItem> items = [];
    for (final l in lines) {
      final m = _reAmount.allMatches(l).toList().lastOrNull;
      if (m == null) continue;
      final price = _toDouble(m.group(1)!);

      final lead = l.substring(0, m.start).trim();
      final lower = l.toLowerCase();
      if (totalKeywords.any((k) => lower.contains(k))) continue; // keine Total-Zeile
      if (lead.isEmpty) continue;
      // Häufig Artikelnummern o. ä. entfernen
      final name = lead.replaceAll(RegExp(r'\b(\d{6,}|\d{2,}-\d{2,})\b'), '').trim();
      if (name.isEmpty) continue;

      items.add(ReceiptItem(name: name, price: price));
    }

    return _Parsed(merchant: merchant, date: date, total: total, items: items);
  }

  static DateTime? _parseDateFlexible(String s) {
    String norm = s.replaceAll('-', '.').replaceAll('/', '.');
    final parts = norm.split('.');
    if (parts.length < 3) return null;
    int d = int.tryParse(parts[0]) ?? -1;
    int m = int.tryParse(parts[1]) ?? -1;
    int y = int.tryParse(parts[2]) ?? -1;
    if (y < 100) y += 2000;
    if (d <= 0 || m <= 0 || y < 1900) return null;
    try {
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  static double? _maxAmount(List<String> lines) {
    double? maxv;
    for (final l in lines) {
      for (final m in _reAmount.allMatches(l)) {
        final v = _toDouble(m.group(1)!);
        if (maxv == null || v > maxv) maxv = v;
      }
    }
    return maxv;
  }

  static double _toDouble(String s) {
    return double.parse(s.replaceAll('.', '').replaceAll(',', '.'));
  }
}

extension _LastOrNull<E> on List<E> {
  E? get lastOrNull => isEmpty ? null : last;
}

class _Parsed {
  final String? merchant;
  final DateTime? date;
  final double? total;
  final List<ReceiptItem> items;
  _Parsed({this.merchant, this.date, this.total, this.items = const []});
}
