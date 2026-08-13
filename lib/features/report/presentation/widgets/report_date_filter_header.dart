import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/features/report/presentation/pages/date_filter_page.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/date_range_preset_chips.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/cards/report_date_range_card.dart';

/// Shared date chrome for Report and History.
class ReportDateFilterHeader extends StatelessWidget {
  const ReportDateFilterHeader({
    super.key,
    required this.from,
    required this.to,
    required this.fmt,
    required this.onPreset,
    this.onCustom,
    required this.onPick,
    this.compact = false,
  });

  final DateTime from;
  final DateTime to;
  final DateFormat fmt;
  final void Function(DateTime from, DateTime to) onPreset;
  final VoidCallback? onCustom;
  final VoidCallback onPick;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ReportDateRangeCard(
        from: from,
        to: to,
        fmt: fmt,
        onTap: () => _showFilterPage(context),
      );
    }

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

  Future<void> _showFilterPage(BuildContext context) async {
    final result = await DateFilterPage.show(
      context,
      from: from,
      to: to,
      fmt: fmt,
    );
    if (result == null || !context.mounted) return;
    if (result.from != null && result.to != null) {
      onPreset(result.from!, result.to!);
    } else if (result.isCustom) {
      onPick();
    }
  }
}
