import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/payment_sheet_redesign.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/discount_dialog.dart';

class CartTotalBar extends StatelessWidget {
  const CartTotalBar({super.key, required this.state, required this.currency});

  final SaleState state;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 340;
          final total = Column(
            crossAxisAlignment: isNarrow
                ? CrossAxisAlignment.stretch
                : CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.cartTotal,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              MoneyText(
                value: state.total,
                currency: currency,
                style: theme.textTheme.headlineSmall,
                color: theme.colorScheme.primary,
              ),
            ],
          );
          final checkout = FilledButton.icon(
            onPressed: () => _showPayment(context, state),
            icon: const Icon(Icons.payment),
            label: Text(context.l10n.checkout(state.itemCount)),
          );

          final discountBtn = TextButton.icon(
            onPressed: () => DiscountDialog.showCartDiscount(
              context,
              title: context.l10n.cartDiscount,
              currency: currency,
              initialType: state.cartDiscountType ?? 'PERCENT',
              initialValue: state.cartDiscountValue,
              onApply: (type, value) {
                context.read<SaleBloc>().add(
                  SaleCartDiscountChanged(discountType: type, discountValue: value),
                );
              },
              onClear: state.hasCartDiscount
                  ? () => context.read<SaleBloc>().add(const SaleCartDiscountCleared())
                  : null,
            ),
            icon: Icon(
              state.hasCartDiscount
                  ? Icons.local_offer
                  : Icons.local_offer_outlined,
              size: 18,
              color: state.hasCartDiscount
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            label: Text(
              state.hasCartDiscount
                  ? '$currency${state.cartDiscountAmount.toStringAsFixed(2)}'
                  : context.l10n.applyCartDiscount,
              style: state.hasCartDiscount
                  ? TextStyle(color: Theme.of(context).colorScheme.error)
                  : null,
            ),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                discountBtn,
                total,
                const SizedBox(height: 10),
                checkout,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [discountBtn, const Spacer(), checkout]),
              total,
            ],
          );
        },
      ),
    );
  }

  void _showPayment(BuildContext context, SaleState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<SaleBloc>(),
        child: PaymentSheet(total: state.total),
      ),
    );
  }
}
