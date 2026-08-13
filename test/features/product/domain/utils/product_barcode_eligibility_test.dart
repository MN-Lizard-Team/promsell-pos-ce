import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_barcode_eligibility.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  Product p({String? barcode}) => Product(
    id: '1',
    name: 'X',
    barcode: barcode,
    price: Money.fromDouble(10),
    stock: 1,
    isActive: true,
    trackStock: true,
    createdAt: now,
    updatedAt: now,
  );

  test('productNeedsBarcode true for null and blank', () {
    expect(productNeedsBarcode(p()), isTrue);
    expect(productNeedsBarcode(p(barcode: '')), isTrue);
    expect(productNeedsBarcode(p(barcode: '   ')), isTrue);
  });

  test('productNeedsBarcode false when set', () {
    expect(productNeedsBarcode(p(barcode: '123')), isFalse);
  });

  test('countProductsNeedingBarcode', () {
    expect(
      countProductsNeedingBarcode([p(), p(barcode: '1'), p(barcode: '  ')]),
      2,
    );
  });
}
