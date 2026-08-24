import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/history/data/repositories/history_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late HistoryRepositoryImpl repo;
  late MockSaleLocalDatasource mockDs;

  setUpAll(() {
    registerFallbackValue(
      SaleCursor(createdAt: DateTime(2000), id: 'fallback'),
    );
  });

  setUp(() {
    mockDs = MockSaleLocalDatasource();
    repo = HistoryRepositoryImpl(mockDs);
  });

  group('HistoryRepositoryImpl', () {
    test('getSales loads a single page when the cursor is exhausted', () async {
      when(
        () => mockDs.querySalesPage(
          from: any(named: 'from'),
          to: any(named: 'to'),
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer(
        (_) async => SalePage(sales: [tSale], nextCursor: null, totalCount: 1),
      );

      final result = await repo.getSales();

      expect(result, [tSale]);
      verify(
        () => mockDs.querySalesPage(
          from: null,
          to: null,
          cursor: null,
          pageSize: 500,
        ),
      ).called(1);
    });

    test('getSales follows cursors and concatenates pages', () async {
      final secondCursor = SaleCursor(createdAt: tSale.createdAt, id: tSale.id);
      var call = 0;
      when(
        () => mockDs.querySalesPage(
          from: any(named: 'from'),
          to: any(named: 'to'),
          cursor: any(named: 'cursor'),
          pageSize: any(named: 'pageSize'),
        ),
      ).thenAnswer((invocation) async {
        final cursor = invocation.namedArguments[#cursor] as SaleCursor?;
        if (cursor == null) {
          call++;
          return SalePage(
            sales: [tSale],
            nextCursor: secondCursor,
            totalCount: 2,
          );
        }
        return SalePage(sales: [tSale], nextCursor: null, totalCount: 2);
      });

      final result = await repo.getSales();

      expect(result.length, 2);
      expect(call, 1);
      verify(
        () => mockDs.querySalesPage(
          from: null,
          to: null,
          cursor: secondCursor,
          pageSize: 500,
        ),
      ).called(1);
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
