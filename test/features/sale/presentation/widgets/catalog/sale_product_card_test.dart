import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/category.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/category/category_cue.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_product_card.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockCategoryBloc mockCategoryBloc;

  final tNow = DateTime(2025, 1, 1);

  final drinks = Category(
    id: 'c1',
    name: 'Drinks',
    color: '#0D9488',
    iconName: 'local_cafe',
    createdAt: tNow,
    updatedAt: tNow,
  );

  final product = Product(
    id: 'p1',
    name: 'Coffee',
    price: Money.fromDouble(50),
    stock: 10,
    isActive: true,
    createdAt: tNow,
    updatedAt: tNow,
  );

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockCategoryBloc = MockCategoryBloc();
    when(() => mockCartBloc.state).thenReturn(const CartState());
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
  });

  Future<void> pumpCard(WidgetTester tester, Product p, {bool isGrid = false}) {
    return tester.pumpApp(
      SizedBox(
        height: isGrid ? 200 : 92,
        width: isGrid ? 160 : 400,
        child: SaleProductCard(product: p, currency: '฿', isGrid: isGrid),
      ),
      cartBloc: mockCartBloc,
      settingsCubit: mockSettingsCubit,
      categoryBloc: mockCategoryBloc,
    );
  }

  group('SaleProductCard', () {
    testWidgets('renders product name and price', (tester) async {
      await pumpCard(tester, product);

      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('renders out of stock product dimmed', (tester) async {
      final outOfStock = product.copyWith(stock: 0);
      await pumpCard(tester, outOfStock);

      // OOS products are wrapped in ColorFiltered (grayscale) + badge.
      expect(find.byType(ColorFiltered), findsOneWidget);
      expect(find.text('Out of stock'), findsOneWidget);
    });

    testWidgets('shows SKU meta when sku present (preferred over category)', (
      tester,
    ) async {
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: [drinks]),
      );
      final withSku = product.copyWith(sku: 'COF-001', categoryId: 'c1');
      await pumpCard(tester, withSku);

      expect(find.textContaining('COF-001'), findsOneWidget);
      expect(find.byType(CategoryCue), findsNothing);
    });

    testWidgets('shows category cue when no sku', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: [drinks]),
      );
      final withCat = product.copyWith(categoryId: 'c1');
      await pumpCard(tester, withCat);

      expect(find.byType(CategoryCue), findsOneWidget);
      expect(find.text('Drinks'), findsOneWidget);
    });

    testWidgets('list height 92 does not overflow with meta', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: [drinks]),
      );
      final withSku = product.copyWith(sku: 'COF-001', categoryId: 'c1');
      await pumpCard(tester, withSku);

      expect(tester.takeException(), isNull);
    });

    testWidgets('grid renders with meta without exception', (tester) async {
      when(() => mockCategoryBloc.state).thenReturn(
        CategoryState(status: CategoryStatus.success, categories: [drinks]),
      );
      final withSku = product.copyWith(sku: 'COF-001');
      await pumpCard(tester, withSku, isGrid: true);

      expect(find.text('Coffee'), findsOneWidget);
      expect(find.textContaining('COF-001'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
