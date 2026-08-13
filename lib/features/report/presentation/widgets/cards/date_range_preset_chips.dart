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
      final scheme = Theme.of(context).colorScheme;
      final isSelected = selected == kind;
      // Report filter chips use primary teal selection (not the global orange
      // accent chip theme which reads as a Pay/CTA state).
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        onSelected: (_) => apply(kind),
        selectedColor: scheme.primaryContainer,
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        labelStyle: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant,
        ),
        side: BorderSide(
          color: isSelected
              ? scheme.primary.withValues(alpha: 0.55)
              : scheme.outline.withValues(alpha: 0.35),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      );
    }

    return SizedBox(
      height: 52,
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
