import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/image_viewer_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_detail_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_dotted_line_row.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_item_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_avatar.dart';

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

  void _showProductDetailSheet(BuildContext context, CartItem item) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ProductAvatar(
                    imagePath: item.product.imagePath,
                    imageThumbnailPath: item.product.imageThumbnailPath,
                    imageUrl: item.product.imageUrl,
                    size: 64,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.product.category ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CartDetailRow(
                'Price',
                '฿${item.product.price.toStringAsFixed(2)}',
              ),
              CartDetailRow('Stock', '${item.product.stock}'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeQty(BuildContext context, CartItem item, int delta) {
    final newQty = (item.qty + delta).clamp(1, 9999);
    if (newQty != item.qty) {
      HapticFeedback.selectionClick();
      context.read<SaleBloc>().add(
        SaleItemQtyChanged(productId: item.product.id, qty: newQty),
      );
    }
  }

  void _removeItem(BuildContext context, CartItem item) {
    HapticFeedback.mediumImpact();
    context.read<SaleBloc>().add(SaleProductRemoved(item.product.id));
    AppSnackBar.withAction(
      context,
      '${item.product.name} removed',
      actionLabel: 'Undo',
      onAction: () {
        context.read<SaleBloc>().add(SaleProductAdded(item.product));
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
            tooltip: 'Add Items',
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (_, state) {
          final items = state.items;
          final itemDiscountTotal = items.fold(
            0.0,
            (s, i) => s + i.discountAmount,
          );

          return Column(
            children: [
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
                      onRowTap: () => _showProductDetailSheet(context, item),
                      onDecrement: () => _changeQty(context, item, -1),
                      onIncrement: () => _changeQty(context, item, 1),
                      onDelete: () => _removeItem(context, item),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Card(
                  margin: EdgeInsets.zero,
                  elevation: 4,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
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
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back, size: 22),
                          label: const Text(
                            'Back to Payment',
                            style: TextStyle(
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
                          onPressed: () =>
                              Navigator.of(context).popUntil((r) => r.isFirst),
                          icon: const Icon(Icons.storefront_outlined, size: 20),
                          label: const Text(
                            'Back to Sale',
                            style: TextStyle(
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
            ],
          );
        },
      ),
    );
  }
}
