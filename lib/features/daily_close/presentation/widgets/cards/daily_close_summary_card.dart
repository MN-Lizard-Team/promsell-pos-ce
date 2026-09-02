import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/rows/daily_close_summary_row.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class DailyCloseSummaryCard extends StatelessWidget {
  const DailyCloseSummaryCard({super.key, required this.dailyClose});

  final DailyClose dailyClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = _currency(context);
    final scheme = Theme.of(context).colorScheme;

    return ReportSectionCard(
      key: const Key(TestKeys.dailyCloseSummaryCard),
      title: l10n.dailyCloseSummaryTitle,
      icon: Icons.analytics_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: l10n.netRevenue,
                  value: dailyClose.totalRevenue.value,
                  currency: currency,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: l10n.dailyCloseSalesCountLabel,
                  value: dailyClose.salesCount.toDouble(),
                  currency: '',
                  isCount: true,
                ),
              ),
              Expanded(
                child: _Metric(
                  label: l10n.dailyCloseVoidedCountLabel,
                  value: dailyClose.voidCount.toDouble(),
                  currency: '',
                  isCount: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          DailyCloseSummaryRow(
            label: l10n.dailyCloseGrossRevenue,
            value: MoneyText(
              value: (dailyClose.totalRevenue + dailyClose.totalVoid).value,
              currency: currency,
            ),
          ),
          DailyCloseSummaryRow(
            label: l10n.dailyCloseVoidedAmount,
            value: MoneyText(
              value: (-dailyClose.totalVoid).value,
              currency: currency,
              color: scheme.error,
            ),
          ),
          if (dailyClose.paymentBreakdown.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.dailyCloseByPayment,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            ...dailyClose.paymentBreakdown.entries.map(
              (e) => DailyCloseSummaryRow(
                label: localizePaymentMethod(context, e.key),
                value: MoneyText(value: e.value, currency: currency),
              ),
            ),
          ],
          if (dailyClose.vatAmount.isPositive)
            DailyCloseSummaryRow(
              label: l10n.dailyCloseVatCollected,
              value: MoneyText(
                value: dailyClose.vatAmount.value,
                currency: currency,
              ),
            ),
          if (dailyClose.discountAmount.isPositive)
            DailyCloseSummaryRow(
              label: l10n.dailyCloseDiscountsGiven,
              value: MoneyText(
                value: (-dailyClose.discountAmount).value,
                currency: currency,
                color: scheme.error,
              ),
            ),
        ],
      ),
    );
  }

  String _currency(BuildContext context) {
    try {
      return context.read<SettingsCubit>().state.settings.currency;
    } catch (_) {
      return '฿';
    }
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.currency,
    this.isCount = false,
  });
  final String label;
  final double value;
  final String currency;
  final bool isCount;

  @override
  Widget build(BuildContext context) {
    final Widget display = isCount
        ? Text(
            value.toInt().toString(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          )
        : MoneyText(value: value, currency: currency);
    return Semantics(
      label:
          '$label: ${isCount ? value.toInt() : '$currency${value.toStringAsFixed(2)}'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          display,
        ],
      ),
    );
  }
}
