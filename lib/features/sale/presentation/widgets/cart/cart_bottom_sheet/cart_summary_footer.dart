import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class CartSummaryFooter extends StatefulWidget {
  const CartSummaryFooter({
    super.key,
    required this.bottomInset,
    required this.currency,
    required this.settings,
  });

  final double bottomInset;
  final String currency;
  final Settings settings;

  @override
  State<CartSummaryFooter> createState() => _CartSummaryFooterState();
}

class _CartSummaryFooterState extends State<CartSummaryFooter> {
  bool _checkingOut = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currency = widget.currency;
    final settings = widget.settings;
    final bottomInset = widget.bottomInset;

    return BlocBuilder<CartBloc, CartState>(
      builder: (_, state) {
        if (state.isEmpty) {
          return SizedBox(height: bottomInset + 16);
        }
        return Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottomInset),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow,
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (state.hasCartDiscount ||
                      state.items.any((i) => i.discountAmount > 0)) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.receiptLabelSubtotal,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        MoneyText(
                          value: state.itemsSubtotal,
                          currency: currency,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.totalAmount,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        MoneyText(
                          value: state.total,
                          currency: currency,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (settings.enableCartDiscount) ...[
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () => DiscountDialog.showCartDiscount(
                    context,
                    title: l10n.cartDiscount,
                    currency: currency,
                    initialType:
                        state.cartDiscountType ?? settings.defaultDiscountType,
                    initialValue: state.cartDiscountValue,
                    onApply: (type, value) {
                      context.read<CartBloc>().add(
                        CartDiscountChanged(
                          discountType: type,
                          discountValue: value,
                        ),
                      );
                    },
                    onClear: state.hasCartDiscount
                        ? () => context.read<CartBloc>().add(
                            const CartDiscountCleared(),
                          )
                        : null,
                    maxPercent: settings.maxDiscountPercent,
                    maxAmount: settings.maxDiscountAmount,
                    presetValues: settings.activeDiscountPreset.values,
                    presetType: settings.activeDiscountPreset.type,
                  ),
                  icon: Icon(
                    state.hasCartDiscount
                        ? Icons.local_offer
                        : Icons.local_offer_outlined,
                    size: 18,
                  ),
                  label: Text(
                    state.hasCartDiscount
                        ? l10n.cartDiscount
                        : l10n.applyCartDiscount,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              FilledButton.icon(
                onPressed: _checkingOut
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _navigateToCheckout(context);
                      },
                icon: _checkingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.shopping_bag_outlined, size: 18),
                label: Text(l10n.checkout(state.itemCount)),
                style: theme.filledButtonTheme.style?.copyWith(
                  minimumSize: const WidgetStatePropertyAll(
                    Size(double.infinity, 44),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToCheckout(BuildContext context) {
    navigateToCheckout(
      context,
      onLoadingChange: (loading) {
        if (mounted) setState(() => _checkingOut = loading);
      },
    );
  }
}
