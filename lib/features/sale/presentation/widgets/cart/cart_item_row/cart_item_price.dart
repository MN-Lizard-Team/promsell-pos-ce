import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

class CartItemDiscountBadge extends StatelessWidget {
  const CartItemDiscountBadge({
    super.key,
    required this.currency,
    required this.discountAmount,
  });

  final String currency;
  final double discountAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 12,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 3),
          Text(
            '-$currency${discountAmount.toStringAsFixed(2)}',
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: 'NotoSansThai',
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class CartItemPriceColumn extends StatelessWidget {
  const CartItemPriceColumn({
    super.key,
    required this.currency,
    required this.item,
    required this.hasDiscount,
  });

  final String currency;
  final dynamic item;
  final bool hasDiscount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasDiscount)
          Text(
            '$currency${(item.product.price * item.qty).toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasDiscount) ...[
              CartItemDiscountBadge(
                currency: currency,
                discountAmount: item.discountAmount,
              ),
              const SizedBox(width: 4),
            ],
            MoneyText(
              value: item.subtotal,
              currency: currency,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: 'NotoSansThai',
                fontWeight: FontWeight.w800,
              ),
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }
}
