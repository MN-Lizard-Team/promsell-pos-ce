import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_page.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/get_products_page.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/import_products.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/csv_product_parser.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

/// Local mock — [MockGetProducts]-style classes live in helpers/mocks.dart,
/// which does not yet carry a SearchProductsPage mock.
class _MockSearchProductsPage extends Mock implements SearchProductsPage {}

/// Products living beyond the 500-item pagination cap.
final _deepProduct = Product(
  id: 'prod-deep-0000-0000-0000-000000000001',
  name: 'Deep Cola Beyond Cap',
  price: Money.fromDouble(10.0),
  stock: 3,
  isActive: true,
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
);

final _searchPage1Product = Product(
  id: 'prod-search-0000-0000-0000-000000000001',
  name: 'Cola One',
  price: Money.fromDouble(11.0),
  stock: 4,
  isActive: true,
  createdAt: DateTime(2024, 5, 2),
  updatedAt: DateTime(2024, 5, 2),
);

final _searchPage2Product = Product(
  id: 'prod-search-0000-0000-0000-000000000002',
  name: 'Cola Two',
  price: Money.fromDouble(12.0),
  stock: 5,
  isActive: true,
  createdAt: DateTime(2024, 5, 1),
  updatedAt: DateTime(2024, 5, 1),
);

void main() {
  late MockGetProducts mockGetProducts;
  late MockGetProductCount mockGetProductCount;
  late MockAddProduct mockAddProduct;
  late MockUpdateProduct mockUpdateProduct;
  late MockDeleteProduct mockDeleteProduct;
  late MockRestoreProduct mockRestoreProduct;
  late MockBatchGenerateBarcodes mockBatchGenerateBarcodes;
  late MockImportProducts mockImportProducts;

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockGetProductCount = MockGetProductCount();
    mockAddProduct = MockAddProduct();
    mockUpdateProduct = MockUpdateProduct();
    mockDeleteProduct = MockDeleteProduct();
    mockRestoreProduct = MockRestoreProduct();
    mockBatchGenerateBarcodes = MockBatchGenerateBarcodes();
    mockImportProducts = MockImportProducts();
  });

  setUpAll(() {
    registerFallbackValue(tProduct);
  });

  ProductBloc buildBloc({SearchProductsPage? searchProductsPage}) =>
      ProductBloc(
        getProducts: mockGetProducts,
        getProductCount: mockGetProductCount,
        addProduct: mockAddProduct,
        updateProduct: mockUpdateProduct,
        deleteProduct: mockDeleteProduct,
        restoreProduct: mockRestoreProduct,
        batchGenerateBarcodes: mockBatchGenerateBarcodes,
        importProducts: mockImportProducts,
        searchProductsPage: searchProductsPage,
      );

  group('ProductBloc', () {
    test('initial state is ProductState()', () {
      when(() => mockGetProducts()).thenAnswer((_) => const Stream.empty());
      expect(buildBloc().state, const ProductState());
    });

    blocTest<ProductBloc, ProductState>(
      'ProductsSubscribed emits loading then success',
      setUp: () {
        when(() => mockGetProductCount()).thenAnswer((_) async => 2);
        when(
          () => mockGetProducts(limit: any(named: 'limit')),
        ).thenAnswer((_) => Stream.value([tProduct, tProduct2]));
      },
      build: buildBloc,
      act: (b) => b.add(const ProductsSubscribed()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        ProductState(
          status: ProductStatus.success,
          products: [tProduct, tProduct2],
          totalProductCount: 2,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'ProductAdded calls addProduct use case',
      setUp: () {
        when(
          () => mockAddProduct(
            name: any(named: 'name'),
            price: any(named: 'price'),
            stock: any(named: 'stock'),
            categoryId: any(named: 'categoryId'),
            imageUrl: any(named: 'imageUrl'),
            imagePath: any(named: 'imagePath'),
          ),
        ).thenAnswer((_) async => 'new-uuid');
      },
      build: buildBloc,
      act: (b) => b.add(const ProductAdded(name: 'New', price: 50, stock: 10)),
      verify: (_) {
        verify(
          () => mockAddProduct(name: 'New', price: 50, stock: 10),
        ).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ProductUpdated calls updateProduct use case',
      setUp: () {
        when(() => mockUpdateProduct(any())).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (b) => b.add(ProductUpdated(tProduct)),
      verify: (_) {
        verify(() => mockUpdateProduct(tProduct)).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ProductDeleted calls deleteProduct use case',
      setUp: () {
        when(() => mockDeleteProduct(any())).thenAnswer((_) async {});
      },
      build: buildBloc,
      act: (b) =>
          b.add(const ProductDeleted('prod-0001-0001-0001-000000000001')),
      verify: (_) {
        verify(
          () => mockDeleteProduct('prod-0001-0001-0001-000000000001'),
        ).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ProductSearchChanged updates searchQuery',
      build: buildBloc,
      act: (b) => b.add(const ProductSearchChanged('drink')),
      expect: () => [const ProductState(searchQuery: 'drink')],
    );

    test('ProductState.filtered filters by name, SKU, and barcode', () {
      final state = ProductState(
        products: [tProduct, tProduct2, tInactiveProduct],
        searchQuery: 'Test',
      );
      expect(state.filtered, [tProduct]);
    });

    blocTest<ProductBloc, ProductState>(
      'ProductSearchChanged with empty string resets filter (UI-BUG-1 regression)',
      seed: () => ProductState(
        status: ProductStatus.success,
        products: [tProduct, tProduct2],
        searchQuery: 'drink',
      ),
      build: buildBloc,
      act: (b) => b.add(const ProductSearchChanged('')),
      expect: () => [
        ProductState(
          status: ProductStatus.success,
          products: [tProduct, tProduct2],
          searchQuery: '',
        ),
      ],
      verify: (bloc) {
        expect(bloc.state.filtered, [tProduct, tProduct2]);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ProductAdded emits error on DuplicateBarcodeException',
      setUp: () {
        when(
          () => mockAddProduct(
            name: any(named: 'name'),
            price: any(named: 'price'),
            stock: any(named: 'stock'),
            barcode: any(named: 'barcode'),
          ),
        ).thenThrow(const DuplicateBarcodeException('123'));
      },
      build: buildBloc,
      act: (b) => b.add(
        const ProductAdded(name: 'New', price: 50, stock: 10, barcode: '123'),
      ),
      expect: () => [
        const ProductState(saveStatus: ProductSaveStatus.saving),
        const ProductState(
          saveStatus: ProductSaveStatus.error,
          error: BusinessRuleError('DuplicateBarcode'),
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'ProductUpdated emits error on DuplicateBarcodeException',
      setUp: () {
        when(
          () => mockUpdateProduct(any()),
        ).thenThrow(const DuplicateBarcodeException('123'));
      },
      build: buildBloc,
      act: (b) => b.add(ProductUpdated(tProductWithBarcode)),
      expect: () => [
        const ProductState(saveStatus: ProductSaveStatus.saving),
        const ProductState(
          saveStatus: ProductSaveStatus.error,
          error: BusinessRuleError('DuplicateBarcode'),
        ),
      ],
    );
    blocTest<ProductBloc, ProductState>(
      'ProductTabChanged updates selectedTab',
      build: buildBloc,
      act: (b) => b.add(const ProductTabChanged(ProductTabFilter.stock)),
      expect: () => [const ProductState(selectedTab: ProductTabFilter.stock)],
    );

    blocTest<ProductBloc, ProductState>(
      'ProductsImported uses importStatus (not ProductStatus) so catalog stream cannot race dialog',
      setUp: () {
        when(
          () => mockImportProducts(any()),
        ).thenAnswer((_) async => const ProductImportResult(importedCount: 3));
      },
      build: buildBloc,
      act: (b) => b.add(
        const ProductsImported([
          CsvProductRow(sourceRow: 2, name: 'Test', price: 10),
        ]),
      ),
      expect: () => [
        const ProductState(importStatus: ProductImportStatus.importing),
        const ProductState(
          importStatus: ProductImportStatus.success,
          importResult: ProductImportResult(importedCount: 3),
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'ProductsSubscribed emits failure when getProductCount throws',
      setUp: () {
        when(() => mockGetProductCount()).thenThrow(Exception('count failed'));
      },
      build: buildBloc,
      act: (b) => b.add(const ProductsSubscribed()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        const ProductState(
          status: ProductStatus.failure,
          error: DatabaseError(
            'Exception: count failed',
            operation: 'load_products',
          ),
        ),
      ],
      verify: (_) {
        verify(() => mockGetProductCount()).called(1);
        verifyNever(() => mockGetProducts(limit: any(named: 'limit')));
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ProductsSubscribed emits failure when getProductCount throws (preserves products)',
      setUp: () {
        when(() => mockGetProductCount()).thenThrow(Exception('count failed'));
      },
      seed: () =>
          ProductState(status: ProductStatus.success, products: [tProduct]),
      build: buildBloc,
      act: (b) => b.add(const ProductsSubscribed()),
      expect: () => [
        ProductState(status: ProductStatus.loading, products: [tProduct]),
        ProductState(
          status: ProductStatus.failure,
          products: [tProduct],
          error: const DatabaseError(
            'Exception: count failed',
            operation: 'load_products',
          ),
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'Bug 8: stream update preserves saveStatus when saving (race condition regression)',
      setUp: () {
        when(() => mockGetProductCount()).thenAnswer((_) async => 2);
        when(
          () => mockGetProducts(limit: any(named: 'limit')),
        ).thenAnswer((_) => Stream.value([tProduct, tProduct2]));
      },
      seed: () => ProductState(
        status: ProductStatus.success,
        products: [tProduct],
        saveStatus: ProductSaveStatus.saving,
      ),
      build: buildBloc,
      act: (b) => b.add(const ProductsSubscribed()),
      expect: () => [
        ProductState(
          status: ProductStatus.loading,
          products: [tProduct],
          saveStatus: ProductSaveStatus.saving,
        ),
        ProductState(
          status: ProductStatus.success,
          products: [tProduct, tProduct2],
          totalProductCount: 2,
          saveStatus: ProductSaveStatus.saving,
        ),
      ],
    );

    blocTest<ProductBloc, ProductState>(
      'Bug 8: stream update preserves saveStatus when saved (race condition regression)',
      setUp: () {
        when(() => mockGetProductCount()).thenAnswer((_) async => 2);
        when(
          () => mockGetProducts(limit: any(named: 'limit')),
        ).thenAnswer((_) => Stream.value([tProduct, tProduct2]));
      },
      seed: () => ProductState(
        status: ProductStatus.success,
        products: [tProduct],
        saveStatus: ProductSaveStatus.saved,
      ),
      build: buildBloc,
      act: (b) => b.add(const ProductsSubscribed()),
      expect: () => [
        ProductState(
          status: ProductStatus.loading,
          products: [tProduct],
          saveStatus: ProductSaveStatus.saved,
        ),
        ProductState(
          status: ProductStatus.success,
          products: [tProduct, tProduct2],
          totalProductCount: 2,
          saveStatus: ProductSaveStatus.saved,
        ),
      ],
    );
  });

  group('ProductBloc DB search (capped catalog)', () {
    late _MockSearchProductsPage mockSearch;

    setUp(() {
      mockSearch = _MockSearchProductsPage();
    });

    setUpAll(() {
      registerFallbackValue('');
      registerFallbackValue(
        ProductCursor(createdAt: DateTime(2024), id: 'cursor-fallback'),
      );
    });

    // Capped seed: loaded set (1) < total (501) → search must hit the DB.
    ProductState cappedSeed() => ProductState(
      status: ProductStatus.success,
      products: [tProduct],
      totalProductCount: 501,
    );

    blocTest<ProductBloc, ProductState>(
      'search beyond cap queries DB and emits ranked searchResults',
      setUp: () {
        when(
          () => mockSearch(query: 'cola', activeOnly: true, pageSize: 100),
        ).thenAnswer(
          (_) async => ProductPage(
            products: [_deepProduct],
            nextCursor: ProductCursor(
              createdAt: _deepProduct.createdAt,
              id: _deepProduct.id,
            ),
            totalCount: 501,
          ),
        );
      },
      seed: cappedSeed,
      build: () => buildBloc(searchProductsPage: mockSearch),
      act: (b) => b.add(const ProductSearchChanged(' cola ')),
      expect: () => [
        ProductState(
          status: ProductStatus.success,
          products: [tProduct],
          totalProductCount: 501,
          searchQuery: 'cola',
          isSearching: true,
        ),
        ProductState(
          status: ProductStatus.success,
          products: [tProduct],
          totalProductCount: 501,
          searchQuery: 'cola',
          searchResults: [_deepProduct],
          hasMoreSearchResults: true,
        ),
      ],
      verify: (_) {
        verify(
          () => mockSearch(query: 'cola', activeOnly: true, pageSize: 100),
        ).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'empty query clears searchResults without fetching',
      setUp: () {
        when(
          () => mockSearch(query: '', activeOnly: true, pageSize: 100),
        ).thenAnswer(
          (_) async => const ProductPage(
            products: [],
            nextCursor: null,
            totalCount: 501,
          ),
        );
      },
      seed: () => ProductState(
        status: ProductStatus.success,
        products: [tProduct],
        totalProductCount: 501,
        searchQuery: 'cola',
        searchResults: [_deepProduct],
        hasMoreSearchResults: true,
      ),
      build: () => buildBloc(searchProductsPage: mockSearch),
      act: (b) => b.add(const ProductSearchChanged('')),
      expect: () => [
        ProductState(
          status: ProductStatus.success,
          products: [tProduct],
          totalProductCount: 501,
          searchQuery: '',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockSearch(query: '', activeOnly: true, pageSize: 100),
        );
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ProductLoadMore appends second page via cursor and flips hasMoreSearchResults off when exhausted',
      setUp: () {
        when(
          () => mockSearch(
            query: 'cola',
            cursor: ProductCursor(
              createdAt: _searchPage1Product.createdAt,
              id: _searchPage1Product.id,
            ),
            activeOnly: true,
            pageSize: 100,
          ),
        ).thenAnswer(
          (_) async => ProductPage(
            products: [_searchPage2Product],
            nextCursor: null,
            totalCount: 501,
          ),
        );
      },
      seed: () => ProductState(
        status: ProductStatus.success,
        products: [tProduct],
        totalProductCount: 501,
        searchQuery: 'cola',
        searchResults: [_searchPage1Product],
        hasMoreSearchResults: true,
      ),
      build: () => buildBloc(searchProductsPage: mockSearch),
      act: (b) => b.add(const ProductLoadMore()),
      expect: () => [
        ProductState(
          status: ProductStatus.success,
          products: [tProduct],
          totalProductCount: 501,
          searchQuery: 'cola',
          searchResults: [_searchPage1Product],
          isSearching: true,
          hasMoreSearchResults: true,
        ),
        ProductState(
          status: ProductStatus.success,
          products: [tProduct],
          totalProductCount: 501,
          searchQuery: 'cola',
          searchResults: [_searchPage1Product, _searchPage2Product],
          hasMoreSearchResults: false,
        ),
      ],
      verify: (_) {
        verify(
          () => mockSearch(
            query: 'cola',
            cursor: ProductCursor(
              createdAt: _searchPage1Product.createdAt,
              id: _searchPage1Product.id,
            ),
            activeOnly: true,
            pageSize: 100,
          ),
        ).called(1);
      },
    );

    blocTest<ProductBloc, ProductState>(
      'ProductLoadMore emits nothing when no search results are active',
      build: () => buildBloc(searchProductsPage: mockSearch),
      seed: cappedSeed,
      act: (b) => b.add(const ProductLoadMore()),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockSearch(query: any(named: 'query')));
      },
    );

    blocTest<ProductBloc, ProductState>(
      'uncapped catalog keeps client-side search and never fetches pages',
      build: () => buildBloc(searchProductsPage: mockSearch),
      seed: () => ProductState(
        status: ProductStatus.success,
        products: [tProduct, tProduct2],
        totalProductCount: 2,
      ),
      act: (b) => b.add(const ProductSearchChanged('another')),
      expect: () => [
        ProductState(
          status: ProductStatus.success,
          products: [tProduct, tProduct2],
          totalProductCount: 2,
          searchQuery: 'another',
        ),
      ],
      verify: (_) {
        verifyNever(
          () => mockSearch(query: 'another', activeOnly: true, pageSize: 100),
        );
      },
    );

    blocTest<ProductBloc, ProductState>(
      'search failure lands in failure state without losing prior products',
      setUp: () {
        when(
          () => mockSearch(query: 'cola', activeOnly: true, pageSize: 100),
        ).thenThrow(Exception('db down'));
      },
      seed: cappedSeed,
      build: () => buildBloc(searchProductsPage: mockSearch),
      act: (b) => b.add(const ProductSearchChanged('cola')),
      expect: () => [
        ProductState(
          status: ProductStatus.success,
          products: [tProduct],
          totalProductCount: 501,
          searchQuery: 'cola',
          isSearching: true,
        ),
        ProductState(
          status: ProductStatus.failure,
          products: [tProduct],
          totalProductCount: 501,
          searchQuery: 'cola',
          error: const DatabaseError(
            'Exception: db down',
            operation: 'search_products',
          ),
        ),
      ],
    );
  });
}
