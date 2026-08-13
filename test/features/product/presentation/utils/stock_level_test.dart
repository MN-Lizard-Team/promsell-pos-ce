import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/utils/stock_level.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  Product product({int stock = 3, bool track = true}) => Product(
    id: 'p',
    name: 'P',
    price: Money.fromDouble(1),
    stock: stock,
    isActive: true,
    trackStock: track,
    createdAt: now,
    updatedAt: now,
  );

  test('isProductLowStock respects trackStock and threshold', () {
    expect(isProductLowStock(product(stock: 3), lowStockThreshold: 5), isTrue);
    expect(isProductLowStock(product(stock: 0), lowStockThreshold: 5), isFalse);
    expect(
      isProductLowStock(product(stock: 3, track: false), lowStockThreshold: 5),
      isFalse,
    );
    // threshold < 1 clamps to 1 → only stock==1 is low
    expect(isProductLowStock(product(stock: 1), lowStockThreshold: 0), isTrue);
    expect(isProductLowStock(product(stock: 3), lowStockThreshold: 0), isFalse);
  });

  test('isStockQtyLow', () {
    expect(isStockQtyLow(2, lowStockThreshold: 5), isTrue);
    expect(isStockQtyLow(0, lowStockThreshold: 5), isFalse);
    expect(isStockQtyLow(2, lowStockThreshold: 5, trackStock: false), isFalse);
  });

  test('isProductOutOfStock', () {
    expect(isProductOutOfStock(product(stock: 0)), isTrue);
    expect(isProductOutOfStock(product(stock: 1)), isFalse);
    expect(isProductOutOfStock(product(stock: 0, track: false)), isFalse);
  });
}
