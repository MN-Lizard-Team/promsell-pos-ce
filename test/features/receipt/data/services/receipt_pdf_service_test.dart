import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/receipt/data/services/receipt_pdf_service.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';

void main() {
  late ReceiptPdfService service;

  const labels = ReceiptLabels(
    receipt: 'Receipt',
    payment: 'Payment',
    paymentMethodLabel: 'Cash',
    total: 'Total',
    received: 'Received',
    change: 'Change',
    note: 'Note',
    vat: 'VAT',
    vatIncluded: 'VAT Included',
    subtotal: 'Subtotal',
    itemDiscounts: 'Item Discounts',
    cartDiscount: 'Cart Discount',
  );

  const defaultSettings = Settings();

  setUp(() {
    service = ReceiptPdfService();
  });

  group('ReceiptPdfService.calculateVat', () {
    test('returns null for NONE mode', () {
      final result = service.calculateVat(total: 100, rate: 7, mode: 'NONE');
      expect(result, isNull);
    });

    test('INCLUSIVE mode calculates correctly', () {
      final result = service.calculateVat(
        total: 107,
        rate: 7,
        mode: 'INCLUSIVE',
      );
      expect(result, isNotNull);
      expect(result!.isInclusive, isTrue);
      expect(result.subtotal, 100.0);
      expect(result.vatAmount, 7.0);
      expect(result.totalWithVat, 107.0);
    });

    test('EXCLUSIVE mode with isTotalPreTax=true', () {
      final result = service.calculateVat(
        total: 100,
        rate: 7,
        mode: 'EXCLUSIVE',
        isTotalPreTax: true,
      );
      expect(result, isNotNull);
      expect(result!.isInclusive, isFalse);
      expect(result.subtotal, 100.0);
      expect(result.vatAmount, 7.0);
      expect(result.totalWithVat, 107.0);
    });

    test('EXCLUSIVE mode with isTotalPreTax=false', () {
      final result = service.calculateVat(
        total: 107,
        rate: 7,
        mode: 'EXCLUSIVE',
        isTotalPreTax: false,
      );
      expect(result, isNotNull);
      expect(result!.isInclusive, isFalse);
      expect(result.vatAmount, 7.0);
      expect(result.subtotal, 100.0);
      expect(result.totalWithVat, 107.0);
    });

    test('INCLUSIVE with 0% rate', () {
      final result = service.calculateVat(
        total: 100,
        rate: 0,
        mode: 'INCLUSIVE',
      );
      expect(result, isNotNull);
      expect(result!.subtotal, 100.0);
      expect(result.vatAmount, 0.0);
    });

    test('EXCLUSIVE with 0% rate', () {
      final result = service.calculateVat(
        total: 100,
        rate: 0,
        mode: 'EXCLUSIVE',
        isTotalPreTax: true,
      );
      expect(result, isNotNull);
      expect(result!.vatAmount, 0.0);
      expect(result.totalWithVat, 100.0);
    });
  });

  group('ReceiptPdfService.buildDocumentForTest', () {
    test('builds document with minimal sale', () {
      final sale = Sale(
        id: 'sale-1',
        totalAmount: 100,
        paymentMethod: 'CASH',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-1',
            productId: 'p1',
            productName: 'Coffee',
            price: 50,
            qty: 2,
            subtotal: 100,
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: defaultSettings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });

    test('builds document with item discounts', () {
      final sale = Sale(
        id: 'sale-2',
        totalAmount: 85,
        paymentMethod: 'CASH',
        discountType: 'PERCENT',
        discountValue: 10,
        discountAmount: 10,
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-2',
            productId: 'p1',
            productName: 'Coffee',
            price: 50,
            qty: 2,
            subtotal: 90,
            discountAmount: 10,
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: defaultSettings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });

    test('builds document with VAT', () {
      final sale = Sale(
        id: 'sale-3',
        totalAmount: 107,
        paymentMethod: 'CASH',
        vatMode: 'INCLUSIVE',
        vatRate: 7,
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-3',
            productId: 'p1',
            productName: 'Coffee',
            price: 107,
            qty: 1,
            subtotal: 107,
          ),
        ],
      );

      const settings = Settings(
        taxConfig: TaxConfig(vatRate: 7, vatMode: 'INCLUSIVE'),
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: settings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });

    test('builds document with amountReceived and change', () {
      final sale = Sale(
        id: 'sale-4',
        totalAmount: 100,
        paymentMethod: 'CASH',
        amountReceived: 200,
        changeAmount: 100,
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-4',
            productId: 'p1',
            productName: 'Coffee',
            price: 100,
            qty: 1,
            subtotal: 100,
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: defaultSettings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });

    test('builds document with note', () {
      final sale = Sale(
        id: 'sale-5',
        totalAmount: 50,
        paymentMethod: 'CASH',
        note: 'Test note',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-5',
            productId: 'p1',
            productName: 'Tea',
            price: 50,
            qty: 1,
            subtotal: 50,
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: defaultSettings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });

    test('builds document with shop info on receipt', () {
      const settings = Settings(
        shopInfo: ShopInfo(
          name: 'Test Shop',
          address: '123 Test St',
          phone: '02-123-4567',
        ),
        receiptConfig: ReceiptConfig(showShopInfo: true),
      );

      final sale = Sale(
        id: 'sale-6',
        totalAmount: 50,
        paymentMethod: 'CASH',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-6',
            productId: 'p1',
            productName: 'Tea',
            price: 50,
            qty: 1,
            subtotal: 50,
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: settings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });

    test('builds document with receipt note footer', () {
      const settings = Settings(
        receiptConfig: ReceiptConfig(receiptNote: 'Custom footer text'),
      );

      final sale = Sale(
        id: 'sale-7',
        totalAmount: 50,
        paymentMethod: 'CASH',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-7',
            productId: 'p1',
            productName: 'Tea',
            price: 50,
            qty: 1,
            subtotal: 50,
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: settings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });

    test('builds document with receipt number', () {
      final sale = Sale(
        id: 'sale-8',
        receiptNumber: 'R-001',
        totalAmount: 50,
        paymentMethod: 'CASH',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: const [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-8',
            productId: 'p1',
            productName: 'Tea',
            price: 50,
            qty: 1,
            subtotal: 50,
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: defaultSettings,
        labels: labels,
      );

      expect(doc, isNotNull);
    });
  });

  group('Sale', () {
    test('isVoided returns true when status is VOIDED', () {
      final sale = Sale(
        id: 's1',
        totalAmount: 100,
        paymentMethod: 'CASH',
        status: 'VOIDED',
        createdAt: DateTime.utc(2025, 1, 1),
      );
      expect(sale.isVoided, isTrue);
    });

    test('isVoided returns false when status is COMPLETED', () {
      final sale = Sale(
        id: 's1',
        totalAmount: 100,
        paymentMethod: 'CASH',
        status: 'COMPLETED',
        createdAt: DateTime.utc(2025, 1, 1),
      );
      expect(sale.isVoided, isFalse);
    });
  });
}
