import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/sale_repository.dart';

import '../../../../helpers/fake_app_lock.dart';

class MockDailyCloseRepository extends Mock implements DailyCloseRepository {}

class MockSaleRepository extends Mock implements SaleRepository {}

class FakeDailyClose extends Fake implements DailyClose {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDailyClose());
  });
  group('CloseDay', () {
    late MockDailyCloseRepository mockRepo;
    late MockSaleRepository mockSales;
    late AppLockService appLock;
    late CloseDay usecase;

    setUp(() {
      mockRepo = MockDailyCloseRepository();
      mockSales = MockSaleRepository();
      appLock = fakeAppLock();
      usecase = CloseDay(mockRepo, mockSales, appLock);
    });

    test('calculates expected cash and over/short correctly', () async {
      when(
        () => mockRepo.getByDate('2026-06-05'),
      ).thenAnswer((_) async => null);
      when(() => mockRepo.save(any())).thenAnswer((inv) async {
        return inv.positionalArguments.first as DailyClose;
      });

      final sales = [
        Sale(
          id: 's1',
          receiptNumber: '001',
          totalAmount: Money.fromDouble(100),
          paymentMethod: 'cash',
          status: 'COMPLETED',
          vatAmount: Money.fromDouble(7),
          discountAmount: Money.zero,
          createdAt: DateTime(2026, 6, 5, 10),
        ),
        Sale(
          id: 's2',
          receiptNumber: '002',
          totalAmount: Money.fromDouble(50),
          paymentMethod: 'promptpay',
          status: 'COMPLETED',
          vatAmount: Money.fromDouble(3.5),
          discountAmount: Money.zero,
          createdAt: DateTime(2026, 6, 5, 11),
        ),
      ];

      when(
        () => mockSales.getSales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => sales);

      final result = await usecase(
        date: '2026-06-05',
        openingCash: 200,
        countedCash: 310,
        deviceId: 'dev1',
      );

      expect(result.openingCash, Money.fromDouble(200));
      expect(
        result.expectedCash,
        Money.fromDouble(300),
      ); // 200 + 100 cash sales
      expect(result.overShortAmount, Money.fromDouble(10)); // 310 - 300
      expect(result.totalRevenue, Money.fromDouble(150));
      expect(result.salesCount, 2);
    });

    test('handles 0 sales day', () async {
      when(
        () => mockRepo.getByDate('2026-06-05'),
      ).thenAnswer((_) async => null);
      when(() => mockRepo.save(any())).thenAnswer((inv) async {
        return inv.positionalArguments.first as DailyClose;
      });
      when(
        () => mockSales.getSales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => []);

      final result = await usecase(
        date: '2026-06-05',
        openingCash: 0,
        countedCash: 0,
        deviceId: 'dev1',
      );

      expect(result.totalRevenue, Money.zero);
      expect(result.expectedCash, Money.zero);
      expect(result.overShortAmount, Money.zero);
    });

    test('throws when day is already closed', () async {
      final existing = DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        closedAt: DateTime(2026, 6, 5, 22),
      );
      when(
        () => mockRepo.getByDate('2026-06-05'),
      ).thenAnswer((_) async => existing);

      expect(
        () => usecase(
          date: '2026-06-05',
          openingCash: 0,
          countedCash: 0,
          deviceId: 'dev1',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('separates voided sales from revenue', () async {
      when(
        () => mockRepo.getByDate('2026-06-05'),
      ).thenAnswer((_) async => null);
      when(() => mockRepo.save(any())).thenAnswer((inv) async {
        return inv.positionalArguments.first as DailyClose;
      });

      final sales = [
        Sale(
          id: 's1',
          receiptNumber: '001',
          totalAmount: Money.fromDouble(200),
          paymentMethod: 'cash',
          status: 'COMPLETED',
          vatAmount: Money.fromDouble(14),
          discountAmount: Money.zero,
          createdAt: DateTime(2026, 6, 5, 10),
        ),
        Sale(
          id: 's2',
          receiptNumber: '002',
          totalAmount: Money.fromDouble(50),
          paymentMethod: 'cash',
          status: 'VOIDED',
          vatAmount: Money.zero,
          discountAmount: Money.zero,
          createdAt: DateTime(2026, 6, 5, 11),
        ),
      ];

      when(
        () => mockSales.getSales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => sales);

      final result = await usecase(
        date: '2026-06-05',
        openingCash: 100,
        countedCash: 400,
        deviceId: 'dev1',
      );

      expect(result.totalRevenue, Money.fromDouble(200));
      expect(result.totalVoid, Money.fromDouble(50));
      expect(result.salesCount, 1);
      expect(result.voidCount, 1);
      expect(result.expectedCash, Money.fromDouble(300)); // 100 + 200 cash
    });

    test(
      'expected cash uses cash tender lines only for multi-tender sales',
      () async {
        when(
          () => mockRepo.getByDate('2026-06-05'),
        ).thenAnswer((_) async => null);
        when(() => mockRepo.save(any())).thenAnswer((inv) async {
          return inv.positionalArguments.first as DailyClose;
        });

        final sales = [
          Sale(
            id: 'mixed-1',
            receiptNumber: '001',
            totalAmount: Money.fromDouble(200),
            paymentMethod: 'mixed',
            status: 'COMPLETED',
            payments: [
              SalePayment(method: 'cash', amount: Money.fromDouble(80)),
              SalePayment(method: 'promptpay', amount: Money.fromDouble(120)),
            ],
            vatAmount: Money.zero,
            discountAmount: Money.zero,
            createdAt: DateTime(2026, 6, 5, 10),
          ),
          Sale(
            id: 'cash-2',
            receiptNumber: '002',
            totalAmount: Money.fromDouble(50),
            paymentMethod: 'cash',
            status: 'COMPLETED',
            vatAmount: Money.zero,
            discountAmount: Money.zero,
            createdAt: DateTime(2026, 6, 5, 11),
          ),
        ];

        when(
          () => mockSales.getSales(
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => sales);

        final result = await usecase(
          date: '2026-06-05',
          openingCash: 100,
          countedCash: 230, // 100 + 80 + 50
          deviceId: 'dev1',
        );

        // cash lines only: 80 (mixed) + 50 (cash) — not full 200 mixed bill
        expect(result.expectedCash, Money.fromDouble(230));
        expect(result.overShortAmount, Money.zero);
        expect(result.totalRevenue, Money.fromDouble(250));
        expect(result.paymentBreakdown['cash'], 130);
        expect(result.paymentBreakdown['promptpay'], 120);
        expect(result.paymentBreakdown['mixed'], isNull);
      },
    );

    // V092-B.3 regression: domain gate refuses when PIN on + locked.
    test(
      'throws BusinessRuleError AppLockRequired when PIN enabled and locked',
      () async {
        final locked = fakeAppLock();
        await locked.setPin('147258');
        locked.lockSession();
        final gated = CloseDay(mockRepo, mockSales, locked);

        await expectLater(
          () => gated(
            date: '2026-06-05',
            openingCash: 0,
            countedCash: 0,
            deviceId: 'dev1',
          ),
          throwsA(
            isA<BusinessRuleError>().having(
              (e) => e.rule,
              'rule',
              AppLockService.ruleAppLockRequired,
            ),
          ),
        );
        verifyNever(() => mockRepo.save(any()));
      },
    );
  });
}
