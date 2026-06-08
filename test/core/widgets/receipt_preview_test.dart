import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/receipt/domain/entities/receipt_labels.dart';
import 'package:promsell_pos_ce/core/widgets/receipt_preview.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

void main() {
  group('ReceiptPreview', () {
    final settings = AppSettings(
      shopName: 'Test Shop',
      address: '123 Street',
      phone: '0812345678',
      currency: '\$',
      showShopInfoOnReceipt: true,
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
      itemDiscounts: 'Item Discounts',
      cartDiscount: 'Cart Discount',
    );

    final items = const [
      ReceiptPreviewItem(name: 'Apple', qty: 2, price: 1.5, subtotal: 3.0),
      ReceiptPreviewItem(name: 'Banana', qty: 1, price: 2.0, subtotal: 2.0),
    ];

    testWidgets('thermal style renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptPreview(
              settings: settings,
              labels: labels,
              style: ReceiptPreviewStyle.thermal,
              items: items,
              total: 5.0,
              receiptNumber: 'R001',
              createdAt: DateTime(2024, 1, 15, 10, 30),
            ),
          ),
        ),
      );

      expect(find.text('Test Shop'), findsOneWidget);
      expect(find.text('123 Street'), findsOneWidget);
      expect(find.textContaining('R001'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('card style renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptPreview(
              settings: settings,
              labels: labels,
              style: ReceiptPreviewStyle.card,
              items: items,
              total: 5.0,
              receiptNumber: 'R001',
              createdAt: DateTime(2024, 1, 15, 10, 30),
            ),
          ),
        ),
      );

      expect(find.text('Test Shop'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('shows VAT lines when vatInfo provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptPreview(
              settings: settings,
              labels: labels,
              style: ReceiptPreviewStyle.thermal,
              items: items,
              total: 107.0,
              vatInfo: (
                subtotal: 100.0,
                vatAmount: 7.0,
                totalWithVat: 107.0,
                isInclusive: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.textContaining('VAT'), findsOneWidget);
    });

    testWidgets('hides shop info when showShopInfoOnReceipt is false', (
      tester,
    ) async {
      final hiddenSettings = AppSettings(
        shopName: 'Test Shop',
        address: '123 Street',
        showShopInfoOnReceipt: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptPreview(
              settings: hiddenSettings,
              labels: labels,
              style: ReceiptPreviewStyle.thermal,
              items: items,
              total: 5.0,
            ),
          ),
        ),
      );

      expect(find.text('123 Street'), findsNothing);
    });

    testWidgets('shows Preview placeholder when receiptNumber is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptPreview(
              settings: settings,
              labels: labels,
              style: ReceiptPreviewStyle.thermal,
              items: items,
              total: 5.0,
            ),
          ),
        ),
      );

      expect(find.textContaining('Preview'), findsOneWidget);
    });

    testWidgets('none style returns SizedBox.shrink', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptPreview(
              settings: settings,
              labels: labels,
              style: ReceiptPreviewStyle.none,
              items: items,
              total: 5.0,
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.text('Test Shop'), findsNothing);
    });

    testWidgets('shows payment and received/change', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceiptPreview(
              settings: settings,
              labels: labels,
              style: ReceiptPreviewStyle.card,
              items: items,
              total: 5.0,
              paymentMethod: 'cash',
              amountReceived: 10.0,
              changeAmount: 5.0,
            ),
          ),
        ),
      );

      expect(find.text('Received'), findsOneWidget);
      expect(find.text('Change'), findsOneWidget);
    });
  });
}
