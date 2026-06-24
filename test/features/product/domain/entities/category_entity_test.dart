import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

void main() {
  group('Category', () {
    final category = Category(
      id: 'c1',
      name: 'Drinks',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

    test('has default values for optional fields', () {
      expect(category.sortOrder, 0);
      expect(category.color, isNull);
      expect(category.iconName, isNull);
    });

    test('supports value equality', () {
      final a = Category(
        id: 'c1',
        name: 'Drinks',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(a, equals(category));
    });

    test('copyWith updates fields', () {
      final updated = category.copyWith(
        name: 'Food',
        color: '0xFF0000',
        iconName: 'restaurant',
        sortOrder: 2,
      );
      expect(updated.name, 'Food');
      expect(updated.color, '0xFF0000');
      expect(updated.iconName, 'restaurant');
      expect(updated.sortOrder, 2);
      expect(updated.id, 'c1');
    });

    test('copyWith preserves unchanged fields', () {
      final updated = category.copyWith(name: 'Food');
      expect(updated.id, 'c1');
      expect(updated.color, isNull);
      expect(updated.createdAt, DateTime(2025, 1, 1));
    });

    test('different categories are not equal', () {
      final other = Category(
        id: 'c2',
        name: 'Drinks',
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 1, 1),
      );
      expect(other, isNot(equals(category)));
    });
  });
}
