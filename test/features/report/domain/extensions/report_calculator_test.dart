import 'package:flutter_test/flutter_test.dart';
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
    final s1 = _sale(status: 'COMPLETED', totalAmount: 100);
    final s2 = _sale(status: 'COMPLETED', totalAmount: 200);
    final s3 = _sale(status: 'VOIDED', totalAmount: 50);
    final sales = [s1, s2, s3];

    test('netRevenue sums completed sales only', () {
      expect(sales.netRevenue, 300.0);
    });

    test('voidedTotal sums voided sales only', () {
      expect(sales.voidedTotal, 50.0);
    });

    group('byPaymentMethod', () {
      test('groups by normalized method and sums amounts', () {
        final byMethod = sales.byPaymentMethod();
        expect(byMethod.length, 1);
        expect(byMethod['CASH'], 300.0);
      });

      test('returns empty map when no completed sales', () {
        expect([s3].byPaymentMethod(), isEmpty);
      });
    });

    group('topProducts', () {
      test('aggregates qty by product name and limits to 5', () {
        final top = sales.topProducts();
        expect(top.length, 2);
        expect(top['Product A'], 4);
        expect(top['Product B'], 2);
      });

      test('returns empty map when no completed sales', () {
        expect([s3].topProducts(), isEmpty);
      });
    });
  });
}

Sale _sale({required String status, required double totalAmount}) {
  final isVoided = status == 'VOIDED';
  return Sale(
    id: 'test-${isVoided ? 'voided' : 'completed'}',
    receiptNumber: 'R001',
    status: status,
    items: const [
      SaleItem(
        id: 'i1',
        saleId: 's1',
        productId: 'p1',
        productName: 'Product A',
        price: 10,
        qty: 2,
        subtotal: 20,
      ),
      SaleItem(
        id: 'i2',
        saleId: 's1',
        productId: 'p2',
        productName: 'Product B',
        price: 5,
        qty: 1,
        subtotal: 5,
      ),
    ],
    totalAmount: totalAmount,
    paymentMethod: 'CASH',
    createdAt: DateTime(2026, 6, 1),
    voidedAt: isVoided ? DateTime(2026, 6, 2) : null,
  );
}
