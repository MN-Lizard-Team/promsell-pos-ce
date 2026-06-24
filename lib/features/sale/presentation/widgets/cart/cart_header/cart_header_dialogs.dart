import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';

class CartHeaderDialogs {
  CartHeaderDialogs._();

  static void showCreateDialog(BuildContext context) {
    final bloc = context.read<DraftBloc>();
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.newDraft),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: context.l10n.draftNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
              bloc.add(DraftCreated(name: name));
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  static void confirmClearCart(BuildContext context) {
    final bloc = context.read<CartBloc>();
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
              bloc.add(const CartCleared());
              Navigator.pop(dialogCtx);
              AppSnackBar.withAction(
                context,
                l10n.cartCleared,
                actionLabel: l10n.undo,
                onAction: () => bloc.add(
                  CartRestored(
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
