import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/svg_icon.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_app_bar_field.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_result_tile.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_search.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/search_surface_config.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Max ranked hits painted on the search page (full count still shown in label).
/// Prefer [SearchSurfaceConfig.catalogFullSearch.resultCap].
const int kProductSearchResultCap = SearchSurfaceConfig.defaultResultCap;

class ProductSearchPage extends StatelessWidget {
  const ProductSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Prefer ancestor catalog blocs when opened from Product list; fall back
    // to DI for deep links / tests that only mount this page.
    ProductBloc productBloc;
    CategoryBloc categoryBloc;
    try {
      productBloc = context.read<ProductBloc>();
    } catch (_) {
      productBloc = sl<ProductBloc>();
    }
    try {
      categoryBloc = context.read<CategoryBloc>();
    } catch (_) {
      categoryBloc = sl<CategoryBloc>();
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: productBloc),
        BlocProvider.value(value: categoryBloc),
        BlocProvider(
          create: (_) => SearchHistoryCubit(
            sl<SettingsLocalDatasource>(),
            SearchSurfaceConfig.catalogFullSearch.historyKey,
          )..load(),
        ),
      ],
      child: const _ProductSearchView(),
    );
  }
}

class _ProductSearchView extends StatefulWidget {
  const _ProductSearchView();

  @override
  State<_ProductSearchView> createState() => _ProductSearchViewState();
}

class _ProductSearchViewState extends State<_ProductSearchView> {
  static const _config = SearchSurfaceConfig.catalogFullSearch;

  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  bool _hydrated = false;

  /// Persist history only after open / exact scan / submit with hits.
  bool _committedSearch = false;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hydrateFromBloc());
  }

  void _hydrateFromBloc() {
    if (!mounted || _hydrated) return;
    _hydrated = true;
    final q = context.read<ProductBloc>().state.searchQuery;
    if (q.isNotEmpty) {
      _searchController.text = q;
      _searchController.selection = TextSelection.collapsed(offset: q.length);
      // Returning with sticky query is a prior commit.
      _committedSearch = true;
      setState(() {});
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _markCommitted([String? query]) async {
    final q = (query ?? _searchController.text).trim();
    if (q.isEmpty) return;
    _committedSearch = true;
    if (!mounted) return;
    await context.read<SearchHistoryCubit>().add(q);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<ProductBloc>().add(ProductSearchChanged(query));
      setState(() {});
    });
  }

  void _applyQuery(String query, {bool unfocus = false}) {
    _debounce?.cancel();
    _searchController.text = query;
    _searchController.selection = TextSelection.collapsed(offset: query.length);
    if (unfocus) _focusNode.unfocus();
    context.read<ProductBloc>().add(ProductSearchChanged(query));
    setState(() {});
  }

  void _onRecentTap(String query) {
    _applyQuery(query, unfocus: true);
  }

  Future<void> _saveHistoryIfNeeded() async {
    if (!_committedSearch || !mounted) return;
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      await context.read<SearchHistoryCubit>().add(q);
    }
  }

  Future<void> _onSubmitted(String raw) async {
    _debounce?.cancel();
    final query = raw.trim();
    if (query.isEmpty) return;

    context.read<ProductBloc>().add(ProductSearchChanged(query));
    setState(() {});

    final products = context.read<ProductBloc>().state.products;
    final exact = resolveExactBarcodeMatches(products, query);

    if (exact.length == 1) {
      await _markCommitted(query);
      if (!mounted) return;
      showProductPreviewPage(context, exact.first);
      return;
    }
    if (exact.length > 1) {
      if (!mounted) return;
      AppSnackBar.info(
        context,
        context.l10n.barcodeAmbiguousCount(exact.length),
      );
      // Ambiguous is still a useful recent.
      await _markCommitted(query);
      return;
    }

    final hits = matchProducts(
      products,
      query,
      includeInactive: _config.includeInactive,
    );
    if (hits.isNotEmpty) {
      await _markCommitted(query);
    }
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    _committedSearch = false;
    context.read<ProductBloc>().add(const ProductSearchChanged(''));
    setState(() {});
    _focusNode.requestFocus();
  }

  Future<void> _popWithCleanup() async {
    if (_isPopping) return;
    _isPopping = true;
    _debounce?.cancel();
    // Unfocus before pop so keyboard/overlay teardown does not race
    // InheritedWidget deactivate (debugDeactivated _dependents.isEmpty).
    _focusNode.unfocus();
    // Capture navigator before awaits; PopScope.canPop is false so maybePop
    // never leaves — force pop when a previous route exists (pushed search).
    final navigator = Navigator.of(context);
    try {
      await _saveHistoryIfNeeded();
    } catch (_) {
      // Best-effort history; always leave the page.
    }
    if (!mounted) return;
    // Keep ProductBloc.searchQuery (sticky list filter).
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _onScan() async {
    final settings = context.read<SettingsCubit>().state.settings;
    final productBloc = context.read<ProductBloc>();
    final barcode = await showProductBarcodeScanner(
      context,
      beepOnScan: settings.barcodeBeepOnScan,
      formats: barcodeFormatsFromNames(settings.barcodeEnabledFormats),
      autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
      continuousScan: false,
      currency: settings.currency,
    );
    if (barcode == null || !mounted) return;

    final code = barcode.trim();
    _applyQuery(code, unfocus: true);

    final exact = resolveExactBarcodeMatches(productBloc.state.products, code);
    if (exact.length == 1) {
      await _markCommitted(code);
      if (!mounted) return;
      showProductPreviewPage(context, exact.first);
    } else if (exact.isEmpty) {
      final l10n = context.l10n;
      AppSnackBar.withAction(
        context,
        l10n.barcodeNotFound,
        actionLabel: l10n.createProductFromBarcode,
        onAction: () async {
          final product = await showProductCreatePageForResult(
            context,
            initialBarcode: code,
          );
          if (!mounted) return;
          if (product != null) {
            _applyQuery(code, unfocus: true);
            await _markCommitted(code);
            if (!mounted) return;
            showProductPreviewPage(context, product);
          }
        },
      );
    } else {
      await _markCommitted(code);
      if (!mounted) return;
      AppSnackBar.info(
        context,
        context.l10n.barcodeAmbiguousCount(exact.length),
      );
    }
  }

  String? _matchTypeLabel(
    String? field,
    AppLocalizations l10n,
    Product product,
  ) {
    final base = switch (field) {
      'name' => l10n.searchMatchName,
      'sku' => l10n.searchMatchSku,
      'barcode' => l10n.searchMatchBarcode,
      _ => null,
    };
    if (!product.isActive) {
      final inactive = l10n.inactive;
      return base == null ? inactive : '$base · $inactive';
    }
    return base;
  }

  Future<void> _openProduct(
    BuildContext context,
    Product product,
    String query,
  ) async {
    final q = query.trim();
    if (q.isNotEmpty) {
      await _markCommitted(q);
    }
    if (!context.mounted) return;
    showProductPreviewPage(context, product);
  }

  @override
  Widget build(BuildContext context) {
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
      child: Scaffold(
        backgroundColor: scheme.surface,
        appBar: AppBar(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 56,
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _popWithCleanup,
          ),
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
                key: const ValueKey('product-search-scan'),
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
        body: SafeArea(
          child: _buildBody(
            context,
            query,
            query.isEmpty && history.isNotEmpty,
            history,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    String query,
    bool showRecents,
    List<String> history,
  ) {
    if (query.isEmpty) {
      if (showRecents) {
        return _buildRecentSearches(context, history);
      }
      return const SearchEmptyState(query: '', onClear: null);
    }

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        final l10n = context.l10n;
        final theme = Theme.of(context);

        if (state.status == ProductStatus.loading && state.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == ProductStatus.failure && state.products.isEmpty) {
          return SearchEmptyState(query: query, onClear: _clearSearch);
        }

        // Catalog admin search includes inactive (manage / restore path).
        final hits = matchProducts(
          state.products,
          query,
          includeInactive: _config.includeInactive,
        );
        final filtersActive =
            _config.showFiltersIgnoredBanner && state.hasListFiltersActive;
        final total = hits.length;
        final cap = _config.resultCap;
        final shown = total > cap ? cap : total;

        if (total == 0) {
          return SearchEmptyState(query: query, onClear: _clearSearch);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (filtersActive)
              Material(
                color: theme.colorScheme.secondaryContainer,
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
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.searchFiltersIgnoredHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                shown < total
                    ? l10n.searchShowingCount(shown, total)
                    : l10n.searchResultCount(total),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                itemCount: shown,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final hit = hits[i];
                  final product = hit.product;
                  return Opacity(
                    opacity: product.isActive ? 1 : 0.72,
                    child: SearchResultTile(
                      key: ValueKey(product.id),
                      product: product,
                      query: query,
                      matchType: _matchTypeLabel(hit.matchField, l10n, product),
                      matchField: hit.matchField,
                      onTap: () => _openProduct(context, product, query),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentSearches(BuildContext context, List<String> history) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

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
                    onPressed: () => _onRecentTap(q),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
