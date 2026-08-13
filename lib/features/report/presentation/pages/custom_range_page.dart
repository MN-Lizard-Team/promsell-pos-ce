import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/date_range_preset_chips.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/calendar_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/selected_range_header.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_primary_app_bar.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Full-page custom date range picker with inline [TableCalendar].
class CustomRangePage extends StatefulWidget {
  const CustomRangePage({
    super.key,
    required this.initialFrom,
    required this.initialTo,
    required this.fmt,
  });

  final DateTime initialFrom;
  final DateTime initialTo;
  final DateFormat fmt;

  /// Pushes the page and returns the selected range, or null if dismissed.
  static Future<(DateTime, DateTime)?> show(
    BuildContext context, {
    required DateTime initialFrom,
    required DateTime initialTo,
    required DateFormat fmt,
  }) {
    return Navigator.of(context).push<(DateTime, DateTime)>(
      MaterialPageRoute(
        builder: (_) => CustomRangePage(
          initialFrom: initialFrom,
          initialTo: initialTo,
          fmt: fmt,
        ),
      ),
    );
  }

  @override
  State<CustomRangePage> createState() => _CustomRangePageState();
}

class _CustomRangePageState extends State<CustomRangePage> {
  late DateTime _from = DateRangePresets.startOfDay(widget.initialFrom);
  late DateTime _to = DateRangePresets.endOfDay(widget.initialTo);
  late DateTime _focused = _from;

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focused) {
    if (start == null) return;
    setState(() {
      // Auto-swap if end is before start (TableCalendar can produce this
      // when the user taps a date earlier than the current start).
      if (end != null && end.isBefore(start)) {
        _from = end;
        _to = start;
      } else {
        _from = start;
        _to = end ?? start;
      }
      _focused = focused;
    });
  }

  void _apply() {
    // Final safety: ensure from ≤ to.
    final from = DateRangePresets.startOfDay(_from);
    final to = DateRangePresets.endOfDay(_to);
    if (to.isBefore(from)) {
      Navigator.of(context).pop((to, from));
    } else {
      Navigator.of(context).pop((from, to));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reportTheme =
        theme.extension<ReportThemeExtension>() ?? ReportThemeExtension.light;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: PosPrimaryAppBar(
        toolbarHeight: 68,
        title: Text(l10n.dateFilterCustomTile),
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonLabel,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(TablerIcons.x, size: 24),
            splashRadius: 24,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(boxShadow: reportTheme.barShadow),
          ),
          Expanded(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = constraints.maxWidth > 760
                      ? 680.0
                      : double.infinity;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SelectedRangeHeader(
                              from: _from,
                              to: _to,
                              fmt: widget.fmt,
                              scheme: scheme,
                              label: l10n.dateFilterCustomCurrent,
                              heroShadow: reportTheme.heroShadow,
                            ),
                            const SizedBox(height: 12),
                            DateRangePresetChips(
                              from: _from,
                              to: _to,
                              onPreset: (f, t) => setState(() {
                                _from = DateRangePresets.startOfDay(f);
                                _to = DateRangePresets.endOfDay(t);
                                _focused = _from;
                              }),
                            ),
                            const SizedBox(height: 16),
                            CalendarCard(
                              from: _from,
                              to: _to,
                              focused: _focused,
                              scheme: scheme,
                              onRangeSelected: _onRangeSelected,
                              cardShadow: reportTheme.cardShadow,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border(
              top: BorderSide(color: scheme.outline.withValues(alpha: 0.14)),
            ),
            boxShadow: reportTheme.barShadow,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.accentShadow,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: FilledButton.icon(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(TablerIcons.check, size: 19),
                  label: Text(l10n.dateFilterCustomApply),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
