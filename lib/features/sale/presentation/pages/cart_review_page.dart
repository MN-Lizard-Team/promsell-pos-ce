import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_review_body.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_primary_app_bar.dart';

/// Full-page live bill — Counter Receipt Dock (not a bottom sheet).
class CartReviewPage extends StatelessWidget {
  const CartReviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pos = context.posTheme;
    final media = MediaQuery.of(context);

    return KeyedSubtree(
      key: const ValueKey('sale_cart_review_page'),
      child: Scaffold(
        // Continuous ticket paper under AppBar (no slate gap).
        backgroundColor: pos.billStubPaper,
        resizeToAvoidBottomInset: true,
        appBar: PosPrimaryAppBar(
          // Square bottom — no radius on cart review AppBar.
          roundBottom: false,
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
                          style: PosPrimaryAppBar.subtitleStyle(scheme),
                        ),
                    ],
                  );
                },
              );
            },
          ),
          actions: [
            BlocBuilder<CartBloc, CartState>(
              buildWhen: (p, c) =>
                  p.isEmpty != c.isEmpty || p.paymentLocked != c.paymentLocked,
              builder: (context, state) {
                final locked = CartLineActions.isPaymentLocked(context);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: context.l10n.draftsTitle,
                      icon: const Icon(Icons.receipt_long_outlined),
                      onPressed: () => CartReviewBody.handleMenuAction(
                        context,
                        CartMenuAction.drafts,
                        state,
                      ),
                    ),
                    // Clear in overflow — hidden while payment locked.
                    if (!state.isEmpty && !locked)
                      PopupMenuButton<String>(
                        key: const ValueKey('sale_cart_review_more'),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).moreButtonTooltip,
                        onSelected: (v) {
                          if (v == 'clear') {
                            CartReviewBody.clearCart(context, state);
                          }
                        },
                        itemBuilder: (ctx) => [
                          PopupMenuItem(
                            value: 'clear',
                            child: Text(
                              context.l10n.clearCart,
                              style: TextStyle(color: scheme.error),
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: MediaQuery(
          data: media.copyWith(viewInsets: media.viewInsets),
          child: const SafeArea(top: false, child: CartReviewBody()),
        ),
      ),
    );
  }
}
