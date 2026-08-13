import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/report/presentation/widgets/report_section_card.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:thai_promptpay/thai_promptpay.dart' as pp;

class ReportPromptPayCard extends StatelessWidget {
  const ReportPromptPayCard({
    super.key,
    required this.sales,
    required this.currency,
    required this.fmt,
    required this.calculator,
  });

  final List<Sale> sales;
  final String currency;
  final DateFormat fmt;
  final ReportCalculatorService calculator;

  String _bankLabel(BuildContext context, String code) {
    final bank = pp.thaiBankByCode(code);
    if (bank == null) return code;
    final isTh = Localizations.localeOf(context).languageCode == 'th';
    if (isTh) {
      return bank.nameTh.isNotEmpty ? bank.nameTh : code;
    }
    return bank.nameEn.isNotEmpty
        ? bank.nameEn
        : (bank.nameTh.isNotEmpty ? bank.nameTh : code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final promptPaySales = calculator.promptPaySales(sales);

    if (promptPaySales.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = calculator.promptPayLegTotal(sales).value;
    final average = promptPaySales.isEmpty
        ? 0.0
        : total / promptPaySales.length;

    return ReportSectionCard(
      title: l10n.promptpay,
      icon: TablerIcons.wallet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.netRevenue,
                  value: total,
                  currency: currency,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: l10n.salesCount(promptPaySales.length),
                  value: null,
                  count: promptPaySales.length,
                  currency: currency,
                  theme: theme,
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: l10n.reportAverage,
                  value: average,
                  currency: currency,
                  theme: theme,
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Text(
            l10n.reportRecent,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          ...promptPaySales.take(5).map((s) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      fmt.format(s.createdAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _bankLabel(context, s.sendingBankCode!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSecondaryContainer,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  MoneyText(
                    value: calculator.promptPayLegAmount(s).value,
                    currency: currency,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ],
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
            currency: currency,
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
