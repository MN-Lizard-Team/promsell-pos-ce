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
    final itemDiscountTotal = state.items.fold<double>(
      0,
      (sum, i) => sum + i.discountAmount,
    );

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _SummaryLine(
              label: context.l10n.receiptLabelSubtotal,
              value: state.itemsSubtotal,
              currency: currency,
              theme: theme,
            ),
            if (itemDiscountTotal > 0)
              _SummaryLine(
                label: context.l10n.receiptItemDiscounts,
                value: -itemDiscountTotal,
                currency: currency,
                theme: theme,
                valueColor: theme.colorScheme.error,
              ),
            if (state.hasCartDiscount)
              _SummaryLine(
                label: context.l10n.cartDiscount,
                value: -state.cartDiscountAmount,
                currency: currency,
                theme: theme,
                valueColor: theme.colorScheme.error,
              ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Text(
                  context.l10n.totalAmount,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                MoneyText(
                  value: state.total,
                  currency: currency,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
            if (enableCartDiscount) ...[
              const SizedBox(height: 4),
              TextButton.icon(
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
                ),
                label: Text(
                  state.hasCartDiscount
                      ? context.l10n.cartDiscount
                      : context.l10n.applyCartDiscount,
                ),
              ),
            ],
            const SizedBox(height: 4),
            FilledButton.icon(
              onPressed: () => _showPayment(context, state),
              icon: const Icon(Icons.payment, size: 18),
              label: Text(context.l10n.checkout(state.itemCount)),
              style: theme.filledButtonTheme.style?.copyWith(
                minimumSize: const WidgetStatePropertyAll(
                  Size(double.infinity, 44),
                ),
              ),
            ),
          ],
        ),
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
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
      ),
    );
  }
}
