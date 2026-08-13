import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/date_range_preset_chips.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_date_range_card.dart';

/// Modern bottom-sheet date filter bar for Report page
/// Replaces old full modal date picker
class DateRangeFilterBar extends StatelessWidget {
  const DateRangeFilterBar({
    super.key,
    required this.from,
    required this.to,
    required this.fmt,
    required this.onPreset,
    this.onCustom,
    required this.onPick,
  });

  final DateTime from;
  final DateTime to;
  final DateFormat fmt;
  final void Function(DateTime from, DateTime to) onPreset;
  final VoidCallback? onCustom;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DateRangePresetChips(
          from: from,
          to: to,
          onPreset: onPreset,
          onCustom: onCustom ?? onPick,
        ),
        const SizedBox(height: 10),
        ReportDateRangeCard(from: from, to: to, fmt: fmt, onTap: onPick),
      ],
    );
  }
}
