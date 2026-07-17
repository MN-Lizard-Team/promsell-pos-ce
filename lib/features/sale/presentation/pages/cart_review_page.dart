import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_body.dart';

/// Full-page bill review — Counter Receipt Dock layout.
class CartReviewPage extends StatelessWidget {
  const CartReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // Back = return to catalog / add items (single exit).
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: context.l10n.addItems,
          onPressed: () => Navigator.maybePop(context),
        ),
        title: BlocBuilder<CartBloc, CartState>(
          buildWhen: (p, c) =>
              p.itemCount != c.itemCount || p.tableId != c.tableId,
          builder: (context, cartState) {
            return BlocBuilder<DraftBloc, DraftState>(
              buildWhen: (p, c) => p.activeDraftName != c.activeDraftName,
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
                  children: [
                    Text(context.l10n.cartTitle),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            buildWhen: (p, c) => p.isEmpty != c.isEmpty,
            builder: (context, state) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!state.isEmpty)
                    TextButton(
                      onPressed: () => CartReviewBody.clearCart(context, state),
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      child: Text(
                        context.l10n.clearCart,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
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
        ],
      ),
      body: const CartReviewBody(),
    );
  }
}
