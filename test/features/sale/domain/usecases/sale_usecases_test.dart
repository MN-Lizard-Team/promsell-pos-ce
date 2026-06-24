import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/get_sale_by_id.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/get_sales.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/watch_recent_sales.dart';
import 'package:promsell_pos_ce/features/sale/domain/usecases/watch_sales.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockSaleRepository mockRepo;

  setUp(() {
    mockRepo = MockSaleRepository();
  });

  group('GetSaleById', () {
    late GetSaleById useCase;

    setUp(() => useCase = GetSaleById(mockRepo));

    test('delegates to repository.getSaleById', () async {
      when(() => mockRepo.getSaleById(tSale.id)).thenAnswer((_) async => tSale);

      final result = await useCase(tSale.id);

      expect(result, tSale);
      verify(() => mockRepo.getSaleById(tSale.id)).called(1);
    });

    test('returns null when not found', () async {
      when(
        () => mockRepo.getSaleById('not-found'),
      ).thenAnswer((_) async => null);

      final result = await useCase('not-found');

      expect(result, isNull);
    });
  });

  group('GetSales', () {
    late GetSales useCase;

    setUp(() => useCase = GetSales(mockRepo));

    test('delegates to repository.getSales without date range', () async {
      when(
        () => mockRepo.getSales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => [tSale]);

      final result = await useCase();

      expect(result, [tSale]);
      verify(() => mockRepo.getSales(from: null, to: null)).called(1);
    });

    test('delegates with date range', () async {
      final from = DateTime(2025, 1, 1);
      final to = DateTime(2025, 1, 31);
      when(
        () => mockRepo.getSales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => [tSale]);

      final result = await useCase(from: from, to: to);

      expect(result, [tSale]);
      verify(() => mockRepo.getSales(from: from, to: to)).called(1);
    });
  });

  group('WatchSales', () {
    late WatchSales useCase;

    setUp(() => useCase = WatchSales(mockRepo));

    test('delegates to repository.watchSales', () {
      when(
        () => mockRepo.watchSales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value([tSale]));

      final stream = useCase();

      expect(stream, emits([tSale]));
      verify(() => mockRepo.watchSales(from: null, to: null)).called(1);
    });
  });

  group('WatchRecentSales', () {
    late WatchRecentSales useCase;

    setUp(() => useCase = WatchRecentSales(mockRepo));

    test('delegates with default limit', () {
      when(
        () => mockRepo.watchRecentSales(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream.value([tSale]));

      final stream = useCase();

      expect(stream, emits([tSale]));
      verify(() => mockRepo.watchRecentSales(limit: 20)).called(1);
    });

    test('delegates with custom limit', () {
      when(
        () => mockRepo.watchRecentSales(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream.value([tSale]));

      final stream = useCase(limit: 5);

      expect(stream, emits([tSale]));
      verify(() => mockRepo.watchRecentSales(limit: 5)).called(1);
    });
  });
}
