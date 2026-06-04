import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/history/data/repositories/history_repository_impl.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late HistoryRepositoryImpl repo;
  late MockSaleLocalDatasource mockDs;

  setUp(() {
    mockDs = MockSaleLocalDatasource();
    repo = HistoryRepositoryImpl(mockDs);
  });

  group('HistoryRepositoryImpl', () {
    test('getSales delegates to datasource.querySales', () async {
      when(
        () => mockDs.querySales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => [tSale]);

      final result = await repo.getSales();

      expect(result, [tSale]);
      verify(() => mockDs.querySales()).called(1);
    });

    test('watchSales delegates to datasource.watchSales', () {
      when(
        () => mockDs.watchSales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value([tSale]));

      final stream = repo.watchSales();

      expect(stream, emits([tSale]));
    });
  });
}
