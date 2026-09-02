import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_aggregate.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/data/repositories/sale_repository_impl.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

ReportSummary get tReportSummary => ReportSummary(
  netRevenue: Money.fromDouble(100),
  voidedTotal: Money.zero,
  salesCount: 1,
  voidCount: 0,
  vatAmount: Money.zero,
  discountAmount: Money.zero,
  serviceChargeAmount: Money.zero,
  promotionDiscountAmount: Money.zero,
  paymentBreakdown: const {},
  paymentCounts: const {},
  orderTypeBreakdown: const {},
  orderChannelBreakdown: const {},
  voidReasonBreakdown: const {},
  promotionCount: 0,
);

ReportAggregate get tReportAggregate =>
    ReportAggregate(summary: tReportSummary);

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
        amountReceived: Money.fromDouble(500),
        changeAmount: Money.fromDouble(300),
      );

      expect(result, tSale);
      verify(
        () => mockDs.insertSaleWithItems(
          items: [tCartItem],
          paymentMethod: 'cash',
          vatMode: 'NONE',
          vatRate: 0,
          amountReceived: Money.fromDouble(500),
          changeAmount: Money.fromDouble(300),
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

    test('getSalesCount delegates to datasource', () async {
      when(
        () => mockDs.querySalesCount(
          from: any(named: 'from'),
          to: any(named: 'to'),
          searchQuery: any(named: 'searchQuery'),
        ),
      ).thenAnswer((_) async => 7);

      final result = await repo.getSalesCount();

      expect(result, 7);
      verify(
        () => mockDs.querySalesCount(from: null, to: null, searchQuery: null),
      ).called(1);
    });

    test('getReportSummary delegates to datasource', () async {
      when(
        () => mockDs.queryReportSummary(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => tReportSummary);

      final result = await repo.getReportSummary();

      expect(result, tReportSummary);
    });

    test('watchReportAggregate delegates to datasource', () {
      when(
        () => mockDs.watchReportAggregate(
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) => Stream.value(tReportAggregate));

      final stream = repo.watchReportAggregate();

      expect(stream, emits(tReportAggregate));
    });

    test('voidSale delegates to datasource', () async {
      when(
        () => mockDs.voidSale(any(), reason: any(named: 'reason')),
      ).thenAnswer((_) async {});

      await repo.voidSale('sale-1', reason: 'test');

      verify(() => mockDs.voidSale('sale-1', reason: 'test')).called(1);
    });
  });
}
