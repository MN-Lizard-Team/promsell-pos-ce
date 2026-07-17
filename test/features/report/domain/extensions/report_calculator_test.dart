import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/report/domain/extensions/report_calculator.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

void main() {
  group('ReportFilterExtension', () {
    final completed = _sale(status: 'COMPLETED', totalAmount: 100);
    final voided = _sale(status: 'VOIDED', totalAmount: 50);
    final sales = [completed, voided];

    test('completedSales filters out voided', () {
      expect(sales.completedSales, [completed]);
    });

    test('voidedSales filters out completed', () {
      expect(sales.voidedSales, [voided]);
    });
  });

  group('ReportCalculator', () {
    final s1 = _sale(status: 'COMPLETED', totalAmount: 100, method: 'cash');
    final s2 = _sale(
      status: 'COMPLETED',
      totalAmount: 200,
      method: 'promptpay',
    );
    final s3 = _sale(status: 'VOIDED', totalAmount: 50, method: 'cash');
    final sales = [s1, s2, s3];

    test('netRevenue sums completed sales only', () {
      expect(sales.netRevenue, Money.fromDouble(300));
    });

    test('voidedTotal sums voided sales only', () {
      expect(sales.voidedTotal, Money.fromDouble(50));
    });

    test('periodTotals matches net and payment maps', () {
      final t = sales.periodTotals;
      expect(t.netRevenue, Money.fromDouble(300));
      expect(t.salesCount, 2);
      expect(t.paymentBreakdown['cash'], 100);
      expect(t.paymentBreakdown['promptpay'], 200);
      expect(t.paymentCounts['cash'], 1);
      expect(t.paymentCounts['promptpay'], 1);
    });

    group('byPaymentMethod', () {
      test('groups by normalized method and sums amounts', () {
        final byMethod = sales.byPaymentMethod();
        expect(byMethod.length, 2);
        expect(byMethod['cash'], 100.0);
        expect(byMethod['promptpay'], 200.0);
      });

      test('returns empty map when no completed sales', () {
        expect([s3].byPaymentMethod(), isEmpty);
      });
    });

    group('topProducts / topProductStats', () {
      test('aggregates qty by product name and limits to 5', () {
        final top = sales.topProducts();
        expect(top.length, 2);
        expect(top['Product A'], 4);
        expect(top['Product B'], 2);
      });

      test('topProductStats includes secondary revenue from subtotals', () {
        final stats = sales.topProductStats();
        expect(stats.length, 2);
        // 2 completed sales × Product A subtotal 20 = 40
        final a = stats.firstWhere((s) => s.displayName == 'Product A');
        expect(a.qty, 4);
        expect(a.revenue, 40);
        final b = stats.firstWhere((s) => s.displayName == 'Product B');
        expect(b.qty, 2);
        expect(b.revenue, 10);
      });

      test('returns empty map when no completed sales', () {
        expect([s3].topProducts(), isEmpty);
        expect([s3].topProductStats(), isEmpty);
      });
    });
  });
}

Sale _sale({
  required String status,
  required double totalAmount,
  String method = 'cash',
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
    createdAt: DateTime(2026, 6, 1),
    voidedAt: isVoided ? DateTime(2026, 6, 2) : null,
  );
}
