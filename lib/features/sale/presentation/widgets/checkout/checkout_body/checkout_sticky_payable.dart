import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';

/// Amount-due hero under AppBar — single money spotlight (Command Deck).
///
/// Display-only — [amount] must already be payable SSOT from the parent.
/// Stacked label + large total (cart settle dialect), not a weak horizontal row.
class CheckoutStickyPayable extends StatelessWidget {
  const CheckoutStickyPayable({
    super.key,
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = context.posTheme;
    return Material(
      key: const ValueKey('sale_checkout_sticky_payable'),
      elevation: pos.elevFlat,
      color: pos.billStubPaper,
      surfaceTintColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: pos.billStubPaper,
          border: Border(bottom: BorderSide(color: pos.billStubBorder)),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.amountDue,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: 'NotoSansThai',
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                MoneyText(
                  value: amount,
                  currency: currency,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontFamily: 'NotoSansThai',
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                  color: theme.colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
