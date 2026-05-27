import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/domain/entities/product.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/pages/product_list_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockProductBloc mockProductBloc;
  late MockSettingsCubit mockSettingsCubit;
  final sl = GetIt.instance;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: AppSettings(),
      ),
    );
    sl.registerSingleton<ProductBloc>(mockProductBloc);
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
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Product(
          id: 'prod-0002-0002-0002-000000000002',
          name: 'Coke',
          price: 25.0,
          stock: 50,
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
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
