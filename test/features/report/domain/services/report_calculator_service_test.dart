import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

void main() {
  const calculator = ReportCalculatorService();

  group('ReportCalculatorService — filter helpers', () {
    final completed = _sale(status: 'COMPLETED', totalAmount: 100);
    final voided = _sale(status: 'VOIDED', totalAmount: 50);
    final sales = [completed, voided];

    test('completedSales filters out voided', () {
      expect(calculator.completedSales(sales), [completed]);
    });

    test('voidedSales filters out completed', () {
      expect(calculator.voidedSales(sales), [voided]);
    });
  });

  group('ReportCalculatorService — period totals', () {
    final s1 = _sale(status: 'COMPLETED', totalAmount: 100, method: 'cash');
    final s2 = _sale(
      status: 'COMPLETED',
      totalAmount: 200,
      method: 'promptpay',
    );
    final s3 = _sale(status: 'VOIDED', totalAmount: 50, method: 'cash');
    final sales = [s1, s2, s3];

    test('netRevenue sums completed sales only', () {
      expect(calculator.netRevenue(sales), Money.fromDouble(300));
    });

    test('voidedTotal sums voided sales only', () {
      expect(calculator.voidedTotal(sales), Money.fromDouble(50));
    });

    test('periodTotals matches net and payment maps', () {
      final t = calculator.periodTotals(sales);
      expect(t.netRevenue, Money.fromDouble(300));
      expect(t.salesCount, 2);
      expect(t.paymentBreakdown['cash'], 100);
      expect(t.paymentBreakdown['promptpay'], 200);
      expect(t.paymentCounts['cash'], 1);
      expect(t.paymentCounts['promptpay'], 1);
    });

    test('periodTotals aggregates service charge and promotions', () {
      final promoted = _sale(
        status: 'COMPLETED',
        totalAmount: 120,
        serviceCharge: 10,
        promotionDiscount: 5,
        promotionId: 'promo-1',
      );
      final t = calculator.periodTotals([promoted]);

      expect(t.serviceChargeAmount, Money.fromDouble(10));
      expect(t.promotionDiscountAmount, Money.fromDouble(5));
      expect(t.promotionCount, 1);
      expect(t.cartDiscountAmount, Money.zero);
    });

    test('aggregates fractional money in satang without float drift', () {
      final sales = List.generate(
        10,
        (_) => _sale(
          status: 'COMPLETED',
          totalAmount: 0.10,
          method: 'cash',
          createdAt: DateTime(2026, 6, 1, 10),
        ),
      );
      final totals = calculator.periodTotals(sales);

      expect(totals.netRevenue, const Money.fromSatang(100));
      expect(totals.paymentBreakdown['cash'], 1.0);
      expect(calculator.dailyRevenue(sales).single.revenue, 1.0);
    });
  });

  group('ReportCalculatorService — daily revenue', () {
    test(
      'dailyRevenueBetween returns zero-filled days when there are no sales',
      () {
        final daily = calculator.dailyRevenueBetween(
          const <Sale>[],
          DateTime(2026, 6, 1),
          DateTime(2026, 6, 3),
        );

        expect(daily.map((d) => d.date.day), [1, 2, 3]);
        expect(daily.every((d) => d.revenue == 0 && d.count == 0), isTrue);
      },
    );

    test('dailyRevenueBetween keeps zero-sales calendar days', () {
      final first = _sale(
        status: 'COMPLETED',
        totalAmount: 100,
        createdAt: DateTime(2026, 6, 1, 10),
      );
      final last = _sale(
        status: 'COMPLETED',
        totalAmount: 200,
        createdAt: DateTime(2026, 6, 3, 10),
      );

      final daily = calculator.dailyRevenueBetween(
        [first, last],
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 3),
      );

      expect(daily.map((d) => d.date.day), [1, 2, 3]);
      expect(daily.map((d) => d.revenue), [100, 0, 200]);
      expect(daily.map((d) => d.count), [1, 0, 1]);
    });
  });

  group('ReportCalculatorService — payment methods', () {
    final s1 = _sale(status: 'COMPLETED', totalAmount: 100, method: 'cash');
    final s2 = _sale(
      status: 'COMPLETED',
      totalAmount: 200,
      method: 'promptpay',
    );
    final s3 = _sale(status: 'VOIDED', totalAmount: 50, method: 'cash');
    final sales = [s1, s2, s3];

    test('byPaymentMethod groups by normalized method and sums amounts', () {
      final byMethod = calculator.byPaymentMethod(sales);
      expect(byMethod.length, 2);
      expect(byMethod['cash'], 100.0);
      expect(byMethod['promptpay'], 200.0);
    });

    test('byPaymentMethod returns empty map when no completed sales', () {
      expect(calculator.byPaymentMethod([s3]), isEmpty);
    });
  });

  group('ReportCalculatorService — top products', () {
    final s1 = _sale(status: 'COMPLETED', totalAmount: 100, method: 'cash');
    final s2 = _sale(
      status: 'COMPLETED',
      totalAmount: 200,
      method: 'promptpay',
    );
    final s3 = _sale(status: 'VOIDED', totalAmount: 50, method: 'cash');
    final sales = [s1, s2, s3];

    test('topProducts aggregates qty by product name and limits to 5', () {
      final top = calculator.topProducts(sales);
      expect(top.length, 2);
      expect(top['Product A'], 4);
      expect(top['Product B'], 2);
    });

    test('topProductStats includes secondary revenue from subtotals', () {
      final stats = calculator.topProductStats(sales);
      expect(stats.length, 2);
      // 2 completed sales × Product A subtotal 20 = 40
      final a = stats.firstWhere((s) => s.displayName == 'Product A');
      expect(a.qty, 4);
      expect(a.revenue, 40);
      final b = stats.firstWhere((s) => s.displayName == 'Product B');
      expect(b.qty, 2);
      expect(b.revenue, 10);
    });

    test('returns empty when no completed sales', () {
      expect(calculator.topProducts([s3]), isEmpty);
      expect(calculator.topProductStats([s3]), isEmpty);
    });

    test('topProductStats with productLookup computes cost and margin', () {
      final lookup = {
        'p1': _product(id: 'p1', name: 'Product A', cost: 4),
        'p2': _product(id: 'p2', name: 'Product B', cost: 2),
      };
      final stats = calculator.topProductStats(sales, productLookup: lookup);
      final a = stats.firstWhere((s) => s.displayName == 'Product A');
      expect(a.cost, 16); // 4 cost × 4 qty
      expect(a.profit, 24); // 40 revenue − 16 cost
      expect(a.marginPercent, closeTo(60.0, 0.01));
      final b = stats.firstWhere((s) => s.displayName == 'Product B');
      expect(b.cost, 4); // 2 cost × 2 qty
      expect(b.profit, 6); // 10 revenue − 4 cost
      expect(b.marginPercent, closeTo(60.0, 0.01));
    });

    test('topProductStats without lookup has null cost/profit', () {
      final stats = calculator.topProductStats(sales);
      for (final s in stats) {
        expect(s.cost, isNull);
        expect(s.profit, isNull);
        expect(s.marginPercent, isNull);
      }
    });
  });

  group('ReportCalculatorService — profit analytics', () {
    final s1 = _sale(status: 'COMPLETED', totalAmount: 100, method: 'cash');
    final s2 = _sale(
      status: 'COMPLETED',
      totalAmount: 200,
      method: 'promptpay',
    );
    final s3 = _sale(status: 'VOIDED', totalAmount: 50, method: 'cash');
    final sales = [s1, s2, s3];

    test('computes total cost, gross profit, and margin', () {
      final lookup = {
        'p1': _product(id: 'p1', name: 'Product A', cost: 4),
        'p2': _product(id: 'p2', name: 'Product B', cost: 2),
      };
      final profit = calculator.profitAnalytics(sales, lookup);
      // 2 completed sales × 2 items each = 4 line items, all with cost.
      // Product A: 4 qty × 4 cost = 16; Product B: 2 qty × 2 cost = 4; total = 20
      expect(profit.totalCost, Money.fromDouble(20));
      // Line revenue: 40 + 10 = 50
      expect(profit.grossProfit, Money.fromDouble(30));
      expect(profit.marginPercent, closeTo(60.0, 0.01));
      expect(profit.itemsWithCost, 4);
      expect(profit.itemsWithoutCost, 0);
      expect(profit.hasFullCoverage, isTrue);
      expect(profit.hasNoCoverage, isFalse);
    });

    test('counts items without cost as uncovered', () {
      final lookup = {
        'p1': _product(id: 'p1', name: 'Product A', cost: 4),
        // p2 missing → uncovered
      };
      final profit = calculator.profitAnalytics(sales, lookup);
      // 2 completed sales × 2 items each = 4 line items.
      // p1 items (2) have cost; p2 items (2) are uncovered.
      expect(profit.itemsWithCost, 2);
      expect(profit.itemsWithoutCost, 2);
      expect(profit.hasFullCoverage, isFalse);
      expect(profit.hasNoCoverage, isFalse);
      expect(profit.coveragePercent, closeTo(0.5, 0.01));
    });

    test('returns empty analytics for no completed sales', () {
      final profit = calculator.profitAnalytics(
        [s3],
        {'p1': _product(id: 'p1', cost: 4)},
      );
      expect(profit.totalCost, Money.zero);
      expect(profit.grossProfit, Money.zero);
      expect(profit.marginPercent, 0);
      expect(profit.hasNoCoverage, isTrue);
    });

    test('hasNoCoverage when lookup has no matching products', () {
      final profit = calculator.profitAnalytics(sales, {});
      expect(profit.itemsWithCost, 0);
      expect(profit.hasNoCoverage, isTrue);
    });
  });
}

Sale _sale({
  required String status,
  required double totalAmount,
  String method = 'cash',
  DateTime? createdAt,
  double serviceCharge = 0,
  double promotionDiscount = 0,
  String? promotionId,
}) {
  final isVoided = status == 'VOIDED';
  return Sale(
    id: 'test-${isVoided ? 'voided' : 'completed'}-$totalAmount',
    receiptNumber: 'R001',
    status: status,
    items: [
      SaleItem(
        id: 'i1',
        saleId: 's1',
        productId: 'p1',
        productName: 'Product A',
        price: Money.fromDouble(10),
        qty: 2,
        subtotal: Money.fromDouble(20),
      ),
      SaleItem(
        id: 'i2',
        saleId: 's1',
        productId: 'p2',
        productName: 'Product B',
        price: Money.fromDouble(5),
        qty: 1,
        subtotal: Money.fromDouble(5),
      ),
    ],
    totalAmount: Money.fromDouble(totalAmount),
    paymentMethod: method,
    serviceChargeAmount: Money.fromDouble(serviceCharge),
    promotionDiscountAmount: Money.fromDouble(promotionDiscount),
    promotionId: promotionId,
    discountAmount: Money.fromDouble(promotionDiscount),
    createdAt: createdAt ?? DateTime(2026, 6, 1),
    voidedAt: isVoided ? DateTime(2026, 6, 2) : null,
  );
}

Product _product({
  required String id,
  String name = 'Product',
  double cost = 0,
}) {
  final now = DateTime(2026, 6, 1);
  return Product(
    id: id,
    name: name,
    price: Money.fromDouble(10),
    cost: Money.fromDouble(cost),
    stock: 100,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}
