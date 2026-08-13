import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

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
    final scheme = theme.colorScheme;
    final l10n = context.l10n;

    return ReportSectionCard(
      title: l10n.byPaymentMethod,
      icon: TablerIcons.creditCard,
      child: byMethod.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.noSalesYet,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                for (final e in byMethod.entries) ...[
                  _PaymentMethodRow(
                    key: ValueKey('payment-${e.key}'),
                    methodKey: e.key,
                    amount: e.value,
                    count: methodCounts[e.key] ?? 0,
                    netRevenue: netRevenue,
                    currency: currency,
                  ),
                ],
              ],
            ),
    );
  }
}

class _PaymentMethodRow extends StatelessWidget {
  const _PaymentMethodRow({
    super.key,
    required this.methodKey,
    required this.amount,
    required this.count,
    required this.netRevenue,
    required this.currency,
  });

  final String methodKey;
  final double amount;
  final int count;
  final double netRevenue;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = context.l10n;
    final pct = netRevenue > 0 ? (amount / netRevenue * 100) : 0.0;
    final pctLabel = l10n.paymentMethodShare(
      pct >= 10 || pct == 0 ? pct.toStringAsFixed(0) : pct.toStringAsFixed(1),
    );
    final bar = (pct / 100).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      label:
          '${localizePaymentMethod(context, methodKey)}, $pctLabel, ${l10n.salesCount(count)}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizePaymentMethod(context, methodKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.salesCount(count),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    MoneyText(
                      value: amount,
                      currency: currency,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pctLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Semantics(
              label: pctLabel,
              value: pct.toStringAsFixed(1),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: bar,
                  minHeight: 10,
                  backgroundColor: scheme.surfaceContainerHighest.withValues(
                    alpha: 0.7,
                  ),
                  color: scheme.primary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
