import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class PresetList extends StatelessWidget {
  const PresetList({
    super.key,
    required this.activePreset,
    required this.fmt,
    required this.l10n,
    required this.scheme,
    required this.reportTheme,
    required this.onSelect,
  });

  final DateRangePresetKind activePreset;
  final DateFormat fmt;
  final AppLocalizations l10n;
  final ColorScheme scheme;
  final ReportThemeExtension reportTheme;
  final void Function((DateTime, DateTime) range) onSelect;

  @override
  Widget build(BuildContext context) {
    final locale = l10n.localeName;
    final presets = [
      _PresetData(
        DateRangePresetKind.today,
        l10n.datePresetToday,
        _formatFullRange(locale, DateRangePresets.today()),
        TablerIcons.sun,
        DateRangePresets.today(),
        scheme.primary,
        scheme.onPrimary,
      ),
      _PresetData(
        DateRangePresetKind.yesterday,
        l10n.datePresetYesterday,
        _formatFullRange(locale, DateRangePresets.yesterday()),
        TablerIcons.moon,
        DateRangePresets.yesterday(),
        scheme.secondary,
        scheme.onSecondary,
      ),
      _PresetData(
        DateRangePresetKind.last7Days,
        l10n.datePresetLast7Days,
        _formatFullRange(locale, DateRangePresets.last7Days()),
        TablerIcons.calendarWeek,
        DateRangePresets.last7Days(),
        scheme.tertiary,
        scheme.onTertiary,
      ),
      _PresetData(
        DateRangePresetKind.thisMonth,
        l10n.datePresetThisMonth,
        _formatFullRange(locale, DateRangePresets.thisMonth()),
        TablerIcons.calendarMonth,
        DateRangePresets.thisMonth(),
        scheme.primary,
        scheme.onPrimary,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < presets.length; i++) ...[
          _PresetRow(
            data: presets[i],
            isActive: activePreset == presets[i].kind,
            scheme: scheme,
            reportTheme: reportTheme,
            onTap: () => onSelect(presets[i].range),
          ),
          if (i < presets.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

String _formatFullRange(String locale, (DateTime, DateTime) range) {
  final full = DateFormat('d MMMM yyyy', locale);
  final from = full.format(range.$1);
  final to = full.format(range.$2);
  return from == to ? from : '$from – $to';
}

class _PresetData {
  const _PresetData(
    this.kind,
    this.label,
    this.description,
    this.icon,
    this.range,
    this.accent,
    this.onAccent,
  );

  final DateRangePresetKind kind;
  final String label;
  final String description;
  final IconData icon;
  final (DateTime, DateTime) range;
  final Color accent;
  final Color onAccent;
}

class _PresetRow extends StatelessWidget {
  const _PresetRow({
    required this.data,
    required this.isActive,
    required this.scheme,
    required this.reportTheme,
    required this.onTap,
  });

  final _PresetData data;
  final bool isActive;
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
    final cardColor = isActive
        ? scheme.primaryContainer
        : scheme.surfaceContainerLow;

    return Semantics(
      button: true,
      selected: isActive,
      label: data.label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(reportTheme.cardRadius),
          border: Border.all(
            color: isActive
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outline.withValues(alpha: 0.18),
            width: isActive ? 1.2 : 0.8,
          ),
          boxShadow: isActive ? reportTheme.cardShadow : const <BoxShadow>[],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(reportTheme.cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive
                          ? data.accent
                          : data.accent.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      data.icon,
                      size: reportTheme.iconSize,
                      color: isActive ? data.onAccent : data.accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: foreground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: secondary,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: isActive
                        ? Container(
                            key: const ValueKey('selected'),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              TablerIcons.check,
                              size: 15,
                              color: scheme.onPrimary,
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('idle'),
                            width: 24,
                            height: 24,
                          ),
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
