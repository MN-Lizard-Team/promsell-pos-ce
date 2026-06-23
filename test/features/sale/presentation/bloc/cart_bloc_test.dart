import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockProductRepo;
  late MockSettingsRepository mockSettingsRepo;

  final tProduct = Product(
    id: 'prod-0001',
    name: 'Test Product',
    price: 100.0,
    stock: 50,
    isActive: true,
    trackStock: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final tProduct2 = Product(
    id: 'prod-0002',
    name: 'Another Product',
    price: 250.5,
    stock: 10,
    isActive: true,
    trackStock: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final tServiceProduct = Product(
    id: 'prod-0004',
    name: 'Service Item',
    price: 200.0,
    stock: 0,
    isActive: true,
    trackStock: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final tCartItem = CartItem(product: tProduct, qty: 2);
  final tCartItem2 = CartItem(product: tProduct2, qty: 1);

  setUp(() {
    mockProductRepo = MockProductRepository();
    mockSettingsRepo = MockSettingsRepository();
    registerFallbackValue(const Settings());
  });

  CartBloc buildBloc() =>
      CartBloc(productRepo: mockProductRepo, settingsRepo: mockSettingsRepo);

  test('initial state is CartState()', () {
    expect(buildBloc().state, const CartState());
  });

  group('CartProductAdded', () {
    blocTest<CartBloc, CartState>(
      'adds product to cart',
      build: buildBloc,
      act: (b) => b.add(CartProductAdded(tProduct)),
      expect: () => [
        CartState(items: [CartItem(product: tProduct, qty: 1)]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'increments qty for existing product',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) => b.add(CartProductAdded(tProduct)),
      expect: () => [
        CartState(items: [tCartItem.copyWith(qty: 3)]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits outOfStock error when stock=0 and trackStock=true (Bug 3)',
      build: buildBloc,
      act: (b) => b.add(CartProductAdded(tProduct.copyWith(stock: 0))),
      expect: () => [
        const CartState(errorMessage: 'outOfStock', errorNonce: 1),
      ],
    );

    blocTest<CartBloc, CartState>(
      'allowOversell=true can add beyond stock',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem.copyWith(qty: 50)]),
      act: (b) => b.add(CartProductAdded(tProduct, allowOversell: true)),
      expect: () => [
        CartState(items: [tCartItem.copyWith(qty: 51)]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'trackStock=false can always add regardless of stock=0',
      build: buildBloc,
      act: (b) => b.add(CartProductAdded(tServiceProduct)),
      expect: () => [
        CartState(items: [CartItem(product: tServiceProduct, qty: 1)]),
      ],
    );
  });

  group('CartProductRemoved', () {
    blocTest<CartBloc, CartState>(
      'removes product from cart',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) => b.add(const CartProductRemoved('prod-0001')),
      expect: () => [const CartState()],
    );
  });

  group('CartItemQtyChanged', () {
    blocTest<CartBloc, CartState>(
      'updates qty',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) =>
          b.add(const CartItemQtyChanged(productId: 'prod-0001', qty: 5)),
      expect: () => [
        CartState(items: [tCartItem.copyWith(qty: 5)]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'qty <= 0 removes item',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) =>
          b.add(const CartItemQtyChanged(productId: 'prod-0001', qty: 0)),
      expect: () => [const CartState()],
    );
  });

  group('CartCleared', () {
    blocTest<CartBloc, CartState>(
      'resets state',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem], note: 'note'),
      act: (b) => b.add(const CartCleared()),
      expect: () => [const CartState()],
    );
  });

  group('CartNoteChanged', () {
    blocTest<CartBloc, CartState>(
      'updates note',
      build: buildBloc,
      act: (b) => b.add(const CartNoteChanged('hello')),
      expect: () => [const CartState(note: 'hello')],
    );
  });

  group('CartItemDiscountChanged', () {
    blocTest<CartBloc, CartState>(
      'updates item discount',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) => b.add(
        const CartItemDiscountChanged(
          productId: 'prod-0001',
          discountType: 'PERCENT',
          discountValue: 10.0,
        ),
      ),
      expect: () => [
        CartState(
          items: [
            tCartItem.copyWith(discountType: 'PERCENT', discountValue: 10.0),
          ],
        ),
      ],
    );
  });

  group('CartItemDiscountCleared', () {
    blocTest<CartBloc, CartState>(
      'removes item discount',
      build: buildBloc,
      seed: () => CartState(
        items: [
          tCartItem.copyWith(discountType: 'PERCENT', discountValue: 10.0),
        ],
      ),
      act: (b) => b.add(const CartItemDiscountCleared('prod-0001')),
      expect: () => [
        CartState(items: [tCartItem.clearDiscount()]),
      ],
    );
  });

  group('CartDiscountChanged', () {
    blocTest<CartBloc, CartState>(
      'sets cart discount',
      build: buildBloc,
      act: (b) => b.add(
        const CartDiscountChanged(discountType: 'PERCENT', discountValue: 10.0),
      ),
      expect: () => [
        const CartState(cartDiscountType: 'PERCENT', cartDiscountValue: 10.0),
      ],
    );
  });

  group('CartDiscountCleared', () {
    blocTest<CartBloc, CartState>(
      'removes cart discount',
      build: buildBloc,
      seed: () =>
          const CartState(cartDiscountType: 'PERCENT', cartDiscountValue: 10.0),
      act: (b) => b.add(const CartDiscountCleared()),
      expect: () => [const CartState()],
    );
  });

  group('CartBulkItemsRemoved', () {
    blocTest<CartBloc, CartState>(
      'removes multiple items from cart',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem, tCartItem2]),
      act: (b) => b.add(CartBulkItemsRemoved([tProduct.id, tProduct2.id])),
      expect: () => [const CartState()],
    );
  });

  group('CartBulkItemDiscountsCleared', () {
    blocTest<CartBloc, CartState>(
      'clears discounts on specified items',
      build: buildBloc,
      seed: () => CartState(
        items: [
          tCartItem.copyWith(discountType: 'PERCENT', discountValue: 10.0),
          tCartItem2.copyWith(discountType: 'AMOUNT', discountValue: 5.0),
        ],
      ),
      act: (b) =>
          b.add(CartBulkItemDiscountsCleared([tProduct.id, tProduct2.id])),
      expect: () => [
        CartState(
          items: [tCartItem.clearDiscount(), tCartItem2.clearDiscount()],
        ),
      ],
    );
  });

  group('CartItemsReordered', () {
    blocTest<CartBloc, CartState>(
      'reorders items',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem, tCartItem2]),
      act: (b) => b.add(CartItemsReordered([tProduct2.id, tProduct.id])),
      expect: () => [
        CartState(items: [tCartItem2, tCartItem]),
      ],
    );
  });

  group('CartProductsRefreshed', () {
    blocTest<CartBloc, CartState>(
      'keeps out-of-stock items and sets stockWarning',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) => b.add(CartProductsRefreshed([tProduct.copyWith(stock: 0)])),
      expect: () => [
        CartState(
          items: [CartItem(product: tProduct.copyWith(stock: 0), qty: 2)],
          stockWarning: 'Test Product',
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'clamps qty when stock is lower than cart qty',
      build: buildBloc,
      seed: () => CartState(items: [CartItem(product: tProduct, qty: 5)]),
      act: (b) => b.add(CartProductsRefreshed([tProduct.copyWith(stock: 2)])),
      expect: () => [
        CartState(
          items: [CartItem(product: tProduct.copyWith(stock: 2), qty: 2)],
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'includes deleted product name in warning (Bug 5)',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) => b.add(const CartProductsRefreshed([])),
      expect: () => [const CartState(items: [], stockWarning: 'Test Product')],
    );
  });

  group('CartBarcodeScanned', () {
    blocTest<CartBloc, CartState>(
      'adds product to cart when found',
      build: buildBloc,
      setUp: () {
        when(
          () => mockProductRepo.getProductByBarcode('1234567890123'),
        ).thenAnswer((_) async => tProduct);
        when(
          () => mockSettingsRepo.load(),
        ).thenAnswer((_) async => const Settings());
      },
      act: (b) => b.add(const CartBarcodeScanned('1234567890123')),
      expect: () => [
        CartState(items: [CartItem(product: tProduct, qty: 1)]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'emits barcodeNotFound error when not found',
      build: buildBloc,
      setUp: () {
        when(
          () => mockProductRepo.getProductByBarcode('0000000000000'),
        ).thenAnswer((_) async => null);
      },
      act: (b) => b.add(const CartBarcodeScanned('0000000000000')),
      expect: () => [
        const CartState(errorMessage: 'barcodeNotFound', errorNonce: 1),
      ],
    );
  });

  test('close completes', () async {
    final bloc = buildBloc();
    bloc.add(CartProductAdded(tProduct));
    await bloc.stream.first;
    await expectLater(bloc.close(), completes);
  });
}
