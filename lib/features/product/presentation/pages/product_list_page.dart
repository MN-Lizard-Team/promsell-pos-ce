import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/errors/app_error_display.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/category_management_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/batch_barcode_feedback.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/stock_level.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/batch_generate_dialog.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_csv_import_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_bottom_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_filter_tabs.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_list_paging.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_search_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_sliver_content.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_stats_row.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide blocs at the root so MultiBlocListener in the child tree can
    // resolve ProductBloc even when this page is opened from Home (new route).
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
  final _scrollController = ScrollController();
  int _displayCount = ProductListPaging.initialPageSize;
  bool _loadingMore = false;
  int _lastFilteredLen = 0;

  bool _isRefreshing = false;

  ProductBloc _resolveProductBloc(BuildContext context) {
    try {
      return context.read<ProductBloc>();
    } catch (_) {
      return sl<ProductBloc>();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Restore catalog filter snapshot (isolated from Sale).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resolveProductBloc(
        context,
      ).add(const ProductSurfaceEntered(ProductSurface.catalog));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingMore) return;
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (!pos.hasPixels || !pos.hasContentDimensions) return;
    if (pos.pixels < pos.maxScrollExtent - ProductListPaging.loadMoreExtent) {
      return;
    }
    if (_displayCount >= _lastFilteredLen) return;

    _loadingMore = true;
    setState(() {
      _displayCount = (_displayCount + ProductListPaging.pageSize).clamp(
        0,
        _lastFilteredLen,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadingMore = false;
    });
  }

  void _resetDisplayCount() {
    if (!mounted) {
      _displayCount = ProductListPaging.initialPageSize;
      return;
    }
    setState(() {
      _displayCount = ProductListPaging.initialPageSize;
    });
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    context.read<ProductBloc>().add(const ProductsSubscribed());
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() => _isRefreshing = false);
  }

  void _clearFilters() {
    _searchController.clear();
    context.read<ProductBloc>().add(const ProductFiltersCleared());
  }

  @override
  Widget build(BuildContext context) {
    // Prefer inherited ProductBloc; fall back to DI so listeners never throw
    // ProviderNotFound (IndexedStack first mount / partial hot-reload).
    final productBloc = _resolveProductBloc(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          bloc: productBloc,
          listenWhen: productCatalogFailureChanged,
          listener: (ctx, state) {
            AppSnackBar.error(
              ctx,
              state.error?.displayMessage(ctx.l10n) ?? ctx.l10n.errorOccurred,
            );
          },
        ),
        BlocListener<ProductBloc, ProductState>(
          bloc: productBloc,
          listenWhen: batchBarcodeResultChanged,
          listener: (ctx, state) {
            showBatchBarcodeResultSnack(ctx, productBloc, state);
          },
        ),
        BlocListener<ProductBloc, ProductState>(
          bloc: productBloc,
          listenWhen: batchBarcodeFailed,
          listener: (ctx, state) {
            showBatchBarcodeFailureSnack(ctx, state);
          },
        ),
        BlocListener<ProductBloc, ProductState>(
          bloc: productBloc,
          listenWhen: (prev, curr) =>
              prev.searchQuery != curr.searchQuery ||
              prev.selectedTab != curr.selectedTab ||
              prev.categoryFilter != curr.categoryFilter ||
              prev.stockFilter != curr.stockFilter ||
              prev.productSort != curr.productSort ||
              prev.priceRange != curr.priceRange,
          listener: (_, _) => _resetDisplayCount(),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          title: Text(context.l10n.productsTitle),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: ProductSearchBar(controller: _searchController),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showOptionsMenu(context),
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: BlocBuilder<ProductBloc, ProductState>(
              bloc: productBloc,
              builder: (context, state) {
                final settings = context.watch<SettingsCubit>().state.settings;
                final threshold = settings.lowStockThreshold;
                final products = state.filteredProducts(
                  lowStockThreshold: threshold,
                );
                final searchActive = state.searchQuery.trim().isNotEmpty;
                final filtersPaused =
                    searchActive && state.hasListFiltersActive;
                _lastFilteredLen = products.length;
                // Keep window in range when list shrinks (delete / filter).
                if (_displayCount > products.length && products.isNotEmpty) {
                  _displayCount = products.length;
                } else if (products.isEmpty) {
                  _displayCount = ProductListPaging.initialPageSize;
                }
                final allProducts = state.products;
                final activeCount = allProducts.where((p) => p.isActive).length;
                final lowStockCount = allProducts
                    .where(
                      (p) => isProductLowStock(p, lowStockThreshold: threshold),
                    )
                    .length;
                final outOfStockCount = allProducts
                    .where((p) => p.trackStock && p.stock == 0)
                    .length;
                final totalCount = allProducts.length;
                final inventoryValue = allProducts
                    .where((p) => p.trackStock)
                    .fold<double>(0, (sum, p) => sum + p.stock * p.cost.value);
                final currency = settings.currency;

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    if ((state.status == ProductStatus.loading &&
                            allProducts.isNotEmpty) ||
                        state.isBatchGenerating)
                      const SliverToBoxAdapter(
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: ProductStatsRow(
                          activeCount: activeCount,
                          lowStockCount: lowStockCount,
                          outOfStockCount: outOfStockCount,
                          totalCount: totalCount,
                          inventoryValue: inventoryValue,
                          currency: currency,
                          isLoading: state.status == ProductStatus.loading,
                          activeFilter: state.stockFilter,
                          onFilterTap: (filter) {
                            _resetDisplayCount();
                            context.read<ProductBloc>().add(
                              ProductStockFilterChanged(filter),
                            );
                            if (filter != StockFilter.all) {
                              context.read<ProductBloc>().add(
                                const ProductTabChanged(ProductTabFilter.stock),
                              );
                            } else {
                              context.read<ProductBloc>().add(
                                const ProductTabChanged(ProductTabFilter.all),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ProductFilterTabs(),
                      ),
                    ),
                    if (filtersPaused)
                      SliverToBoxAdapter(
                        child: Material(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_alt_off_outlined,
                                  size: 18,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    context.l10n.searchFiltersIgnoredHint,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryContainer,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ProductSliverContent(
                      status: state.status,
                      products: products,
                      displayCount: _displayCount,
                      allProducts: state.products,
                      searchQuery: state.searchQuery,
                      searchController: _searchController,
                      onClearFilters: _clearFilters,
                      hasMore: products.length > _displayCount,
                      onImport: () => openProductCsvImport(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: ProductBottomBar(
          onManageCategories: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CategoryManagementPage()),
            );
          },
          onAdd: () => _showAddProductPage(context),
          onImport: () => openProductCsvImport(context),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: Text(l10n.importProducts),
              onTap: () {
                Navigator.pop(ctx);
                openProductCsvImport(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code_2_outlined),
              title: Text(l10n.batchGenerateBarcodes),
              subtitle: Text(l10n.batchGenerateBarcodesHint),
              onTap: () {
                Navigator.pop(ctx);
                showBatchGenerateDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddProductPage(BuildContext context) async {
    final product = await showProductCreatePageForResult(context);
    if (product != null && context.mounted) {
      // Form already shows productSaved snackbar; open preview to verify setup.
      showProductPreviewPage(context, product);
    }
  }
}
