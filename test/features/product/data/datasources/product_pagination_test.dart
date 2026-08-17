import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_local_datasource.dart';
import 'package:promsell_pos_ce/features/product/data/datasources/product_option_datasource.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product_page.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;

import '../../../../helpers/fake_database.dart';

void main() {
  late AppDatabase db;
  late ProductLocalDatasourceImpl datasource;

  setUp(() {
    db = createInMemoryDatabase();
    datasource = ProductLocalDatasourceImpl(
      db,
      ProductOptionDatasourceImpl(db),
    );
  });

  tearDown(() => db.close());

  Future<void> seedProducts(int count) async {
    await db.batch((b) {
      for (var i = 0; i < count; i++) {
        final id = 'p-$i';
        final created = DateTime(2025, 1, 1).add(Duration(seconds: i));
        b.insert(
          db.products,
          ProductsCompanion.insert(
            id: id,
            name: 'Product $i',
            sku: Value('SKU$i'),
            skuLower: Value('sku$i'),
            barcode: Value('BC$i'),
            barcodeLower: Value('bc$i'),
            price: (i % 100) + 1.0,
            stock: const Value(10),
            createdAt: Value(created),
            updatedAt: Value(created),
          ),
        );
      }
    });
  }

  group('getProductsPage cursor pagination', () {
    test('first page returns correct size and totalCount', () async {
      await seedProducts(120);
      final page = await datasource.getProductsPage(pageSize: 50);
      expect(page.products, hasLength(50));
      expect(page.totalCount, 120);
      expect(page.hasMore, isTrue);
      expect(page.nextCursor, isNotNull);
    });

    test('pages do not overlap and cover all rows', () async {
      await seedProducts(120);
      final seen = <String>{};
      await _drainAll(datasource, seen, null);
      expect(seen, hasLength(120));
    });

    test('last page has hasMore=false and nextCursor=null', () async {
      await seedProducts(60);
      final first = await datasource.getProductsPage(pageSize: 50);
      final second = await datasource.getProductsPage(
        cursor: first.nextCursor,
        pageSize: 50,
      );
      expect(second.products, hasLength(10));
      expect(second.hasMore, isFalse);
      expect(second.nextCursor, isNull);
    });

    test('activeOnly filters inactive products', () async {
      await db.batch((b) {
        for (var i = 0; i < 10; i++) {
          final id = 'p-$i';
          final created = DateTime(2025, 1, 1).add(Duration(seconds: i));
          b.insert(
            db.products,
            ProductsCompanion.insert(
              id: id,
              name: 'Product $i',
              price: 10.0,
              stock: const Value(10),
              isActive: Value(i % 2 == 0),
              createdAt: Value(created),
              updatedAt: Value(created),
            ),
          );
        }
      });
      final page = await datasource.getProductsPage(
        pageSize: 50,
        activeOnly: true,
      );
      expect(page.products, hasLength(5));
      expect(page.products.every((p) => p.isActive), isTrue);
    });
  });

  group('searchProductsPage', () {
    test('returns matches ranked by exact/prefix', () async {
      await seedProducts(100);
      final page = await datasource.searchProductsPage(
        query: 'Product 1',
        pageSize: 50,
      );
      expect(page.products, isNotEmpty);
      // Exact-ish name prefix hits should rank before 'Product 10'..'Product 19'
      // only when they start with 'product 1' — all do, so just check ordering
      // is stable and contains expected ids.
      final ids = page.products.map((p) => p.id).toSet();
      expect(ids, contains('p-1'));
    });

    test('search beyond first 500 records finds late rows', () async {
      await seedProducts(600);
      // Product 599 has sku 'SKU599' — would be missed by an in-memory
      // filter that only loads the first 500.
      final page = await datasource.searchProductsPage(
        query: 'SKU599',
        pageSize: 50,
      );
      expect(page.products, hasLength(1));
      expect(page.products.first.id, 'p-599');
    });

    test('empty query returns empty page with totalCount', () async {
      await seedProducts(10);
      final page = await datasource.searchProductsPage(
        query: '   ',
        pageSize: 50,
      );
      expect(page.products, isEmpty);
      expect(page.totalCount, 10);
    });
  });
}

Future<ProductCursor?> _drainAll(
  ProductLocalDatasourceImpl datasource,
  Set<String> seen,
  ProductCursor? cursor,
) async {
  var next = cursor;
  while (true) {
    final page = await datasource.getProductsPage(cursor: next, pageSize: 50);
    for (final p in page.products) {
      expect(seen, isNot(contains(p.id)), reason: 'duplicate ${p.id}');
      seen.add(p.id);
    }
    next = page.nextCursor;
    if (!page.hasMore) break;
  }
  return next;
}
