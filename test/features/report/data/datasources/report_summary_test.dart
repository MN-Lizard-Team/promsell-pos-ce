import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late SaleQueryLocalDatasource query;

  setUp(() {
    db = createInMemoryDatabase();
    query = SaleQueryLocalDatasource(db);
  });

  tearDown(() => db.close());

  Future<void> seedSales() async {
    final base = DateTime(2025, 1, 1);
    await db.batch((b) {
      // Completed cash sale
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's1',
          receiptNumber: const Value('R1'),
          totalAmount: 100.0,
          subtotalAmount: const Value(100.0),
          paymentMethod: 'cash',
          createdAt: Value(base),
          updatedAt: Value(base),
          vatAmount: const Value(7.0),
          discountAmount: const Value(0.0),
          totalAmountSatang: Value(Money.fromDouble(100.0)),
          subtotalAmountSatang: Value(Money.fromDouble(100.0)),
          vatAmountSatang: Value(Money.fromDouble(7.0)),
        ),
      );
      // Completed promptpay sale with promotion
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's2',
          receiptNumber: const Value('R2'),
          totalAmount: 200.0,
          subtotalAmount: const Value(220.0),
          discountAmount: const Value(20.0),
          promotionId: const Value('promo1'),
          promotionDiscountAmount: const Value(20.0),
          paymentMethod: 'promptpay',
          orderType: const Value('dinein'),
          createdAt: Value(base.add(const Duration(hours: 1))),
          updatedAt: Value(base.add(const Duration(hours: 1))),
          totalAmountSatang: Value(Money.fromDouble(200.0)),
          subtotalAmountSatang: Value(Money.fromDouble(220.0)),
          discountAmountSatang: Value(Money.fromDouble(20.0)),
          promotionDiscountAmountSatang: Value(Money.fromDouble(20.0)),
        ),
      );
      // Voided sale
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's3',
          receiptNumber: const Value('R3'),
          status: const Value('VOIDED'),
          totalAmount: 50.0,
          paymentMethod: 'cash',
          voidReason: const Value('customer_cancel'),
          createdAt: Value(base.add(const Duration(hours: 2))),
          updatedAt: Value(base.add(const Duration(hours: 2))),
          totalAmountSatang: Value(Money.fromDouble(50.0)),
        ),
      );
      // Items for s1, s2
      b.insert(
        db.saleItems,
        SaleItemsCompanion.insert(
          id: 'si1',
          saleId: 's1',
          productId: 'p1',
          productName: 'Product 1',
          price: 100.0,
          qty: 1,
          subtotal: 100.0,
        ),
      );
      b.insert(
        db.saleItems,
        SaleItemsCompanion.insert(
          id: 'si2',
          saleId: 's2',
          productId: 'p2',
          productName: 'Product 2',
          price: 110.0,
          qty: 2,
          subtotal: 220.0,
        ),
      );
    });
  }

  group('queryReportSummary SQL aggregate', () {
    test('matches SalesPeriodTotals.from on the same data', () async {
      await seedSales();
      final summary = await query.queryReportSummary();

      // Hydrate sales the old way for comparison.
      final sales = await query.querySales();
      final totals = SalesPeriodTotals.from(sales);

      expect(summary.salesCount, totals.salesCount);
      expect(summary.voidCount, totals.voidCount);
      expect(summary.netRevenue, totals.netRevenue);
      expect(summary.voidedTotal, totals.voidedTotal);
      expect(summary.vatAmount, totals.vatAmount);
      expect(summary.discountAmount, totals.discountAmount);
      expect(summary.promotionCount, totals.promotionCount);
      expect(summary.paymentBreakdown, totals.paymentBreakdown);
      expect(summary.paymentCounts, totals.paymentCounts);
      expect(summary.orderTypeBreakdown, totals.orderTypeBreakdown);
      expect(summary.voidReasonBreakdown, totals.voidReasonBreakdown);
    });

    test('date range filters correctly', () async {
      await seedSales();
      final from = DateTime(2025, 1, 1, 0, 30);
      final to = DateTime(2025, 1, 1, 1, 30);
      final summary = await query.queryReportSummary(from: from, to: to);

      // Only s2 falls in this range.
      expect(summary.salesCount, 1);
      expect(summary.voidCount, 0);
      expect(summary.netRevenue, Money.fromDouble(200.0));
    });

    test('empty range returns empty summary', () async {
      await seedSales();
      final summary = await query.queryReportSummary(
        from: DateTime(2030, 1, 1),
        to: DateTime(2030, 1, 2),
      );
      expect(summary.salesCount, 0);
      expect(summary.netRevenue, Money.zero);
    });
  });
}
