import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_card_shell.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_image_container.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_info_block.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_action_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ModernProductTile extends StatefulWidget {
  const ModernProductTile({super.key, required this.product});

  final Product product;

  @override
  State<ModernProductTile> createState() => _ModernProductTileState();
}

class _ModernProductTileState extends State<ModernProductTile> {
  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final product = widget.product;

    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: _DeleteBackground(),
      confirmDismiss: (_) => _confirmDelete(context),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (_, catState) {
          final cat = catState.categories
              .where((c) => c.id == product.categoryId)
              .firstOrNull;

          return ProductCardShell(
            onTap: () => _showEdit(context),
            onLongPress: () => showProductActionSheet(context, product),
            isActive: product.isActive,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProductImageContainer(
                    imagePath: product.imagePath,
                    imageThumbnailPath: product.imageThumbnailPath,
                    imageUrl: product.imageUrl,
                    categoryName: cat?.name,
                    size: 64,
                    borderRadius: BorderRadius.circular(16),
                    heroTag: product.id,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ProductInfoBlock(
                      product: product,
                      currency: currency,
                      categoryName: cat?.name,
                      layout: ProductInfoLayout.row,
                      onNameTap: () => _quickEditName(context),
                      onPriceTap: () => _quickEditPrice(context),
                      onStockTap: () => _quickEditStock(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteProduct),
        content: Text(context.l10n.confirmDeleteProduct(widget.product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(
                ProductDeleted(widget.product.id),
              );
              Navigator.pop(context, true);
            },
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _showEdit(BuildContext context) {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
          ],
          child: ProductFormPage(product: widget.product),
        ),
      ),
    );
  }

  Future<void> _quickEditName(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.name,
      initialValue: widget.product.name,
      productName: widget.product.name,
    );
    if (!context.mounted) return;
    if (result != null && result.isNotEmpty && result != widget.product.name) {
      context.read<ProductBloc>().add(
        ProductUpdated(widget.product.copyWith(name: result)),
      );
    }
  }

  Future<void> _quickEditPrice(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.price,
      initialValue: widget.product.price.toStringAsFixed(2),
      productName: widget.product.name,
    );
    if (!context.mounted) return;
    final price = double.tryParse(result ?? '');
    if (price != null && price >= 0 && price != widget.product.price) {
      context.read<ProductBloc>().add(
        ProductUpdated(widget.product.copyWith(price: price)),
      );
    }
  }

  Future<void> _quickEditStock(BuildContext context) async {
    final result = await showQuickEditSheet(
      context,
      field: QuickEditField.stock,
      initialValue: widget.product.stock.toString(),
      productName: widget.product.name,
    );
    if (!context.mounted) return;
    final stock = int.tryParse(result ?? '');
    if (stock != null && stock >= 0 && stock != widget.product.stock) {
      context.read<ProductBloc>().add(
        ProductUpdated(widget.product.copyWith(stock: stock)),
      );
    }
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.error,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Icon(Icons.delete, color: theme.colorScheme.onError, size: 28),
    );
  }
}
