import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_event.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_filter_page.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockProductBloc productBloc;
  late MockCategoryBloc categoryBloc;
  final now = DateTime(2026, 1, 1);

  Product p({
    required String id,
    String name = 'P',
    String? categoryId,
    int stock = 5,
    double price = 50,
    bool active = true,
  }) => Product(
    id: id,
    name: name,
    price: Money.fromDouble(price),
    stock: stock,
    categoryId: categoryId,
    isActive: active,
    trackStock: true,
    createdAt: now,
    updatedAt: now,
  );

  setUp(() {
    productBloc = MockProductBloc();
    categoryBloc = MockCategoryBloc();
    when(() => productBloc.state).thenReturn(
      ProductState(
        status: ProductStatus.success,
        products: [
          p(id: '1', name: 'A', categoryId: 'c1', stock: 2, price: 20),
          p(id: '2', name: 'B', categoryId: 'c1', stock: 0, price: 80),
          p(id: '3', name: 'C', stock: 10, price: 40),
          p(
            id: '4',
            name: 'D',
            categoryId: 'c2',
            stock: 3,
            price: 15,
            active: false,
          ),
        ],
      ),
    );
    when(() => categoryBloc.state).thenReturn(
      CategoryState(
        status: CategoryStatus.success,
        categories: [
          Category(id: 'c1', name: 'Drinks', createdAt: now, updatedAt: now),
          Category(id: 'c2', name: 'Food', createdAt: now, updatedAt: now),
        ],
      ),
    );
    registerFallbackValue(const ProductStockFilterChanged(StockFilter.all));
    registerFallbackValue(const ProductSortChanged(ProductSort.default_));
    registerFallbackValue(const ProductPriceRangeChanged(null));
    registerFallbackValue(const ProductCategoryFilterChanged(null));
    registerFallbackValue(
      const ProductListFiltersApplied(
        stockFilter: StockFilter.all,
        productSort: ProductSort.default_,
      ),
    );
  });

  testWidgets('full page renders category and list filters', (tester) async {
    await tester.pumpApp(
      const SaleFilterPage(),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );
    expect(find.byType(SaleFilterPage), findsOneWidget);
    expect(find.byType(ListView), findsWidgets);
  });

  testWidgets('asSheet embeds SaleFilterSheet without category list', (
    tester,
  ) async {
    await tester.pumpApp(
      const SaleFilterPage(asSheet: true),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );
    expect(find.byType(SaleFilterSheet), findsOneWidget);
    expect(find.text('All Categories'), findsNothing);
    // No permanent category apology hint.
    expect(find.textContaining('Categories stay'), findsNothing);
  });

  testWidgets('stock chip live-applies ProductListFiltersApplied', (
    tester,
  ) async {
    await tester.pumpApp(
      const SaleFilterPage(asSheet: true, lowStockThreshold: 5),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );

    final lowStock = find.text('Low stock');
    expect(lowStock, findsOneWidget);
    await tester.ensureVisible(lowStock);
    await tester.tap(lowStock);
    await tester.pump(const Duration(milliseconds: 200));

    // Live apply — no need to tap Done first.
    final captured = verify(
      () => productBloc.add(captureAny(that: isA<ProductListFiltersApplied>())),
    ).captured;
    expect(captured, isNotEmpty);
    final applied = captured.last as ProductListFiltersApplied;
    expect(applied.stockFilter, StockFilter.lowStock);
    verifyNever(
      () => productBloc.add(any(that: isA<ProductCategoryFilterChanged>())),
    );
  });

  testWidgets('Done dismisses and commits once more', (tester) async {
    await tester.pumpApp(
      const SaleFilterPage(asSheet: true),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );

    clearInteractions(productBloc);

    final done = find.text('Done');
    expect(done, findsOneWidget);
    await tester.tap(done);
    await tester.pumpAndSettle();

    verify(
      () => productBloc.add(any(that: isA<ProductListFiltersApplied>())),
    ).called(1);
    expect(find.byType(SaleFilterSheet), findsNothing);
  });

  testWidgets('Clear resets and live-applies defaults', (tester) async {
    await tester.pumpApp(
      const SaleFilterPage(asSheet: true),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );

    await tester.tap(find.text('Low stock'));
    await tester.pump(const Duration(milliseconds: 200));
    clearInteractions(productBloc);

    await tester.tap(find.text('Clear'));
    await tester.pump(const Duration(milliseconds: 200));

    final captured = verify(
      () => productBloc.add(captureAny(that: isA<ProductListFiltersApplied>())),
    ).captured;
    final applied = captured.single as ProductListFiltersApplied;
    expect(applied.stockFilter, StockFilter.all);
    expect(applied.productSort, ProductSort.default_);
    expect(applied.priceRange, isNull);
  });

  testWidgets('sheet has no hand-drawn 44x4 dual handle bar', (tester) async {
    await tester.pumpApp(
      const SaleFilterPage(asSheet: true),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );
    final thinBars = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.constraints?.maxWidth == 44 &&
          w.constraints?.maxHeight == 4,
    );
    expect(thinBars, findsNothing);
  });

  testWidgets('remaining count shows active-only total', (tester) async {
    await tester.pumpApp(
      const SaleFilterPage(asSheet: true),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );
    // 3 active of 4 fixtures.
    expect(find.textContaining('3 items'), findsOneWidget);
  });

  testWidgets('price preset live-applies Money range', (tester) async {
    await tester.pumpApp(
      const SaleFilterPage(asSheet: true),
      productBloc: productBloc,
      categoryBloc: categoryBloc,
    );

    final preset = find.textContaining('≤');
    expect(preset, findsWidgets);
    await tester.tap(preset.first);
    await tester.pump(const Duration(milliseconds: 200));

    final captured = verify(
      () => productBloc.add(captureAny(that: isA<ProductListFiltersApplied>())),
    ).captured;
    final applied = captured.last as ProductListFiltersApplied;
    expect(applied.priceRange, isNotNull);
    expect(applied.priceRange!.max, Money.fromDouble(50));
    expect(applied.priceRange!.min, isNull);
  });
}
