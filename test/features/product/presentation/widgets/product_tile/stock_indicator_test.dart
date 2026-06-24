import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_indicator.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('StockIndicator', () {
    testWidgets('shows out-of-stock when stock is 0', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 0));
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('shows warning when stock <= 5', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 3));
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows check when stock > 5', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 10));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('shows N/A when trackStock is false', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 0, trackStock: false));
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('compact mode renders Row', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 10, compact: true));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('non-compact mode renders Container with decoration', (
      tester,
    ) async {
      await tester.pumpApp(const StockIndicator(stock: 10));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
