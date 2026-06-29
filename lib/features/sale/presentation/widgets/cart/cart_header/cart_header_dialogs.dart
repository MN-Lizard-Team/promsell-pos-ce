import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';

class _CreateDraftDialog extends StatefulWidget {
  const _CreateDraftDialog({required this.bloc});

  final DraftBloc bloc;

  @override
  State<_CreateDraftDialog> createState() => _CreateDraftDialogState();
}

class _CreateDraftDialogState extends State<_CreateDraftDialog> {
  late final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.newDraft),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        decoration: InputDecoration(hintText: l10n.draftNameHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final name = _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim();
            widget.bloc.add(DraftCreated(name: name));
            Navigator.pop(context);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

class CartHeaderDialogs {
  CartHeaderDialogs._();

  static void showCreateDialog(BuildContext context) {
    final bloc = context.read<DraftBloc>();
    showDialog(
      context: context,
      builder: (_) => _CreateDraftDialog(bloc: bloc),
    );
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
