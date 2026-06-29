import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';

class CartItemQtyDialog {
  CartItemQtyDialog._();

  static void show(
    BuildContext context, {
    required CartItem item,
    required bool allowOversell,
    required bool atStockLimit,
  }) {
    showDialog(
      context: context,
      builder: (_) =>
          _CartItemQtyDialogContent(item: item, allowOversell: allowOversell),
    );
  }
}

class _CartItemQtyDialogContent extends StatefulWidget {
  const _CartItemQtyDialogContent({
    required this.item,
    required this.allowOversell,
  });

  final CartItem item;
  final bool allowOversell;

  @override
  State<_CartItemQtyDialogContent> createState() =>
      _CartItemQtyDialogContentState();
}

class _CartItemQtyDialogContentState extends State<_CartItemQtyDialogContent> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.item.qty}');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final qty = int.tryParse(_ctrl.text);
    if (qty == null || qty <= 0) return;
    var clamped = qty;
    if (widget.item.product.trackStock && !widget.allowOversell) {
      clamped = qty.clamp(0, widget.item.product.stock);
    }
    Navigator.pop(context);
    if (clamped != widget.item.qty) {
      context.read<CartBloc>().add(
        CartItemQtyChanged(
          productId: widget.item.product.id,
          qty: clamped,
          allowOversell: widget.allowOversell,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(widget.item.product.name),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        decoration: InputDecoration(
          labelText: l10n.quantityLabel,
          suffixText: widget.item.product.trackStock
              ? l10n.stockLabel(widget.item.product.stock)
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}

class CartItemRemoveDialog {
  CartItemRemoveDialog._();

  static void show(BuildContext context, CartItem item, bool allowOversell) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteProduct),
        content: Text(l10n.confirmDeleteProduct(item.product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final prevItem = item;
              final bloc = context.read<CartBloc>();
              bloc.add(
                CartItemQtyChanged(
                  productId: item.product.id,
                  qty: 0,
                  allowOversell: allowOversell,
                ),
              );
              Navigator.pop(context);
              AppSnackBar.withAction(
                context,
                l10n.itemRemoved(item.product.name),
                actionLabel: l10n.undo,
                onAction: () => bloc.add(
                  CartRestored(items: [...bloc.state.items, prevItem]),
                ),
              );
            },
            child: Text(
              l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
