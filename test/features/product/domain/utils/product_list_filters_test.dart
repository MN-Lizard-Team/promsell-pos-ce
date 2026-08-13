import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/domain/utils/product_list_filters.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  Product p({
    required String id,
    String name = 'P',
    String? categoryId,
    int stock = 5,
    double price = 50,
    bool active = true,
    bool trackStock = true,
  }) => Product(
    id: id,
    name: name,
    price: Money.fromDouble(price),
    stock: stock,
    categoryId: categoryId,
    isActive: active,
    trackStock: trackStock,
    createdAt: now,
    updatedAt: now,
  );

  final catalog = [
    p(id: '1', name: 'A', categoryId: 'c1', stock: 2, price: 20),
    p(id: '2', name: 'B', categoryId: 'c1', stock: 0, price: 80),
    p(id: '3', name: 'C', stock: 10, price: 40),
    p(id: '4', name: 'D', categoryId: 'c2', stock: 3, price: 15, active: false),
  ];

  test('activeOnly excludes inactive', () {
    final out = applyProductListFilters(
      catalog,
      const ProductListFilterSpec(activeOnly: true),
    );
    expect(out.map((e) => e.id), ['1', '2', '3']);
  });

  test('low stock uses threshold and trackStock', () {
    final out = applyProductListFilters(
      catalog,
      const ProductListFilterSpec(
        stockFilter: StockFilter.lowStock,
        lowStockThreshold: 5,
        activeOnly: true,
      ),
    );
    expect(out.map((e) => e.id), ['1']);
  });

  test('price range uses Money compare (satang)', () {
    final out = applyProductListFilters(
      catalog,
      ProductListFilterSpec(
        priceRange: PriceRange(
          min: Money.fromDouble(20),
          max: Money.fromDouble(40),
        ),
        activeOnly: true,
      ),
    );
    expect(out.map((e) => e.id), ['1', '3']);
  });

  test('normalized swaps inverted min/max', () {
    final range = PriceRange(
      min: Money.fromDouble(100),
      max: Money.fromDouble(10),
    ).normalized();
    expect(range.min, Money.fromDouble(10));
    expect(range.max, Money.fromDouble(100));
  });

  test('sort price low-high', () {
    final out = applyProductListFilters(
      catalog,
      const ProductListFilterSpec(
        productSort: ProductSort.priceLowHigh,
        activeOnly: true,
      ),
    );
    expect(out.map((e) => e.id), ['1', '3', '2']);
  });

  test('category none sentinel', () {
    final out = applyProductListFilters(
      catalog,
      const ProductListFilterSpec(
        categoryFilter: kNoCategoryFilter,
        activeOnly: true,
      ),
    );
    expect(out.map((e) => e.id), ['3']);
  });
}
