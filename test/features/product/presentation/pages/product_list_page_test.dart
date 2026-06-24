import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_list_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';
import 'package:promsell_pos_ce/core/widgets/search/search_history_cubit.dart';

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockSearchHistoryCubit mockSearchHistoryCubit;
  final sl = GetIt.instance;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockSearchHistoryCubit = MockSearchHistoryCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    when(
      () => mockSearchHistoryCubit.state,
    ).thenReturn(const SearchHistoryState());
    sl.registerSingleton<ProductBloc>(mockProductBloc);
    sl.registerSingleton<CategoryBloc>(mockCategoryBloc);
    if (sl.isRegistered<SettingsLocalDatasource>()) {
      sl.unregister<SettingsLocalDatasource>();
    }
    final mockSettingsLocal = MockSettingsLocalDatasource();
    when(
      () => mockSettingsLocal.getString(any()),
    ).thenAnswer((_) async => null);
    sl.registerSingleton<SettingsLocalDatasource>(mockSettingsLocal);
  });

  tearDown(() => sl.reset());

  group('ProductListPage', () {
    testWidgets('shows loading indicator when status is loading', (
      tester,
    ) async {
      when(
        () => mockProductBloc.state,
      ).thenReturn(const ProductState(status: ProductStatus.loading));

      await tester.pumpApp(
        const ProductListPage(),
        settingsCubit: mockSettingsCubit,
        searchHistoryCubit: mockSearchHistoryCubit,
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows product list when loaded', (tester) async {
      final products = [
        Product(
          id: 'prod-0001-0001-0001-000000000001',
          name: 'Water',
          price: 10.0,
          stock: 100,
          imageThumbnailPath: null,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'prod-0002-0002-0002-000000000002',
          name: 'Coke',
          price: 25.0,
          stock: 50,
          imageThumbnailPath: null,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(() => mockProductBloc.state).thenReturn(
        ProductState(status: ProductStatus.success, products: products),
      );

      await tester.pumpApp(
        const ProductListPage(),
        settingsCubit: mockSettingsCubit,
        searchHistoryCubit: mockSearchHistoryCubit,
      );

      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Coke'), findsOneWidget);
    });

    testWidgets('shows empty state when no products', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        const ProductState(status: ProductStatus.success, products: []),
      );

      await tester.pumpApp(
        const ProductListPage(),
        settingsCubit: mockSettingsCubit,
        searchHistoryCubit: mockSearchHistoryCubit,
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows error state', (tester) async {
      when(() => mockProductBloc.state).thenReturn(
        const ProductState(
          status: ProductStatus.failure,
          errorMessage: 'DB error',
        ),
      );

      await tester.pumpApp(
        const ProductListPage(),
        settingsCubit: mockSettingsCubit,
        searchHistoryCubit: mockSearchHistoryCubit,
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
