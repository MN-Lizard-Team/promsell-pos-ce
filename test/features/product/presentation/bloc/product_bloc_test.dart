import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  setUp(() {
    mockGetProducts = MockGetProducts();
    mockAddProduct = MockAddProduct();
    mockUpdateProduct = MockUpdateProduct();
    mockDeleteProduct = MockDeleteProduct();
  });

  setUpAll(() {
    registerFallbackValue(tProduct);
  });

  ProductBloc buildBloc() => ProductBloc(
    getProducts: mockGetProducts,
    addProduct: mockAddProduct,
    updateProduct: mockUpdateProduct,
    deleteProduct: mockDeleteProduct,
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
            category: any(named: 'category'),
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

    test('ProductState.filtered filters by name and category', () {
      final state = ProductState(
        products: [tProduct, tProduct2, tInactiveProduct],
        searchQuery: 'drink',
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
  });
}
