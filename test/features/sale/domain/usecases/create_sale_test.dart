import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sales_day_lock.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/create_sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late CreateSale useCase;
  late MockSaleRepository mockRepo;
  late MockSettingsRepository mockSettings;

  setUp(() {
    mockRepo = MockSaleRepository();
    mockSettings = MockSettingsRepository();
    useCase = CreateSale(mockRepo, mockSettings);
    when(() => mockSettings.load()).thenAnswer((_) async => const Settings());
  });

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
    registerFallbackValue(<SalePayment>[]);
    registerFallbackValue('');
    registerFallbackValue(Money.zero);
  });

  test('delegates to repository.createSale when day open', () async {
    when(
      () => mockRepo.createSale(
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
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
      ),
    ).thenAnswer((_) async => tSale);

    final result = await useCase(
      items: [tCartItem],
      paymentMethod: 'cash',
      vatMode: 'NONE',
      vatRate: 0,
      amountReceived: Money.fromDouble(500.0),
      changeAmount: Money.fromDouble(300.0),
    );

    expect(result, tSale);
    verify(
      () => mockRepo.createSale(
        items: [tCartItem],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        cartDiscountType: null,
        cartDiscountValue: null,
        cartDiscountAmount: Money.zero,
        amountReceived: Money.fromDouble(500.0),
        changeAmount: Money.fromDouble(300.0),
        note: null,
        paymentReference: null,
        sendingBankCode: null,
        payments: null,
        orderType: 'delivery',
        orderChannel: 'walkin',
        externalOrderRef: null,
        tableId: null,
        serviceChargeRate: 0.0,
        serviceChargeAmount: Money.zero,
        customerId: null,
        promotionId: null,
        promotionDiscountAmount: Money.zero,
      ),
    ).called(1);
  });

  test('throws DayClosed when lock on and today closed', () async {
    final today = SalesDayLock.todayIso();
    when(() => mockSettings.load()).thenAnswer(
      (_) async => const Settings().copyWith(
        dailyCloseLock: true,
        lastClosedDate: today,
      ),
    );

    await expectLater(
      () => useCase(
        items: [tCartItem],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
      ),
      throwsA(
        isA<BusinessRuleError>().having(
          (e) => e.rule,
          'rule',
          SalesDayLock.ruleDayClosed,
        ),
      ),
    );
    verifyNever(
      () => mockRepo.createSale(
        items: any(named: 'items'),
        paymentMethod: any(named: 'paymentMethod'),
        vatMode: any(named: 'vatMode'),
        vatRate: any(named: 'vatRate'),
      ),
    );
  });

  test('forwards multi-tender payments to repository', () async {
    final tenders = [
      SalePayment(method: 'cash', amount: Money.fromDouble(80)),
      SalePayment(
        method: 'promptpay',
        amount: Money.fromDouble(120),
        reference: 'PP-1',
      ),
    ];
    when(
      () => mockRepo.createSale(
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
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
      ),
    ).thenAnswer((_) async => tSale);

    await useCase(
      items: [tCartItem],
      paymentMethod: 'mixed',
      vatMode: 'NONE',
      vatRate: 0,
      payments: tenders,
      amountReceived: Money.fromDouble(80),
      changeAmount: Money.zero,
      paymentReference: 'PP-1',
    );

    final captured = verify(
      () => mockRepo.createSale(
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
        paymentReference: 'PP-1',
        sendingBankCode: any(named: 'sendingBankCode'),
        payments: captureAny(named: 'payments'),
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
      ),
    ).captured;
    expect(captured.single, tenders);
  });

  test('clamps VAT rate and percent cart discount to settings max', () async {
    when(() => mockSettings.load()).thenAnswer(
      (_) async => const Settings().copyWith(maxDiscountPercent: 20),
    );
    when(
      () => mockRepo.createSale(
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
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
      ),
    ).thenAnswer((_) async => tSale);

    await useCase(
      items: [tCartItem],
      paymentMethod: 'cash',
      vatMode: 'EXCLUSIVE',
      vatRate: 150, // clamp → 100
      cartDiscountType: 'PERCENT',
      cartDiscountValue: 50, // clamp → 20
      serviceChargeRate: 200, // clamp → 100
    );

    // tCartItem: 2×100 = 200; 20% cart disc = 40; SC 100% of net 160 = 160
    verify(
      () => mockRepo.createSale(
        items: any(named: 'items'),
        paymentMethod: 'cash',
        vatMode: 'EXCLUSIVE',
        vatRate: 100.0,
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 20.0,
        cartDiscountAmount: Money.fromDouble(40),
        amountReceived: any(named: 'amountReceived'),
        changeAmount: any(named: 'changeAmount'),
        note: any(named: 'note'),
        paymentReference: any(named: 'paymentReference'),
        sendingBankCode: any(named: 'sendingBankCode'),
        payments: any(named: 'payments'),
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: 100.0,
        serviceChargeAmount: Money.fromDouble(160),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: Money.zero,
      ),
    ).called(1);
  });

  test(
    'Wave D recomputes cartDiscountAmount ignoring stale client amount',
    () async {
      when(
        () => mockRepo.createSale(
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
          orderType: any(named: 'orderType'),
          orderChannel: any(named: 'orderChannel'),
          externalOrderRef: any(named: 'externalOrderRef'),
          tableId: any(named: 'tableId'),
          serviceChargeRate: any(named: 'serviceChargeRate'),
          serviceChargeAmount: any(named: 'serviceChargeAmount'),
          customerId: any(named: 'customerId'),
          promotionId: any(named: 'promotionId'),
          promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
        ),
      ).thenAnswer((_) async => tSale);

      // Client lies: amount 1 but type 10% of 200 should be 20.
      await useCase(
        items: [tCartItem],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        cartDiscountType: 'PERCENT',
        cartDiscountValue: 10,
        cartDiscountAmount: Money.fromDouble(1),
        serviceChargeRate: 10,
        serviceChargeAmount: Money.fromDouble(999), // ignored
        promotionDiscountAmount: Money.fromDouble(5),
      );

      // cart 20; promo 5; net 175; SC 10% = 17.5
      verify(
        () => mockRepo.createSale(
          items: any(named: 'items'),
          paymentMethod: any(named: 'paymentMethod'),
          vatMode: any(named: 'vatMode'),
          vatRate: any(named: 'vatRate'),
          cartDiscountType: 'PERCENT',
          cartDiscountValue: 10.0,
          cartDiscountAmount: Money.fromDouble(20),
          amountReceived: any(named: 'amountReceived'),
          changeAmount: any(named: 'changeAmount'),
          note: any(named: 'note'),
          paymentReference: any(named: 'paymentReference'),
          sendingBankCode: any(named: 'sendingBankCode'),
          payments: any(named: 'payments'),
          orderType: any(named: 'orderType'),
          orderChannel: any(named: 'orderChannel'),
          externalOrderRef: any(named: 'externalOrderRef'),
          tableId: any(named: 'tableId'),
          serviceChargeRate: 10.0,
          serviceChargeAmount: Money.fromDouble(17.5),
          customerId: any(named: 'customerId'),
          promotionId: any(named: 'promotionId'),
          promotionDiscountAmount: Money.fromDouble(5),
        ),
      ).called(1);
    },
  );

  test('Wave D clamps inflated promotion to post-cart base', () async {
    when(
      () => mockRepo.createSale(
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
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
      ),
    ).thenAnswer((_) async => tSale);

    await useCase(
      items: [tCartItem], // 200
      paymentMethod: 'cash',
      vatMode: 'NONE',
      vatRate: 0,
      cartDiscountType: 'PERCENT',
      cartDiscountValue: 50, // 100
      promotionDiscountAmount: Money.fromDouble(500), // cap → 100
    );

    final promo = verify(
      () => mockRepo.createSale(
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
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: captureAny(named: 'promotionDiscountAmount'),
      ),
    ).captured.single;
    expect(promo, Money.fromDouble(100));
  });

  test('clamps amount cart discount to maxDiscountAmount when > 0', () async {
    when(() => mockSettings.load()).thenAnswer(
      (_) async =>
          const Settings().copyWith(maxDiscountAmount: Money.fromDouble(30)),
    );
    when(
      () => mockRepo.createSale(
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
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
      ),
    ).thenAnswer((_) async => tSale);

    await useCase(
      items: [tCartItem],
      paymentMethod: 'cash',
      vatMode: 'NONE',
      vatRate: 0,
      cartDiscountType: 'AMOUNT',
      cartDiscountValue: 99,
    );

    final captured = verify(
      () => mockRepo.createSale(
        items: any(named: 'items'),
        paymentMethod: any(named: 'paymentMethod'),
        vatMode: any(named: 'vatMode'),
        vatRate: any(named: 'vatRate'),
        cartDiscountType: captureAny(named: 'cartDiscountType'),
        cartDiscountValue: captureAny(named: 'cartDiscountValue'),
        cartDiscountAmount: captureAny(named: 'cartDiscountAmount'),
        amountReceived: any(named: 'amountReceived'),
        changeAmount: any(named: 'changeAmount'),
        note: any(named: 'note'),
        paymentReference: any(named: 'paymentReference'),
        sendingBankCode: any(named: 'sendingBankCode'),
        payments: any(named: 'payments'),
        orderType: any(named: 'orderType'),
        orderChannel: any(named: 'orderChannel'),
        externalOrderRef: any(named: 'externalOrderRef'),
        tableId: any(named: 'tableId'),
        serviceChargeRate: any(named: 'serviceChargeRate'),
        serviceChargeAmount: any(named: 'serviceChargeAmount'),
        customerId: any(named: 'customerId'),
        promotionId: any(named: 'promotionId'),
        promotionDiscountAmount: any(named: 'promotionDiscountAmount'),
      ),
    ).captured;
    // Type string is preserved; amount branch is case-insensitive in CreateSale.
    expect((captured[0] as String).toUpperCase(), 'AMOUNT'.toUpperCase());
    expect(captured[1], 30.0);
    // Wave D: amount recomputed from clamped value (not client-supplied).
    expect(captured[2], Money.fromDouble(30));
  });
}
