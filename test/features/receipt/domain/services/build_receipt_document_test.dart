import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/features/receipt/domain/services/build_receipt_document.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';

void main() {
  const builder = BuildReceiptDocument();
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
    itemDiscounts: 'Item Discounts',
    cartDiscount: 'Cart Discount',
    serviceCharge: 'Service Charge',
    promotionDiscount: 'Promo',
  );

  group('BuildReceiptDocument.fromSale', () {
    test('uses stored sale money fields (SC, promo, cart disc, VAT)', () {
      // items 1000, cart 100, promo 30, SC 87, VAT excl 66.99 → total 1023.99
      final sale = Sale(
        id: 's1',
        receiptNumber: '260715-A1-0001',
        totalAmount: Money.fromDouble(1023.99),
        subtotalAmount: Money.fromDouble(957.00),
        discountAmount: Money.fromDouble(100),
        promotionDiscountAmount: Money.fromDouble(30),
        serviceChargeAmount: Money.fromDouble(87),
        serviceChargeRate: 10,
        vatMode: 'EXCLUSIVE',
        vatRate: 7,
        vatAmount: Money.fromDouble(66.99),
        paymentMethod: 'CASH',
        createdAt: DateTime(2026, 7, 15, 12),
        items: [
          SaleItem(
            id: 'i1',
            saleId: 's1',
            productId: 'p1',
            productName: 'Item',
            price: Money.fromDouble(1000),
            qty: 1,
            subtotal: Money.fromDouble(1000),
            discountAmount: Money.fromDouble(50),
          ),
        ],
      );

      final doc = builder.fromSale(
        sale: sale,
        settings: const Settings(),
        labels: labels,
      );

      expect(doc.total.value, closeTo(1023.99, 0.001));
      expect(doc.cartDiscount.value, closeTo(100, 0.001));
      expect(doc.promotionDiscount.value, closeTo(30, 0.001));
      expect(doc.serviceCharge.value, closeTo(87, 0.001));
      expect(doc.vatAmount.value, closeTo(66.99, 0.001));
      expect(doc.pretaxOrNetOfVat.value, closeTo(957, 0.001));
      expect(doc.hasVat, isTrue);
      expect(doc.isVatInclusive, isFalse);
      expect(doc.receiptSize, '80mm');
      // Net line only — item discount not aggregated as separate money row.
      expect(doc.items.single.lineTotal.value, closeTo(1000, 0.001));
      expect(doc.itemsNetTotal.value, closeTo(1000, 0.001));
    });

    test('voided sale flags and reason', () {
      final sale = Sale(
        id: 's2',
        totalAmount: Money.fromDouble(50),
        paymentMethod: 'CASH',
        status: 'VOIDED',
        voidReason: 'Mistake',
        voidedAt: DateTime(2026, 7, 15),
        createdAt: DateTime(2026, 7, 15),
        items: const [],
      );

      final doc = builder.fromSale(
        sale: sale,
        settings: const Settings(),
        labels: labels,
        isReprint: true,
        notTaxInvoiceDisclaimer: 'Not a tax invoice',
      );

      expect(doc.isVoided, isTrue);
      expect(doc.voidReason, 'Mistake');
      expect(doc.isReprint, isTrue);
      expect(doc.notTaxInvoiceDisclaimer, 'Not a tax invoice');
    });

    test('NONE vat has no vat breakdown', () {
      final sale = Sale(
        id: 's3',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'CASH',
        vatMode: 'NONE',
        createdAt: DateTime(2026, 7, 15),
        items: [
          SaleItem(
            id: 'i1',
            saleId: 's3',
            productId: 'p1',
            productName: 'X',
            price: Money.fromDouble(100),
            qty: 1,
            subtotal: Money.fromDouble(100),
          ),
        ],
      );

      final doc = builder.fromSale(
        sale: sale,
        settings: const Settings(),
        labels: labels,
      );

      expect(doc.hasVat, isFalse);
      expect(doc.total.value, 100);
    });

    // V092-A.1 regression: disclaimer shows even when Tax ID is set.
    test('disclaimer shows even when taxId is set (V092-A.1)', () {
      const settings = Settings(
        shopInfo: ShopInfo(name: 'Shop', taxId: '1234567890123'),
      );
      final sale = Sale(
        id: 's-tax',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'CASH',
        createdAt: DateTime(2026, 7, 15),
        items: [
          SaleItem(
            id: 'i1',
            saleId: 's-tax',
            productId: 'p1',
            productName: 'X',
            price: Money.fromDouble(100),
            qty: 1,
            subtotal: Money.fromDouble(100),
          ),
        ],
      );

      final doc = builder.fromSale(
        sale: sale,
        settings: settings,
        labels: labels,
        notTaxInvoiceDisclaimer: 'Not a tax invoice',
      );

      expect(doc.taxId, '1234567890123');
      expect(doc.notTaxInvoiceDisclaimer, 'Not a tax invoice');
    });

    // V092-A.1 regression: disclaimer shows when taxId is empty too.
    test('disclaimer shows when taxId is empty (V092-A.1)', () {
      final sale = Sale(
        id: 's-no-tax',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'CASH',
        createdAt: DateTime(2026, 7, 15),
        items: [
          SaleItem(
            id: 'i1',
            saleId: 's-no-tax',
            productId: 'p1',
            productName: 'X',
            price: Money.fromDouble(100),
            qty: 1,
            subtotal: Money.fromDouble(100),
          ),
        ],
      );

      final doc = builder.fromSale(
        sale: sale,
        settings: const Settings(),
        labels: labels,
        notTaxInvoiceDisclaimer: 'Not a tax invoice',
      );

      expect(doc.taxId, isEmpty);
      expect(doc.notTaxInvoiceDisclaimer, 'Not a tax invoice');
    });
  });
}
