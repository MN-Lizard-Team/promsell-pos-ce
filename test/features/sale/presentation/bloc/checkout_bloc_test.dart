import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';

import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(Money.zero);
    registerFallbackValue(<CartItem>[]);
    registerFallbackValue(<SalePayment>[]);
  });

  late MockCreateSale mockCreateSale;
  late MockCartBloc mockCartBloc;
  late MockDraftBloc mockDraftBloc;

  final tNow = DateTime(2025, 1, 15, 10, 30);

  final tSale = Sale(
    id: 'sale-0001',
    totalAmount: Money.fromDouble(200),
    subtotalAmount: Money.fromDouble(200),
    discountType: null,
    discountValue: null,
    discountAmount: Money.zero,
    vatMode: 'NONE',
    vatRate: 0.0,
    vatAmount: Money.zero,
    paymentMethod: 'cash',
    amountReceived: Money.fromDouble(500),
    changeAmount: Money.fromDouble(300),
    note: null,
    createdAt: tNow,
    items: const [],
  );

  setUp(() {
    registerFallbackValue(const CartCleared());
    registerFallbackValue(const CartPaymentLockChanged(true));
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
              price: Money.fromDouble(100),
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
        CheckoutConfirmed(
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(500),
          changeAmount: Money.fromDouble(300),
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
        verify(() => mockCartBloc.add(const CartCleared())).called(1);
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
            .having((s) => s.errorMessage, 'errorMessage', 'saleError'),
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
    blocTest<CheckoutBloc, CheckoutState>(
      'emits waitingPayment for mixed cash+promptpay with PP amount',
      build: buildBloc,
      act: (b) => b.add(
        CheckoutConfirmed(
          paymentMethod: 'mixed',
          vatMode: 'NONE',
          vatRate: 0,
          payments: [
            SalePayment(method: 'cash', amount: Money.fromDouble(80)),
            SalePayment(method: 'promptpay', amount: Money.fromDouble(120)),
          ],
          amountReceived: Money.fromDouble(80),
          changeAmount: Money.zero,
        ),
      ),
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.waitingPayment)
            .having((s) => s.promptPayAmount, 'promptPayAmount', 120),
      ],
      verify: (_) {
        verifyNever(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: any(named: 'paymentMethod'),
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
          ),
        );
      },
    );
    blocTest<CheckoutBloc, CheckoutState>(
      'ignores second CheckoutConfirmed while waitingPayment',
      build: buildBloc,
      act: (b) async {
        b.add(
          const CheckoutConfirmed(
            paymentMethod: 'promptpay',
            vatMode: 'NONE',
            vatRate: 0,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        b.add(
          const CheckoutConfirmed(
            paymentMethod: 'cash',
            vatMode: 'NONE',
            vatRate: 0,
          ),
        );
      },
      expect: () => [
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.waitingPayment,
        ),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'passes paymentReference to CreateSale',
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
          paymentMethod: 'transfer',
          vatMode: 'NONE',
          vatRate: 0,
          note: 'customer note',
          paymentReference: 'TXN-99',
        ),
      ),
      verify: (_) {
        verify(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: 'transfer',
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
            cartDiscountType: any(named: 'cartDiscountType'),
            cartDiscountValue: any(named: 'cartDiscountValue'),
            cartDiscountAmount: any(named: 'cartDiscountAmount'),
            amountReceived: any(named: 'amountReceived'),
            changeAmount: any(named: 'changeAmount'),
            note: 'customer note',
            paymentReference: 'TXN-99',
          ),
        ).called(1);
      },
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
      'mixed cash+promptpay stamps ref on PP tender only',
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
            payments: any(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).thenAnswer((_) async => tSale);
      },
      act: (b) {
        b.add(
          CheckoutConfirmed(
            paymentMethod: 'mixed',
            vatMode: 'NONE',
            vatRate: 0,
            payments: [
              SalePayment(method: 'cash', amount: Money.fromDouble(80)),
              SalePayment(method: 'promptpay', amount: Money.fromDouble(120)),
            ],
            amountReceived: Money.fromDouble(80),
            changeAmount: Money.zero,
          ),
        );
        b.add(
          const CheckoutPaymentConfirmed(
            paymentReference: 'PP-MIX-1',
            sendingBankCode: '014',
          ),
        );
      },
      expect: () => [
        isA<CheckoutState>()
            .having((s) => s.status, 'status', CheckoutStatus.waitingPayment)
            .having((s) => s.promptPayAmount, 'promptPayAmount', 120),
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
        final captured = verify(
          () => mockCreateSale(
            items: any(named: 'items'),
            paymentMethod: 'mixed',
            vatMode: any(named: 'vatMode'),
            vatRate: any(named: 'vatRate'),
            cartDiscountType: any(named: 'cartDiscountType'),
            cartDiscountValue: any(named: 'cartDiscountValue'),
            cartDiscountAmount: any(named: 'cartDiscountAmount'),
            amountReceived: any(named: 'amountReceived'),
            changeAmount: any(named: 'changeAmount'),
            note: any(named: 'note'),
            paymentReference: 'PP-MIX-1',
            sendingBankCode: '014',
            payments: captureAny(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).captured;
        expect(captured, hasLength(1));
        final payments = captured.single as List<SalePayment>;
        expect(payments, hasLength(2));
        expect(payments[0].method, 'cash');
        expect(payments[0].reference, isNull);
        expect(payments[1].method, 'promptpay');
        expect(payments[1].reference, 'PP-MIX-1');
        expect(payments[1].sendingBankCode, '014');
        expect(payments[1].amount, Money.fromDouble(120));
      },
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'uses frozen cart items after waitingPayment even if live cart changes',
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
            payments: any(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).thenAnswer((_) async => tSale);
      },
      act: (b) async {
        b.add(
          const CheckoutConfirmed(
            paymentMethod: 'promptpay',
            vatMode: 'NONE',
            vatRate: 0,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        // Live cart mutates after freeze — complete must still use snapshot.
        when(() => mockCartBloc.state).thenReturn(const CartState());
        b.add(const CheckoutPaymentConfirmed(paymentReference: 'FROZEN-1'));
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
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.success,
        ),
      ],
      verify: (_) {
        final captured = verify(
          () => mockCreateSale(
            items: captureAny(named: 'items'),
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
            payments: any(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).captured;
        final items = captured.single as List<CartItem>;
        expect(items, hasLength(1));
        expect(items.first.qty, 2);
        expect(items.first.product.id, 'p1');
      },
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'maps DayClosed to dayClosed key',
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
            payments: any(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).thenThrow(const BusinessRuleError('DayClosed'));
      },
      act: (b) => b.add(
        CheckoutConfirmed(
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(200),
          changeAmount: Money.zero,
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
            .having((s) => s.errorMessage, 'errorMessage', 'dayClosed'),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'maps PaymentMismatch to paymentMismatch key',
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
            payments: any(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).thenThrow(const BusinessRuleError('PaymentMismatch'));
      },
      act: (b) => b.add(
        CheckoutConfirmed(
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(200),
          changeAmount: Money.zero,
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
            .having((s) => s.errorMessage, 'errorMessage', 'paymentMismatch'),
      ],
    );

    blocTest<CheckoutBloc, CheckoutState>(
      'ignores CheckoutPaymentConfirmed while processing',
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
            payments: any(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return tSale;
        });
      },
      act: (b) async {
        b.add(
          const CheckoutConfirmed(
            paymentMethod: 'promptpay',
            vatMode: 'NONE',
            vatRate: 0,
          ),
        );
        await Future<void>.delayed(Duration.zero);
        b.add(const CheckoutPaymentConfirmed(paymentReference: 'A'));
        // Second confirm while first complete still processing — must no-op.
        b.add(const CheckoutPaymentConfirmed(paymentReference: 'B'));
      },
      wait: const Duration(milliseconds: 80),
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
        isA<CheckoutState>().having(
          (s) => s.status,
          'status',
          CheckoutStatus.success,
        ),
      ],
      verify: (_) {
        verify(
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
            paymentReference: 'A',
            sendingBankCode: any(named: 'sendingBankCode'),
            payments: any(named: 'payments'),
            customerId: any(named: 'customerId'),
            promotionId: any(named: 'promotionId'),
            promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
          ),
        ).called(1);
      },
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
