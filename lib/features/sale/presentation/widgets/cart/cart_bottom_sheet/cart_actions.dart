import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';

class CartActions {
  CartActions._();

  static void changeQty(
    BuildContext context,
    CartBloc bloc,
    CartItem item,
    int delta,
  ) {
    if (delta < 0 && item.qty == 1) {
      removeItem(context, bloc, item);
      return;
    }
    final newQty = (item.qty + delta).clamp(1, 9999);
    if (newQty != item.qty) {
      HapticFeedback.selectionClick();
      bloc.add(CartItemQtyChanged(productId: item.product.id, qty: newQty));
    }
  }

  static void removeItem(BuildContext context, CartBloc bloc, CartItem item) {
    HapticFeedback.mediumImpact();
    bloc.add(CartProductRemoved(item.product.id));
    AppSnackBar.withAction(
      context,
      context.l10n.itemRemoved,
      actionLabel: context.l10n.undo,
      onAction: () {
        bloc.add(CartItemRestored(item));
      },
    );
  }
}
