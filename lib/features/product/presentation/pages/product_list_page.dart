import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/money_text.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_form_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

enum _ViewMode { list, grid }

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ProductBloc>(),
      child: const _ProductListView(),
    );
  }
}

class _ProductListView extends StatefulWidget {
  const _ProductListView();

  @override
  State<_ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<_ProductListView> {
  final _searchController = TextEditingController();
  _ViewMode _viewMode = _ViewMode.list;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) =>
          curr.status == ProductStatus.failure &&
          prev.status != ProductStatus.failure,
      listener: (ctx, state) {
        AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.errorOccurred);
      },
      child: BlocListener<ProductBloc, ProductState>(
        listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
        listener: (_, state) {
          if (_searchController.text != state.searchQuery) {
            _searchController.text = state.searchQuery;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.productsTitle),
            actions: [
              IconButton(
                tooltip: context.l10n.listView,
                icon: _viewMode == _ViewMode.list
                    ? const Icon(Icons.view_list)
                    : const Icon(Icons.view_list_outlined),
                color: _viewMode == _ViewMode.list
                    ? Theme.of(context).colorScheme.primary
                    : null,
                onPressed: () => setState(() => _viewMode = _ViewMode.list),
              ),
              IconButton(
                tooltip: context.l10n.gridView,
                icon: _viewMode == _ViewMode.grid
                    ? const Icon(Icons.grid_view)
                    : const Icon(Icons.grid_view_outlined),
                color: _viewMode == _ViewMode.grid
                    ? Theme.of(context).colorScheme.primary
                    : null,
                onPressed: () => setState(() => _viewMode = _ViewMode.grid),
              ),
              const SizedBox(width: 4),
              IconButton.filled(
                tooltip: context.l10n.addProduct,
                icon: const Icon(Icons.add),
                onPressed: () => _showProductForm(context, null),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: SafeArea(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                final categories =
                    state.products
                        .map((p) => p.category)
                        .whereType<String>()
                        .toSet()
                        .toList()
                      ..sort();
                final selectedCategory =
                    categories.contains(state.categoryFilter)
                    ? state.categoryFilter
                    : null;
                final products = selectedCategory == null
                    ? state.filtered
                    : state.filtered
                          .where((p) => p.category == selectedCategory)
                          .toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                      child: SearchBar(
                        controller: _searchController,
                        hintText: context.l10n.searchProducts,
                        leading: const Icon(Icons.search),
                        onChanged: (q) => context.read<ProductBloc>().add(
                          ProductSearchChanged(q),
                        ),
                      ),
                    ),
                    if (categories.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 6),
                          itemBuilder: (_, i) {
                            if (i == 0) {
                              return FilterChip(
                                label: Text(context.l10n.allCategories),
                                selected: selectedCategory == null,
                                onSelected: (_) =>
                                    context.read<ProductBloc>().add(
                                      const ProductCategoryFilterChanged(null),
                                    ),
                              );
                            }
                            final cat = categories[i - 1];
                            return FilterChip(
                              label: Text(cat),
                              selected: selectedCategory == cat,
                              onSelected: (_) =>
                                  context.read<ProductBloc>().add(
                                    ProductCategoryFilterChanged(
                                      selectedCategory == cat ? null : cat,
                                    ),
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Expanded(child: _buildContent(context, state, products)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ProductState state,
    List<Product> products,
  ) {
    if (state.status == ProductStatus.loading ||
        state.status == ProductStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == ProductStatus.failure) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: state.errorMessage ?? context.l10n.errorOccurred,
      );
    }
    if (products.isEmpty) {
      return state.products.isEmpty
          ? AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.noProductsYet,
            )
          : AppEmptyState(
              icon: Icons.search_off,
              title: context.l10n.noMatchingProducts,
            );
    }
    return RefreshIndicator(
      onRefresh: () async {
        final bloc = context.read<ProductBloc>();
        bloc.add(const ProductsSubscribed());
        await bloc.stream.firstWhere(
          (s) =>
              s.status == ProductStatus.success ||
              s.status == ProductStatus.failure,
        );
      },
      child: _viewMode == _ViewMode.list
          ? ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ProductTile(product: products[i]),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.76,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => _ProductGridCard(product: products[i]),
            ),
    );
  }

  void _showProductForm(BuildContext context, Product? product) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: ProductFormPage(product: product),
      ),
    );
    if (result == true && context.mounted) {
      AppSnackBar.success(context, context.l10n.productSaved);
    }
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Opacity(
      opacity: product.isActive ? 1.0 : 0.45,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showEdit(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
            child: Row(
              children: [
                _ProductAvatar(imageUrl: product.imageUrl, size: 52),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: product.isActive
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      if (product.category != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          product.category!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      _StockBadge(stock: product.stock),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MoneyText(
                      value: product.price,
                      currency: currency,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 6),
                    PopupMenuButton<String>(
                      onSelected: (action) {
                        switch (action) {
                          case 'edit':
                            _showEdit(context);
                          case 'delete':
                            _confirmDelete(context);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Text(ctx.l10n.edit),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            ctx.l10n.delete,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEdit(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: ProductFormPage(product: product),
      ),
    );
    if (result == true && context.mounted) {
      AppSnackBar.success(context, context.l10n.productSaved);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteProduct),
        content: Text(context.l10n.confirmDeleteProduct(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(ProductDeleted(product.id));
              Navigator.pop(context);
            },
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductGridCard extends StatelessWidget {
  const _ProductGridCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return Opacity(
      opacity: product.isActive ? 1.0 : 0.45,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _showEdit(context),
          onLongPress: () => _showContextMenu(context),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: _ProductAvatar(imageUrl: product.imageUrl, size: 72),
                ),
                const SizedBox(height: 10),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    decoration: product.isActive
                        ? null
                        : TextDecoration.lineThrough,
                  ),
                ),
                const Spacer(),
                MoneyText(
                  value: product.price,
                  currency: currency,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 6),
                _StockBadge(stock: product.stock),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEdit(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductBloc>(),
        child: ProductFormPage(product: product),
      ),
    );
    if (result == true && context.mounted) {
      AppSnackBar.success(context, context.l10n.productSaved);
    }
  }

  void _showContextMenu(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.edit),
              onTap: () {
                Navigator.pop(sheetCtx);
                _showEdit(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outlined,
                color: theme.colorScheme.error,
              ),
              title: Text(
                context.l10n.delete,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(sheetCtx);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.deleteProduct),
        content: Text(context.l10n.confirmDeleteProduct(product.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(ProductDeleted(product.id));
              Navigator.pop(context);
            },
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductAvatar extends StatelessWidget {
  const _ProductAvatar({required this.imageUrl, this.size = 52});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = size * 0.27;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, err, st) => _iconBox(theme, radius),
        ),
      );
    }
    return _iconBox(theme, radius);
  }

  Widget _iconBox(ThemeData theme, double radius) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        color: theme.colorScheme.primary,
        size: size * 0.48,
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color color;
    if (stock == 0) {
      color = theme.colorScheme.error;
    } else if (stock <= 5) {
      color = theme.colorScheme.tertiary;
    } else {
      color = theme.colorScheme.primary;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Text(
          context.l10n.stockLabel(stock),
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
