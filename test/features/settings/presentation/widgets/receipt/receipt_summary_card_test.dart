import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/receipt/receipt_summary_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ReceiptSummaryCard', () {
    testWidgets('renders thermal style icon', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: 'Thank you',
          showShopInfo: true,
          previewStyle: 'thermal',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      );

      expect(find.byIcon(Icons.receipt_long_outlined), findsWidgets);
    });

    testWidgets('renders card style icon', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: '',
          showShopInfo: false,
          previewStyle: 'card',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      );

      expect(find.byIcon(Icons.credit_card_outlined), findsWidgets);
    });

    testWidgets('renders none style icon', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: '',
          showShopInfo: false,
          previewStyle: 'none',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      );

      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);
    });

    testWidgets('shows ON for shop info enabled', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: '',
          showShopInfo: true,
          previewStyle: 'thermal',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      );

      expect(find.text('ON'), findsOneWidget);
    });

    testWidgets('shows OFF for shop info disabled', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: '',
          showShopInfo: false,
          previewStyle: 'thermal',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      );

      expect(find.text('OFF'), findsOneWidget);
    });

    testWidgets('renders inclusive VAT label with rate', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: '',
          showShopInfo: false,
          previewStyle: 'thermal',
          vatMode: 'INCLUSIVE',
          vatRate: 7.0,
        ),
      );

      expect(find.textContaining('7.0%'), findsOneWidget);
    });

    testWidgets('renders exclusive VAT label with rate', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: '',
          showShopInfo: false,
          previewStyle: 'thermal',
          vatMode: 'EXCLUSIVE',
          vatRate: 7.0,
        ),
      );

      expect(find.textContaining('7.0%'), findsOneWidget);
    });

    testWidgets('hides note row when note is empty', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: '',
          showShopInfo: false,
          previewStyle: 'thermal',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      );

      expect(find.byIcon(Icons.notes_outlined), findsNothing);
    });

    testWidgets('shows note row when note is not empty', (tester) async {
      await tester.pumpApp(
        const ReceiptSummaryCard(
          receiptNote: 'Thank you',
          showShopInfo: false,
          previewStyle: 'thermal',
          vatMode: 'NONE',
          vatRate: 0,
        ),
      );

      expect(find.byIcon(Icons.notes_outlined), findsOneWidget);
      expect(find.text('Thank you'), findsOneWidget);
    });
  });
}
