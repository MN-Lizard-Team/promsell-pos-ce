import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/report/domain/utils/date_range_presets.dart';

class DateRangePresetChips extends StatelessWidget {
  const DateRangePresetChips({
    super.key,
    required this.from,
    required this.to,
    required this.onPreset,
    this.onCustom,
  });

  final DateTime from;
  final DateTime to;
  final void Function(DateTime from, DateTime to) onPreset;
  final VoidCallback? onCustom;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selected =
        DateRangePresets.match(from, to) ?? DateRangePresetKind.custom;

    void apply(DateRangePresetKind kind) {
      HapticFeedback.selectionClick();
      final range = switch (kind) {
        DateRangePresetKind.today => DateRangePresets.today(),
        DateRangePresetKind.yesterday => DateRangePresets.yesterday(),
        DateRangePresetKind.last7Days => DateRangePresets.last7Days(),
        DateRangePresetKind.thisMonth => DateRangePresets.thisMonth(),
        DateRangePresetKind.custom => null,
      };
      if (range == null) {
        onCustom?.call();
        return;
      }
      onPreset(range.$1, range.$2);
    }

    Widget chip(String label, DateRangePresetKind kind) {
      return ChoiceChip(
        label: Text(label),
        selected: selected == kind,
        onSelected: (_) => apply(kind),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(l10n.datePresetToday, DateRangePresetKind.today),
          const SizedBox(width: 8),
          chip(l10n.datePresetYesterday, DateRangePresetKind.yesterday),
          const SizedBox(width: 8),
          chip(l10n.datePresetLast7Days, DateRangePresetKind.last7Days),
          const SizedBox(width: 8),
          chip(l10n.datePresetThisMonth, DateRangePresetKind.thisMonth),
          if (onCustom != null) ...[
            const SizedBox(width: 8),
            chip(l10n.datePresetCustom, DateRangePresetKind.custom),
          ],
        ],
      ),
    );
  }
}
