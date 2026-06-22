import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/exceptions/duplicate_barcode_exception.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockGetProducts mockGetProducts;
  late MockAddProduct mockAddProduct;
  late MockUpdateProduct mockUpdateProduct;
  late MockDeleteProduct mockDeleteProduct;
  late MockBatchGenerateBarcodes mockBatchGenerateBarcodes;

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockAddProduct = MockAddProduct();
    mockUpdateProduct = MockUpdateProduct();
    mockDeleteProduct = MockDeleteProduct();
    mockBatchGenerateBarcodes = MockBatchGenerateBarcodes();
  });

  setUpAll(() {
    registerFallbackValue(tProduct);
  });

  ProductBloc buildBloc() => ProductBloc(
    getProducts: mockGetProducts,
    addProduct: mockAddProduct,
    updateProduct: mockUpdateProduct,
    deleteProduct: mockDeleteProduct,
    batchGenerateBarcodes: mockBatchGenerateBarcodes,
  );

  group('ProductBloc', () {
    test('initial state is ProductState()', () {
      when(() => mockGetProducts()).thenAnswer((_) => const Stream.empty());
      expect(buildBloc().state, const ProductState());
    });

    blocTest<ProductBloc, ProductState>(
      'ProductsSubscribed emits loading then success',
      setUp: () {
        when(
          () => mockGetProducts(),
        ).thenAnswer((_) => Stream.value([tProduct, tProduct2]));
      },
      build: buildBloc,
      act: (b) => b.add(const ProductsSubscribed()),
      expect: () => [
        const ProductState(status: ProductStatus.loading),
        ProductState(
          status: ProductStatus.success,
          products: [tProduct, tProduct2],
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
          errorMessage: 'duplicateBarcode',
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
          errorMessage: 'duplicateBarcode',
        ),
      ],
    );
  });
}
