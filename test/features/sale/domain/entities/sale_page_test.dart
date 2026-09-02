import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_page.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  final cursorTime = DateTime(2026, 9, 1, 12);

  group('SaleCursor', () {
    test('equal cursors with identical fields are equal', () {
      final a = SaleCursor(createdAt: cursorTime, id: 'sale-1');
      final b = SaleCursor(createdAt: cursorTime, id: 'sale-1');

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different id means inequality', () {
      final a = SaleCursor(createdAt: cursorTime, id: 'sale-1');
      final b = SaleCursor(createdAt: cursorTime, id: 'sale-2');

      expect(a, isNot(equals(b)));
    });

    test('different createdAt means inequality', () {
      final a = SaleCursor(createdAt: cursorTime, id: 'sale-1');
      final b = SaleCursor(
        createdAt: cursorTime.add(const Duration(minutes: 1)),
        id: 'sale-1',
      );

      expect(a, isNot(equals(b)));
    });
  });

  group('SalePage', () {
    test('hasMore is true only when nextCursor exists', () {
      final withCursor = SalePage(
        sales: const [],
        nextCursor: SaleCursor(createdAt: cursorTime, id: 'sale-1'),
        totalCount: 1,
      );
      const withoutCursor = SalePage(
        sales: [],
        nextCursor: null,
        totalCount: 0,
      );

      expect(withCursor.hasMore, isTrue);
      expect(withoutCursor.hasMore, isFalse);
    });

    test('equal pages with identical fields are equal', () {
      final a = SalePage(
        sales: [tSale],
        nextCursor: SaleCursor(createdAt: cursorTime, id: 'sale-1'),
        totalCount: 5,
      );
      final b = SalePage(
        sales: [tSale],
        nextCursor: SaleCursor(createdAt: cursorTime, id: 'sale-1'),
        totalCount: 5,
      );

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('different totalCount means inequality', () {
      final a = SalePage(sales: [tSale], nextCursor: null, totalCount: 5);
      final b = SalePage(sales: [tSale], nextCursor: null, totalCount: 6);

      expect(a, isNot(equals(b)));
    });
  });
}
