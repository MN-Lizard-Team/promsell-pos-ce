import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/daily_close/data/datasources/daily_close_local_datasource.dart';
import 'package:promsell_pos_ce/features/daily_close/data/repositories/daily_close_repository_impl.dart';
import 'package:promsell_pos_ce/features/daily_close/domain/entities/daily_close.dart';

class MockDailyCloseLocalDatasource extends Mock
    implements DailyCloseLocalDatasource {}

class FakeDailyCloseData extends Fake implements DailyCloseData {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDailyCloseData());
  });
  group('DailyCloseRepositoryImpl', () {
    late MockDailyCloseLocalDatasource mockDatasource;
    late DailyCloseRepositoryImpl repo;

    setUp(() {
      mockDatasource = MockDailyCloseLocalDatasource();
      repo = DailyCloseRepositoryImpl(mockDatasource);
    });

    test('getByDate returns null when not found', () async {
      when(
        () => mockDatasource.getByDate('2026-06-05'),
      ).thenAnswer((_) async => null);
      final result = await repo.getByDate('2026-06-05');
      expect(result, isNull);
    });

    test('getByDate returns DailyClose when found', () async {
      final data = DailyCloseData(
        id: '1',
        closeDate: '2026-06-05',
        openingCash: 0,
        expectedCash: 0,
        countedCash: 0,
        overShortAmount: 0,
        totalRevenue: 0,
        totalVoid: 0,
        salesCount: 0,
        voidCount: 0,
        paymentBreakdown: '{}',
        vatAmount: 0,
        discountAmount: 0,
        closedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        version: 1,
      );
      when(
        () => mockDatasource.getByDate('2026-06-05'),
      ).thenAnswer((_) async => data);
      final result = await repo.getByDate('2026-06-05');
      expect(result, isNotNull);
      expect(result!.id, '1');
      expect(result.closeDate, '2026-06-05');
    });

    test('save persists and returns entity', () async {
      final entity = const DailyClose(
        id: '1',
        closeDate: '2026-06-05',
        totalRevenue: 100,
        paymentBreakdown: {'cash': 100},
      );
      final savedData = DailyCloseData(
        id: '1',
        closeDate: '2026-06-05',
        openingCash: 0,
        expectedCash: 0,
        countedCash: 0,
        overShortAmount: 0,
        totalRevenue: 100,
        totalVoid: 0,
        salesCount: 1,
        voidCount: 0,
        paymentBreakdown: '{"cash":100.0}',
        vatAmount: 0,
        discountAmount: 0,
        updatedAt: DateTime.now(),
        version: 1,
      );
      when(() => mockDatasource.save(any())).thenAnswer((_) async => savedData);

      final result = await repo.save(entity);

      expect(result.id, '1');
      expect(result.totalRevenue, 100);
      verify(() => mockDatasource.save(any())).called(1);
    });

    test('delete calls datasource', () async {
      when(() => mockDatasource.delete('1')).thenAnswer((_) async {});
      await repo.delete('1');
      verify(() => mockDatasource.delete('1')).called(1);
    });
  });
}
