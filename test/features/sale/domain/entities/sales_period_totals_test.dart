import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sales_period_totals.dart';

void main() {
  group('SalesPeriodTotals', () {
    test('empty list yields zeros', () {
      final t = SalesPeriodTotals.from(const []);
      expect(t.netRevenue, Money.zero);
      expect(t.voidedTotal, Money.zero);
      expect(t.salesCount, 0);
      expect(t.voidCount, 0);
      expect(t.paymentBreakdown, isEmpty);
      expect(t.paymentCounts, isEmpty);
    });

    test('sums non-void revenue and excludes voids', () {
      final sales = [
        _sale(total: 100, method: 'cash'),
        _sale(total: 50, method: 'promptpay'),
        _sale(total: 30, method: 'cash', voided: true),
      ];
      final t = SalesPeriodTotals.from(sales);
      expect(t.netRevenue, Money.fromDouble(150));
      expect(t.voidedTotal, Money.fromDouble(30));
      expect(t.salesCount, 2);
      expect(t.voidCount, 1);
      expect(t.paymentBreakdown['cash'], 100);
      expect(t.paymentBreakdown['promptpay'], 50);
      expect(t.paymentCounts['cash'], 1);
      expect(t.paymentCounts['promptpay'], 1);
      expect(t.cashSales, Money.fromDouble(100));
    });

    test('normalizes Thai cash label to cash', () {
      final t = SalesPeriodTotals.from([_sale(total: 20, method: 'เงินสด')]);
      expect(t.paymentBreakdown.keys, ['cash']);
      expect(t.paymentBreakdown['cash'], 20);
    });

    test('sums vat and cart discount on non-void only', () {
      final t = SalesPeriodTotals.from([
        _sale(total: 100, method: 'cash', vat: 7, discount: 5),
        _sale(total: 50, method: 'cash', vat: 3, discount: 1, voided: true),
      ]);
      expect(t.vatAmount, Money.fromDouble(7));
      expect(t.discountAmount, Money.fromDouble(5));
    });

    test('grossRevenue is net + voided', () {
      final t = SalesPeriodTotals.from([
        _sale(total: 100, method: 'cash'),
        _sale(total: 40, method: 'cash', voided: true),
      ]);
      expect(t.grossRevenue, Money.fromDouble(140));
    });

    test('multi-tender allocates amounts per method', () {
      final sale = Sale(
        id: 'mixed-1',
        receiptNumber: 'R',
        status: 'COMPLETED',
        items: const [],
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'mixed',
        payments: [
          SalePayment(method: 'cash', amount: Money.fromDouble(40)),
          SalePayment(method: 'promptpay', amount: Money.fromDouble(60)),
        ],
        createdAt: DateTime(2026, 6, 1),
      );
      final t = SalesPeriodTotals.from([sale]);
      expect(t.paymentBreakdown['cash'], 40);
      expect(t.paymentBreakdown['promptpay'], 60);
      // Counts follow tender legs (not header `mixed` only).
      expect(t.paymentCounts['cash'], 1);
      expect(t.paymentCounts['promptpay'], 1);
      expect(t.paymentCounts['mixed'], isNull);
      expect(t.cashSales, Money.fromDouble(40));
    });
  });
}

Sale _sale({
  required double total,
  required String method,
  bool voided = false,
  double vat = 0,
  double discount = 0,
}) {
  return Sale(
    id: 's-$total-$method-$voided',
    receiptNumber: 'R',
    status: voided ? 'VOIDED' : 'COMPLETED',
    items: const [],
    totalAmount: Money.fromDouble(total),
    paymentMethod: method,
    vatAmount: Money.fromDouble(vat),
    discountAmount: Money.fromDouble(discount),
    createdAt: DateTime(2026, 6, 1),
    voidedAt: voided ? DateTime(2026, 6, 2) : null,
  );
}
