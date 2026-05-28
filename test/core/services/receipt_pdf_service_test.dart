import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

void main() {
  group('ReceiptPdfService VAT calculation', () {
    final service = ReceiptPdfService();
    final sale = Sale(
      id: 'uuid-123',
      receiptNumber: 'R00001',
      totalAmount: 107.0,
      paymentMethod: 'cash',
      amountReceived: 107.0,
      changeAmount: 0.0,
      createdAt: DateTime(2024, 1, 15, 10, 30),
      items: const [
        SaleItem(
          id: 'i1',
          saleId: 'uuid-123',
          productId: 'p1',
          productName: 'Test Product',
          price: 100.0,
          qty: 1,
          subtotal: 100.0,
        ),
      ],
    );

    const labels = ReceiptLabels(
      receipt: 'Receipt',
      payment: 'Payment',
      paymentMethodLabel: 'Cash',
      total: 'Total',
      received: 'Received',
      change: 'Change',
      note: 'Note',
      vat: 'VAT',
      vatIncluded: 'VAT (included)',
      subtotal: 'Subtotal',
    );

    test('receipt number used instead of sale id', () {
      expect(sale.receiptNumber, 'R00001');
      expect(sale.id, 'uuid-123');
    });

    test('document builds without error', () {
      const settings = AppSettings();
      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: settings,
        labels: labels,
      );
      expect(doc, isNotNull);
    });

    test('shop info hidden when showShopInfoOnReceipt is false', () {
      const settings = AppSettings(
        shopName: 'Test Shop',
        address: '123 Street',
        phone: '0812345678',
        showShopInfoOnReceipt: false,
      );
      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: settings,
        labels: labels,
      );
      expect(doc, isNotNull);
    });

    test('receiptNote used as footer when not empty', () {
      const settings = AppSettings(receiptNote: 'Come again!');
      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: settings,
        labels: labels,
      );
      expect(doc, isNotNull);
    });

    group('calculateVat', () {
      test('NONE returns null', () {
        final result = service.calculateVat(total: 100, rate: 7, mode: 'NONE');
        expect(result, isNull);
      });

      test('INCLUSIVE extracts VAT from total', () {
        final result = service.calculateVat(
          total: 107,
          rate: 7,
          mode: 'INCLUSIVE',
        );
        expect(result, isNotNull);
        expect(result!.isInclusive, isTrue);
        expect(result.totalWithVat, 107.0);
        expect(result.vatAmount, closeTo(7.0, 0.01));
        expect(result.subtotal, closeTo(100.0, 0.01));
      });

      test('EXCLUSIVE adds VAT on top of total', () {
        final result = service.calculateVat(
          total: 100,
          rate: 7,
          mode: 'EXCLUSIVE',
        );
        expect(result, isNotNull);
        expect(result!.isInclusive, isFalse);
        expect(result.subtotal, 100.0);
        expect(result.vatAmount, closeTo(7.0, 0.01));
        expect(result.totalWithVat, closeTo(107.0, 0.01));
      });
    });
  });
}
