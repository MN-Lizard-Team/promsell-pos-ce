import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Custom range tile — navigates to [CustomRangePage] for full-page calendar.
class CustomRangeTile extends StatelessWidget {
  const CustomRangeTile({
    super.key,
    required this.isActive,
    required this.from,
    required this.to,
    required this.fmt,
    required this.l10n,
    required this.scheme,
    required this.reportTheme,
    required this.onTap,
  });

  final bool isActive;
  final DateTime from;
  final DateTime to;
  final DateFormat fmt;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ReportThemeExtension reportTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isActive ? scheme.onPrimaryContainer : scheme.onSurface;
    final secondary = isActive
        ? scheme.onPrimaryContainer.withValues(alpha: 0.72)
        : scheme.onSurfaceVariant;
    final showRange = isActive;
    final rangeText = _formatRange(fmt, (from, to));

    return Semantics(
      button: true,
      selected: isActive,
      label: l10n.dateFilterCustomTile,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(reportTheme.cardRadius),
          boxShadow: reportTheme.cardShadow,
        ),
        child: Material(
          color: isActive
              ? scheme.primaryContainer
              : scheme.surfaceContainerLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(reportTheme.cardRadius),
            side: BorderSide(
              color: isActive
                  ? scheme.primary.withValues(alpha: 0.55)
                  : scheme.outline.withValues(alpha: 0.22),
              width: isActive ? 1.2 : 0.8,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isActive
                          ? scheme.primary
                          : scheme.primaryContainer.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      TablerIcons.calendarPlus,
                      size: reportTheme.iconSize,
                      color: isActive ? scheme.onPrimary : scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dateFilterCustomTile,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          showRange ? rangeText : l10n.dateFilterCustomDesc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    TablerIcons.chevronRight,
                    size: 22,
                    color: isActive
                        ? scheme.onPrimaryContainer.withValues(alpha: 0.72)
                        : scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatRange(DateFormat fmt, (DateTime, DateTime) range) =>
    '${fmt.format(range.$1)} – ${fmt.format(range.$2)}';
