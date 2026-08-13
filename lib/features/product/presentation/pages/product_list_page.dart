import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/errors/app_error_display.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/date_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
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
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
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
  // Persist view mode across page rebuilds within the session.
  static ViewMode _lastViewMode = ViewMode.list;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  int _displayCount = ProductListPaging.initialPageSize;
  bool _loadingMore = false;
  int _lastFilteredLen = 0;
  ViewMode _viewMode = _ProductListViewState._lastViewMode;

  bool _isRefreshing = false;
  StreamSubscription<DateTime>? _clockSub;
  final _clockController = StreamController<DateTime>.broadcast();

  ProductBloc _resolveProductBloc(BuildContext context) {
    try {
      return context.read<ProductBloc>();
    } on ProviderNotFoundException {
      return sl<ProductBloc>();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _clockSub = Stream<DateTime>.periodic(
      const Duration(seconds: 30),
      (_) => DateTime.now(),
    ).listen((now) => _clockController.add(now));
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
    _clockSub?.cancel();
    _clockController.close();
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
    // Reset scroll to top so user sees filtered results immediately.
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    final bloc = _resolveProductBloc(context);
    final completer = Completer<void>();
    late StreamSubscription<ProductState> sub;
    sub = bloc.stream.listen(
      (state) {
        if (state.status == ProductStatus.success ||
            state.status == ProductStatus.failure) {
          if (!completer.isCompleted) completer.complete();
        }
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
    );
    bloc.add(const ProductsSubscribed());
    await completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
    await sub.cancel();
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
              prev.lastDeletedProductId != curr.lastDeletedProductId,
          listener: (ctx, state) {
            final id = state.lastDeletedProductId;
            final name = state.lastDeletedProductName;
            if (id == null) return;
            ScaffoldMessenger.of(ctx)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(
                    name != null && name.isNotEmpty
                        ? ctx.l10n.productDeletedWithName(name)
                        : ctx.l10n.productDeletedShort,
                  ),
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: ctx.l10n.undo,
                    onPressed: () {
                      productBloc.add(ProductRestored(id));
                    },
                  ),
                ),
              );
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
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 64,
          titleSpacing: 16,
          titleTextStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            fontFamily: 'NotoSansThai',
          ),
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          actionsIconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(context.posTheme.appBarBottomRadius),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(context.l10n.productsTitle),
              StreamBuilder<DateTime>(
                stream: _clockController.stream,
                initialData: DateTime.now(),
                builder: (context, snap) {
                  final now = snap.data ?? DateTime.now();
                  final productCount = productBloc.state.products.length;
                  final label = DateFormatter.formatDateTimeWithSuffix(
                    context,
                    now,
                    context.l10n.productCountAt(productCount),
                  );
                  return Text(
                    label,
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimary.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'NotoSansThai',
                    ),
                  );
                },
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(88),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ProductSearchBar(controller: _searchController),
                  const SizedBox(height: 8),
                  // View mode segmented control — discoverable, labeled.
                  _ViewModeSegmentedControl(
                    viewMode: _viewMode,
                    onChanged: (mode) => setState(() {
                      _viewMode = mode;
                      _lastViewMode = mode;
                    }),
                  ),
                ],
              ),
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
                final filteredLen = products.length;
                // Update _lastFilteredLen after build to avoid mutating during build.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _lastFilteredLen = filteredLen;
                });
                // Clamp display count without mutating state during build.
                final displayCount = products.isEmpty
                    ? ProductListPaging.initialPageSize
                    : (_displayCount > filteredLen
                          ? filteredLen
                          : _displayCount);
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
                      displayCount: displayCount,
                      allProducts: state.products,
                      searchQuery: state.searchQuery,
                      searchController: _searchController,
                      onClearFilters: _clearFilters,
                      hasMore: products.length > displayCount,
                      viewMode: _viewMode,
                      onImport: () => openProductCsvImport(context),
                      onAddProduct: () => _showAddProductPage(context),
                      onRetry: () => _onRefresh(),
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

/// Segmented control for list/grid view toggle — more discoverable than
/// an icon-only button in the AppBar.
class _ViewModeSegmentedControl extends StatelessWidget {
  const _ViewModeSegmentedControl({
    required this.viewMode,
    required this.onChanged,
  });
  final ViewMode viewMode;
  final ValueChanged<ViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<ViewMode>(
        segments: [
          ButtonSegment(
            value: ViewMode.list,
            icon: const Icon(Icons.view_list_rounded, size: 18),
            label: Text(l10n.listView, style: const TextStyle(fontSize: 13)),
          ),
          ButtonSegment(
            value: ViewMode.grid,
            icon: const Icon(Icons.grid_view_rounded, size: 18),
            label: Text(l10n.gridView, style: const TextStyle(fontSize: 13)),
          ),
        ],
        selected: {viewMode},
        onSelectionChanged: (set) => onChanged(set.first),
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return cs.primaryContainer;
            }
            return cs.surface;
          }),
        ),
      ),
    );
  }
}
