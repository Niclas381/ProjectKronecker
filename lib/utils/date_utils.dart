import 'package:flutter/material.dart';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String weekdayLabel(int weekday) {
  const labels = ['', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  if (weekday < 1 || weekday > 7) return '—';
  return labels[weekday];
}

// Neu: sichere Variante für null
String weekdayLabelNullable(int? weekday) {
  if (weekday == null) return 'Kein Wochentag';
  return 'Wochentag: ${weekdayLabel(weekday)}';
}

List<DropdownMenuItem<int?>> weekdayDropdownItems() {
  return const [
    DropdownMenuItem<int?>(value: null, child: Text('Kein Wochentag')),
    DropdownMenuItem<int?>(value: 1, child: Text('Montag')),
    DropdownMenuItem<int?>(value: 2, child: Text('Dienstag')),
    DropdownMenuItem<int?>(value: 3, child: Text('Mittwoch')),
    DropdownMenuItem<int?>(value: 4, child: Text('Donnerstag')),
    DropdownMenuItem<int?>(value: 5, child: Text('Freitag')),
    DropdownMenuItem<int?>(value: 6, child: Text('Samstag')),
    DropdownMenuItem<int?>(value: 7, child: Text('Sonntag')),
  ];
}
