import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/services/restaurant_table_name_resolver.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/draft_naming.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_line_actions.dart';
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
              buildWhen: (p, c) =>
                  p.itemCount != c.itemCount || p.tableId != c.tableId,
              builder: (context, cartState) {
                return BlocBuilder<DraftBloc, DraftState>(
                  buildWhen: (p, c) =>
                      p.activeDraftName != c.activeDraftName ||
                      p.activeDraftId != c.activeDraftId,
                  builder: (context, draftState) {
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
                        _CartSubtitle(
                          draftName: draftState.activeDraftName,
                          tableId: cartState.tableId,
                          itemCount: cartState.itemCount,
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
                p.isEmpty != c.isEmpty ||
                p.itemCount != c.itemCount ||
                p.paymentLocked != c.paymentLocked,
            builder: (context, state) {
              final locked = CartLineActions.isPaymentLocked(context);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!state.isEmpty && !locked)
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

/// Subtitle under the cart title: active bill · item count · table.
///
/// Table ids resolve asynchronously via [RestaurantTableNameResolver] —
/// until then (or when the table was deleted) a short id is shown.
class _CartSubtitle extends StatefulWidget {
  const _CartSubtitle({
    required this.draftName,
    required this.tableId,
    required this.itemCount,
  });

  final String? draftName;
  final String? tableId;
  final int itemCount;

  @override
  State<_CartSubtitle> createState() => _CartSubtitleState();
}

class _CartSubtitleState extends State<_CartSubtitle> {
  String? _resolvedFor;
  String? _tableName;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(covariant _CartSubtitle old) {
    super.didUpdateWidget(old);
    if (old.tableId != widget.tableId) _resolve();
  }

  Future<void> _resolve() async {
    final id = widget.tableId?.trim();
    if (id == null || id.isEmpty || _resolvedFor == id) return;
    _resolvedFor = id;
    final name = await sl<RestaurantTableNameResolver>().resolve(id);
    if (!mounted || _resolvedFor != id) return;
    setState(() => _tableName = name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final draftName = widget.draftName?.trim();
    final tableId = widget.tableId?.trim();
    final hasTableId = tableId != null && tableId.isNotEmpty;
    // Bills parked against a table carry the raw tableId as their name —
    // swap in the resolved table name once available and skip the redundant
    // trailing table segment.
    final billIsTable = hasTableId && draftName == tableId;
    final billLabel = (draftName != null && draftName.isNotEmpty)
        ? l10n.cartActiveBill(
            billIsTable && _tableName != null ? _tableName! : draftName,
          )
        : null;
    final tableLabel = hasTableId && !billIsTable
        ? l10n.tableChipLabel(_tableName ?? DraftNaming.shortTableRef(tableId))
        : null;

    final subtitle = [
      ?billLabel,
      l10n.cartItemCount(widget.itemCount),
      ?tableLabel,
    ].join(' · ');
    if (subtitle.isEmpty) return const SizedBox.shrink();

    return Text(
      subtitle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
