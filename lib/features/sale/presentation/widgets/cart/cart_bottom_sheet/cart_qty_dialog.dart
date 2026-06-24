import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

class CartQtyDialog {
  CartQtyDialog._();

  static void show(
    BuildContext context, {
    required CartBloc bloc,
    required CartItem item,
    required Settings settings,
  }) {
    final ctrl = TextEditingController(text: '${item.qty}');
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item.product.name),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(signed: true),
          decoration: InputDecoration(
            labelText: l10n.quantityLabel,
            suffixText: item.product.trackStock
                ? l10n.stockLabel(item.product.stock)
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final qty = int.tryParse(ctrl.text);
              if (qty == null || qty <= 0) {
                Navigator.pop(context);
                bloc.add(CartProductRemoved(item.product.id));
                return;
              }
              final allowOversell = settings.allowOversell;
              var clamped = qty;
              if (item.product.trackStock && !allowOversell) {
                clamped = qty.clamp(1, item.product.stock);
              }
              Navigator.pop(context);
              if (clamped != item.qty) {
                bloc.add(
                  CartItemQtyChanged(
                    productId: item.product.id,
                    qty: clamped,
                    allowOversell: allowOversell,
                  ),
                );
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}
