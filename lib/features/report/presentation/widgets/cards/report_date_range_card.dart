import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Pill-style date range control for Report / History chrome.
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
    final scheme = theme.colorScheme;
    final reportTheme =
        theme.extension<ReportThemeExtension>() ?? ReportThemeExtension.light;
    final radius = reportTheme.controlRadius;
    final rangeLabel = '${fmt.format(from)} – ${fmt.format(to)}';

    return Semantics(
      button: true,
      label: rangeLabel,
      hint: context.l10n.datePresetCustom,
      child: Material(
        color: scheme.primaryContainer,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.28)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: Icon(
                    TablerIcons.calendar,
                    size: reportTheme.iconSize,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rangeLabel,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: scheme.onPrimaryContainer,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.l10n.dateFilterSheetSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimaryContainer.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  TablerIcons.chevronRight,
                  size: reportTheme.iconSize + 2,
                  color: scheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
