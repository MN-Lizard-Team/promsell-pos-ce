import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/report/data/services/report_export_service.dart';
import 'package:promsell_pos_ce/features/report/domain/entities/report_data.dart';
import 'package:promsell_pos_ce/features/report/domain/services/report_calculator_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';

void main() {
  const calculator = ReportCalculatorService();
  const exportService = ReportExportService();

  ReportData buildData(List<Sale> sales) {
    return ReportData(
      sales: sales,
      from: DateTime(2026, 6, 1),
      to: DateTime(2026, 6, 3),
      totals: calculator.periodTotals(sales),
      dailyRevenue: const [],
    );
  }

  Sale buildSale({
    String status = 'COMPLETED',
    double total = 100,
    String method = 'cash',
    String receiptNumber = 'R001',
  }) {
    final isVoided = status == 'VOIDED';
    return Sale(
      id: 'sale-$receiptNumber',
      receiptNumber: receiptNumber,
      status: status,
      items: [
        SaleItem(
          id: 'i1',
          saleId: 'sale-$receiptNumber',
          productId: 'p1',
          productName: 'Coffee',
          price: Money.fromDouble(50),
          qty: 2,
          subtotal: Money.fromDouble(100),
        ),
      ],
      totalAmount: Money.fromDouble(total),
      subtotalAmount: Money.fromDouble(total),
      paymentMethod: method,
      amountReceived: Money.fromDouble(total),
      changeAmount: Money.zero,
      createdAt: DateTime(2026, 6, 2, 10),
      voidedAt: isVoided ? DateTime(2026, 6, 2, 11) : null,
    );
  }

  group('ReportExportService — CSV', () {
    test('exportCsv includes header row', () {
      final csv = exportService.exportCsv(buildData([]));
      expect(csv, contains('Receipt Number'));
      expect(csv, contains('Date'));
      expect(csv, contains('Status'));
      expect(csv, contains('Payment Method'));
      expect(csv, contains('Total Amount'));
      expect(csv, contains('Items'));
    });

    test('exportCsv includes sale rows with correct data', () {
      final sales = [buildSale(receiptNumber: 'R001', total: 200)];
      final csv = exportService.exportCsv(buildData(sales));
      expect(csv, contains('R001'));
      expect(csv, contains('COMPLETED'));
      expect(csv, contains('cash'));
      expect(csv, contains('200.00'));
      expect(csv, contains('Coffee x2'));
    });

    test('exportCsv marks voided sales as VOIDED', () {
      final sales = [buildSale(status: 'VOIDED', receiptNumber: 'R002')];
      final csv = exportService.exportCsv(buildData(sales));
      expect(csv, contains('VOIDED'));
      expect(csv, contains('R002'));
    });

    test('exportCsv escapes formula-injection characters', () {
      final malicious = Sale(
        id: 'sale-x',
        receiptNumber: '=cmd',
        status: 'COMPLETED',
        items: [
          SaleItem(
            id: 'i1',
            saleId: 'sale-x',
            productId: 'p1',
            productName: 'Coffee',
            price: Money.fromDouble(50),
            qty: 1,
            subtotal: Money.fromDouble(50),
          ),
        ],
        totalAmount: Money.fromDouble(50),
        subtotalAmount: Money.fromDouble(50),
        paymentMethod: 'cash',
        amountReceived: Money.fromDouble(50),
        changeAmount: Money.zero,
        createdAt: DateTime(2026, 6, 2, 10),
      );
      final csv = exportService.exportCsv(buildData([malicious]));
      // The receipt number starting with '=' should be escaped with a
      // leading single quote.
      expect(csv, contains("'=cmd"));
    });

    test('exportCsv appends profitability summary when profit data exists', () {
      final sales = [buildSale(receiptNumber: 'R003', total: 100)];
      final lookup = <String, Product>{'p1': _product(id: 'p1', cost: 30)};
      final profit = calculator.profitAnalytics(sales, lookup);
      final data = ReportData(
        sales: sales,
        from: DateTime(2026, 6, 1),
        to: DateTime(2026, 6, 3),
        totals: calculator.periodTotals(sales),
        dailyRevenue: const [],
        profit: profit,
      );
      final csv = exportService.exportCsv(data);
      expect(csv, contains('Profitability Summary'));
      expect(csv, contains('Total Cost'));
      expect(csv, contains('Gross Profit'));
      expect(csv, contains('Margin %'));
    });

    test('exportCsv omits profitability summary when no cost coverage', () {
      final sales = [buildSale(receiptNumber: 'R004')];
      final profit = calculator.profitAnalytics(sales, {});
      final data = ReportData(
        sales: sales,
        from: DateTime(2026, 6, 1),
        to: DateTime(2026, 6, 3),
        totals: calculator.periodTotals(sales),
        dailyRevenue: const [],
        profit: profit,
      );
      final csv = exportService.exportCsv(data);
      expect(csv, isNot(contains('Profitability Summary')));
    });
  });

  group('ReportExportService — PDF', () {
    test('exportPdf produces non-empty bytes', () async {
      final sales = [buildSale(receiptNumber: 'R005', total: 150)];
      final bytes = await exportService.exportPdf(buildData(sales));
      expect(bytes, isNotEmpty);
      // PDF files start with %PDF
      expect(bytes[0], 0x25); // %
      expect(bytes[1], 0x50); // P
      expect(bytes[2], 0x44); // D
      expect(bytes[3], 0x46); // F
    });

    test('exportPdf with productLookup includes cost data', () async {
      final sales = [buildSale(receiptNumber: 'R006', total: 100)];
      final lookup = <String, Product>{'p1': _product(id: 'p1', cost: 30)};
      final profit = calculator.profitAnalytics(sales, lookup);
      final data = ReportData(
        sales: sales,
        from: DateTime(2026, 6, 1),
        to: DateTime(2026, 6, 3),
        totals: calculator.periodTotals(sales),
        dailyRevenue: const [],
        profit: profit,
      );
      final bytes = await exportService.exportPdf(
        data,
        productLookup: lookup,
        calculator: calculator,
      );
      expect(bytes, isNotEmpty);
    });
  });
}

Product _product({required String id, double cost = 0}) {
  final now = DateTime(2026, 6, 1);
  return Product(
    id: id,
    name: 'Test Product',
    price: Money.fromDouble(50),
    cost: Money.fromDouble(cost),
    stock: 100,
    isActive: true,
    createdAt: now,
    updatedAt: now,
  );
}
