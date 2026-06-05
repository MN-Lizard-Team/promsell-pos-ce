import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/repositories/daily_close_repository.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/usecases/close_day.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

class MockDailyCloseRepository extends Mock implements DailyCloseRepository {}

class MockSaleLocalDatasource extends Mock implements SaleLocalDatasource {}

class FakeDailyClose extends Fake implements DailyClose {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDailyClose());
  });
  group('CloseDay', () {
    late MockDailyCloseRepository mockRepo;
    late MockSaleLocalDatasource mockSales;
    late CloseDay usecase;

    setUp(() {
      mockRepo = MockDailyCloseRepository();
      mockSales = MockSaleLocalDatasource();
      usecase = CloseDay(mockRepo, mockSales);
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
          totalAmount: 100,
          paymentMethod: 'cash',
          status: 'COMPLETED',
          vatAmount: 7,
          discountAmount: 0,
          createdAt: DateTime(2026, 6, 5, 10),
        ),
        Sale(
          id: 's2',
          receiptNumber: '002',
          totalAmount: 50,
          paymentMethod: 'promptpay',
          status: 'COMPLETED',
          vatAmount: 3.5,
          discountAmount: 0,
          createdAt: DateTime(2026, 6, 5, 11),
        ),
      ];

      when(
        () => mockSales.querySales(
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

      expect(result.openingCash, 200);
      expect(result.expectedCash, 300); // 200 + 100 cash sales
      expect(result.overShortAmount, 10); // 310 - 300
      expect(result.totalRevenue, 150);
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
        () => mockSales.querySales(
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

      expect(result.totalRevenue, 0);
      expect(result.expectedCash, 0);
      expect(result.overShortAmount, 0);
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
          totalAmount: 200,
          paymentMethod: 'cash',
          status: 'COMPLETED',
          vatAmount: 14,
          discountAmount: 0,
          createdAt: DateTime(2026, 6, 5, 10),
        ),
        Sale(
          id: 's2',
          receiptNumber: '002',
          totalAmount: 50,
          paymentMethod: 'cash',
          status: 'VOIDED',
          vatAmount: 0,
          discountAmount: 0,
          createdAt: DateTime(2026, 6, 5, 11),
        ),
      ];

      when(
        () => mockSales.querySales(
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

      expect(result.totalRevenue, 200);
      expect(result.totalVoid, 50);
      expect(result.salesCount, 1);
      expect(result.voidCount, 1);
      expect(result.expectedCash, 300); // 100 + 200 cash
    });
  });
}
