import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/checkout_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/discount_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartTotalBar extends StatelessWidget {
  const CartTotalBar({super.key, required this.state, required this.currency});

  final SaleState state;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.read<SettingsCubit>().state.settings;
    final enableCartDiscount = settings.enableCartDiscount;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 520;
          final showBreakdown = state.hasCartDiscount;
          final total = Column(
            crossAxisAlignment: isNarrow
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.cartTotal,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              MoneyText(
                value: state.total,
                currency: currency,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                color: theme.colorScheme.primary,
              ),
              if (showBreakdown) ...[
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MoneyText(
                      value: state.itemsSubtotal,
                      currency: currency,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '-$currency${state.cartDiscountAmount.toStringAsFixed(2)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (settings.vatMode == 'EXCLUSIVE' && settings.vatRate > 0) ...[
                const SizedBox(height: 2),
                Text(
                  '+${context.l10n.receiptLabelVat} ${settings.vatRate}%',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          );
          final checkout = FilledButton.icon(
            onPressed: () => _showPayment(context, state),
            icon: const Icon(Icons.payment, size: 18),
            label: Text(context.l10n.checkout(state.itemCount)),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 40),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          );

          final discountBtn = enableCartDiscount
              ? TextButton.icon(
                  onPressed: () => DiscountDialog.showCartDiscount(
                    context,
                    title: context.l10n.cartDiscount,
                    currency: currency,
                    initialType:
                        state.cartDiscountType ?? settings.defaultDiscountType,
                    initialValue: state.cartDiscountValue,
                    onApply: (type, value) {
                      context.read<SaleBloc>().add(
                        SaleCartDiscountChanged(
                          discountType: type,
                          discountValue: value,
                        ),
                      );
                    },
                    onClear: state.hasCartDiscount
                        ? () => context.read<SaleBloc>().add(
                            const SaleCartDiscountCleared(),
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
                    color: state.hasCartDiscount
                        ? theme.colorScheme.error
                        : null,
                  ),
                  label: Text(
                    state.hasCartDiscount
                        ? '$currency${state.cartDiscountAmount.toStringAsFixed(2)}'
                        : context.l10n.applyCartDiscount,
                    style: state.hasCartDiscount
                        ? TextStyle(color: theme.colorScheme.error)
                        : null,
                  ),
                )
              : null;

          if (isNarrow) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  total,
                  const SizedBox(height: 2),
                  ...(discountBtn != null ? [discountBtn] : const <Widget>[]),
                  const SizedBox(height: 2),
                  FilledButton.icon(
                    onPressed: () => _showPayment(context, state),
                    icon: const Icon(Icons.payment, size: 18),
                    label: Text(context.l10n.checkout(state.itemCount)),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                discountBtn ?? const SizedBox.shrink(),
                const Spacer(),
                total,
                const SizedBox(width: 12),
                checkout,
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPayment(BuildContext context, SaleState state) {
    final settings = context.read<SettingsCubit>().state.settings;
    final today = DateTime.now().toIso8601String().split('T').first;
    if (settings.dailyCloseLock && settings.lastClosedDate == today) {
      AppSnackBar.error(context, context.l10n.dayClosedMessage);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<SaleBloc>(),
          child: BlocProvider.value(
            value: context.read<SettingsCubit>(),
            child: const CheckoutPage(),
          ),
        ),
      ),
    );
  }
}
