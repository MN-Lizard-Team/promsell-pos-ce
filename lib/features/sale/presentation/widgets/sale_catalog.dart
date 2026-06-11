import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/app_search_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search_result_tile.dart';
import 'package:promsell_pos_ce/core/widgets/search_history_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category_list_tile.dart'
    show parseCategoryColor, parseCategoryIcon;
import 'package:promsell_pos_ce/features/sale/presentation/widgets/sale_product_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleCatalog extends StatefulWidget {
  const SaleCatalog({super.key});

  @override
  State<SaleCatalog> createState() => _SaleCatalogState();
}

class _SaleCatalogState extends State<SaleCatalog> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchFocused = false;

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _searchFocused = _searchFocus.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        context.read<ProductBloc>().add(const ProductSearchChanged(''));
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
      listener: (_, state) {
        if (_searchController.text != state.searchQuery) {
          _searchController.text = state.searchQuery;
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (ctx, state) {
          if (state.status == ProductStatus.loading ||
              state.status == ProductStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ProductStatus.failure) {
            return AppEmptyState(
              icon: Icons.error_outline,
              title: state.errorMessage ?? ctx.l10n.errorOccurred,
            );
          }

          final activeProducts = state.filtered
              .where((product) => product.isActive && product.isInStock)
              .toList();
          final categoryState = ctx.watch<CategoryBloc>().state;
          final categories = categoryState.categories;
          final selectedCategoryId = state.categoryFilter;
          final products = selectedCategoryId == null
              ? activeProducts
              : activeProducts
                    .where(
                      (product) => product.categoryId == selectedCategoryId,
                    )
                    .toList();

          if (activeProducts.isEmpty) {
            return AppEmptyState(
              icon: Icons.inventory_2_outlined,
              title: ctx.l10n.noProducts,
              message: ctx.l10n.tapProductToAdd,
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BlocBuilder<SearchHistoryCubit, SearchHistoryState>(
                    builder: (ctx, historyState) {
                      return AppSearchBar(
                        controller: _searchController,
                        focusNode: _searchFocus,
                        hintText: context.l10n.saleSearchProducts,
                        isFocused: _searchFocused,
                        recentSearches: historyState.searches,
                        onChanged: (q) => context.read<ProductBloc>().add(
                          ProductSearchChanged(q),
                        ),
                        onSubmitted: (q) {
                          context.read<SearchHistoryCubit>().add(q);
                        },
                        onRecentTap: (q) {
                          _searchController.text = q;
                          context.read<ProductBloc>().add(
                            ProductSearchChanged(q),
                          );
                          _searchFocus.unfocus();
                        },
                        onRecentDismiss: (q) =>
                            context.read<SearchHistoryCubit>().remove(q),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 44,
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white,
                            Colors.white,
                            Colors.white.withValues(alpha: 0),
                          ],
                          stops: const [0, 0.85, 1],
                        ).createShader(bounds),
                        blendMode: BlendMode.dstIn,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length + 1,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            final isAll = index == 0;
                            final category = isAll
                                ? null
                                : categories[index - 1];
                            final selected = selectedCategoryId == category?.id;

                            final catColor = isAll
                                ? null
                                : parseCategoryColor(category!.color);
                            final catIcon = isAll
                                ? null
                                : parseCategoryIcon(category!.iconName);
                            return ChoiceChip(
                              avatar: isAll || catColor == null
                                  ? null
                                  : Icon(
                                      catIcon,
                                      size: 16,
                                      color: selected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : catColor,
                                    ),
                              label: Text(
                                isAll ? ctx.l10n.allCategories : category!.name,
                              ),
                              selected: selected,
                              selectedColor: theme.colorScheme.primaryContainer,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              checkmarkColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                color: selected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurfaceVariant,
                                fontWeight: selected ? FontWeight.w600 : null,
                              ),
                              onSelected: (_) {
                                HapticFeedback.selectionClick();
                                ctx.read<ProductBloc>().add(
                                  ProductCategoryFilterChanged(category?.id),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    if (state.searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          ctx.l10n.searchResultsCount(products.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              if (products.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: state.searchQuery.isNotEmpty
                      ? SearchEmptyState(
                          query: state.searchQuery,
                          onClear: () {
                            _searchController.clear();
                            context.read<ProductBloc>().add(
                              const ProductSearchChanged(''),
                            );
                          },
                        )
                      : AppEmptyState(
                          icon: Icons.inventory_2_outlined,
                          title: ctx.l10n.noProducts,
                          message: ctx.l10n.tapProductToAdd,
                        ),
                )
              else if (state.searchQuery.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  sliver: SliverList.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) => SearchResultTile(
                      product: products[i],
                      query: state.searchQuery,
                      onTap: () {},
                    ),
                  ),
                )
              else
                SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.crossAxisExtent >= 720;
                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: isWide ? 220 : 186,
                        mainAxisExtent: isWide ? 160 : 148,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) => SaleProductCard(
                          product: products[index],
                          currency: currency,
                        ),
                        childCount: products.length,
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
