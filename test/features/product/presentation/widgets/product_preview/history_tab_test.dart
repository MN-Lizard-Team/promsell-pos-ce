import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/inventory/domain/entities/inventory_log.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_preview/history_tab.dart';

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

  group('HistoryTab', () {
    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      when(
        () => mockWatchInventoryLogs(productId: 'p1'),
      ).thenAnswer((_) => const Stream.empty());

      await tester.pumpApp(
        HistoryTab(productId: 'p1', watchInventoryLogs: mockWatchInventoryLogs),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows AppEmptyState when no logs', (tester) async {
      when(
        () => mockWatchInventoryLogs(productId: 'p1'),
      ).thenAnswer((_) => Stream.value([]));

      await tester.pumpApp(
        HistoryTab(productId: 'p1', watchInventoryLogs: mockWatchInventoryLogs),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
    });

    testWidgets('renders log list with correct icons', (tester) async {
      final logs = [
        InventoryLog(
          id: 'log1',
          productId: 'p1',
          type: 'SALE',
          qtyChange: -2,
          balanceAfter: 8,
          reason: 'Test sale',
          createdAt: DateTime(2025, 1, 3, 10, 30),
        ),
        InventoryLog(
          id: 'log2',
          productId: 'p1',
          type: 'ADJUSTMENT_IN',
          qtyChange: 5,
          balanceAfter: 13,
          reason: null,
          createdAt: DateTime(2025, 1, 4, 11, 0),
        ),
      ];
      when(
        () => mockWatchInventoryLogs(productId: 'p1'),
      ).thenAnswer((_) => Stream.value(logs));

      await tester.pumpApp(
        HistoryTab(productId: 'p1', watchInventoryLogs: mockWatchInventoryLogs),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
      expect(find.text('Test sale'), findsOneWidget);
    });

    testWidgets('shows error state with retry on failure', (tester) async {
      when(
        () => mockWatchInventoryLogs(productId: 'p1'),
      ).thenAnswer((_) => Stream.error(Exception('DB error')));

      await tester.pumpApp(
        HistoryTab(productId: 'p1', watchInventoryLogs: mockWatchInventoryLogs),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppEmptyState), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
