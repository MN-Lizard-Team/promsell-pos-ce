import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/custom_range_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/theme/report_theme_extension.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/current_range_card.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/custom_range_tile.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/preset_list.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/section_heading.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/date_filter/usage_note.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_primary_app_bar.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class DateFilterResult {
  const DateFilterResult.preset(this.from, this.to) : isCustom = false;
  const DateFilterResult.custom(this.from, this.to) : isCustom = true;

  final DateTime? from;
  final DateTime? to;
  final bool isCustom;
}

class DateFilterPage extends StatefulWidget {
  const DateFilterPage({
    super.key,
    required this.from,
    required this.to,
    required this.fmt,
  });

  final DateTime from;
  final DateTime to;
  final DateFormat fmt;

  static Future<DateFilterResult?> show(
    BuildContext context, {
    required DateTime from,
    required DateTime to,
    required DateFormat fmt,
  }) {
    return Navigator.of(context).push<DateFilterResult>(
      MaterialPageRoute(
        builder: (_) => DateFilterPage(from: from, to: to, fmt: fmt),
      ),
    );
  }

  @override
  State<DateFilterPage> createState() => _DateFilterPageState();
}

class _DateFilterPageState extends State<DateFilterPage> {
  bool get _isCustomActive =>
      DateRangePresets.match(widget.from, widget.to) == null;

  void _selectPreset(DateTime from, DateTime to) {
    Navigator.of(context).pop(DateFilterResult.preset(from, to));
  }

  Future<void> _openCustomRangePage() async {
    final result = await CustomRangePage.show(
      context,
      initialFrom: widget.from,
      initialTo: widget.to,
      fmt: widget.fmt,
    );
    if (result == null || !mounted) return;
    Navigator.of(context).pop(DateFilterResult.custom(result.$1, result.$2));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reportTheme =
        theme.extension<ReportThemeExtension>() ?? ReportThemeExtension.light;
    final l10n = context.l10n;
    final activePreset =
        DateRangePresets.match(widget.from, widget.to) ??
        DateRangePresetKind.custom;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: PosPrimaryAppBar(
        toolbarHeight: 68,
        title: Text(l10n.dateFilterSheetTitle),
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
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CurrentRangeCard(
                              from: widget.from,
                              to: widget.to,
                              fmt: widget.fmt,
                              scheme: scheme,
                              reportTheme: reportTheme,
                            ),
                            const SizedBox(height: 32),
                            SectionHeading(
                              eyebrow: l10n.dateFilterCategoryTile,
                              title: l10n.dateFilterSheetSubtitle,
                              scheme: scheme,
                            ),
                            const SizedBox(height: 12),
                            PresetList(
                              activePreset: activePreset,
                              fmt: widget.fmt,
                              l10n: l10n,
                              scheme: scheme,
                              reportTheme: reportTheme,
                              onSelect: (range) =>
                                  _selectPreset(range.$1, range.$2),
                            ),
                            const SizedBox(height: 28),
                            SectionHeading(
                              eyebrow: l10n.dateFilterCustomTile,
                              title: l10n.dateFilterCustomDesc,
                              scheme: scheme,
                            ),
                            const SizedBox(height: 12),
                            CustomRangeTile(
                              isActive: _isCustomActive,
                              from: widget.from,
                              to: widget.to,
                              fmt: widget.fmt,
                              l10n: l10n,
                              scheme: scheme,
                              reportTheme: reportTheme,
                              onTap: _openCustomRangePage,
                            ),
                            const SizedBox(height: 20),
                            UsageNote(
                              l10n: l10n,
                              scheme: scheme,
                              reportTheme: reportTheme,
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
    );
  }
}
