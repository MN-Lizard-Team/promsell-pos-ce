import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';

class ReportPaymentMethodCard extends StatelessWidget {
  const ReportPaymentMethodCard({
    super.key,
    required this.byMethod,
    required this.currency,
  });

  final Map<String, double> byMethod;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.byPaymentMethod,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            if (byMethod.isEmpty)
              AppEmptyState(
                icon: Icons.payments_outlined,
                title: context.l10n.noSalesYet,
              )
            else
              ...byMethod.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(localizePaymentMethod(context, e.key)),
                      MoneyText(
                        value: e.value,
                        currency: currency,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
