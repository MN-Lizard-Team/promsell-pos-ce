import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/adaptive_breakpoints.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/product_sliver_content.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_content.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/compact_cart_fab.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/cart_resize_controller.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/drag_handle.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_app_bar_actions.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider.value(value: sl<CategoryBloc>()),
        BlocProvider.value(value: sl<CartBloc>()),
        BlocProvider.value(
          value: sl<DraftBloc>()..add(const DraftInitialized()),
        ),
        BlocProvider.value(value: sl<CheckoutBloc>()),
        BlocProvider(
          create: (_) => SearchHistoryCubit(
            sl<SettingsLocalDatasource>(),
            'sale_search_history',
          )..load(),
        ),
      ],
      child: const _SaleView(),
    );
  }
}

class _SaleView extends StatefulWidget {
  const _SaleView();

  @override
  State<_SaleView> createState() => _SaleViewState();
}

class _SaleViewState extends State<_SaleView> {
  CartResizeController? _resize;
  bool _isRestoring = false;
  final _searchController = TextEditingController();
  bool _isSearching = false;
  ViewMode _viewMode = ViewMode.grid;

  void _toggleSearch() {
    if (_isSearching && _searchController.text.trim().isNotEmpty) {
      context.read<SearchHistoryCubit>().add(_searchController.text);
    }
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
    final bloc = context.read<ProductBloc>();
    bloc.add(const ProductSearchChanged(''));
    bloc.add(const ProductCategoryFilterChanged(null));
    bloc.add(const ProductStockFilterChanged(StockFilter.all));
    bloc.add(const ProductSortChanged(ProductSort.default_));
    bloc.add(const ProductPriceRangeChanged(null));
  }

  bool _hasStockOrPriceChange(List<Product> prev, List<Product> curr) {
    final prevMap = {for (final p in prev) p.id: p};
    for (final c in curr) {
      final p = prevMap[c.id];
      if (p == null) return true;
      if (p.stock != c.stock ||
          p.price != c.price ||
          p.isActive != c.isActive) {
        return true;
      }
    }
    return prev.length != curr.length;
  }

  @override
  void dispose() {
    _resize?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final isExpanded =
        AdaptiveBreakpoints.isExpanded(context) ||
        (isLandscape && size.width >= 600);
    final compactMode = context.select(
      (SettingsCubit c) => c.state.settings.cartCompactMode,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          listenWhen: (prev, curr) =>
              curr.status == ProductStatus.success &&
              prev.products != curr.products &&
              _hasStockOrPriceChange(prev.products, curr.products),
          listener: (context, state) {
            context.read<CartBloc>().add(CartProductsRefreshed(state.products));
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) =>
              prev.stockWarning != curr.stockWarning &&
              curr.stockWarning != null,
          listener: (context, state) {
            AppSnackBar.info(context, state.stockWarning!);
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) =>
              prev.errorNonce != curr.errorNonce && curr.errorMessage != null,
          listener: (context, state) {
            final l10n = context.l10n;
            final msg = state.errorMessage == 'barcodeNotFound'
                ? l10n.barcodeNotFound
                : state.errorMessage == 'errorOccurred'
                ? l10n.errorOccurred
                : state.errorMessage!;
            AppSnackBar.error(context, msg);
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) => prev.items != curr.items,
          listener: (context, state) {
            if (_isRestoring) {
              _isRestoring = false;
              return;
            }
            context.read<DraftBloc>().add(DraftAutoSaveRequested(state));
          },
        ),
        BlocListener<DraftBloc, DraftState>(
          listenWhen: (prev, curr) =>
              curr.loadedDraft != null && prev.loadedDraft != curr.loadedDraft,
          listener: (context, state) {
            _isRestoring = true;
            final draft = state.loadedDraft!;
            context.read<CartBloc>().add(
              CartRestored(
                items: draft.items,
                cartDiscountType: draft.cartDiscountType,
                cartDiscountValue: draft.cartDiscountValue,
              ),
            );
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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                  onChanged: (q) =>
                      context.read<ProductBloc>().add(ProductSearchChanged(q)),
                )
              : Text(context.l10n.salePageTitle),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
            const SaleAppBarActions(),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, isExpanded ? 12 : 8),
                child: isExpanded
                    ? _buildExpandedLayout()
                    : (compactMode
                          ? _buildCompactLayout()
                          : _buildClassicCompactLayout()),
              ),
              if (_isSearching && _searchController.text.isEmpty)
                _buildSearchHistoryOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHistoryOverlay() {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final history = context.watch<SearchHistoryCubit>().state.searches;

    if (history.isEmpty) return const SizedBox.shrink();

    return Positioned.fill(
      child: GestureDetector(
        onTap: () {},
        behavior: HitTestBehavior.opaque,
        child: Material(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.recentSearches,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          context.read<SearchHistoryCubit>().clear(),
                      child: Text(l10n.clear),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: history
                      .map(
                        (q) => ActionChip(
                          label: Text(q),
                          onPressed: () {
                            _searchController.text = q;
                            context.read<ProductBloc>().add(
                              ProductSearchChanged(q),
                            );
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactLayout() {
    final isUltra = context.select(
      (SettingsCubit c) => c.state.settings.ultraCompactMode,
    );

    if (isUltra) {
      return Stack(
        children: [
          SaleCatalog(
            searchController: _searchController,
            viewMode: _viewMode,
            onViewModeChanged: (v) => setState(() => _viewMode = v),
            onClearFilters: _clearFilters,
          ),
          const CompactCartFab(),
        ],
      );
    }

    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 56 + bottomInset),
          child: SaleCatalog(
            searchController: _searchController,
            viewMode: _viewMode,
            onViewModeChanged: (v) => setState(() => _viewMode = v),
            onClearFilters: _clearFilters,
          ),
        ),
        const Positioned(left: 0, right: 0, bottom: 0, child: CartBottomBar()),
      ],
    );
  }

  Widget _buildClassicCompactLayout() {
    _resize ??= CartResizeController();
    final resize = _resize!;
    return Column(
      children: [
        Expanded(
          child: SaleCatalog(
            searchController: _searchController,
            viewMode: _viewMode,
            onViewModeChanged: (v) => setState(() => _viewMode = v),
            onClearFilters: _clearFilters,
          ),
        ),
        DragHandle(
          axis: Axis.vertical,
          isDragging: resize.isDragging,
          semanticLabel: context.l10n.dragToResizeCart,
          onDragStart: resize.onDragStart,
          onDragEnd: resize.onDragEnd,
          onVerticalDragUpdate: (d) => resize.onVerticalDrag(context, d),
          onVerticalDragEnd: (d) => resize.onVerticalDragEnd(context, d),
        ),
        ValueListenableBuilder<double>(
          valueListenable: resize.cartHeight,
          builder: (context, cartHeight, child) {
            return SizedBox(
              height: cartHeight,
              child: CartContent(
                expanded: false,
                currency: context
                    .watch<SettingsCubit>()
                    .state
                    .settings
                    .currency,
                settings: context.read<SettingsCubit>().state.settings,
                sizePreset: resize.currentSizePreset(context),
                onSizePresetChanged: (v) =>
                    resize.onSizePresetChanged(context, v),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildExpandedLayout() {
    _resize ??= CartResizeController();
    final resize = _resize!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SaleCatalog(
            searchController: _searchController,
            viewMode: _viewMode,
            onViewModeChanged: (v) => setState(() => _viewMode = v),
            onClearFilters: _clearFilters,
          ),
        ),
        DragHandle(
          axis: Axis.horizontal,
          isDragging: resize.isDragging,
          semanticLabel: context.l10n.dragToResizeCart,
          onDragStart: resize.onDragStart,
          onDragEnd: resize.onDragEnd,
          onHorizontalDragUpdate: (d) => resize.onHorizontalDrag(context, d),
          onHorizontalDragEnd: resize.onHorizontalDragEnd,
        ),
        ValueListenableBuilder<double>(
          valueListenable: resize.cartWidth,
          builder: (context, cartWidth, child) {
            return SizedBox(
              width: cartWidth,
              child: CartContent(
                expanded: true,
                currency: context
                    .watch<SettingsCubit>()
                    .state
                    .settings
                    .currency,
                settings: context.read<SettingsCubit>().state.settings,
                widthPreset: resize.currentWidthPreset(),
                onWidthPresetChanged: resize.onWidthPresetChanged,
              ),
            );
          },
        ),
      ],
    );
  }
}
