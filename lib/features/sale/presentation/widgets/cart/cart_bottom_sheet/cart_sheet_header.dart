import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';

class CartSheetHeader extends StatelessWidget {
  const CartSheetHeader({
    super.key,
    required this.title,
    this.onClear,
    this.itemCount = 0,
    this.totalDiscount = 0,
    this.currency = '',
  });

  final String title;
  final VoidCallback? onClear;
  final int itemCount;
  final double totalDiscount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Text(
                  itemCount > 0 ? context.l10n.itemsCount(itemCount) : title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onClear != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined, size: 22),
                    tooltip: context.l10n.clearCart,
                    onPressed: onClear,
                    color: theme.colorScheme.error,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          if (totalDiscount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.l10n.totalDiscountLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                MoneyText(
                  value: -totalDiscount,
                  currency: currency,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
