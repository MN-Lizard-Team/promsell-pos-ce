import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/get_report.dart';
import 'package:promsell_pos_ce/features/report/domain/usecases/watch_report.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockSaleRepository mockRepo;

  setUp(() {
    mockRepo = MockSaleRepository();
  });

  group('GetReport', () {
    late GetReport useCase;
    setUp(() => useCase = GetReport(mockRepo));

    test('delegates to repository.getSales', () async {
      when(() => mockRepo.getSales(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) async => [tSale]);

      final result = await useCase();

      expect(result, [tSale]);
      verify(() => mockRepo.getSales()).called(1);
    });
  });

  group('WatchReport', () {
    late WatchReport useCase;
    setUp(() => useCase = WatchReport(mockRepo));

    test('delegates to repository.watchSales', () {
      when(() => mockRepo.watchSales(from: any(named: 'from'), to: any(named: 'to')))
          .thenAnswer((_) => Stream.value([tSale]));

      final stream = useCase();

      expect(stream, emits([tSale]));
      verify(() => mockRepo.watchSales()).called(1);
    });
  });
}
