/// How product search query text is owned relative to [ProductBloc].
enum SearchQueryOwnership {
  /// Debounced write to ProductBloc; hydrate from bloc; sticky list filter.
  blocSticky,

  /// Local TextEditingController only; never mutate shared list filter while open.
  localEphemeral,
}

/// Primary action when the user commits a product hit.
enum SearchResultAction {
  /// Catalog admin: open product preview.
  preview,

  /// POS sale: add to cart and stay on search.
  addToCart,
}

/// How list filters interact with a non-empty search query on a *list* surface.
enum SearchFilterMode {
  /// Catalog list: ranked match only; pause category/stock/price.
  pauseListFilters,

  /// Sale grid: keep category (etc.), rank within filtered set.
  keepListFilters,
}

/// Immutable policy for one product-search surface.
///
/// Prefer [catalogFullSearch], [catalogListSticky], [saleFullSearch], and
/// [saleListFiltered] over free-form construction.
///
/// Does **not** merge Sale and Product into one page — two routes remain.
class SearchSurfaceConfig {
  const SearchSurfaceConfig({
    required this.surfaceId,
    required this.historyKey,
    required this.queryOwnership,
    required this.onResult,
    required this.includeInactive,
    required this.filterMode,
    this.clearBlocQueryOnExit = false,
    this.hydrateFromBloc = false,
    this.showCartQty = false,
    this.showAddAffordance = false,
    this.showFiltersIgnoredBanner = false,
    this.resultCap = defaultResultCap,
    this.barcodeUiEnabled = true,
  });

  /// Shared painted-hit cap for full-screen product search pages.
  static const int defaultResultCap = 80;

  /// Stable id for tests / analytics (not storage).
  final String surfaceId;

  /// [SearchHistoryCubit] persistence key.
  final String historyKey;

  final SearchQueryOwnership queryOwnership;
  final SearchResultAction onResult;

  /// Passed to [matchProducts] / list matching.
  final bool includeInactive;

  /// For inline list filtering (product list vs sale catalog).
  final SearchFilterMode filterMode;

  /// Sale full search: clear shared [ProductBloc.searchQuery] on pop.
  final bool clearBlocQueryOnExit;

  /// Catalog full search: seed field from sticky bloc query.
  final bool hydrateFromBloc;

  final bool showCartQty;
  final bool showAddAffordance;
  final bool showFiltersIgnoredBanner;
  final int resultCap;

  /// AND with [Settings.barcodeScanEnabled] at the call site.
  final bool barcodeUiEnabled;

  bool get writeBlocOnType => queryOwnership == SearchQueryOwnership.blocSticky;

  bool get pauseFiltersOnSearch =>
      filterMode == SearchFilterMode.pauseListFilters;

  bool barcodeVisible(bool settingsEnabled) =>
      barcodeUiEnabled && settingsEnabled;

  // ── Factories ───────────────────────────────────────────────────────────

  /// Full-screen catalog admin search + sticky list coupling.
  static const catalogFullSearch = SearchSurfaceConfig(
    surfaceId: 'catalog.full_search',
    historyKey: 'product_search_history',
    queryOwnership: SearchQueryOwnership.blocSticky,
    onResult: SearchResultAction.preview,
    includeInactive: true,
    filterMode: SearchFilterMode.pauseListFilters,
    clearBlocQueryOnExit: false,
    hydrateFromBloc: true,
    showFiltersIgnoredBanner: true,
  );

  /// Product list app-bar chrome (sticky query display / clear / scan).
  static const catalogListSticky = SearchSurfaceConfig(
    surfaceId: 'catalog.list_sticky',
    historyKey: 'product_search_history',
    queryOwnership: SearchQueryOwnership.blocSticky,
    onResult: SearchResultAction.preview,
    includeInactive: true,
    filterMode: SearchFilterMode.pauseListFilters,
    clearBlocQueryOnExit: false,
    hydrateFromBloc: true,
  );

  /// Full-screen POS sale search (cart-first, stay-on-add, local query).
  static const saleFullSearch = SearchSurfaceConfig(
    surfaceId: 'sale.full_search',
    historyKey: 'sale_search_history',
    queryOwnership: SearchQueryOwnership.localEphemeral,
    onResult: SearchResultAction.addToCart,
    includeInactive: false,
    filterMode: SearchFilterMode.pauseListFilters,
    clearBlocQueryOnExit: true,
    hydrateFromBloc: false,
    showCartQty: true,
    showAddAffordance: true,
    showFiltersIgnoredBanner: false,
  );

  /// Sale product grid under category chips.
  static const saleListFiltered = SearchSurfaceConfig(
    surfaceId: 'sale.list_filtered',
    historyKey: 'sale_search_history',
    queryOwnership: SearchQueryOwnership.blocSticky,
    onResult: SearchResultAction.addToCart,
    includeInactive: false,
    filterMode: SearchFilterMode.keepListFilters,
    clearBlocQueryOnExit: false,
    showCartQty: true,
    showAddAffordance: true,
  );
}
