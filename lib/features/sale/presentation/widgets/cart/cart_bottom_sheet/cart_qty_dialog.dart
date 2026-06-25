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
    showDialog(
      context: context,
      builder: (_) =>
          _CartQtyDialogContent(bloc: bloc, item: item, settings: settings),
    );
  }
}

class _CartQtyDialogContent extends StatefulWidget {
  const _CartQtyDialogContent({
    required this.bloc,
    required this.item,
    required this.settings,
  });

  final CartBloc bloc;
  final CartItem item;
  final Settings settings;

  @override
  State<_CartQtyDialogContent> createState() => _CartQtyDialogContentState();
}

class _CartQtyDialogContentState extends State<_CartQtyDialogContent> {
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
    if (qty == null || qty <= 0) {
      Navigator.pop(context);
      widget.bloc.add(CartProductRemoved(widget.item.product.id));
      return;
    }
    final allowOversell = widget.settings.allowOversell;
    var clamped = qty;
    if (widget.item.product.trackStock && !allowOversell) {
      clamped = qty.clamp(1, widget.item.product.stock);
    }
    Navigator.pop(context);
    if (clamped != widget.item.qty) {
      widget.bloc.add(
        CartItemQtyChanged(
          productId: widget.item.product.id,
          qty: clamped,
          allowOversell: allowOversell,
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
