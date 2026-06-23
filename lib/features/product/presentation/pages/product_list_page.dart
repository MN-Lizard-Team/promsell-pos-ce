import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/add_product_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/category_management_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/modern_product_tile.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/modern_product_grid_card.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_list_tile.dart'
    show parseCategoryColor, parseCategoryIcon;

enum _ViewMode { list, grid }

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider.value(value: sl<CategoryBloc>()),
      ],
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
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<ProductBloc>().add(const ProductSearchChanged(''));
      }
    });
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
        listenWhen: (prev, curr) =>
            curr.batchResultMessage != null &&
            prev.batchResultMessage != curr.batchResultMessage,
        listener: (ctx, state) {
          final count = int.tryParse(state.batchResultMessage ?? '0') ?? 0;
          if (count > 0) {
            AppSnackBar.success(ctx, ctx.l10n.batchGenerateSuccess(count));
          } else {
            AppSnackBar.info(ctx, ctx.l10n.batchGenerateNone);
          }
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
              title: _isSearching
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: context.l10n.searchProducts,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      style: Theme.of(context).textTheme.titleMedium,
                      onChanged: (q) => context.read<ProductBloc>().add(
                        ProductSearchChanged(q),
                      ),
                    )
                  : Text(context.l10n.productsTitle),
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: _toggleSearch,
                ),
                if (!_isSearching) ...[
                  IconButton(
                    icon: const Icon(Icons.folder_outlined),
                    tooltip: context.l10n.manageCategories,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CategoryManagementPage(),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'batch_generate') {
                        _showBatchGenerateDialog(context);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(
                        value: 'batch_generate',
                        child: Row(
                          children: [
                            const Icon(Icons.barcode_reader),
                            const SizedBox(width: 12),
                            Text(context.l10n.batchGenerateBarcodes),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(width: 4),
              ],
            ),
            body: SafeArea(
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final categoryState = context.watch<CategoryBloc>().state;
                  final categories = categoryState.categories;
                  final selectedCategoryId = state.categoryFilter;
                  final products = state.filtered;

                  return CustomScrollView(
                    slivers: [
                      if (categories.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 8),
                            child: SizedBox(
                              height: 44,
                              child: ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(context).colorScheme.surface,
                                    Theme.of(
                                      context,
                                    ).colorScheme.surface.withValues(alpha: 0),
                                  ],
                                  stops: const [0, 0.85, 1],
                                ).createShader(bounds),
                                blendMode: BlendMode.dstIn,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: categories.length + 2,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (_, index) {
                                    final isAll = index == 0;
                                    final isNone =
                                        index == categories.length + 1;
                                    final category = isAll || isNone
                                        ? null
                                        : categories[index - 1];
                                    final selected = isNone
                                        ? selectedCategoryId ==
                                              kNoCategoryFilter
                                        : selectedCategoryId == category?.id;
                                    final theme = Theme.of(context);
                                    final catColor = isAll || isNone
                                        ? null
                                        : parseCategoryColor(category!.color);
                                    final catIcon = isAll || isNone
                                        ? null
                                        : parseCategoryIcon(category!.iconName);
                                    return ChoiceChip(
                                      avatar:
                                          isAll || isNone || catColor == null
                                          ? null
                                          : Icon(
                                              catIcon,
                                              size: 16,
                                              color: selected
                                                  ? theme
                                                        .colorScheme
                                                        .onPrimaryContainer
                                                  : catColor,
                                            ),
                                      label: Text(
                                        isAll
                                            ? context.l10n.allCategories
                                            : isNone
                                            ? context.l10n.noCategory
                                            : category!.name,
                                      ),
                                      selected: selected,
                                      selectedColor:
                                          theme.colorScheme.primaryContainer,
                                      backgroundColor: theme
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      checkmarkColor: theme.colorScheme.primary,
                                      labelStyle: TextStyle(
                                        color: selected
                                            ? theme
                                                  .colorScheme
                                                  .onPrimaryContainer
                                            : theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : null,
                                      ),
                                      onSelected: (_) {
                                        HapticFeedback.selectionClick();
                                        context.read<ProductBloc>().add(
                                          ProductCategoryFilterChanged(
                                            isNone
                                                ? kNoCategoryFilter
                                                : category?.id,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: _StatsDashboard(
                                  products: products,
                                  activeFilter: state.stockFilter,
                                  onFilterTap: (filter) => context
                                      .read<ProductBloc>()
                                      .add(ProductStockFilterChanged(filter)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                flex: 3,
                                child: SegmentedButton<_ViewMode>(
                                  segments: const [
                                    ButtonSegment(
                                      value: _ViewMode.list,
                                      icon: Icon(Icons.view_list, size: 18),
                                    ),
                                    ButtonSegment(
                                      value: _ViewMode.grid,
                                      icon: Icon(Icons.grid_view, size: 18),
                                    ),
                                  ],
                                  selected: {_viewMode},
                                  onSelectionChanged: (selection) => setState(
                                    () => _viewMode = selection.first,
                                  ),
                                  style: const ButtonStyle(
                                    visualDensity: VisualDensity.compact,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 4)),
                      _buildSliverContent(context, state, products),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddProductPage(context),
              heroTag: 'product_add_fab',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      ),
    );
  }

  void _showBatchGenerateDialog(BuildContext context) {
    final state = context.read<ProductBloc>().state;
    final l10n = context.l10n;
    final withoutBarcode = state.products
        .where((p) => p.barcode == null || p.barcode!.isEmpty)
        .length;

    if (withoutBarcode == 0) {
      AppSnackBar.info(context, l10n.batchGenerateNone);
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.batchGenerateConfirmTitle),
        content: Text(l10n.batchGenerateConfirmBody(withoutBarcode)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              final prefix = context
                  .read<SettingsCubit>()
                  .state
                  .settings
                  .barcodeAutoGeneratePrefix;
              context.read<ProductBloc>().add(
                BarcodesBatchGenerated(prefix: prefix),
              );
            },
            child: Text(l10n.generateBarcode),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverContent(
    BuildContext context,
    ProductState state,
    List<Product> products,
  ) {
    if (state.status == ProductStatus.loading ||
        state.status == ProductStatus.initial) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.status == ProductStatus.failure) {
      return SliverFillRemaining(
        child: AppEmptyState(
          icon: Icons.error_outline,
          title: state.errorMessage ?? context.l10n.errorOccurred,
        ),
      );
    }
    if (products.isEmpty) {
      if (state.products.isEmpty) {
        return SliverFillRemaining(
          child: AppEmptyState(
            icon: Icons.inventory_2_outlined,
            title: context.l10n.noProductsYet,
          ),
        );
      }
      return SliverFillRemaining(
        child: AppEmptyState(
          icon: state.searchQuery.isNotEmpty
              ? Icons.search_off
              : Icons.filter_list_off,
          title: state.searchQuery.isNotEmpty
              ? context.l10n.noSearchResults
              : context.l10n.noProductsInCategory,
          actionLabel: context.l10n.clearFilters,
          onAction: () {
            _searchController.clear();
            context.read<ProductBloc>().add(const ProductSearchChanged(''));
            context.read<ProductBloc>().add(
              const ProductCategoryFilterChanged(null),
            );
          },
        ),
      );
    }
    return _viewMode == _ViewMode.list
        ? SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            sliver: SliverList.separated(
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => ModernProductTile(product: products[i]),
            ),
          )
        : SliverPadding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) => ModernProductGridCard(product: products[i]),
                childCount: products.length,
              ),
            ),
          );
  }

  void _showAddProductPage(BuildContext context) async {
    final productBloc = context.read<ProductBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productBloc),
            BlocProvider.value(value: categoryBloc),
            BlocProvider(
              create: (_) =>
                  AddProductDraftCubit(sl<SettingsLocalDatasource>()),
            ),
          ],
          child: const AddProductPage(),
        ),
      ),
    );
    if (result == true && context.mounted) {
      AppSnackBar.success(context, context.l10n.productSaved);
    }
  }
}

class _StatsDashboard extends StatelessWidget {
  const _StatsDashboard({
    required this.products,
    required this.activeFilter,
    required this.onFilterTap,
  });
  final List<Product> products;
  final StockFilter activeFilter;
  final ValueChanged<StockFilter> onFilterTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = products.where((p) => p.isActive).length;
    final lowStock = products
        .where((p) => p.trackStock && p.stock > 0 && p.stock <= 5)
        .length;
    final outOfStock = products
        .where((p) => p.trackStock && p.stock == 0)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.inventory_2,
            label: '$active',
            subtitle: context.l10n.productsCount,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _StatCard(
            icon: Icons.warning_amber_rounded,
            label: '$lowStock',
            subtitle: context.l10n.lowStock,
            color: theme.colorScheme.tertiary,
            dimmed: lowStock == 0,
            isSelected: activeFilter == StockFilter.lowStock,
            onTap: lowStock > 0
                ? () => onFilterTap(StockFilter.lowStock)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _StatCard(
            icon: Icons.error_outline,
            label: '$outOfStock',
            subtitle: context.l10n.outOfStock,
            color: theme.colorScheme.error,
            dimmed: outOfStock == 0,
            isSelected: activeFilter == StockFilter.outOfStock,
            onTap: outOfStock > 0
                ? () => onFilterTap(StockFilter.outOfStock)
                : null,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    this.dimmed = false,
    this.isSelected = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final bool dimmed;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = dimmed ? theme.colorScheme.outline : color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: effectiveColor, width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: effectiveColor),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: effectiveColor,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
