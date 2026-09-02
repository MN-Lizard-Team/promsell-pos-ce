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
    final formatted = DateFormat.yMMMd().format(DateTime.parse(date));
    final cs = Theme.of(context).colorScheme;
    final status = isReadOnly
        ? l10n.dailyCloseStatusClosed
        : l10n.dailyCloseStatusOpen;
    final badge = isReadOnly
        ? l10n.dailyCloseStatusClosedBadge
        : l10n.dailyCloseStatusOpenBadge;
    final color = isReadOnly ? cs.primary : cs.secondary;

    return Semantics(
      container: true,
      label: '$formatted, $status',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: const Icon(Icons.calendar_today_outlined, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatted,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.28)),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
