import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/sale/data/datasources/sale_query_local_datasource.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late SaleQueryLocalDatasource query;

  setUp(() {
    db = createInMemoryDatabase();
    query = SaleQueryLocalDatasource(db);
  });

  tearDown(() => db.close());

  Future<void> seedSales(int count, {DateTime? base}) async {
    final start = base ?? DateTime(2025, 1, 1);
    await db.batch((b) {
      for (var s = 0; s < count; s++) {
        final id = 'sale-$s';
        final date = start.add(Duration(minutes: s));
        b.insert(
          db.sales,
          SalesCompanion.insert(
            id: id,
            receiptNumber: Value('R$s'),
            totalAmount: (s % 100) + 1.0,
            paymentMethod: 'cash',
            createdAt: Value(date),
            updatedAt: Value(date),
          ),
        );
        // 2 items per sale
        for (var j = 0; j < 2; j++) {
          b.insert(
            db.saleItems,
            SaleItemsCompanion.insert(
              id: 'si-$s-$j',
              saleId: id,
              productId: 'p-$j',
              productName: 'Product $j',
              price: 10.0,
              qty: j + 1,
              subtotal: 10.0 * (j + 1),
              updatedAt: Value(date),
            ),
          );
        }
      }
    });
  }

  group('querySalesPage cursor pagination', () {
    test('first page returns correct size and totalCount', () async {
      await seedSales(120);
      final page = await query.querySalesPage(pageSize: 50);
      expect(page.sales, hasLength(50));
      expect(page.totalCount, 120);
      expect(page.hasMore, isTrue);
      // Items hydrated only for the 50 sales on the page.
      expect(page.sales.first.items, hasLength(2));
    });

    test('pages cover all rows without overlap', () async {
      await seedSales(120);
      final seen = <String>{};
      SaleCursor? cursor;
      while (true) {
        final page = await query.querySalesPage(cursor: cursor, pageSize: 50);
        for (final s in page.sales) {
          expect(seen, isNot(contains(s.id)), reason: 'duplicate ${s.id}');
          seen.add(s.id);
        }
        cursor = page.nextCursor;
        if (!page.hasMore) break;
      }
      expect(seen, hasLength(120));
    });

    test('date range filters before pagination', () async {
      await seedSales(120);
      final from = DateTime(2025, 1, 1, 0, 30);
      final to = DateTime(2025, 1, 1, 1, 30);
      final page = await query.querySalesPage(from: from, to: to, pageSize: 50);
      expect(page.totalCount, 61); // 30..90 inclusive = 61 sales
      expect(page.sales, hasLength(50));
      expect(page.hasMore, isTrue);
    });

    test('last page has hasMore=false', () async {
      await seedSales(60);
      final first = await query.querySalesPage(pageSize: 50);
      final second = await query.querySalesPage(
        cursor: first.nextCursor,
        pageSize: 50,
      );
      expect(second.sales, hasLength(10));
      expect(second.hasMore, isFalse);
      expect(second.nextCursor, isNull);
    });

    test('querySalesCount matches total', () async {
      await seedSales(75);
      expect(await query.querySalesCount(), 75);
      final from = DateTime(2025, 1, 1, 0, 30);
      final to = DateTime(2025, 1, 1, 1, 0);
      expect(await query.querySalesCount(from: from, to: to), 31);
    });
  });
}
