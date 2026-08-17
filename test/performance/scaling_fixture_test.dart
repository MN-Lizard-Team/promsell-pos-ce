// ignore_for_file: avoid_print

import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';

import '../helpers/scaling_fixture.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('scaling_fixture_test_');
    registerFakePathProvider(tempDir);
    db = createFileBackedDatabase(tempDir);
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('scaling fixture seeds and counts match', () async {
    final sw = Stopwatch()..start();
    final counts = await seedScalingFixture(
      db,
      productCount: 200,
      saleCount: 500,
      saleItemCount: 1500,
      inventoryLogCount: 300,
    );
    print('  Seeded $counts in ${sw.elapsedMilliseconds}ms');

    final productCount = await db.products.count().getSingle();
    expect(productCount, counts.products);

    final saleCount = await db.sales.count().getSingle();
    expect(saleCount, counts.sales);

    final itemCount = await db.saleItems.count().getSingle();
    expect(itemCount, counts.saleItems);

    final logCount = await db.inventoryLogs.count().getSingle();
    expect(logCount, counts.inventoryLogs);
  });

  test(
    'baseline fixture sizes are reachable',
    () async {
      final sw = Stopwatch()..start();
      final counts = await seedScalingFixture(
        db,
        productCount: kBaselineProductCount,
        saleCount: kBaselineSaleCount,
        saleItemCount: kBaselineSaleItemCount,
        inventoryLogCount: kBaselineInventoryLogCount,
      );
      print('  Baseline seeded $counts in ${sw.elapsedMilliseconds}ms');

      expect(counts.products, kBaselineProductCount);
      expect(counts.sales, kBaselineSaleCount);
      expect(counts.saleItems, kBaselineSaleItemCount);
      expect(counts.inventoryLogs, kBaselineInventoryLogCount);

      // Spot-check: products span both years of the 2-year window.
      final firstCreated =
          await (db.select(db.products)
                ..orderBy([(p) => OrderingTerm.asc(p.createdAt)])
                ..limit(1))
              .getSingle();
      final lastCreated =
          await (db.select(db.products)
                ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
                ..limit(1))
              .getSingle();
      expect(firstCreated.createdAt.year, lessThanOrEqualTo(2024));
      expect(lastCreated.createdAt.year, greaterThanOrEqualTo(2025));
    },
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
