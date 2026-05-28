import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late SaleRepositoryImpl repo;
  late MockSaleLocalDatasource mockDs;

  setUp(() {
    mockDs = MockSaleLocalDatasource();
    repo = SaleRepositoryImpl(mockDs);
  });

  setUpAll(() {
    registerFallbackValue(<CartItem>[]);
  });

  group('SaleRepositoryImpl', () {
    test('createSale delegates to datasource', () async {
      when(
        () => mockDs.insertSaleWithItems(
          items: any(named: 'items'),
          paymentMethod: any(named: 'paymentMethod'),
          vatMode: any(named: 'vatMode'),
          vatRate: any(named: 'vatRate'),
          amountReceived: any(named: 'amountReceived'),
          changeAmount: any(named: 'changeAmount'),
          note: any(named: 'note'),
        ),
      ).thenAnswer((_) async => tSale);

      final result = await repo.createSale(
        items: [tCartItem],
        paymentMethod: 'cash',
        vatMode: 'NONE',
        vatRate: 0,
        amountReceived: 500,
        changeAmount: 300,
      );

      expect(result, tSale);
      verify(
        () => mockDs.insertSaleWithItems(
          items: [tCartItem],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: 500,
          changeAmount: 300,
        ),
      ).called(1);
    });

    test('getSales delegates to datasource', () async {
      when(
        () => mockDs.querySales(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => [tSale]);

      final result = await repo.getSales();

      expect(result, [tSale]);
    });

    test('getSaleById delegates to datasource', () async {
      when(() => mockDs.querySaleById(any())).thenAnswer((_) async => tSale);

      final result = await repo.getSaleById('sale-0001-0001-0001-000000000001');

      expect(result, tSale);
    });

    test('watchRecentSales delegates to datasource', () {
      when(
        () => mockDs.watchRecentSales(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream.value([tSale]));

      final stream = repo.watchRecentSales();

      expect(stream, emits([tSale]));
    });

    test('watchSales delegates to datasource', () {
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
