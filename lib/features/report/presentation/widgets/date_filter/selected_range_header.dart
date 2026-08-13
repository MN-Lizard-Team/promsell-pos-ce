import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Primary summary panel for the currently selected range.
class SelectedRangeHeader extends StatelessWidget {
  const SelectedRangeHeader({
    super.key,
    required this.from,
    required this.to,
    required this.fmt,
    required this.scheme,
    required this.label,
    required this.heroShadow,
  });

  final DateTime from;
  final DateTime to;
  final DateFormat fmt;
  final ColorScheme scheme;
  final String label;
  final List<BoxShadow> heroShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final rangeText = '${fmt.format(from)} – ${fmt.format(to)}';
    final fullFrom = DateFormat('d MMMM yyyy', locale).format(from);
    final fullTo = DateFormat('d MMMM yyyy', locale).format(to);
    final fullRange = fullFrom == fullTo ? fullFrom : '$fullFrom – $fullTo';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: heroShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                TablerIcons.calendarEvent,
                size: 18,
                color: scheme.onPrimary.withValues(alpha: 0.82),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            rangeText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            fullRange,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.78),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
