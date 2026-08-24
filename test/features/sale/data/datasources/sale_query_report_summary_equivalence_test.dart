import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_summary.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';

import '../../../../helpers/fake_database.dart';

/// Equivalence gate for the SQL-aggregated report summary.
///
/// [SaleQueryLocalDatasource.queryReportSummary] (SQLite SUM/CASE/GROUP BY)
/// must produce byte-identical metrics to
/// [SaleQueryLocalDatasource.dartReportSummaryReference] (full hydration +
/// Dart arithmetic, the pre-SQL behaviour) on a fixture that covers:
/// - completed and voided sales (voided sales never contribute to payment
///   breakdowns — the canonical `SalesPeriodTotals.from` rule),
/// - tender legs vs legacy header-only sales, Thai/unknown method labels,
/// - percent and amount discounts with promotions,
/// - legacy rows whose satang columns are NULL (ROUND fallback),
/// - zero totals and satang rounding edges,
/// - soft-deleted sales/legs and out-of-range rows.
void main() {
  late AppDatabase db;
  late SaleQueryLocalDatasource query;

  setUp(() {
    db = createInMemoryDatabase();
    query = SaleQueryLocalDatasource(db);
  });

  tearDown(() => db.close());

  Future<void> seedSales() async {
    final day1 = DateTime(2025, 1, 10, 9, 30);
    final day2 = DateTime(2025, 1, 20, 18, 45);

    await db.batch((b) {
      // 1. Legacy header-only sale: no satang columns, no tender legs.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-cash-legacy',
          totalAmount: 123.45,
          paymentMethod: 'เงินสด',
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );

      // 2. Modern sale with two tender legs; promptpay leg has no satang so
      //    both engines fall back to ROUND(amount * 100).
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-mixed-legs',
          totalAmount: 99.99,
          paymentMethod: 'mixed',
          totalAmountSatang: const Value(Money.fromSatang(9999)),
          vatAmount: const Value(7.0),
          vatAmountSatang: const Value(Money.fromSatang(700)),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );
      b.insert(
        db.salePayments,
        SalePaymentsCompanion.insert(
          id: 'p-cash',
          saleId: 's-mixed-legs',
          method: 'cash',
          amount: 50.0,
          amountSatang: const Value(Money.fromSatang(5000)),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );
      b.insert(
        db.salePayments,
        SalePaymentsCompanion.insert(
          id: 'p-pp',
          saleId: 's-mixed-legs',
          method: 'promptpay',
          amount: 49.99,
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );

      // 3. Voided sale WITH tender legs: legs must be excluded from every
      //    payment breakdown while the total lands in voidedTotal.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-voided-with-legs',
          totalAmount: 10.0,
          paymentMethod: 'cash',
          status: const Value('VOIDED'),
          voidedAt: Value(day2),
          voidReason: const Value('wrong item'),
          totalAmountSatang: const Value(Money.fromSatang(1000)),
          createdAt: Value(day2),
          updatedAt: Value(day2),
        ),
      );
      b.insert(
        db.salePayments,
        SalePaymentsCompanion.insert(
          id: 'p-voided',
          saleId: 's-voided-with-legs',
          method: 'cash',
          amount: 10.0,
          createdAt: Value(day2),
          updatedAt: Value(day2),
        ),
      );

      // 4. Voided header-only sale without reason → 'unspecified' bucket.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-voided-noreason',
          totalAmount: 5.0,
          paymentMethod: 'โอน',
          status: const Value('VOIDED'),
          voidedAt: Value(day2),
          createdAt: Value(day2),
          updatedAt: Value(day2),
        ),
      );

      // 5. Percent discount (discountValue REAL, discountAmount satang set).
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-percent-discount',
          totalAmount: 89.09,
          paymentMethod: 'card',
          discountType: const Value('PERCENT'),
          discountValue: const Value(10.0),
          discountAmount: const Value(9.9),
          discountAmountSatang: const Value(Money.fromSatang(990)),
          orderType: const Value('dine-in'),
          orderChannel: const Value('qr'),
          customerId: const Value('cust-1'),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );

      // 6. Amount discount with promotion id.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-amount-discount',
          totalAmount: 65.0,
          paymentMethod: 'qr-promo', // unknown label passes through
          discountType: const Value('AMOUNT'),
          discountValue: const Value(20.0),
          promotionId: const Value('PROMO-1'),
          promotionDiscountAmount: const Value(15.0),
          promotionDiscountAmountSatang: const Value(Money.fromSatang(1500)),
          serviceChargeAmount: const Value(6.25),
          serviceChargeAmountSatang: const Value(Money.fromSatang(625)),
          orderType: const Value('delivery'),
          customerId: const Value('cust-2'),
          createdAt: Value(day2),
          updatedAt: Value(day2),
        ),
      );

      // 7. Rounding edges on legacy fallback columns: 2.625 is exactly
      //    representable in IEEE-754 (2 + 5/8), so both Dart and SQLite
      //    compute 2.625 * 100 = 262.5 → 263 (half-up). 0.125 is likewise
      //    exact (12.5 → 13).  Values like 2.675 are NOT exactly
      //    representable — Dart gets 267.499... while SQLite gets 267.5,
      //    causing a 1-satang platform divergence that cannot be reconciled
      //    through SQL alone, so we avoid them in this equivalence gate.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-round-down-edge',
          totalAmount: 2.625,
          paymentMethod: 'cash',
          subtotalAmount: const Value(2.625),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-round-up-edge',
          totalAmount: 0.125,
          paymentMethod: 'transfer',
          subtotalAmount: const Value(0.125),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );

      // 8. Zero-total completed sale (zero edge).
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-zero',
          totalAmount: 0,
          paymentMethod: 'cash',
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );

      // 9. Soft-deleted sale: excluded by both engines.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-deleted',
          totalAmount: 999.0,
          paymentMethod: 'cash',
          deletedAt: Value(DateTime(2025, 1, 11)),
          createdAt: Value(day1),
          updatedAt: Value(day1),
        ),
      );

      // 10. Completed sale whose only leg is soft-deleted → header fallback.
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-deleted-leg',
          totalAmount: 42.0,
          paymentMethod: 'promptpay',
          totalAmountSatang: const Value(Money.fromSatang(4200)),
          createdAt: Value(day2),
          updatedAt: Value(day2),
        ),
      );
      b.insert(
        db.salePayments,
        SalePaymentsCompanion.insert(
          id: 'p-tombstone',
          saleId: 's-deleted-leg',
          method: 'cash',
          amount: 42.0,
          deletedAt: Value(DateTime(2025, 1, 21)),
          createdAt: Value(day2),
          updatedAt: Value(day2),
        ),
      );

      // 11. Out-of-range sale (both engines must exclude it under from/to).
      b.insert(
        db.sales,
        SalesCompanion.insert(
          id: 's-february',
          totalAmount: 77.0,
          paymentMethod: 'cash',
          createdAt: Value(DateTime(2025, 2, 1, 10)),
          updatedAt: Value(DateTime(2025, 2, 1, 10)),
        ),
      );
    });
  }

  void expectSummaryEquivalent(ReportSummary sql, ReportSummary dart) {
    expect(sql.netRevenue.satang, dart.netRevenue.satang, reason: 'netRevenue');
    expect(
      sql.voidedTotal.satang,
      dart.voidedTotal.satang,
      reason: 'voidedTotal',
    );
    expect(sql.salesCount, dart.salesCount, reason: 'salesCount');
    expect(sql.voidCount, dart.voidCount, reason: 'voidCount');
    expect(sql.vatAmount.satang, dart.vatAmount.satang, reason: 'vatAmount');
    expect(
      sql.discountAmount.satang,
      dart.discountAmount.satang,
      reason: 'discountAmount',
    );
    expect(
      sql.serviceChargeAmount.satang,
      dart.serviceChargeAmount.satang,
      reason: 'serviceChargeAmount',
    );
    expect(
      sql.promotionDiscountAmount.satang,
      dart.promotionDiscountAmount.satang,
      reason: 'promotionDiscountAmount',
    );
    expect(sql.paymentBreakdown, dart.paymentBreakdown, reason: 'breakdown');
    expect(sql.paymentCounts, dart.paymentCounts, reason: 'counts');
    expect(
      sql.orderTypeBreakdown,
      dart.orderTypeBreakdown,
      reason: 'orderTypeBreakdown',
    );
    expect(
      sql.orderChannelBreakdown,
      dart.orderChannelBreakdown,
      reason: 'orderChannelBreakdown',
    );
    expect(
      sql.voidReasonBreakdown,
      dart.voidReasonBreakdown,
      reason: 'voidReasonBreakdown',
    );
    expect(sql.promotionCount, dart.promotionCount, reason: 'promotionCount');
  }

  test('SQL summary equals Dart reference on bounded range', () async {
    await seedSales();
    final sql = await query.queryReportSummary(
      from: DateTime(2025, 1, 1),
      to: DateTime(2025, 1, 31, 23, 59, 59),
    );
    final dart = await query.dartReportSummaryReference(
      from: DateTime(2025, 1, 1),
      to: DateTime(2025, 1, 31, 23, 59, 59),
    );
    expectSummaryEquivalent(sql, dart);

    // Spot-check the fixture actually exercised the tricky buckets instead
    // of trivially agreeing on emptiness.
    expect(sql.salesCount, 8);
    expect(sql.voidCount, 2);
    expect(sql.netRevenue.satang, 42229);
    expect(sql.paymentCounts['cash'], 4);
    expect(sql.paymentCounts['promptpay'], 2);
    // pp leg 49.99 (ROUND fallback) + deleted-leg header fallback 42.00.
    expect(sql.paymentBreakdown['promptpay'], closeTo(91.99, 0.0001));
    expect(sql.orderTypeBreakdown['dine-in'], closeTo(89.09, 0.0001));
    expect(sql.promotionCount, 1);
    expect(sql.voidReasonBreakdown['wrong item'], 1);
    expect(sql.voidReasonBreakdown['unspecified'], 1);
  });

  test('SQL summary equals Dart reference on unbounded range', () async {
    await seedSales();
    final sql = await query.queryReportSummary();
    final dart = await query.dartReportSummaryReference();
    expectSummaryEquivalent(sql, dart);
    expect(sql.salesCount, 9); // february row joins in
    expect(sql.netRevenue.satang, 49929);
  });

  test('voided sale tender legs are excluded from payment breakdown', () async {
    await seedSales();
    final sql = await query.queryReportSummary(
      from: DateTime(2025, 1, 1),
      to: DateTime(2025, 1, 31, 23, 59, 59),
    );
    // s-voided-with-legs (cash 10.00) must not inflate cash anywhere.
    expect(
      sql.paymentBreakdown['cash'],
      closeTo(123.45 + 50.00 + 2.63, 0.0001),
    ); // 176.08
    expect(sql.voidedTotal.satang, 1500); // 10.00 + 5.00
  });
}
