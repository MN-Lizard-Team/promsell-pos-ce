import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_card_shell.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_image_container.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_info_block.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_action_sheet.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ModernProductGridCard extends StatefulWidget {
  const ModernProductGridCard({super.key, required this.product});

  final Product product;

  @override
  State<ModernProductGridCard> createState() => _ModernProductGridCardState();
}

class _ModernProductGridCardState extends State<ModernProductGridCard> {
  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final product = widget.product;

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (_, catState) {
        final cat = catState.categories
            .where((c) => c.id == product.categoryId)
            .firstOrNull;

        return ProductCardShell(
          onTap: () => _showEdit(context),
          onLongPress: () => showProductActionSheet(context, product),
          isActive: product.isActive,
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImageArea(
                product: product,
                currency: currency,
                categoryName: cat?.name,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: ProductInfoBlock(
                  product: product,
                  currency: currency,
                  categoryName: cat?.name,
                  layout: ProductInfoLayout.grid,
                  onNameTap: () => _quickEditName(context),
                  onPriceTap: () => _quickEditPrice(context),
                  onStockTap: () => _quickEditStock(context),
                ),
              ),
            ],
          ),
        );
      },
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
    if (price != null && price > 0 && price != widget.product.price) {
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
}

class _ImageArea extends StatelessWidget {
  const _ImageArea({
    required this.product,
    required this.currency,
    this.categoryName,
  });

  final Product product;
  final String currency;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ProductImageContainer(
              imagePath: product.imagePath,
              imageThumbnailPath: product.imageThumbnailPath,
              imageUrl: product.imageUrl,
              categoryName: categoryName,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              heroTag: product.id,
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.scrim.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(999),
              ),
              child: MoneyText(
                value: product.price,
                currency: currency,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          if (!product.isActive)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.scrim.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  context.l10n.inactive,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
