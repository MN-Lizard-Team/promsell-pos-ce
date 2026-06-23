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
    final theme = Theme.of(context);
    final isEnough = change >= 0;
    final color = isEnough
        ? theme.colorScheme.primary
        : theme.colorScheme.error;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      height: visible ? null : 0,
      decoration: BoxDecoration(
        color: visible ? color.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: visible ? 1.0 : 0.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                isEnough ? Icons.price_check : Icons.warning_amber_rounded,
                color: color,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isEnough ? context.l10n.change : context.l10n.remainingAmount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'NotoSansThai',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              MoneyText(
                value: change,
                currency: currency,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'NotoSansThai',
                  fontWeight: FontWeight.w700,
                ),
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AnimatedScale(
      scale: selected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: selected ? 4 : 0,
        color: selected
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: selected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: 'NotoSansThai',
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
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
    final finalStyle = style?.copyWith(fontFamily: 'NotoSansThai');
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: finalStyle)),
          Text(
            '${value < 0 ? '-' : ''}$currency${value.abs().toStringAsFixed(2)}',
            style: finalStyle,
          ),
        ],
      ),
    );
  }
}
