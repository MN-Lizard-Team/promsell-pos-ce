import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('Product', () {
    test('supports value equality', () {
      final a = tProduct;
      final b = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Test Product',
        price: 100.0,
        stock: 50,
        category: 'Drinks',
        imageUrl: null,
        isActive: true,
        createdAt: tNow,
        updatedAt: tNow,
      );
      expect(a, equals(b));
    });

    test('isInStock returns true when stock > 0', () {
      expect(tProduct.isInStock, isTrue);
    });

    test('isInStock returns false when stock == 0', () {
      expect(tInactiveProduct.isInStock, isFalse);
    });

    test('copyWith returns a new Product with updated fields', () {
      final updated = tProduct.copyWith(name: 'Updated', price: 200.0);
      expect(updated.name, 'Updated');
      expect(updated.price, 200.0);
      expect(updated.id, tProduct.id);
    });

    test('copyWith can set nullable fields to null', () {
      final withCategory = tProduct.copyWith(category: 'Food');
      expect(withCategory.category, 'Food');
      final cleared = withCategory.copyWith(category: null);
      expect(cleared.category, isNull);
    });

    test('props contains all fields', () {
      expect(tProduct.props.length, 9);
    });
  });
}
