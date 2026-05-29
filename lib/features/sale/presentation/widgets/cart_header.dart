import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({super.key, required this.state});

  final SaleState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
      child: Row(
        children: [
          Icon(Icons.shopping_cart_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.l10n.cartTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (!state.isEmpty)
            TextButton.icon(
              onPressed: () => _confirmClearCart(context),
              icon: const Icon(Icons.delete_outline),
              label: Text(context.l10n.clearCart),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                minimumSize: const Size(48, 48),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    final bloc = context.read<SaleBloc>();
    final prevItems = List<CartItem>.from(bloc.state.items);
    final prevDiscountType = bloc.state.cartDiscountType;
    final prevDiscountValue = bloc.state.cartDiscountValue;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.clearCart),
        content: Text(context.l10n.confirmClearCart),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final l10n = context.l10n;
              bloc.add(const SaleCartCleared());
              Navigator.pop(dialogCtx);
              AppSnackBar.withAction(
                context,
                l10n.cartCleared,
                actionLabel: l10n.undo,
                onAction: () => bloc.add(
                  SaleCartRestored(
                    items: prevItems,
                    cartDiscountType: prevDiscountType,
                    cartDiscountValue: prevDiscountValue,
                  ),
                ),
              );
            },
            child: Text(
              context.l10n.clearCart,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
