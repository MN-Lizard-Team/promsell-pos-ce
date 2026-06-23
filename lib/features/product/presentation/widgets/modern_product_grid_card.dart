import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_preview_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_card_shell.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_avatar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/stock_indicator.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_list_tile.dart'
    show parseCategoryColor, parseCategoryIcon;
import 'package:promsell_pos_ce/features/product/presentation/widgets/quick_edit_mixin.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ModernProductGridCard extends StatefulWidget {
  const ModernProductGridCard({super.key, required this.product});

  final Product product;

  @override
  State<ModernProductGridCard> createState() => _ModernProductGridCardState();
}

class _ModernProductGridCardState extends State<ModernProductGridCard>
    with QuickEditMixin {
  @override
  Product get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final product = widget.product;
    final theme = Theme.of(context);

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (_, catState) {
        final cat = catState.categories
            .where((c) => c.id == product.categoryId)
            .firstOrNull;

        return ProductCardShell(
          onTap: () => _showPreview(context),
          onLongPress: () => _showEdit(context),
          isActive: product.isActive,
          borderRadius: 16,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ProductAvatar(
                        imagePath: product.imagePath,
                        imageThumbnailPath: product.imageThumbnailPath,
                        imageUrl: product.imageUrl,
                        size: 52,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (cat != null)
                      Center(child: _CategoryLabel(category: cat))
                    else
                      const SizedBox(height: 16),
                    const SizedBox(height: 2),
                    InkWell(
                      onTap: () => quickEditName(context),
                      borderRadius: BorderRadius.circular(4),
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => quickEditPrice(context),
                            borderRadius: BorderRadius.circular(6),
                            child: MoneyText(
                              value: product.price,
                              currency: currency,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => quickEditStock(context),
                          borderRadius: BorderRadius.circular(8),
                          child: StockIndicator(
                            stock: product.stock,
                            trackStock: product.trackStock,
                            compact: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!product.isActive)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      context.l10n.inactive,
                      style: TextStyle(
                        color: theme.colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
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

  void _showPreview(BuildContext context) {
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
          child: ProductPreviewPage(product: widget.product),
        ),
      ),
    );
  }
}

class _CategoryLabel extends StatelessWidget {
  const _CategoryLabel({required this.category});
  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = parseCategoryColor(category.color);
    final icon = parseCategoryIcon(category.iconName);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(icon, size: 10, color: color),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}
