import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/presentation/widgets/daily_close_summary_row.dart';

class DailyCloseSummaryCard extends StatelessWidget {
  const DailyCloseSummaryCard({super.key, required this.dailyClose});

  final DailyClose dailyClose;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Summary', style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            DailyCloseSummaryRow(
              label: 'Sales count',
              value: Text('${dailyClose.salesCount}'),
            ),
            DailyCloseSummaryRow(
              label: 'Voided count',
              value: Text('${dailyClose.voidCount}'),
            ),
            const Divider(),
            DailyCloseSummaryRow(
              label: 'Gross revenue',
              value: MoneyText(
                value: dailyClose.totalRevenue + dailyClose.totalVoid,
                currency: '฿',
              ),
            ),
            DailyCloseSummaryRow(
              label: 'Voided amount',
              value: MoneyText(
                value: -dailyClose.totalVoid,
                currency: '฿',
                color: Colors.red,
              ),
            ),
            const Divider(),
            DailyCloseSummaryRow(
              label: 'Net revenue',
              value: MoneyText(
                value: dailyClose.totalRevenue,
                currency: '฿',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (dailyClose.paymentBreakdown.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('By payment:', style: Theme.of(context).textTheme.bodySmall),
              ...dailyClose.paymentBreakdown.entries.map(
                (e) => DailyCloseSummaryRow(
                  label: '  ${e.key}',
                  value: MoneyText(value: e.value, currency: '฿'),
                ),
              ),
            ],
            if (dailyClose.vatAmount > 0)
              DailyCloseSummaryRow(
                label: 'VAT collected',
                value: MoneyText(value: dailyClose.vatAmount, currency: '฿'),
              ),
            if (dailyClose.discountAmount > 0)
              DailyCloseSummaryRow(
                label: 'Discounts given',
                value: MoneyText(
                  value: -dailyClose.discountAmount,
                  currency: '฿',
                  color: Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
