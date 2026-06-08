import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_empty_state.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/sale_product_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SaleCatalog extends StatefulWidget {
  const SaleCatalog({super.key});

  @override
  State<SaleCatalog> createState() => _SaleCatalogState();
}

class _SaleCatalogState extends State<SaleCatalog> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
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
          final categories = _categoriesOf(activeProducts);
          final selectedCategory = categories.contains(state.categoryFilter)
              ? state.categoryFilter
              : null;
          final products = selectedCategory == null
              ? activeProducts
              : activeProducts
                    .where((product) => product.category == selectedCategory)
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
                  child: SearchBar(
                    controller: _searchController,
                    hintText: context.l10n.saleSearchProducts,
                    leading: const Icon(Icons.search),
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    side: WidgetStatePropertyAll(
                      BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (query) => context.read<ProductBloc>().add(
                      ProductSearchChanged(query),
                    ),
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
                            final selected = selectedCategory == category;

                            return ChoiceChip(
                              label: Text(
                                isAll ? ctx.l10n.allCategories : category!,
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
                                  ProductCategoryFilterChanged(category),
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
                  child: AppEmptyState(
                    icon: Icons.search_off,
                    title: ctx.l10n.noMatchingProducts,
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

  List<String> _categoriesOf(List<Product> products) {
    final categories =
        products
            .map((product) => product.category?.trim())
            .whereType<String>()
            .where((category) => category.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    return categories;
  }
}
