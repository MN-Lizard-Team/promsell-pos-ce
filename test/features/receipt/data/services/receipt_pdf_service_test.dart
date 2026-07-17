import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
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
    serviceCharge: 'Service Charge',
    promotionDiscount: 'Promo',
    voided: 'VOIDED',
    voidReason: 'Reason',
    reprint: 'REPRINT',
  );

  const defaultSettings = Settings();

  setUp(() {
    service = ReceiptPdfService();
  });

  group('ReceiptPdfService.calculateVat (legacy)', () {
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

    test('INCLUSIVE with rounding produces exact 2-decimal values', () {
      final result = service.calculateVat(
        total: 99.99,
        rate: 7,
        mode: 'INCLUSIVE',
      );
      expect(result, isNotNull);
      expect(
        result!.subtotal,
        double.parse(result.subtotal.toStringAsFixed(2)),
      );
      expect(
        result.vatAmount,
        double.parse(result.vatAmount.toStringAsFixed(2)),
      );
    });
  });

  group('ReceiptPdfService.buildDocumentForTest', () {
    test('builds document with minimal sale', () {
      final sale = Sale(
        id: 'sale-1',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'CASH',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-1',
            productId: 'p1',
            productName: 'Coffee',
            price: Money.fromDouble(50),
            qty: 2,
            subtotal: Money.fromDouble(100),
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

    test('builds document with SC promo cart disc and stored VAT', () {
      final sale = Sale(
        id: 'sale-ssot',
        receiptNumber: 'R-SSOT',
        totalAmount: Money.fromDouble(1023.99),
        subtotalAmount: Money.fromDouble(957),
        discountAmount: Money.fromDouble(100),
        promotionDiscountAmount: Money.fromDouble(30),
        serviceChargeAmount: Money.fromDouble(87),
        serviceChargeRate: 10,
        vatMode: 'EXCLUSIVE',
        vatRate: 7,
        vatAmount: Money.fromDouble(66.99),
        paymentMethod: 'CASH',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-ssot',
            productId: 'p1',
            productName: 'Coffee',
            price: Money.fromDouble(1000),
            qty: 1,
            subtotal: Money.fromDouble(1000),
            discountAmount: Money.fromDouble(50),
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

    test('builds voided document without error', () {
      final sale = Sale(
        id: 'sale-void',
        totalAmount: Money.fromDouble(50),
        paymentMethod: 'CASH',
        status: 'VOIDED',
        voidReason: 'Test',
        voidedAt: DateTime(2025, 1, 15),
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-void',
            productId: 'p1',
            productName: 'Tea',
            price: Money.fromDouble(50),
            qty: 1,
            subtotal: Money.fromDouble(50),
          ),
        ],
      );

      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: defaultSettings,
        labels: labels,
        isReprint: true,
        notTaxInvoiceDisclaimer: 'Not a tax invoice',
      );

      expect(doc, isNotNull);
    });

    test('builds document with amountReceived and change', () {
      final sale = Sale(
        id: 'sale-4',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'CASH',
        amountReceived: Money.fromDouble(200),
        changeAmount: Money.fromDouble(100),
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-4',
            productId: 'p1',
            productName: 'Coffee',
            price: Money.fromDouble(100),
            qty: 1,
            subtotal: Money.fromDouble(100),
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

    test('builds document with note and shop info', () {
      const settings = Settings(
        shopInfo: ShopInfo(
          name: 'Test Shop',
          address: '123 Test St',
          phone: '02-123-4567',
        ),
        receiptConfig: ReceiptConfig(
          showShopInfo: true,
          receiptNote: 'Custom footer text',
        ),
      );

      final sale = Sale(
        id: 'sale-6',
        totalAmount: Money.fromDouble(50),
        paymentMethod: 'CASH',
        note: 'Test note',
        createdAt: DateTime(2025, 1, 15, 10, 30),
        items: [
          SaleItem(
            id: 'item-1',
            saleId: 'sale-6',
            productId: 'p1',
            productName: 'Tea',
            price: Money.fromDouble(50),
            qty: 1,
            subtotal: Money.fromDouble(50),
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

    test('builds document with product images without error', () {
      final sale = Sale(
        id: 'uuid-123',
        receiptNumber: 'R00001',
        totalAmount: Money.fromDouble(107.0),
        paymentMethod: 'cash',
        amountReceived: Money.fromDouble(107.0),
        changeAmount: Money.zero,
        createdAt: DateTime(2024, 1, 15, 10, 30),
        items: [
          SaleItem(
            id: 'i1',
            saleId: 'uuid-123',
            productId: 'p1',
            productName: 'Test Product',
            price: Money.fromDouble(100.0),
            qty: 1,
            subtotal: Money.fromDouble(100.0),
          ),
        ],
      );
      final pngBytes = Uint8List.fromList([
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]);
      final doc = service.buildDocumentForTest(
        sale: sale,
        settings: defaultSettings,
        labels: labels,
        productImages: {'p1': pngBytes},
      );
      expect(doc, isNotNull);
    });

    test(
      'builds document with VAT settings (stored sale fields preferred)',
      () {
        final sale = Sale(
          id: 'sale-3',
          totalAmount: Money.fromDouble(107),
          subtotalAmount: Money.fromDouble(100),
          paymentMethod: 'CASH',
          vatMode: 'INCLUSIVE',
          vatRate: 7,
          vatAmount: Money.fromDouble(7),
          createdAt: DateTime(2025, 1, 15, 10, 30),
          items: [
            SaleItem(
              id: 'item-1',
              saleId: 'sale-3',
              productId: 'p1',
              productName: 'Coffee',
              price: Money.fromDouble(107),
              qty: 1,
              subtotal: Money.fromDouble(107),
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
      },
    );
  });

  group('Sale.isVoided', () {
    test('isVoided returns true when status is VOIDED', () {
      final sale = Sale(
        id: 's1',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'CASH',
        status: 'VOIDED',
        createdAt: DateTime.utc(2025, 1, 1),
      );
      expect(sale.isVoided, isTrue);
    });

    test('isVoided returns false when status is COMPLETED', () {
      final sale = Sale(
        id: 's1',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'CASH',
        status: 'COMPLETED',
        createdAt: DateTime.utc(2025, 1, 1),
      );
      expect(sale.isVoided, isFalse);
    });
  });
}
