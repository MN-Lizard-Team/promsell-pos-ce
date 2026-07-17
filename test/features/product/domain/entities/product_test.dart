import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('Product', () {
    test('supports value equality', () {
      final a = tProduct;
      final b = Product(
        id: 'prod-0001-0001-0001-000000000001',
        name: 'Test Product',
        price: Money.fromDouble(100.0),
        stock: 50,
        categoryId: 'Drinks',
        imageUrl: null,
        imagePath: null,
        imageThumbnailPath: null,
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
      final updated = tProduct.copyWith(
        name: 'Updated',
        price: Money.fromDouble(200.0),
      );
      expect(updated.name, 'Updated');
      expect(updated.price.value, 200.0);
      expect(updated.id, tProduct.id);
    });

    test('copyWith can set nullable fields to null', () {
      final withCategory = tProduct.copyWith(categoryId: 'Food');
      expect(withCategory.category, 'Food');
      final cleared = withCategory.copyWith(categoryId: null);
      expect(cleared.category, isNull);
    });

    test('props contains all fields', () {
      expect(tProduct.props.length, 22);
    });

    test('description is null by default', () {
      expect(tProduct.description, isNull);
    });

    test('copyWith updates description', () {
      final withDesc = tProduct.copyWith(description: 'A test product');
      expect(withDesc.description, 'A test product');
    });

    test('copyWith can set description to null', () {
      final withDesc = tProduct.copyWith(description: 'A test product');
      final cleared = withDesc.copyWith(description: null);
      expect(cleared.description, isNull);
    });
  });
}
