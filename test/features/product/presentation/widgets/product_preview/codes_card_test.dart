import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/codes_card.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('CodesCard', () {
    testWidgets('renders N/A when SKU and barcode are null', (tester) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: Money.fromDouble(50),
            stock: 10,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('N/A'), findsNWidgets(2));
    });

    testWidgets('renders SKU when available', (tester) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: Money.fromDouble(50),
            stock: 10,
            sku: 'SKU123',
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('SKU123'), findsOneWidget);
    });

    testWidgets('renders barcode when available', (tester) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: Money.fromDouble(50),
            stock: 10,
            barcode: '1234567890',
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('1234567890'), findsNWidgets(2));
      // 10 digits → Code 128 (not EAN-13)
      expect(find.text('Code 128'), findsWidgets);
      expect(
        find.byKey(const ValueKey('codes-card-barcode-type')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('preview-barcode-type-chip')),
        findsOneWidget,
      );
    });

    testWidgets('shows EAN-13 type for 13-digit barcode', (tester) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: Money.fromDouble(50),
            stock: 10,
            barcode: '1234567890123',
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('EAN-13'), findsWidgets);
    });

    testWidgets('card title shows SKU & Barcode not just SKU (P7)', (
      tester,
    ) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: Money.fromDouble(50),
            stock: 10,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.text('SKU & Barcode'), findsOneWidget);
    });

    testWidgets('barcode image wrapped in frame container (U8)', (
      tester,
    ) async {
      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: Money.fromDouble(50),
            stock: 10,
            barcode: '1234567890',
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsNothing);
      expect(find.text('1234567890'), findsWidgets);
    });

    testWidgets('shows generate barcode CTA when barcode is missing', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpApp(
        CodesCard(
          product: Product(
            id: 'p1',
            name: 'Test',
            price: Money.fromDouble(50),
            stock: 10,
            isActive: true,
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          onGenerateBarcode: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Generate Barcode'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
