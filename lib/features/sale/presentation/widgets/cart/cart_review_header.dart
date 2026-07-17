import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_body.dart';

/// Shared cart title row: bill name + item count + clear all + drafts.
class CartReviewHeader extends StatelessWidget {
  const CartReviewHeader({
    super.key,
    this.showClose = false,
    this.onClose,
    this.onAddItems,
  });

  final bool showClose;
  final VoidCallback? onClose;
  final VoidCallback? onAddItems;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              buildWhen: (p, c) => p.itemCount != c.itemCount,
              builder: (context, cartState) {
                return BlocBuilder<DraftBloc, DraftState>(
                  buildWhen: (p, c) =>
                      p.activeDraftName != c.activeDraftName ||
                      p.activeDraftId != c.activeDraftId,
                  builder: (context, draftState) {
                    final draftName = draftState.activeDraftName?.trim();
                    final tableId = cartState.tableId?.trim();
                    final subtitle = [
                      if (draftName != null && draftName.isNotEmpty)
                        context.l10n.cartActiveBill(draftName),
                      context.l10n.cartItemCount(cartState.itemCount),
                      if (tableId != null && tableId.isNotEmpty) tableId,
                    ].join(' · ');

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.cartTitle,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) =>
                p.isEmpty != c.isEmpty || p.itemCount != c.itemCount,
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!state.isEmpty)
                    TextButton(
                      onPressed: () => CartReviewBody.clearCart(context, state),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Text(
                        context.l10n.clearCart,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (onAddItems != null)
                    IconButton(
                      tooltip: context.l10n.addItems,
                      icon: const Icon(Icons.add_shopping_cart_outlined),
                      onPressed: onAddItems,
                    ),
                  IconButton(
                    tooltip: context.l10n.draftsTitle,
                    icon: const Icon(Icons.folder_copy_outlined),
                    onPressed: () => CartReviewBody.handleMenuAction(
                      context,
                      CartMenuAction.drafts,
                      state,
                    ),
                  ),
                ],
              );
            },
          ),
          if (showClose)
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              icon: const Icon(Icons.close),
              onPressed: onClose ?? () => Navigator.maybePop(context),
            ),
        ],
      ),
    );
  }
}
