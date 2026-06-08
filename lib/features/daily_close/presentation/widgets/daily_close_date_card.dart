import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyCloseDateCard extends StatelessWidget {
  const DailyCloseDateCard({
    super.key,
    required this.date,
    required this.isReadOnly,
  });

  final String date;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(formatted),
        subtitle: Text(isReadOnly ? 'Closed' : 'Open'),
        trailing: isReadOnly
            ? Chip(
                label: Text('CLOSED', style: TextStyle(color: cs.onPrimary)),
                backgroundColor: cs.primary,
              )
            : Chip(
                label: Text(
                  'OPEN',
                  style: TextStyle(color: cs.onErrorContainer),
                ),
                backgroundColor: cs.errorContainer,
              ),
      ),
    );
  }
}
