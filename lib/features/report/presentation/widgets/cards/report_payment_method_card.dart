import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

class ReportPaymentMethodCard extends StatelessWidget {
  const ReportPaymentMethodCard({
    super.key,
    required this.byMethod,
    required this.methodCounts,
    required this.netRevenue,
    required this.currency,
  });

  final Map<String, double> byMethod;
  final Map<String, int> methodCounts;
  final double netRevenue;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.byPaymentMethod, style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),
            if (byMethod.isEmpty)
              AppEmptyState(
                icon: Icons.payments_outlined,
                title: l10n.noSalesYet,
              )
            else
              ...byMethod.entries.map((e) {
                final count = methodCounts[e.key] ?? 0;
                final pct = netRevenue > 0 ? (e.value / netRevenue * 100) : 0.0;
                final pctLabel = l10n.paymentMethodShare(
                  pct >= 10 || pct == 0
                      ? pct.toStringAsFixed(0)
                      : pct.toStringAsFixed(1),
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(localizePaymentMethod(context, e.key)),
                            Text(
                              l10n.salesCount(count),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MoneyText(
                            value: e.value,
                            currency: currency,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            pctLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
