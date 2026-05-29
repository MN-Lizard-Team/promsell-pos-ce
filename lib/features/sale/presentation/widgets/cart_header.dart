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
    final draftName = state.activeDraftName?.isNotEmpty == true
        ? state.activeDraftName!
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 4),
      child: Row(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            color: theme.colorScheme.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  draftName ?? context.l10n.cartTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (draftName != null)
                  Text(
                    context.l10n.cartTitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showCreateDialog(context),
            icon: const Icon(Icons.add_circle_outline, size: 20),
            tooltip: context.l10n.newDraft,
            visualDensity: VisualDensity.compact,
          ),
          if (!state.isEmpty)
            TextButton.icon(
              onPressed: () => _confirmClearCart(context),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: Text(context.l10n.clearCart),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final bloc = context.read<SaleBloc>();
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
              bloc.add(SaleDraftCreated(name: name));
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
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
