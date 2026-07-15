import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockProductRepository mockProductRepo;
  late MockSettingsRepository mockSettingsRepo;
  late MockPromotionRepository mockPromotionRepo;

  final tProduct = Product(
    id: 'prod-0001',
    name: 'Test Product',
    price: Money.fromDouble(100),
    stock: 50,
    isActive: true,
    trackStock: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final tProduct2 = Product(
    id: 'prod-0002',
    name: 'Another Product',
    price: Money.fromDouble(250.5),
    stock: 10,
    isActive: true,
    trackStock: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final tServiceProduct = Product(
    id: 'prod-0004',
    name: 'Service Item',
    price: Money.fromDouble(200),
    stock: 0,
    isActive: true,
    trackStock: false,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  final tCartItem = CartItem(product: tProduct, qty: 2, lineId: 'line-a');
  final tCartItem2 = CartItem(product: tProduct2, qty: 1, lineId: 'line-b');

  /// Match cart state by product/qty (ignore generated [CartItem.lineId]).
  Matcher cartWith(
    List<CartItem> items, {
    String? stockWarning,
    String? errorMessage,
    String? lastFailedBarcode,
    int? errorNonce,
  }) {
    return predicate<CartState>((s) {
      if (s.items.length != items.length) return false;
      for (var i = 0; i < items.length; i++) {
        final a = s.items[i];
        final b = items[i];
        if (a.product != b.product ||
            a.qty != b.qty ||
            a.discountType != b.discountType ||
            a.discountValue != b.discountValue ||
            a.note != b.note ||
            a.isAvailable != b.isAvailable) {
          return false;
        }
      }
      if (stockWarning != null && s.stockWarning != stockWarning) return false;
      if (errorMessage != null && s.errorMessage != errorMessage) return false;
      if (lastFailedBarcode != null &&
          s.lastFailedBarcode != lastFailedBarcode) {
        return false;
      }
      if (errorNonce != null && s.errorNonce != errorNonce) return false;
      return true;
    }, 'CartState with matching items (lineId ignored)');
  }

  setUp(() {
    mockProductRepo = MockProductRepository();
    mockSettingsRepo = MockSettingsRepository();
    mockPromotionRepo = MockPromotionRepository();
    registerFallbackValue(const Settings());
  });

  CartBloc buildBloc() => CartBloc(
    productRepo: mockProductRepo,
    settingsRepo: mockSettingsRepo,
    promotionRepo: mockPromotionRepo,
  );

  test('initial state is CartState()', () {
    expect(buildBloc().state, const CartState());
  });

  group('CartProductAdded', () {
    blocTest<CartBloc, CartState>(
      'adds product to cart',
      build: buildBloc,
      act: (b) => b.add(CartProductAdded(tProduct)),
      expect: () => [
        cartWith([CartItem(product: tProduct, qty: 1, lineId: 'x')]),
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
        cartWith([CartItem(product: tServiceProduct, qty: 1, lineId: 'x')]),
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

  group('CartRestored', () {
    blocTest<CartBloc, CartState>(
      'restores full session meta from draft/snapshot fields',
      build: buildBloc,
      act: (b) => b.add(
        CartRestored(
          items: [tCartItem],
          note: 'table 5',
          cartDiscountType: 'PERCENT',
          cartDiscountValue: 10,
          orderType: 'dine_in',
          orderChannel: 'walkin',
          externalOrderRef: 'EXT-1',
          tableId: 'table-1',
          serviceChargeRate: 10,
          customerId: 'cust-1',
          promotionId: 'promo-1',
          promotionDiscountAmount: 5,
        ),
      ),
      expect: () => [
        CartState(
          items: [tCartItem],
          note: 'table 5',
          cartDiscountType: 'PERCENT',
          cartDiscountValue: 10,
          orderType: 'dine_in',
          orderChannel: 'walkin',
          externalOrderRef: 'EXT-1',
          tableId: 'table-1',
          serviceChargeRate: 10,
          customerId: 'cust-1',
          promotionId: 'promo-1',
          promotionDiscountAmount: 5,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'fromCartState round-trips session fields',
      build: buildBloc,
      act: (b) {
        const seed = CartState(
          items: [],
          note: 'n',
          orderType: 'takeaway',
          tableId: 't2',
          serviceChargeRate: 5,
          customerId: 'c2',
        );
        b.add(CartRestored.fromCartState(seed));
      },
      expect: () => [
        const CartState(
          note: 'n',
          orderType: 'takeaway',
          tableId: 't2',
          serviceChargeRate: 5,
          customerId: 'c2',
        ),
      ],
    );
  });

  group('CartCustomerSet', () {
    blocTest<CartBloc, CartState>(
      'sets customerId on cart',
      build: buildBloc,
      act: (b) => b.add(const CartCustomerSet('cust-9')),
      expect: () => [const CartState(customerId: 'cust-9')],
    );

    blocTest<CartBloc, CartState>(
      'clears customerId when null',
      build: buildBloc,
      seed: () => const CartState(customerId: 'cust-9'),
      act: (b) => b.add(const CartCustomerSet(null)),
      expect: () => [const CartState()],
    );
  });

  group('CartPromotionSet', () {
    final past = DateTime(2024, 1, 1);
    final now = DateTime(2025, 1, 1);
    final activePromo = Promotion(
      id: 'promo-1',
      name: '10% Off',
      type: PromotionType.percent,
      value: 10,
      startDate: past,
      createdAt: now,
      updatedAt: now,
    );

    blocTest<CartBloc, CartState>(
      'applies active promotion discount via discountFor',
      build: () {
        when(
          () => mockPromotionRepo.getPromotionById('promo-1'),
        ).thenAnswer((_) async => activePromo);
        return buildBloc();
      },
      seed: () => CartState(items: [tCartItem]), // 2 x 100 = 200
      act: (b) => b.add(const CartPromotionSet('promo-1')),
      expect: () => [
        CartState(
          items: [tCartItem],
          promotionId: 'promo-1',
          promotionDiscountAmount: 20, // 10% of 200
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'clears promotion when null',
      build: buildBloc,
      seed: () =>
          const CartState(promotionId: 'promo-1', promotionDiscountAmount: 20),
      act: (b) => b.add(const CartPromotionSet(null)),
      expect: () => [const CartState()],
    );

    blocTest<CartBloc, CartState>(
      'rejects missing promotion',
      build: () {
        when(
          () => mockPromotionRepo.getPromotionById('gone'),
        ).thenAnswer((_) async => null);
        return buildBloc();
      },
      act: (b) => b.add(const CartPromotionSet('gone')),
      expect: () => [
        predicate<CartState>(
          (s) =>
              s.promotionId == null &&
              s.errorMessage == 'promotionNotFound' &&
              s.errorNonce == 1,
        ),
      ],
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

  group('Line-aware cart actions', () {
    blocTest<CartBloc, CartState>(
      'applies a discount to the selected line only',
      build: buildBloc,
      seed: () {
        final first = CartItem(product: tProduct, qty: 1);
        final second = CartItem(product: tProduct, qty: 2);
        return CartState(items: [first, second]);
      },
      act: (bloc) {
        final lineId = bloc.state.items.last.lineId;
        bloc.add(
          CartItemDiscountChanged(
            productId: tProduct.id,
            lineId: lineId,
            discountType: 'PERCENT',
            discountValue: 10,
          ),
        );
      },
      verify: (bloc) {
        expect(bloc.state.items.first.discountAmount, Money.zero);
        expect(bloc.state.items.last.discountAmount, Money.fromDouble(20));
      },
    );

    blocTest<CartBloc, CartState>(
      'duplicates a line while preserving its options and note',
      build: buildBloc,
      seed: () => CartState(
        items: [
          CartItem(
            product: tProduct,
            qty: 2,
            note: 'No ice',
            discountType: 'PERCENT',
            discountValue: 10,
          ),
        ],
      ),
      act: (bloc) => bloc.add(CartItemDuplicated(bloc.state.items.single)),
      verify: (bloc) {
        expect(bloc.state.items, hasLength(2));
        expect(bloc.state.items.last.note, 'No ice');
        expect(bloc.state.items.last.discountAmount, Money.fromDouble(20));
        expect(
          bloc.state.items.last.lineId,
          isNot(bloc.state.items.first.lineId),
        );
      },
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
      act: (b) =>
          b.add(CartBulkItemsRemoved([tCartItem.lineId, tCartItem2.lineId])),
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
      act: (b) => b.add(
        CartBulkItemDiscountsCleared([tCartItem.lineId, tCartItem2.lineId]),
      ),
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
      act: (b) =>
          b.add(CartItemsReordered([tCartItem2.lineId, tCartItem.lineId])),
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
        cartWith([
          CartItem(
            product: tProduct.copyWith(stock: 0),
            qty: 2,
            lineId: tCartItem.lineId,
          ),
        ], stockWarning: 'Test Product'),
      ],
    );

    blocTest<CartBloc, CartState>(
      'clamps qty when stock is lower than cart qty',
      build: buildBloc,
      seed: () => CartState(
        items: [CartItem(product: tProduct, qty: 5, lineId: 'c')],
      ),
      act: (b) => b.add(CartProductsRefreshed([tProduct.copyWith(stock: 2)])),
      expect: () => [
        cartWith([
          CartItem(product: tProduct.copyWith(stock: 2), qty: 2, lineId: 'c'),
        ]),
      ],
    );

    blocTest<CartBloc, CartState>(
      'includes deleted product name in warning and marks item unavailable (Bug 5)',
      build: buildBloc,
      seed: () => CartState(items: [tCartItem]),
      act: (b) => b.add(const CartProductsRefreshed([])),
      expect: () => [
        CartState(
          items: [tCartItem.copyWith(isAvailable: false)],
          stockWarning: 'Test Product',
        ),
      ],
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
        cartWith([CartItem(product: tProduct, qty: 1, lineId: 'x')]),
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
        const CartState(
          errorMessage: 'barcodeNotFound',
          lastFailedBarcode: '0000000000000',
          errorNonce: 1,
        ),
      ],
    );

    blocTest<CartBloc, CartState>(
      'debounces identical barcode within 1s',
      build: buildBloc,
      setUp: () {
        when(
          () => mockProductRepo.getProductByBarcode('1234567890123'),
        ).thenAnswer((_) async => tProduct);
        when(
          () => mockSettingsRepo.load(),
        ).thenAnswer((_) async => const Settings());
      },
      act: (b) {
        b.add(const CartBarcodeScanned('1234567890123'));
        b.add(const CartBarcodeScanned('1234567890123'));
      },
      expect: () => [
        cartWith([CartItem(product: tProduct, qty: 1, lineId: 'x')]),
      ],
    );
  });


  group('payment lock', () {
    blocTest<CartBloc, CartState>(
      'paymentLocked rejects CartProductAdded',
      build: buildBloc,
      seed: () => CartState(
        items: [CartItem(product: tProduct, qty: 1, lineId: 'x')],
        paymentLocked: true,
      ),
      act: (b) => b.add(CartProductAdded(tProduct)),
      expect: () => [
        isA<CartState>()
            .having((s) => s.paymentLocked, 'locked', true)
            .having((s) => s.items, 'items', hasLength(1))
            .having((s) => s.errorMessage, 'err', 'paymentInProgress'),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartPaymentLockChanged toggles paymentLocked',
      build: buildBloc,
      act: (b) {
        b.add(const CartPaymentLockChanged(true));
        b.add(const CartPaymentLockChanged(false));
      },
      expect: () => [
        isA<CartState>().having((s) => s.paymentLocked, 'locked', true),
        isA<CartState>().having((s) => s.paymentLocked, 'locked', false),
      ],
    );

    blocTest<CartBloc, CartState>(
      'CartCleared always allowed and clears lock',
      build: buildBloc,
      seed: () => CartState(
        items: [CartItem(product: tProduct, qty: 2, lineId: 'x')],
        paymentLocked: true,
      ),
      act: (b) => b.add(const CartCleared()),
      expect: () => [const CartState()],
    );
  });

  test('close completes', () async {
    final bloc = buildBloc();
    bloc.add(CartProductAdded(tProduct));
    await bloc.stream.first;
    await expectLater(bloc.close(), completes);
  });
}
