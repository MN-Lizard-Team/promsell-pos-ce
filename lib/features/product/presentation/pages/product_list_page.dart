import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/add_product_draft_cubit.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/add_product_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/category_management_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/batch_generate_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/category_filter_chips.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_sliver_content.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/stats_dashboard.dart';

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
  ViewMode _viewMode = ViewMode.list;
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

  void _clearFilters() {
    _searchController.clear();
    context.read<ProductBloc>().add(const ProductSearchChanged(''));
    context.read<ProductBloc>().add(const ProductCategoryFilterChanged(null));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) =>
              curr.status == ProductStatus.failure &&
              prev.status != ProductStatus.failure,
          listener: (ctx, state) {
            AppSnackBar.error(
              ctx,
              state.errorMessage ?? ctx.l10n.errorOccurred,
            );
          },
        ),
        BlocListener<ProductBloc, ProductState>(
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
        ),
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
          listener: (_, state) {
            if (_searchController.text != state.searchQuery) {
              _searchController.text = state.searchQuery;
            }
          },
        ),
      ],
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
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: theme.textTheme.titleMedium,
                  onChanged: (q) =>
                      context.read<ProductBloc>().add(ProductSearchChanged(q)),
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
                    showBatchGenerateDialog(context);
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
                      child: CategoryFilterChips(
                        categories: categories,
                        selectedCategoryId: selectedCategoryId,
                        onCategorySelected: (categoryId) {
                          context.read<ProductBloc>().add(
                            ProductCategoryFilterChanged(categoryId),
                          );
                        },
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
                            child: StatsDashboard(
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
                            child: SegmentedButton<ViewMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ViewMode.list,
                                  icon: Icon(Icons.view_list, size: 18),
                                ),
                                ButtonSegment(
                                  value: ViewMode.grid,
                                  icon: Icon(Icons.grid_view, size: 18),
                                ),
                              ],
                              selected: {_viewMode},
                              onSelectionChanged: (selection) =>
                                  setState(() => _viewMode = selection.first),
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 4)),
                  ProductSliverContent(
                    status: state.status,
                    products: products,
                    allProducts: state.products,
                    searchQuery: state.searchQuery,
                    viewMode: _viewMode,
                    searchController: _searchController,
                    onClearFilters: _clearFilters,
                  ),
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
    );
  }

  Future<void> _showAddProductPage(BuildContext context) async {
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
