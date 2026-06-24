import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:thai_promptpay/thai_promptpay.dart' as pp;

class ReportPromptPayCard extends StatelessWidget {
  const ReportPromptPayCard({
    super.key,
    required this.sales,
    required this.currency,
    required this.fmt,
  });

  final List<Sale> sales;
  final String currency;
  final DateFormat fmt;

  List<Sale> get _promptPaySales => sales
      .where((s) => !s.isVoided && s.paymentMethod == 'promptpay')
      .toList();

  double get _total =>
      _promptPaySales.fold(0.0, (sum, s) => sum + s.totalAmount);

  double get _average =>
      _promptPaySales.isEmpty ? 0.0 : _total / _promptPaySales.length;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    if (_promptPaySales.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.promptpay,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: l10n.netRevenue,
                    value: _total,
                    currency: currency,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: l10n.salesCount(_promptPaySales.length),
                    value: null,
                    count: _promptPaySales.length,
                    currency: currency,
                    theme: theme,
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: 'Average',
                    value: _average,
                    currency: currency,
                    theme: theme,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Recent',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ..._promptPaySales.take(5).map((s) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        fmt.format(s.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (s.sendingBankCode != null &&
                        s.sendingBankCode!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          pp.thaiBankByCode(s.sendingBankCode!)?.nameTh ??
                              s.sendingBankCode!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.tertiary,
                          ),
                        ),
                      )
                    else if (s.paymentReference != null &&
                        s.paymentReference!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s.paymentReference!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    MoneyText(
                      value: s.totalAmount,
                      currency: currency,
                      style: theme.textTheme.bodyMedium,
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    this.value,
    this.count,
    required this.currency,
    required this.theme,
  });

  final String label;
  final double? value;
  final int? count;
  final String currency;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        if (value != null)
          MoneyText(
            value: value!,
            currency: '',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          )
        else
          Text(
            count?.toString() ?? '0',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}
