import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/stock_tab.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockWatchInventoryLogs mockWatchInventoryLogs;

  setUp(() {
    mockWatchInventoryLogs = MockWatchInventoryLogs();
    when(
      () => mockWatchInventoryLogs(productId: any(named: 'productId')),
    ).thenAnswer((_) => const Stream.empty());
  });

  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(80),
    cost: Money.fromDouble(50),
    stock: 10,
    isActive: true,
    trackStock: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2025, 1, 1),
  );

  group('StockTab', () {
    testWidgets('renders quantity and in-stock status', (tester) async {
      await tester.pumpApp(
        StockTab(
          product: product,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
        ),
      );

      expect(find.textContaining('10'), findsWidgets);
      expect(find.textContaining('In stock'), findsOneWidget);
    });

    testWidgets('renders low stock status when stock <= 5', (tester) async {
      final lowStockProduct = product.copyWith(stock: 3);
      await tester.pumpApp(
        StockTab(
          product: lowStockProduct,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
        ),
      );

      expect(find.textContaining('Low stock'), findsOneWidget);
    });

    testWidgets('renders out of stock status when stock == 0', (tester) async {
      final outOfStockProduct = product.copyWith(stock: 0);
      await tester.pumpApp(
        StockTab(
          product: outOfStockProduct,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
        ),
      );

      expect(find.textContaining('Out of stock'), findsOneWidget);
    });

    testWidgets('renders tracking disabled when trackStock is false', (
      tester,
    ) async {
      final noTrackProduct = product.copyWith(trackStock: false);
      await tester.pumpApp(
        StockTab(
          product: noTrackProduct,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
        ),
      );

      // Matches product form edit stock-tab copy.
      expect(find.textContaining('tracking'), findsWidgets);
    });

    testWidgets('shows adjust stock button when callback provided', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpApp(
        StockTab(
          product: product,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
          onAdjustStock: () => tapped = true,
        ),
      );

      final button = find.byKey(const ValueKey('product-preview-adjust-stock'));
      expect(button, findsOneWidget);
      await tester.tap(button);
      expect(tapped, isTrue);
    });

    testWidgets('renders stock value when cost > 0 and trackStock', (
      tester,
    ) async {
      await tester.pumpApp(
        StockTab(
          product: product,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
        ),
      );

      expect(find.text('Stock Value'), findsWidgets);
    });

    testWidgets('hides stock value section when trackStock is false', (
      tester,
    ) async {
      final noTrackProduct = product.copyWith(trackStock: false);
      await tester.pumpApp(
        StockTab(
          product: noTrackProduct,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
        ),
      );

      expect(find.text('Stock Value'), findsNothing);
    });

    testWidgets('renders recent moves from stream', (tester) async {
      final logs = [
        InventoryLog(
          id: 'log1',
          productId: 'p1',
          type: 'SALE',
          qtyChange: -2,
          balanceAfter: 8,
          reason: null,
          createdAt: DateTime(2025, 1, 3),
        ),
      ];
      when(
        () => mockWatchInventoryLogs(productId: 'p1'),
      ).thenAnswer((_) => Stream.value(logs));

      await tester.pumpApp(
        StockTab(
          product: product,
          currency: '฿',
          watchInventoryLogs: mockWatchInventoryLogs,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Total Sold'), findsOneWidget);
    });
  });
}
