import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

class CartSummaryRow extends StatelessWidget {
  const CartSummaryRow({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final double value;
  final String currency;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        MoneyText(
          value: value,
          currency: currency,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          color: valueColor ?? theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
