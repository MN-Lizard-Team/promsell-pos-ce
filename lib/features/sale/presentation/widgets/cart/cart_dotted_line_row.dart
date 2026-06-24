import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

class CartDottedLineRow extends StatelessWidget {
  const CartDottedLineRow({
    super.key,
    required this.label,
    required this.value,
    required this.currency,
    this.valueColor,
  });

  final String label;
  final double value;
  final String currency;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final textStyle = theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outlineVariant,
                letterSpacing: 1.5,
              );
              final textSpan = TextSpan(text: '.', style: textStyle);
              final painter = TextPainter(
                text: textSpan,
                textDirection: TextDirection.ltr,
              )..layout();
              final dotWidth = painter.width;
              final count = (constraints.maxWidth / dotWidth).floor();
              return Text(
                '.' * count.clamp(0, 100),
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.clip,
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        MoneyText(
          value: value,
          currency: currency,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          color: valueColor ?? theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
