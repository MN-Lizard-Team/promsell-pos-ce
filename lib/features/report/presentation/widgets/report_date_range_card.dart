import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportDateRangeCard extends StatelessWidget {
  const ReportDateRangeCard({
    super.key,
    required this.from,
    required this.to,
    required this.fmt,
    required this.onTap,
  });

  final DateTime from;
  final DateTime to;
  final DateFormat fmt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.date_range, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${fmt.format(from)} – ${fmt.format(to)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
