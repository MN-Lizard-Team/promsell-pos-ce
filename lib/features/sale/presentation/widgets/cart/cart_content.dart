import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_item_tile.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_qty_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_sheet/cart_summary_footer.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_header.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/checkout/sale_receipt_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartContent extends StatefulWidget {
  const CartContent({
    super.key,
    required this.expanded,
    required this.currency,
    required this.settings,
    this.scrollController,
    this.sizePreset,
    this.onSizePresetChanged,
    this.widthPreset,
    this.onWidthPresetChanged,
  });

  final bool expanded;
  final String currency;
  final Settings settings;
  final ScrollController? scrollController;
  final double? sizePreset;
  final ValueChanged<double>? onSizePresetChanged;
  final double? widthPreset;
  final ValueChanged<double>? onWidthPresetChanged;

  @override
  State<CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<CartContent> {
  bool _isShowingReceipt = false;

  Widget _buildItemList(List<CartItem> items) {
    final theme = Theme.of(context);

    if (widget.expanded) {
      return ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: items.length,
        onReorderItem: (oldIndex, newIndex) {
          final reordered = List<CartItem>.from(items);
          final moved = reordered.removeAt(oldIndex);
          reordered.insert(newIndex, moved);
          context.read<CartBloc>().add(
            CartItemsReordered(reordered.map((i) => i.product.id).toList()),
          );
        },
        itemBuilder: (_, index) {
          final item = items[index];
          return Dismissible(
            key: ValueKey(item.product.id),
            direction: DismissDirection.endToStart,
            dismissThresholds: const {DismissDirection.endToStart: 0.5},
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onError,
              ),
            ),
            onDismissed: (_) {
              context.read<CartBloc>().add(CartProductRemoved(item.product.id));
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CartItemTile(
                item: item,
                currency: widget.currency,
                settings: widget.settings,
                onIncrement: () => CartActions.changeQty(
                  context,
                  context.read<CartBloc>(),
                  item,
                  1,
                ),
                onDecrement: () => CartActions.changeQty(
                  context,
                  context.read<CartBloc>(),
                  item,
                  -1,
                ),
                onQtyTap: () => CartQtyDialog.show(
                  context,
                  bloc: context.read<CartBloc>(),
                  item: item,
                  settings: widget.settings,
                ),
                onDelete: () => CartActions.removeItem(
                  context,
                  context.read<CartBloc>(),
                  item,
                ),
                onDuplicate: () {
                  final allowOversell = widget.settings.allowOversell;
                  context.read<CartBloc>().add(
                    CartProductAdded(
                      item.product,
                      allowOversell: allowOversell,
                    ),
                  );
                  AppSnackBar.info(context, context.l10n.duplicateItem);
                },
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.zero,
      itemCount: items.length,
      itemBuilder: (listCtx, index) {
        final item = items[index];
        final bloc = listCtx.read<CartBloc>();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Dismissible(
            key: ValueKey(item.product.id),
            direction: DismissDirection.endToStart,
            dismissThresholds: const {DismissDirection.endToStart: 0.5},
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.delete_outline,
                color: theme.colorScheme.onError,
              ),
            ),
            onDismissed: (_) {
              CartActions.removeItem(context, bloc, item);
            },
            child: CartItemTile(
              item: item,
              currency: widget.currency,
              settings: widget.settings,
              onIncrement: () => CartActions.changeQty(context, bloc, item, 1),
              onDecrement: () => CartActions.changeQty(context, bloc, item, -1),
              onQtyTap: () => CartQtyDialog.show(
                context,
                bloc: bloc,
                item: item,
                settings: widget.settings,
              ),
              onDelete: () => CartActions.removeItem(context, bloc, item),
              onDuplicate: () {
                final allowOversell = widget.settings.allowOversell;
                bloc.add(
                  CartProductAdded(item.product, allowOversell: allowOversell),
                );
                AppSnackBar.info(context, context.l10n.duplicateItem);
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<CheckoutBloc, CheckoutState>(
      listenWhen: (prev, curr) => curr.status == CheckoutStatus.success,
      listener: (ctx, state) {
        if (_isShowingReceipt) return;
        final settings = ctx.read<SettingsCubit>().state.settings;
        if (settings.autoPrintPrompt && state.lastSale != null) {
          final sale = state.lastSale!;
          _isShowingReceipt = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ctx.mounted) {
              SaleReceiptDialog.show(ctx, sale, settings).then((_) {
                _isShowingReceipt = false;
                if (ctx.mounted) {
                  ctx.read<CheckoutBloc>().add(const CheckoutReset());
                }
              });
            }
          });
        } else {
          AppSnackBar.success(ctx, ctx.l10n.saleSavedSuccess);
          ctx.read<CheckoutBloc>().add(const CheckoutReset());
        }
      },
      child: BlocBuilder<CartBloc, CartState>(
        builder: (ctx, state) {
          final draftState = ctx.watch<DraftBloc>().state;

          return Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CartHeader(
                  cartState: state,
                  draftState: draftState,
                  expanded: widget.expanded,
                  sizePreset: widget.sizePreset,
                  onSizePresetChanged: widget.onSizePresetChanged,
                  widthPreset: widget.widthPreset,
                  onWidthPresetChanged: widget.onWidthPresetChanged,
                ),
                if (state.isEmpty)
                  Expanded(
                    child: AppEmptyState(
                      icon: Icons.shopping_cart_outlined,
                      title: ctx.l10n.tapProductToAdd,
                    ),
                  )
                else ...[
                  Expanded(child: _buildItemList(state.items)),
                  CartSummaryFooter(
                    bottomInset: 0,
                    currency: widget.currency,
                    settings: widget.settings,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
