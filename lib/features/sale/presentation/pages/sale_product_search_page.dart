import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_app_bar_field.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_result_tile.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_search.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/search_surface_config.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/utils/sale_add_to_cart.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/barcode_wedge_listener.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/svg_icon.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_barcode_scanner.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Max ranked hits painted on the Sale search page.
/// Prefer [SearchSurfaceConfig.saleFullSearch.resultCap].
const int kSaleSearchResultCap = SearchSurfaceConfig.defaultResultCap;

/// Full-screen POS product search (cart-first, stay-on-add).
///
/// Do **not** use [ProductSearchPage] here — that page opens product preview.
/// Policy: [SearchSurfaceConfig.saleFullSearch] (local query, active-only).
class SaleProductSearchPage extends StatefulWidget {
  const SaleProductSearchPage({super.key});

  @override
  State<SaleProductSearchPage> createState() => _SaleProductSearchPageState();
}

class _SaleProductSearchPageState extends State<SaleProductSearchPage> {
  static const _config = SearchSurfaceConfig.saleFullSearch;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  /// Only persist history after a committed action (add / successful submit).
  bool _committedSearch = false;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    assert(
      !_config.writeBlocOnType,
      'Sale search must stay localEphemeral (no ProductSearchChanged on type)',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    disposeTextEditingControllerAfterFrame(_searchController);
    _focusNode.dispose();
    super.dispose();
  }

  void _markCommitted() {
    _committedSearch = true;
  }

  void _onSearchChanged(String query) {
    // Rebuild immediately so clear icon + results track keystrokes.
    // Do **not** push ProductSearchChanged — shared ProductBloc would filter
    // the Sale catalog under this route. Policy: localEphemeral.
    setState(() {});
  }

  void _applyQuery(String query, {bool unfocus = false}) {
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    if (unfocus) _focusNode.unfocus();
    setState(() {});
  }

  Future<void> _saveHistoryIfNeeded() async {
    if (!_committedSearch || !mounted) return;
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      await context.read<SearchHistoryCubit>().add(q);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _committedSearch = false;
    setState(() {});
    _focusNode.requestFocus();
  }

  Future<void> _popWithCleanup() async {
    if (_isPopping) return;
    _isPopping = true;
    // Unfocus before pop so keyboard/overlay teardown does not race
    // InheritedWidget deactivate (debugDeactivated _dependents.isEmpty).
    _focusNode.unfocus();
    final productBloc = context.read<ProductBloc>();
    // Capture navigator before awaits; PopScope.canPop is false so maybePop
    // never leaves — force pop when a previous route exists (pushed search).
    final navigator = Navigator.of(context);
    try {
      await _saveHistoryIfNeeded();
    } catch (_) {
      // Best-effort history; always leave the page.
    }
    if (!mounted) return;
    if (navigator.canPop()) {
      navigator.pop();
    }
    // Clear sticky query after pop so the bloc event does not trigger a
    // rebuild on the now-disposed widget tree.
    if (_config.clearBlocQueryOnExit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        productBloc.add(const ProductSearchChanged(''));
      });
    }
  }

  String? _matchTypeLabel(String? field, AppLocalizations l10n) {
    return switch (field) {
      'name' => l10n.searchMatchName,
      'sku' => l10n.searchMatchSku,
      'barcode' => l10n.searchMatchBarcode,
      _ => null,
    };
  }

  Future<void> _handleAddResult(SaleAddResult result) async {
    if (!mounted) return;
    if (result == SaleAddResult.blockedOos) {
      AppSnackBar.error(context, context.l10n.outOfStock);
      return;
    }
    if (result == SaleAddResult.added ||
        result == SaleAddResult.optionsOpened) {
      _markCommitted();
      final q = _searchController.text.trim();
      if (q.isNotEmpty) {
        await context.read<SearchHistoryCubit>().add(q);
      }
    }
  }

  Future<void> _onProductTap(Product product) async {
    final result = await saleAddToCart(context, product);
    await _handleAddResult(result);
  }

  Future<void> _onSubmitted(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return;

    setState(() {});

    // V092-E.3: exact barcode/SKU lookup goes to DB (not the paginated
    // in-memory list) so items beyond the 500-row page are not missed.
    final productRepo = sl<ProductRepository>();
    final byBarcode = await productRepo.getProductByBarcode(query);
    if (byBarcode != null) {
      if (!mounted) return;
      final result = await saleAddToCart(context, byBarcode);
      await _handleAddResult(result);
      return;
    }
    final bySku = await productRepo.getProductBySku(query);
    if (bySku != null) {
      if (!mounted) return;
      final result = await saleAddToCart(context, bySku);
      await _handleAddResult(result);
      return;
    }

    // Name search: use the in-memory list (pagination is fine for display).
    if (!mounted) return;
    final products = context.read<ProductBloc>().state.products;
    final hits = matchProducts(
      products,
      query,
      includeInactive: _config.includeInactive,
    );
    if (hits.isNotEmpty) {
      _markCommitted();
      if (!mounted) return;
      await context.read<SearchHistoryCubit>().add(query);
    }
  }

  Future<void> _onScan() async {
    await openSaleBarcodeScanner(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isPopping) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final query = _searchController.text;
    final history = context.watch<SearchHistoryCubit>().state.searches;
    final barcodeEnabled = context.select(
      (SettingsCubit c) => c.state.settings.barcodeScanEnabled,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _popWithCleanup();
      },
      child: BarcodeWedgeListener(
        enabled: barcodeEnabled,
        onBarcode: (code) {
          context.read<CartBloc>().add(CartBarcodeScanned(code));
        },
        child: MultiBlocListener(
          listeners: [
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
                  prev.errorNonce != curr.errorNonce &&
                  curr.errorMessage != null,
              listener: (context, state) {
                final code = state.errorMessage;
                if (code == 'barcodeNotFound') {
                  final failed = state.lastFailedBarcode;
                  AppSnackBar.withAction(
                    context,
                    l10n.barcodeNotFound,
                    actionLabel: l10n.createProductFromBarcode,
                    onAction: () async {
                      final product = await showProductCreatePageForResult(
                        context,
                        initialBarcode: failed,
                      );
                      if (!context.mounted) return;
                      if (product != null &&
                          failed != null &&
                          failed.isNotEmpty) {
                        context.read<CartBloc>().add(
                          CartBarcodeScanned(failed),
                        );
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
          ],
          child: Scaffold(
            backgroundColor: scheme.surface,
            appBar: AppBar(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 56,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _popWithCleanup,
              ),
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SearchAppBarField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  hintText: l10n.searchByNameSkuBarcode,
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSubmitted,
                  onClear: _clearSearch,
                  showClear: query.isNotEmpty,
                ),
              ),
              actions: [
                if (barcodeEnabled)
                  IconButton(
                    key: const ValueKey('sale-search-scan'),
                    icon: SvgIcon(
                      'barcode-scan-icon',
                      size: 22,
                      color: theme.colorScheme.onPrimary,
                    ),
                    tooltip: l10n.scanBarcode,
                    onPressed: _onScan,
                  ),
              ],
            ),
            body: SafeArea(child: _buildBody(context, query, history)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String query, List<String> history) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (query.trim().isEmpty) {
      if (history.isEmpty) {
        return const SearchEmptyState(query: '', onClear: null);
      }
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                  onPressed: () => context.read<SearchHistoryCubit>().clear(),
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
                      onPressed: () => _applyQuery(q, unfocus: true),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<ProductBloc, ProductState>(
      // Catalog list only — query is local (controller), not bloc.searchQuery.
      buildWhen: (p, c) => p.products != c.products,
      builder: (context, state) {
        final hits = matchProducts(
          state.products,
          query,
          includeInactive: _config.includeInactive,
        );
        final total = hits.length;
        final cap = _config.resultCap;
        final shown = total > cap ? cap : total;
        final visible = hits.take(shown).toList();

        if (visible.isEmpty) {
          return SearchEmptyState(query: query, onClear: _clearSearch);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                total > cap
                    ? l10n.searchResultCount(shown)
                    : l10n.searchResultsCount(total),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<CartBloc, CartState>(
                buildWhen: (p, c) => p.items != c.items,
                builder: (context, cart) {
                  int qtyFor(String productId) => cart.items
                      .where((i) => i.product.id == productId)
                      .fold(0, (s, i) => s + i.qty);

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final hit = visible[index];
                      return SearchResultTile(
                        product: hit.product,
                        query: query,
                        matchField: hit.matchField,
                        matchType: _matchTypeLabel(hit.matchField, l10n),
                        cartQty: _config.showCartQty
                            ? qtyFor(hit.product.id)
                            : 0,
                        showAddAffordance: _config.showAddAffordance,
                        onTap: () => _onProductTap(hit.product),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
