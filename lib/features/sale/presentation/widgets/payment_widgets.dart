import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';

class ChangePreview extends StatelessWidget {
  const ChangePreview({
    super.key,
    required this.change,
    required this.currency,
    required this.visible,
  });

  final double change;
  final String currency;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isEnough = change >= 0;
    final color = isEnough
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              isEnough ? Icons.price_check : Icons.warning_amber_rounded,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                context.l10n.change,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            MoneyText(
              value: isEnough ? change : 0,
              currency: currency,
              style: theme.textTheme.titleMedium,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentTotalRow extends StatelessWidget {
  const PaymentTotalRow({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    this.style,
  });

  final String label;
  final double value;
  final String currency;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            '${value < 0 ? '-' : ''}$currency${value.abs().toStringAsFixed(2)}',
            style: style,
          ),
        ],
      ),
    );
  }
}
