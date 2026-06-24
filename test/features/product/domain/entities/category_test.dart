import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';

void main() {
  final tNow = DateTime(2025, 1, 15, 10, 30);

  final tCategory = Category(
    id: 'cat-001',
    name: 'Drinks',
    sortOrder: 1,
    color: '#FF5733',
    iconName: 'local_drink',
    createdAt: tNow,
    updatedAt: tNow,
  );

  group('Category', () {
    test('has correct default values', () {
      final cat = Category(
        id: 'cat-002',
        name: 'Food',
        createdAt: tNow,
        updatedAt: tNow,
      );

      expect(cat.sortOrder, 0);
      expect(cat.color, isNull);
      expect(cat.iconName, isNull);
    });

    test('equality works correctly', () {
      final cat2 = Category(
        id: 'cat-001',
        name: 'Drinks',
        sortOrder: 1,
        color: '#FF5733',
        iconName: 'local_drink',
        createdAt: tNow,
        updatedAt: tNow,
      );

      expect(tCategory, equals(cat2));
    });

    test('inequality when name differs', () {
      final cat2 = tCategory.copyWith(name: 'Snacks');

      expect(tCategory, isNot(equals(cat2)));
    });

    test('inequality when sortOrder differs', () {
      final cat2 = tCategory.copyWith(sortOrder: 2);

      expect(tCategory, isNot(equals(cat2)));
    });

    test('copyWith preserves unchanged fields', () {
      final cat2 = tCategory.copyWith(name: 'Beverages');

      expect(cat2.id, 'cat-001');
      expect(cat2.name, 'Beverages');
      expect(cat2.sortOrder, 1);
      expect(cat2.color, '#FF5733');
      expect(cat2.iconName, 'local_drink');
      expect(cat2.createdAt, tNow);
      expect(cat2.updatedAt, tNow);
    });

    test('copyWith updates all specified fields', () {
      final later = DateTime(2025, 2, 1);
      final cat2 = tCategory.copyWith(
        id: 'cat-003',
        name: 'Desserts',
        sortOrder: 5,
        color: '#00FF00',
        iconName: 'cake',
        createdAt: later,
        updatedAt: later,
      );

      expect(cat2.id, 'cat-003');
      expect(cat2.name, 'Desserts');
      expect(cat2.sortOrder, 5);
      expect(cat2.color, '#00FF00');
      expect(cat2.iconName, 'cake');
      expect(cat2.createdAt, later);
      expect(cat2.updatedAt, later);
    });

    test('props exclude createdAt and updatedAt', () {
      final catWithDiffDates = Category(
        id: 'cat-001',
        name: 'Drinks',
        sortOrder: 1,
        color: '#FF5733',
        iconName: 'local_drink',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 6, 1),
      );

      expect(tCategory, equals(catWithDiffDates));
    });
  });
}
