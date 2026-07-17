import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/search_surface_config.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_product_search_page.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_bottom_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/compact_cart_fab.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/barcode_wedge_listener.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_app_bar_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_barcode_scanner.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

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
            SearchSurfaceConfig.saleFullSearch.historyKey,
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
  bool _isRestoring = false;

  /// Kept for [SaleCatalog] API; catalog search is empty while on Sale shell.
  final _searchController = TextEditingController();
  ViewMode _viewMode = ViewMode.list;

  Future<void> _openSaleSearch() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ProductBloc>()),
            BlocProvider.value(value: context.read<CategoryBloc>()),
            BlocProvider.value(value: context.read<CartBloc>()),
            BlocProvider.value(value: context.read<SettingsCubit>()),
            BlocProvider.value(value: context.read<SearchHistoryCubit>()),
          ],
          child: const SaleProductSearchPage(),
        ),
      ),
    );
    if (!mounted) return;
    // Ensure catalog is not left filtered after search page.
    _searchController.clear();
    context.read<ProductBloc>().add(const ProductSearchChanged(''));
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

  /// Persist draft when line items or session meta change (not stock warnings).
  bool _cartSessionChanged(CartState prev, CartState curr) {
    return prev.items != curr.items ||
        prev.note != curr.note ||
        prev.cartDiscountType != curr.cartDiscountType ||
        prev.cartDiscountValue != curr.cartDiscountValue ||
        prev.orderType != curr.orderType ||
        prev.orderChannel != curr.orderChannel ||
        prev.externalOrderRef != curr.externalOrderRef ||
        prev.tableId != curr.tableId ||
        prev.serviceChargeRate != curr.serviceChargeRate ||
        prev.customerId != curr.customerId ||
        prev.promotionId != curr.promotionId ||
        prev.promotionDiscountAmount != curr.promotionDiscountAmount;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductBloc>().add(
        const ProductSurfaceEntered(ProductSurface.sale),
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Surface snapshot already isolates filters; clear live search as before.
    try {
      sl<ProductBloc>().add(const ProductSearchChanged(''));
    } catch (_) {}
    super.dispose();
  }

  ProductBloc _resolveProductBloc(BuildContext context) {
    try {
      return context.read<ProductBloc>();
    } catch (_) {
      return sl<ProductBloc>();
    }
  }

  @override
  Widget build(BuildContext context) {
    final productBloc = _resolveProductBloc(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<ProductBloc, ProductState>(
          bloc: productBloc,
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
            final code = state.errorMessage;
            if (code == 'barcodeNotFound') {
              final failed = state.lastFailedBarcode;
              AppSnackBar.withAction(
                context,
                l10n.barcodeNotFound,
                actionLabel: l10n.createProductFromBarcode,
                onAction: () async {
                  // Camera path closes scanner before create; wedge has no dialog.
                  final saved = await showProductCreatePage(
                    context,
                    initialBarcode: failed,
                  );
                  if (!context.mounted) return;
                  if (saved) {
                    if (failed != null && failed.isNotEmpty) {
                      context.read<CartBloc>().add(CartBarcodeScanned(failed));
                    }
                    AppSnackBar.success(
                      context,
                      l10n.productCreatedAddedToCart,
                    );
                  }
                },
              );
              return;
            }
            final msg = code == 'errorOccurred'
                ? l10n.errorOccurred
                : code == 'outOfStock'
                ? l10n.outOfStock
                : code!;
            AppSnackBar.error(context, msg);
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (prev, curr) => _cartSessionChanged(prev, curr),
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
              curr.errorMessage != null &&
              curr.errorMessage != prev.errorMessage &&
              curr.lastOp != 'park' &&
              curr.lastOp != 'newBill',
          listener: (context, state) {
            final raw = state.errorMessage!;
            final l10n = context.l10n;
            String msg;
            if (raw == 'draftNotFound') {
              msg = l10n.draftNotFound;
            } else if (raw.startsWith('maxDraftsReached:')) {
              final n = int.tryParse(raw.split(':').last) ?? 0;
              msg = l10n.maxDraftsReached(n);
            } else {
              msg = l10n.errorOccurred;
            }
            AppSnackBar.error(context, msg);
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
                note: draft.note ?? '',
                cartDiscountType: draft.cartDiscountType,
                cartDiscountValue: draft.cartDiscountValue,
                orderType: draft.orderType,
                orderChannel: draft.orderChannel,
                externalOrderRef: draft.externalOrderRef,
                tableId: draft.tableId,
                serviceChargeRate: draft.serviceChargeRate,
                customerId: draft.customerId,
                promotionId: draft.promotionId,
                promotionDiscountAmount: draft.promotionDiscountAmount.value,
              ),
            );
            if (draft.skippedItemCount > 0 && context.mounted) {
              AppSnackBar.info(
                context,
                context.l10n.billItemsMissing(draft.skippedItemCount),
              );
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _isRestoring = false;
            });
          },
        ),
      ],
      child: BarcodeWedgeListener(
        enabled: context
            .watch<SettingsCubit>()
            .state
            .settings
            .barcodeScanEnabled,
        onBarcode: (code) {
          context.read<CartBloc>().add(CartBarcodeScanned(code));
        },
        child: _buildScaffold(),
      ),
    );
  }

  Widget _buildScaffold() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    return Scaffold(
      backgroundColor: pos.catalogBackground,
      appBar: AppBar(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: scheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          fontFamily: 'NotoSansThai',
        ),
        iconTheme: IconThemeData(color: scheme.onPrimary),
        actionsIconTheme: IconThemeData(color: scheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(pos.appBarBottomRadius),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(context.l10n.salePageTitle),
            // Wireframe: dd/mm/yyyy hh:mm under title (live clock).
            StreamBuilder<DateTime>(
              stream: Stream<DateTime>.periodic(
                const Duration(seconds: 30),
                (_) => DateTime.now(),
              ),
              initialData: DateTime.now(),
              builder: (context, snap) {
                final now = snap.data ?? DateTime.now();
                final label = DateFormat('dd/MM/yyyy HH:mm').format(now);
                return Text(
                  label,
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.85),
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
          // Compact search strip (was 64) — less chrome above catalog.
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Material(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const ValueKey('sale-open-search'),
                onTap: _openSaleSearch,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Wireframe: leading square control.
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.search,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.searchProducts,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFamily: 'NotoSansThai',
                          ),
                        ),
                      ),
                      if (context.select(
                        (SettingsCubit c) =>
                            c.state.settings.barcodeScanEnabled,
                      ))
                        IconButton(
                          tooltip: context.l10n.scanBarcode,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            Icons.qr_code_scanner,
                            size: 20,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: () => openSaleBarcodeScanner(context),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: const [SaleAppBarActions(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (SalesDayLock.isCreateBlocked(
              dailyCloseLock: context
                  .watch<SettingsCubit>()
                  .state
                  .settings
                  .dailyCloseLock,
              lastClosedDate: context
                  .watch<SettingsCubit>()
                  .state
                  .settings
                  .lastClosedDate,
            ))
              Material(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_clock,
                        size: 18,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.dayClosedMessage,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: pos.catalogPadding,
                child: _buildDeliveryLayout(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalog({required double bottomContentInset}) {
    return SaleCatalog(
      searchController: _searchController,
      viewMode: _viewMode,
      onViewModeChanged: (v) => setState(() => _viewMode = v),
      onClearFilters: _clearFilters,
      bottomContentInset: bottomContentInset,
    );
  }

  Widget _buildDeliveryLayout() {
    final isUltra = context.select(
      (SettingsCubit c) => c.state.settings.ultraCompactMode,
    );

    // Cart is always a full page ([openCartReviewPage]); no docked dual-pane.
    if (isUltra) {
      return Stack(
        children: [
          _buildCatalog(
            bottomContentInset: 100 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          const CompactCartFab(),
        ],
      );
    }

    return Stack(
      children: [
        _buildCatalog(bottomContentInset: CartBottomBar.contentInset(context)),
        const Positioned(left: 0, right: 0, bottom: 0, child: CartBottomBar()),
      ],
    );
  }
}
