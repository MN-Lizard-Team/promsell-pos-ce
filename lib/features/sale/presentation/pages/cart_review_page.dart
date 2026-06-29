import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/image/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_dotted_line_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_product_detail_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartReviewPage extends StatelessWidget {
  const CartReviewPage({super.key});

  void _showImageDialog(BuildContext context, CartItem item) {
    ImageViewerDialog.showSingle(
      context,
      ImageViewerDialog.providerFromPaths(
        imagePath: item.product.imagePath,
        imageUrl: item.product.imageUrl,
      ),
    );
  }

  void _changeQty(BuildContext context, CartItem item, int delta) {
    final newQty = (item.qty + delta).clamp(1, 9999);
    if (newQty != item.qty) {
      HapticFeedback.selectionClick();
      context.read<CartBloc>().add(
        CartItemQtyChanged(productId: item.product.id, qty: newQty),
      );
    }
  }

  void _removeItem(BuildContext context, CartItem item) {
    HapticFeedback.mediumImpact();
    context.read<CartBloc>().add(CartProductRemoved(item.product.id));
    AppSnackBar.withAction(
      context,
      context.l10n.itemRemoved(item.product.name),
      actionLabel: context.l10n.undo,
      onAction: () {
        context.read<CartBloc>().add(CartProductAdded(item.product));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.cartTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            tooltip: context.l10n.addItems,
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (_, state) {
          final items = state.items;
          final itemDiscountTotal = items.fold(
            0.0,
            (s, i) => s + i.discountAmount,
          );

          return Column(
            children: [
              if (state.isEmpty)
                Expanded(
                  child: AppEmptyState(
                    icon: Icons.shopping_cart_outlined,
                    title: context.l10n.tapProductToAdd,
                  ),
                )
              else ...[
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final item = items[index];
                      return CartItemCard(
                        item: item,
                        currency: currency,
                        onImageTap: () => _showImageDialog(context, item),
                        onRowTap: () =>
                            CartProductDetailSheet.show(context, item),
                        onDecrement: () => _changeQty(context, item, -1),
                        onIncrement: () => _changeQty(context, item, 1),
                        onDelete: () => _removeItem(context, item),
                      );
                    },
                  ),
                ),
              ],
              SafeArea(
                child: Material(
                  elevation: 0,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.shadow.withValues(
                            alpha: 0.08,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CartDottedLineRow(
                            label: context.l10n.receiptLabelSubtotal,
                            value: state.itemsSubtotal,
                            currency: currency,
                          ),
                          if (itemDiscountTotal > 0) ...[
                            const SizedBox(height: 8),
                            CartDottedLineRow(
                              label: context.l10n.receiptItemDiscounts,
                              value: -itemDiscountTotal,
                              currency: currency,
                              valueColor: theme.colorScheme.error,
                            ),
                          ],
                          if (state.hasCartDiscount) ...[
                            const SizedBox(height: 8),
                            CartDottedLineRow(
                              label: context.l10n.cartDiscount,
                              value: -state.cartDiscountAmount,
                              currency: currency,
                              valueColor: theme.colorScheme.error,
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          Row(
                            children: [
                              Text(
                                context.l10n.totalAmount,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              MoneyText(
                                value: state.total,
                                currency: currency,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'NotoSansThai',
                                  fontWeight: FontWeight.w800,
                                ),
                                color: theme.colorScheme.onSurface,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: () => navigateToCheckout(context),
                            icon: const Icon(Icons.payment, size: 22),
                            label: Text(
                              context.l10n.checkoutButton,
                              style: const TextStyle(
                                fontFamily: 'NotoSansThai',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () => Navigator.of(
                              context,
                            ).popUntil((r) => r.isFirst),
                            icon: const Icon(
                              Icons.storefront_outlined,
                              size: 20,
                            ),
                            label: Text(
                              context.l10n.backToSale,
                              style: const TextStyle(
                                fontFamily: 'NotoSansThai',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
