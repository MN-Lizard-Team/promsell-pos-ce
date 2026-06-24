import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/checkout_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_summary_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartSummaryFooter extends StatelessWidget {
  const CartSummaryFooter({
    super.key,
    required this.bottomInset,
    required this.currency,
    required this.settings,
    required this.onCheckout,
  });

  final double bottomInset;
  final String currency;
  final Settings settings;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocBuilder<CartBloc, CartState>(
      builder: (_, state) {
        if (state.isEmpty) {
          return SizedBox(height: bottomInset + 16);
        }
        final itemDiscountTotal = state.items.fold(
          0.0,
          (s, i) => s + i.discountAmount,
        );
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
              CartSummaryRow(
                label: l10n.receiptLabelSubtotal,
                value: state.itemsSubtotal,
                currency: currency,
                theme: theme,
              ),
              if (itemDiscountTotal > 0) ...[
                const SizedBox(height: 2),
                CartSummaryRow(
                  label: l10n.receiptItemDiscounts,
                  value: -itemDiscountTotal,
                  currency: currency,
                  theme: theme,
                  valueColor: theme.colorScheme.error,
                ),
              ],
              if (state.hasCartDiscount) ...[
                const SizedBox(height: 2),
                CartSummaryRow(
                  label: l10n.cartDiscount,
                  value: -state.cartDiscountAmount,
                  currency: currency,
                  theme: theme,
                  valueColor: theme.colorScheme.error,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Divider(height: 1),
              ),
              Row(
                children: [
                  Text(
                    l10n.totalAmount,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
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
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  _navigateToCheckout(context);
                },
                icon: const Icon(Icons.shopping_bag_outlined, size: 18),
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
    final cartBloc = context.read<CartBloc>();
    final checkoutBloc = context.read<CheckoutBloc>();
    final settingsCubit = context.read<SettingsCubit>();
    final s = settingsCubit.state.settings;
    final today = DateTime.now().toIso8601String().split('T').first;
    if (s.dailyCloseLock && s.lastClosedDate == today) {
      AppSnackBar.error(context, context.l10n.dayClosedMessage);
      return;
    }
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: cartBloc),
            BlocProvider.value(value: checkoutBloc),
            BlocProvider.value(value: settingsCubit),
          ],
          child: const CheckoutPage(),
        ),
      ),
    );
  }
}
