// ignore_for_file: avoid_print

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

import '../helpers/fake_database.dart';

/// Lightweight DB performance benchmarks that run on CI (non-stress).
/// Validates query performance with realistic dataset sizes.
void main() {
  late AppDatabase db;

  setUp(() => db = createInMemoryDatabase());
  tearDown(() => db.close());

  test(
    'benchmark: seed 200 products + 1000 sales, query under threshold',
    () async {
      final sw = Stopwatch()..start();

      // Seed 5 categories
      final categoryIds = <String>[];
      await db.batch((b) {
        for (var i = 0; i < 5; i++) {
          final id = 'cat-bench-$i';
          categoryIds.add(id);
          b.insert(
            db.categories,
            CategoriesCompanion.insert(
              id: id,
              name: 'Category $i',
              sortOrder: Value(i),
            ),
          );
        }
      });
      print('  Categories seeded (5): ${sw.elapsedMilliseconds}ms');

      // Seed 200 products
      sw.reset();
      final productIds = <String>[];
      await db.batch((b) {
        for (var i = 0; i < 200; i++) {
          final id = 'prod-bench-$i';
          productIds.add(id);
          b.insert(
            db.products,
            ProductsCompanion.insert(
              id: id,
              name: 'Product $i',
              price: (i % 100) + 1.0,
              cost: Value((i % 50) + 0.5),
              stock: const Value(100),
              categoryId: Value(categoryIds[i % 5]),
              barcode: Value('BC$i'),
              createdAt: Value(DateTime(2025, 1, 1).add(Duration(seconds: i))),
              updatedAt: Value(DateTime(2025, 1, 1).add(Duration(seconds: i))),
            ),
          );
        }
      });
      print('  Products seeded (200): ${sw.elapsedMilliseconds}ms');
      expect(
        sw.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Seeding 200 products should be < 2s',
      );

      // Seed 1000 sales with 3 items each
      sw.reset();
      await db.batch((b) {
        for (var s = 0; s < 1000; s++) {
          final saleId = 'sale-bench-$s';
          final saleDate = DateTime(2025, 1, 1).add(Duration(minutes: s));

          final p1Idx = (s * 7) % 200;
          final p2Idx = (s * 13 + 1) % 200;
          final p3Idx = (s * 17 + 2) % 200;

          final price1 = ((p1Idx % 100) + 1).toDouble();
          final price2 = ((p2Idx % 100) + 1).toDouble();
          final price3 = ((p3Idx % 100) + 1).toDouble();
          final qty1 = (s % 3) + 1;
          final qty2 = (s % 5) + 1;
          final qty3 = (s % 2) + 1;
          final total = price1 * qty1 + price2 * qty2 + price3 * qty3;

          b.insert(
            db.sales,
            SalesCompanion.insert(
              id: saleId,
              receiptNumber: Value('R$s'),
              totalAmount: total,
              subtotalAmount: Value(total),
              paymentMethod: 'cash',
              amountReceived: Value(total),
              createdAt: Value(saleDate),
              updatedAt: Value(saleDate),
            ),
          );

          for (var j = 0; j < 3; j++) {
            final pIdx = [p1Idx, p2Idx, p3Idx][j];
            final price = [price1, price2, price3][j];
            final qty = [qty1, qty2, qty3][j];
            b.insert(
              db.saleItems,
              SaleItemsCompanion.insert(
                id: 'si-$s-$j',
                saleId: saleId,
                productId: productIds[pIdx],
                productName: 'Product $pIdx',
                price: price,
                qty: qty,
                subtotal: price * qty,
                updatedAt: Value(saleDate),
              ),
            );
          }
        }
      });
      print('  Sales seeded (1000, ~3000 items): ${sw.elapsedMilliseconds}ms');
      expect(
        sw.elapsedMilliseconds,
        lessThan(5000),
        reason: 'Seeding 1000 sales should be < 5s',
      );

      // Benchmark: product list query
      sw.reset();
      final products = await db.select(db.products).get();
      print(
        '  ✅ Product list (${products.length}): ${sw.elapsedMilliseconds}ms',
      );
      expect(
        sw.elapsedMilliseconds,
        lessThan(200),
        reason: 'Product list query (200 rows) should be < 200ms',
      );

      // Benchmark: sales history query
      sw.reset();
      final sales = await db.select(db.sales).get();
      print('  ✅ History list (${sales.length}): ${sw.elapsedMilliseconds}ms');
      expect(
        sw.elapsedMilliseconds,
        lessThan(300),
        reason: 'History query (1000 rows) should be < 300ms',
      );

      // Benchmark: report aggregation
      sw.reset();
      final aggResult = await db
          .customSelect(
            'SELECT COUNT(*) AS cnt, COALESCE(SUM(subtotal), 0) AS revenue '
            'FROM sale_items',
          )
          .getSingle();
      final itemCount = aggResult.read<int>('cnt');
      final totalRevenue = aggResult.read<double>('revenue');
      print(
        '  ✅ Report aggregation ($itemCount items, revenue=$totalRevenue): '
        '${sw.elapsedMilliseconds}ms',
      );
      expect(
        sw.elapsedMilliseconds,
        lessThan(200),
        reason: 'Report aggregation (3000 items) should be < 200ms',
      );
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
