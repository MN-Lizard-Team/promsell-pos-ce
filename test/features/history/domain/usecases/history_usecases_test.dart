import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/get_sale_history.dart';
import 'package:promsell_pos_ce/features/history/domain/usecases/watch_sale_history.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockHistoryRepository mockRepo;

  setUp(() {
    mockRepo = MockHistoryRepository();
  });

  group('GetSaleHistory', () {
    late GetSaleHistory useCase;
    setUp(() => useCase = GetSaleHistory(mockRepo));

    test('delegates to repository.getSales', () async {
      when(() => mockRepo.getSales(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => [tSale]);

      final result = await useCase();

      expect(result, [tSale]);
      verify(() => mockRepo.getSales()).called(1);
    });

    test('passes date range parameters', () async {
      final from = DateTime(2025, 1, 1);
      final to = DateTime(2025, 1, 31);
      when(() => mockRepo.getSales(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => []);

      await useCase(from: from, to: to);

      verify(() => mockRepo.getSales(from: from, to: to)).called(1);
    });
  });

  group('WatchSaleHistory', () {
    late WatchSaleHistory useCase;
    setUp(() => useCase = WatchSaleHistory(mockRepo));

    test('delegates to repository.watchSales', () {
      when(() => mockRepo.watchSales(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) => Stream.value([tSale]));

      final stream = useCase();

      expect(stream, emits([tSale]));
      verify(() => mockRepo.watchSales()).called(1);
    });
  });
}
