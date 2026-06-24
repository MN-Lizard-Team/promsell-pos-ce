import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_badge.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/stock_indicator.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('StockBadge', () {
    testWidgets('renders error icon for out of stock', (tester) async {
      await tester.pumpApp(const StockBadge(stock: 0));
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renders warning icon for low stock', (tester) async {
      await tester.pumpApp(const StockBadge(stock: 5));
      expect(find.byIcon(Icons.warning_amber), findsOneWidget);
    });

    testWidgets('renders check icon for in stock', (tester) async {
      await tester.pumpApp(const StockBadge(stock: 100));
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });
  });

  group('StockIndicator', () {
    testWidgets('renders N/A when not tracking stock', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 10, trackStock: false));
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    });

    testWidgets('renders out of stock when stock is 0', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 0));
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('renders warning for low stock', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 3));
      expect(find.byIcon(Icons.warning), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders check for in stock', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 50));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('compact mode renders without container', (tester) async {
      await tester.pumpApp(const StockIndicator(stock: 10, compact: true));
      expect(find.byType(Container), findsNothing);
    });
  });
}
