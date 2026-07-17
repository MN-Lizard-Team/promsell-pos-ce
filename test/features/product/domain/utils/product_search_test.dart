import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_search.dart';

void main() {
  final now = DateTime(2025, 1, 1);

  Product p({
    required String id,
    required String name,
    String? sku,
    String? barcode,
    bool isActive = true,
  }) {
    return Product(
      id: id,
      name: name,
      price: Money.fromDouble(10),
      stock: 5,
      isActive: isActive,
      sku: sku,
      barcode: barcode,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('matchProducts', () {
    test('empty query returns empty', () {
      final products = [p(id: '1', name: 'Coffee')];
      expect(matchProducts(products, ''), isEmpty);
      expect(matchProducts(products, '   '), isEmpty);
    });

    test('excludes inactive by default', () {
      final products = [
        p(id: '1', name: 'Coffee', isActive: true),
        p(id: '2', name: 'Coffee Beans', isActive: false),
      ];
      final hits = matchProducts(products, 'coffee');
      expect(hits.map((h) => h.product.id), ['1']);
    });

    test('includeInactive keeps inactive', () {
      final products = [p(id: '1', name: 'Coffee', isActive: false)];
      final hits = matchProducts(products, 'coffee', includeInactive: true);
      expect(hits, hasLength(1));
    });

    test('ranks barcode exact first', () {
      final products = [
        p(id: 'name', name: '885000111'),
        p(id: 'bc', name: 'Other', barcode: '885000111'),
        p(id: 'sku', name: 'Thing', sku: '885000111'),
      ];
      final hits = matchProducts(products, '885000111');
      expect(hits.first.product.id, 'bc');
      expect(hits.first.rank, 0);
      expect(hits.first.matchField, 'barcode');
    });

    test('ranks SKU exact before name prefix', () {
      final products = [
        p(id: 'name', name: 'ABC-extra'),
        p(id: 'sku', name: 'Zed', sku: 'ABC'),
      ];
      final hits = matchProducts(products, 'ABC');
      expect(hits.first.product.id, 'sku');
      expect(hits.first.rank, 1);
    });

    test('name prefix ranks before contains', () {
      final products = [
        p(id: 'mid', name: 'My Coffee'),
        p(id: 'pre', name: 'Coffee Dark'),
      ];
      final hits = matchProducts(products, 'coffee');
      expect(hits.first.product.id, 'pre');
      expect(hits.first.rank, 2);
    });

    test('case-insensitive barcode/sku', () {
      final products = [p(id: '1', name: 'X', barcode: 'AbC123')];
      final hits = matchProducts(products, 'abc123');
      expect(hits, hasLength(1));
      expect(hits.first.rank, 0);
    });
  });

  group('resolveExactBarcodeMatches', () {
    test('matches trim and case', () {
      final products = [
        p(id: '1', name: 'A', barcode: ' 885x '),
        p(id: '2', name: 'B', barcode: 'other'),
      ];
      final hits = resolveExactBarcodeMatches(products, '885X');
      expect(hits.map((e) => e.id), ['1']);
    });

    test('returns all exact duplicates', () {
      final products = [
        p(id: '1', name: 'A', barcode: '111'),
        p(id: '2', name: 'B', barcode: '111'),
      ];
      expect(resolveExactBarcodeMatches(products, '111'), hasLength(2));
    });
  });

  group('sortProductsBySearchRank', () {
    test('orders filtered list by rank', () {
      final products = [
        p(id: 'mid', name: 'x coffee y'),
        p(id: 'exact', name: 'Other', barcode: 'COFFEE'),
      ];
      final sorted = sortProductsBySearchRank(products, 'coffee');
      expect(sorted.first.id, 'exact');
    });
  });
}
