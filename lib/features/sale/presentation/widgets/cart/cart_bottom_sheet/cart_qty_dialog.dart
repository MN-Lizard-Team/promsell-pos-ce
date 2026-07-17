import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';

class CartQtyDialog {
  CartQtyDialog._();

  static void show(
    BuildContext context, {
    required CartBloc bloc,
    required CartItem item,
    required bool allowOversell,
  }) {
    showDialog(
      context: context,
      builder: (_) => _CartQtyDialogContent(
        bloc: bloc,
        item: item,
        allowOversell: allowOversell,
      ),
    );
  }
}

class _CartQtyDialogContent extends StatefulWidget {
  const _CartQtyDialogContent({
    required this.bloc,
    required this.item,
    required this.allowOversell,
  });

  final CartBloc bloc;
  final CartItem item;
  final bool allowOversell;

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
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  void _pop() {
    unfocusForDialogClose();
    Navigator.pop(context);
  }

  Future<void> _save() async {
    final qty = int.tryParse(_ctrl.text);
    if (qty == null) return;

    if (qty <= 0) {
      final l10n = context.l10n;
      final confirmed = await showConfirmationDialog(
        context,
        title: l10n.removeCartLineTitle,
        message: '',
        detail: widget.item.product.name,
        footnote: l10n.removeCartLineQty(widget.item.qty),
        confirmLabel: l10n.removeCartLineConfirm,
        cancelLabel: l10n.cancel,
        destructive: true,
        confirmIcon: Icons.delete_outline_rounded,
      );
      if (confirmed && mounted) {
        _pop();
        widget.bloc.add(
          CartProductRemoved(
            widget.item.product.id,
            lineId: widget.item.lineId,
          ),
        );
      }
      return;
    }

    var clamped = qty;
    if (widget.item.product.trackStock && !widget.allowOversell) {
      clamped = qty.clamp(1, widget.item.product.stock);
    }
    _pop();
    if (clamped != widget.item.qty) {
      widget.bloc.add(
        CartItemQtyChanged(
          productId: widget.item.product.id,
          qty: clamped,
          allowOversell: widget.allowOversell,
          lineId: widget.item.lineId,
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
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(onPressed: _pop, child: Text(l10n.cancel)),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
