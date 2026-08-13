import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Order breakdown card: order type, order channel (with progress bars),
/// and void reasons (counts). Placed near the end of the report so
/// positive analytics are seen first.
class ReportOrderBreakdownCard extends StatelessWidget {
  const ReportOrderBreakdownCard({
    super.key,
    required this.totals,
    required this.currency,
  });

  final SalesPeriodTotals totals;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final hasContent =
        totals.orderTypeBreakdown.isNotEmpty ||
        totals.orderChannelBreakdown.isNotEmpty ||
        totals.voidReasonBreakdown.isNotEmpty;
    if (!hasContent) return const SizedBox.shrink();

    return ReportSectionCard(
      title: context.l10n.orderBreakdown,
      icon: TablerIcons.listDetails,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (totals.orderTypeBreakdown.isNotEmpty) ...[
            _SectionLabel(text: context.l10n.orderTypeBreakdown),
            for (final entry in totals.orderTypeBreakdown.entries)
              _BreakdownRow(
                label: _orderTypeLabel(context, entry.key),
                value: entry.value,
                total: totals.netRevenue.value,
                currency: currency,
              ),
          ],
          if (totals.orderChannelBreakdown.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionLabel(text: context.l10n.orderChannelBreakdown),
            for (final entry in totals.orderChannelBreakdown.entries)
              _BreakdownRow(
                label: _orderChannelLabel(context, entry.key),
                value: entry.value,
                total: totals.netRevenue.value,
                currency: currency,
              ),
          ],
          if (totals.voidReasonBreakdown.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionLabel(text: context.l10n.voidReasons),
            for (final entry in totals.voidReasonBreakdown.entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text('${entry.value}'),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _orderTypeLabel(BuildContext context, String value) {
    final l10n = context.l10n;
    return switch (value.toLowerCase()) {
      'dinein' || 'dine_in' => l10n.orderTypeDineIn,
      'takeaway' || 'take_away' => l10n.orderTypeTakeaway,
      'delivery' => l10n.orderTypeDelivery,
      _ => value,
    };
  }

  String _orderChannelLabel(BuildContext context, String value) {
    final l10n = context.l10n;
    return switch (value.toLowerCase()) {
      'walkin' || 'walk_in' => l10n.orderChannelWalkIn,
      'phone' => l10n.orderChannelPhone,
      'online' => l10n.orderChannelOnline,
      _ => value,
    };
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.total,
    required this.currency,
  });

  final String label;
  final double value;
  final double total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = total <= 0 ? 0.0 : (value / total).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              MoneyText(
                value: value,
                currency: currency,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: ratio,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(scheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
