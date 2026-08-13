import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class CurrentRangeCard extends StatelessWidget {
  const CurrentRangeCard({
    super.key,
    required this.from,
    required this.to,
    required this.fmt,
    required this.scheme,
    required this.reportTheme,
  });

  final DateTime from;
  final DateTime to;
  final DateFormat fmt;
  final ColorScheme scheme;
  final ReportThemeExtension reportTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final fullFrom = DateFormat('d MMMM yyyy', locale).format(from);
    final fullTo = DateFormat('d MMMM yyyy', locale).format(to);
    final fullRange = fullFrom == fullTo ? fullFrom : '$fullFrom – $fullTo';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(reportTheme.cardRadius),
        boxShadow: reportTheme.heroShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                TablerIcons.calendarClock,
                size: 18,
                color: scheme.onPrimary.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.dateFilterSheetTitle.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: scheme.onPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${fmt.format(from)} – ${fmt.format(to)}',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
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
          const SizedBox(height: 4),
          Text(
            l10n.dateFilterSheetSubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
