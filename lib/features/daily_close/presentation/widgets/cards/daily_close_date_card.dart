import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

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
    final l10n = context.l10n;
    final formatted = DateFormat('dd/MM/yyyy').format(DateTime.parse(date));
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today),
        title: Text(formatted),
        subtitle: Text(
          isReadOnly ? l10n.dailyCloseStatusClosed : l10n.dailyCloseStatusOpen,
        ),
        trailing: isReadOnly
            ? Chip(
                label: Text(
                  l10n.dailyCloseStatusClosedBadge,
                  style: TextStyle(color: cs.onPrimary),
                ),
                backgroundColor: cs.primary,
              )
            : Chip(
                label: Text(
                  l10n.dailyCloseStatusOpenBadge,
                  style: TextStyle(color: cs.onErrorContainer),
                ),
                backgroundColor: cs.errorContainer,
              ),
      ),
    );
  }
}
