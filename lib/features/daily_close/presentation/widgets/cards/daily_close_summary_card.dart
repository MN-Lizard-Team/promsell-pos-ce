import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/rows/daily_close_summary_row.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class DailyCloseSummaryCard extends StatelessWidget {
  const DailyCloseSummaryCard({super.key, required this.dailyClose});

  final DailyClose dailyClose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = _currency(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dailyCloseSummaryTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            DailyCloseSummaryRow(
              label: l10n.dailyCloseSalesCountLabel,
              value: Text('${dailyClose.salesCount}'),
            ),
            DailyCloseSummaryRow(
              label: l10n.dailyCloseVoidedCountLabel,
              value: Text('${dailyClose.voidCount}'),
            ),
            const Divider(),
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
                color: Colors.red,
              ),
            ),
            const Divider(),
            DailyCloseSummaryRow(
              label: l10n.netRevenue,
              value: MoneyText(
                value: dailyClose.totalRevenue.value,
                currency: currency,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (dailyClose.paymentBreakdown.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                l10n.dailyCloseByPayment,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              ...dailyClose.paymentBreakdown.entries.map(
                (e) => DailyCloseSummaryRow(
                  label: '  ${localizePaymentMethod(context, e.key)}',
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
                  color: Colors.red,
                ),
              ),
          ],
        ),
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
