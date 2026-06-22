// ignore_for_file: avoid_print

@Tags(['stress'])
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

import '../helpers/fake_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = createInMemoryDatabase());
  tearDown(() => db.close());

  test(
    'seed 1000 products + 5000 sales and measure load times (quick mode)',
    () async {
      const productCount = 1000;
      const salesCount = 5000;

      await _seedAndMeasure(db, productCount, salesCount);
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );

  test(
    'seed 10000 products + 50000 sales and measure load times (full mode)',
    () async {
      const productCount = 10000;
      const salesCount = 50000;

      await _seedAndMeasure(db, productCount, salesCount);
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}

Future<void> _seedAndMeasure(
  AppDatabase db,
  int productCount,
  int salesCount,
) async {
  final sw = Stopwatch()..start();

  // 1. Seed 10 categories
  final categoryIds = <String>[];
  await db.batch((b) {
    for (var i = 0; i < 10; i++) {
      final id = 'cat-stress-$i';
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
  print('  Categories seeded (10): ${sw.elapsedMilliseconds}ms');

  // 2. Seed products in batches of 500
  sw.reset();
  final productIds = <String>[];
  const batchSize = 500;
  for (var start = 0; start < productCount; start += batchSize) {
    final end = (start + batchSize).clamp(0, productCount);
    await db.batch((b) {
      for (var i = start; i < end; i++) {
        final id = 'prod-stress-$i';
        productIds.add(id);
        final catIdx = i % 10;
        b.insert(
          db.products,
          ProductsCompanion.insert(
            id: id,
            name: 'Product $i',
            price: (i % 1000) + 1.0,
            cost: Value((i % 500) + 0.5),
            stock: const Value(1000),
            categoryId: Value(categoryIds[catIdx]),
            barcode: Value('BC$i'),
            createdAt: Value(DateTime(2025, 1, 1).add(Duration(seconds: i))),
            updatedAt: Value(DateTime(2025, 1, 1).add(Duration(seconds: i))),
          ),
        );
      }
    });
  }
  print('  Products seeded ($productCount): ${sw.elapsedMilliseconds}ms');

  // 3. Seed sales in batches of 200 (each with 3 items)
  sw.reset();
  const salesBatchSize = 200;
  for (var start = 0; start < salesCount; start += salesBatchSize) {
    final end = (start + salesBatchSize).clamp(0, salesCount);
    await db.batch((b) {
      for (var s = start; s < end; s++) {
        final saleId = 'sale-stress-$s';
        final saleDate = DateTime(2025, 1, 1).add(Duration(minutes: s));

        // Pick 3 random products
        final p1Idx = (s * 7) % productCount;
        final p2Idx = (s * 13 + 1) % productCount;
        final p3Idx = (s * 17 + 2) % productCount;
        final p1 = productIds[p1Idx];
        final p2 = productIds[p2Idx];
        final p3 = productIds[p3Idx];

        final price1 = ((p1Idx % 1000) + 1).toDouble();
        final price2 = ((p2Idx % 1000) + 1).toDouble();
        final price3 = ((p3Idx % 1000) + 1).toDouble();
        final qty1 = (s % 3) + 1;
        final qty2 = (s % 5) + 1;
        final qty3 = (s % 2) + 1;
        final subtotal1 = price1 * qty1;
        final subtotal2 = price2 * qty2;
        final subtotal3 = price3 * qty3;
        final total = subtotal1 + subtotal2 + subtotal3;

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

        b.insert(
          db.saleItems,
          SaleItemsCompanion.insert(
            id: 'si-$s-1',
            saleId: saleId,
            productId: p1,
            productName: 'Product $p1Idx',
            price: price1,
            qty: qty1,
            subtotal: subtotal1,
            updatedAt: Value(saleDate),
          ),
        );
        b.insert(
          db.saleItems,
          SaleItemsCompanion.insert(
            id: 'si-$s-2',
            saleId: saleId,
            productId: p2,
            productName: 'Product $p2Idx',
            price: price2,
            qty: qty2,
            subtotal: subtotal2,
            updatedAt: Value(saleDate),
          ),
        );
        b.insert(
          db.saleItems,
          SaleItemsCompanion.insert(
            id: 'si-$s-3',
            saleId: saleId,
            productId: p3,
            productName: 'Product $p3Idx',
            price: price3,
            qty: qty3,
            subtotal: subtotal3,
            updatedAt: Value(saleDate),
          ),
        );
      }
    });
  }
  print(
    '  Sales seeded ($salesCount, ~${salesCount * 3} items): ${sw.elapsedMilliseconds}ms',
  );

  // 4. Measure product list load
  sw.reset();
  final products = await db.select(db.products).get();
  print('  ✅ Product list (${products.length}): ${sw.elapsedMilliseconds}ms');
  expect(
    sw.elapsedMilliseconds,
    lessThan(1000),
    reason: 'Product list load should be < 1s',
  );

  // 5. Measure history (sales) load
  sw.reset();
  final sales = await db.select(db.sales).get();
  print('  ✅ History list (${sales.length}): ${sw.elapsedMilliseconds}ms');
  expect(
    sw.elapsedMilliseconds,
    lessThan(1000),
    reason: 'History list load should be < 1s',
  );

  // 6. Measure report aggregation (SQL SUM — simulates real report query)
  sw.reset();
  final aggResult = await db
      .customSelect(
        'SELECT COUNT(*) AS cnt, COALESCE(SUM(subtotal), 0) AS revenue FROM sale_items',
      )
      .getSingle();
  final itemCount = aggResult.read<int>('cnt');
  final totalRevenue = aggResult.read<double>('revenue');
  print(
    '  ✅ Report aggregation ($itemCount items, revenue=$totalRevenue): ${sw.elapsedMilliseconds}ms',
  );
  expect(
    sw.elapsedMilliseconds,
    lessThan(1000),
    reason: 'Report aggregation should be < 1s',
  );
}
