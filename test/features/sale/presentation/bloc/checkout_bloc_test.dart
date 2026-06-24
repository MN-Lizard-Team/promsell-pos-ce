import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCreateSale mockCreateSale;
  late MockCartBloc mockCartBloc;
  late MockDraftBloc mockDraftBloc;

  final tNow = DateTime(2025, 1, 15, 10, 30);

  final tSale = Sale(
    id: 'sale-0001',
    totalAmount: 200.0,
    subtotalAmount: 200.0,
    discountType: null,
    discountValue: null,
    discountAmount: 0.0,
    vatMode: 'NONE',
    vatRate: 0.0,
    vatAmount: 0.0,
    paymentMethod: 'cash',
    amountReceived: 500.0,
    changeAmount: 300.0,
    note: null,
    createdAt: tNow,
    items: const [],
  );

  setUp(() {
    registerFallbackValue(const CartCleared());
    registerFallbackValue(const DraftRotated());
    mockCreateSale = MockCreateSale();
    mockCartBloc = MockCartBloc();
    mockDraftBloc = MockDraftBloc();
    when(() => mockCartBloc.state).thenReturn(
      CartState(
        items: [
          CartItem(
            product: Product(
              id: 'p1',
              name: 'Test',
              price: 100.0,
              stock: 10,
              isActive: true,
              trackStock: true,
              createdAt: tNow,
              updatedAt: tNow,
            ),
            qty: 2,
          ),
        ],
      ),
    );
    when(() => mockCartBloc.add(any())).thenReturn(null);
    when(() => mockDraftBloc.add(any())).thenReturn(null);
  });

  CheckoutBloc buildBloc() => CheckoutBloc(
    createSale: mockCreateSale,
    cartBloc: mockCartBloc,
    draftBloc: mockDraftBloc,
  );

  test('initial state is CheckoutState()', () {
    expect(buildBloc().state, const CheckoutState());
  });

  group('CheckoutConfirmed', () {
    blocTest<CheckoutBloc, CheckoutState>(
      'emits processing then success',
      build: buildBloc,
      setUp: () {
        when(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
            cartDiscountType: any(named: 'cartDiscountType'),
            cartDiscountValue: any(named: 'cartDiscountValue'),
            cartDiscountAmount: any(named: 'cartDiscountAmount'),
            amountReceived: any(named: 'amountReceived'),
            changeAmount: any(named: 'changeAmount'),
            note: any(named: 'note'),
            paymentReference: any(named: 'paymentReference'),
          ),
        ).thenAnswer((_) async => tSale);
      },
      act: (b) => b.add(
        const CheckoutConfirmed(
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: 500,
          changeAmount: 300,
        ),
      ),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.processing,
        ),
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.success)
            .having((s) => s.lastSale, 'lastSale', tSale),
      ],
      verify: (_) {
        verify(() => mockDraftBloc.add(const DraftRotated())).called(1);
      },
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits failure on error',
      build: buildBloc,
      setUp: () {
        when(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
            cartDiscountType: any(named: 'cartDiscountType'),
            cartDiscountValue: any(named: 'cartDiscountValue'),
            cartDiscountAmount: any(named: 'cartDiscountAmount'),
            amountReceived: any(named: 'amountReceived'),
            changeAmount: any(named: 'changeAmount'),
            note: any(named: 'note'),
            paymentReference: any(named: 'paymentReference'),
          ),
        ).thenThrow(Exception('db error'));
      },
      act: (b) => b.add(
        const CheckoutConfirmed(
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      ),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.processing,
        ),
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNull),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits failure when cart is empty',
      build: buildBloc,
      setUp: () {
        when(() => mockCartBloc.state).thenReturn(const CartState());
      },
      act: (b) => b.add(
        const CheckoutConfirmed(
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      ),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'emits waitingPayment for promptpay',
      build: buildBloc,
      act: (b) => b.add(
        const CheckoutConfirmed(
          paymentMethod: 'promptpay',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      ),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.waitingPayment,
        ),
      ],
    );
  });

  group('CheckoutPaymentConfirmed', () {
    blocTest<CheckoutBloc, CheckoutState>(
      'completes pending promptpay sale',
      build: buildBloc,
      setUp: () {
        when(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
            cartDiscountType: any(named: 'cartDiscountType'),
            cartDiscountValue: any(named: 'cartDiscountValue'),
            cartDiscountAmount: any(named: 'cartDiscountAmount'),
            amountReceived: any(named: 'amountReceived'),
            changeAmount: any(named: 'changeAmount'),
            note: any(named: 'note'),
            paymentReference: any(named: 'paymentReference'),
            sendingBankCode: any(named: 'sendingBankCode'),
          ),
        ).thenAnswer((_) async => tSale);
      },
      act: (b) {
        b.add(
          const CheckoutConfirmed(
            paymentMethod: 'promptpay',
            vatMode: 'NONE',
            vatRate: 0,
          ),
        );
        b.add(
          const CheckoutPaymentConfirmed(
            paymentReference: 'REF123',
            sendingBankCode: '014',
          ),
        );
      },
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.waitingPayment,
        ),
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.processing,
        ),
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.success)
            .having((s) => s.lastSale, 'lastSale', tSale),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'does nothing when no pending sale',
      build: buildBloc,
      act: (b) => b.add(const CheckoutPaymentConfirmed()),
      expect: () => [],
    );
  });

  group('CheckoutPaymentCancelled', () {
    blocTest<CheckoutBloc, CheckoutState>(
      'returns to idle',
      build: buildBloc,
      seed: () => const CheckoutState(status: CheckoutStatus.waitingPayment),
      act: (b) => b.add(const CheckoutPaymentCancelled()),
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.idle,
        ),
      ],
    );
  });

  group('CheckoutReset', () {
    blocTest<CheckoutBloc, CheckoutState>(
      'clears cart and resets state',
      build: buildBloc,
      seed: () =>
          CheckoutState(status: CheckoutStatus.success, lastSale: tSale),
      act: (b) => b.add(const CheckoutReset()),
      expect: () => [const CheckoutState()],
      verify: (_) {
        verify(() => mockCartBloc.add(const CartCleared())).called(1);
      },
    );
  });

  test('close completes', () async {
    final bloc = buildBloc();
    await expectLater(bloc.close(), completes);
  });
}
