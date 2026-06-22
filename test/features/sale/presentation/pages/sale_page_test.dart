import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import 'package:promsell_pos_ce/features/settings/data/datasources/settings_local_datasource.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';

void main() {
  late MockCartBloc mockCartBloc;
  late MockCheckoutBloc mockCheckoutBloc;
  late MockDraftBloc mockDraftBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUp(() {
    mockCartBloc = MockCartBloc();
    mockCheckoutBloc = MockCheckoutBloc();
    mockDraftBloc = MockDraftBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    when(() => mockCartBloc.state).thenReturn(const CartState(items: []));
    when(() => mockCheckoutBloc.state).thenReturn(const CheckoutState());
    when(() => mockDraftBloc.state).thenReturn(const DraftState());
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockProductBloc.state).thenReturn(
      const ProductState(status: ProductStatus.success, products: []),
    );
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );

    if (GetIt.I.isRegistered<ProductBloc>()) {
      GetIt.I.unregister<ProductBloc>();
    }
    GetIt.I.registerSingleton<ProductBloc>(mockProductBloc);
    if (GetIt.I.isRegistered<CategoryBloc>()) {
      GetIt.I.unregister<CategoryBloc>();
    }
    GetIt.I.registerSingleton<CategoryBloc>(mockCategoryBloc);

    if (GetIt.I.isRegistered<CartBloc>()) {
      GetIt.I.unregister<CartBloc>();
    }
    GetIt.I.registerSingleton<CartBloc>(mockCartBloc);
    if (GetIt.I.isRegistered<CheckoutBloc>()) {
      GetIt.I.unregister<CheckoutBloc>();
    }
    GetIt.I.registerSingleton<CheckoutBloc>(mockCheckoutBloc);
    if (GetIt.I.isRegistered<DraftBloc>()) {
      GetIt.I.unregister<DraftBloc>();
    }
    GetIt.I.registerSingleton<DraftBloc>(mockDraftBloc);

    final mockDraftRepo = MockDraftCartRepository();
    when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
    if (GetIt.I.isRegistered<DraftCartRepository>()) {
      GetIt.I.unregister<DraftCartRepository>();
    }
    GetIt.I.registerSingleton<DraftCartRepository>(mockDraftRepo);

    final mockSettingsDs = MockSettingsLocalDatasource();
    when(() => mockSettingsDs.getString(any())).thenAnswer((_) async => null);
    when(() => mockSettingsDs.setString(any(), any())).thenAnswer((_) async {});
    if (GetIt.I.isRegistered<SettingsLocalDatasource>()) {
      GetIt.I.unregister<SettingsLocalDatasource>();
    }
    GetIt.I.registerSingleton<SettingsLocalDatasource>(mockSettingsDs);
  });

  tearDown(() {
    if (GetIt.I.isRegistered<ProductBloc>()) {
      GetIt.I.unregister<ProductBloc>();
    }
    if (GetIt.I.isRegistered<CartBloc>()) {
      GetIt.I.unregister<CartBloc>();
    }
    if (GetIt.I.isRegistered<CheckoutBloc>()) {
      GetIt.I.unregister<CheckoutBloc>();
    }
    if (GetIt.I.isRegistered<DraftBloc>()) {
      GetIt.I.unregister<DraftBloc>();
    }
    if (GetIt.I.isRegistered<CategoryBloc>()) {
      GetIt.I.unregister<CategoryBloc>();
    }
    if (GetIt.I.isRegistered<DraftCartRepository>()) {
      GetIt.I.unregister<DraftCartRepository>();
    }
    if (GetIt.I.isRegistered<SettingsLocalDatasource>()) {
      GetIt.I.unregister<SettingsLocalDatasource>();
    }
  });

  group('SalePage landscape layout', () {
    testWidgets('uses expanded layout in landscape with width >= 600', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpApp(
        const SalePage(),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        draftBloc: mockDraftBloc,
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is MouseRegion && w.cursor == SystemMouseCursors.resizeColumn,
        ),
        findsOneWidget,
      );
    });

    testWidgets('uses compact layout in portrait', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpApp(
        const SalePage(),
        cartBloc: mockCartBloc,
        checkoutBloc: mockCheckoutBloc,
        draftBloc: mockDraftBloc,
        productBloc: mockProductBloc,
        categoryBloc: mockCategoryBloc,
        settingsCubit: mockSettingsCubit,
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeRow,
        ),
        findsOneWidget,
      );
    });
  });
}
