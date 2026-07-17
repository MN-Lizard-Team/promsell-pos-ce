import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/search_surface_config.dart';

void main() {
  group('SearchSurfaceConfig factories', () {
    test('sale is ephemeral; catalog is sticky', () {
      expect(SearchSurfaceConfig.saleFullSearch.writeBlocOnType, isFalse);
      expect(
        SearchSurfaceConfig.saleFullSearch.queryOwnership,
        SearchQueryOwnership.localEphemeral,
      );
      expect(SearchSurfaceConfig.catalogFullSearch.writeBlocOnType, isTrue);
      expect(
        SearchSurfaceConfig.catalogFullSearch.queryOwnership,
        SearchQueryOwnership.blocSticky,
      );
    });

    test('sale clears bloc query on exit; catalog does not', () {
      expect(SearchSurfaceConfig.saleFullSearch.clearBlocQueryOnExit, isTrue);
      expect(
        SearchSurfaceConfig.catalogFullSearch.clearBlocQueryOnExit,
        isFalse,
      );
    });

    test('inactive: catalog includes, sale excludes', () {
      expect(SearchSurfaceConfig.catalogFullSearch.includeInactive, isTrue);
      expect(SearchSurfaceConfig.saleFullSearch.includeInactive, isFalse);
    });

    test('result actions differ', () {
      expect(
        SearchSurfaceConfig.catalogFullSearch.onResult,
        SearchResultAction.preview,
      );
      expect(
        SearchSurfaceConfig.saleFullSearch.onResult,
        SearchResultAction.addToCart,
      );
    });

    test('history keys stay isolated', () {
      expect(
        SearchSurfaceConfig.catalogFullSearch.historyKey,
        'product_search_history',
      );
      expect(
        SearchSurfaceConfig.saleFullSearch.historyKey,
        'sale_search_history',
      );
      expect(
        SearchSurfaceConfig.catalogFullSearch.historyKey,
        isNot(SearchSurfaceConfig.saleFullSearch.historyKey),
      );
    });

    test('sale list keeps filters; catalog list pauses', () {
      expect(
        SearchSurfaceConfig.saleListFiltered.pauseFiltersOnSearch,
        isFalse,
      );
      expect(
        SearchSurfaceConfig.catalogListSticky.pauseFiltersOnSearch,
        isTrue,
      );
    });

    test('sale full search shows cart affordances', () {
      final s = SearchSurfaceConfig.saleFullSearch;
      expect(s.showCartQty, isTrue);
      expect(s.showAddAffordance, isTrue);
      expect(SearchSurfaceConfig.catalogFullSearch.showCartQty, isFalse);
    });

    test('result cap default is 80', () {
      expect(SearchSurfaceConfig.defaultResultCap, 80);
      expect(SearchSurfaceConfig.saleFullSearch.resultCap, 80);
      expect(SearchSurfaceConfig.catalogFullSearch.resultCap, 80);
    });

    test('barcodeVisible requires settings', () {
      expect(
        SearchSurfaceConfig.catalogListSticky.barcodeVisible(true),
        isTrue,
      );
      expect(
        SearchSurfaceConfig.catalogListSticky.barcodeVisible(false),
        isFalse,
      );
    });

    test('catalog full search shows filters-ignored banner flag', () {
      expect(
        SearchSurfaceConfig.catalogFullSearch.showFiltersIgnoredBanner,
        isTrue,
      );
      expect(
        SearchSurfaceConfig.saleFullSearch.showFiltersIgnoredBanner,
        isFalse,
      );
    });
  });
}
