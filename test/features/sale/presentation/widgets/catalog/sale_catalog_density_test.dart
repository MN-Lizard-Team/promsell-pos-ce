import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/category_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_list/view_mode.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_catalog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/catalog/sale_mode_switcher.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockProductBloc mockProductBloc;
  late MockCategoryBloc mockCategoryBloc;
  late MockDraftBloc mockDraftBloc;
  late MockCartBloc mockCartBloc;
  late MockSettingsCubit mockSettingsCubit;
  late TextEditingController searchController;

  setUp(() {
    mockProductBloc = MockProductBloc();
    mockCategoryBloc = MockCategoryBloc();
    mockDraftBloc = MockDraftBloc();
    mockCartBloc = MockCartBloc();
    mockSettingsCubit = MockSettingsCubit();
    searchController = TextEditingController();

    when(() => mockProductBloc.state).thenReturn(
      const ProductState(status: ProductStatus.success, products: []),
    );
    when(() => mockCategoryBloc.state).thenReturn(
      const CategoryState(status: CategoryStatus.success, categories: []),
    );
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockDraftBloc.state).thenReturn(const DraftState());
    when(() => mockCartBloc.state).thenReturn(const CartState());

    if (GetIt.I.isRegistered<ProductBloc>()) {
      GetIt.I.unregister<ProductBloc>();
    }
    GetIt.I.registerSingleton<ProductBloc>(mockProductBloc);
    if (GetIt.I.isRegistered<CategoryBloc>()) {
      GetIt.I.unregister<CategoryBloc>();
    }
    GetIt.I.registerSingleton<CategoryBloc>(mockCategoryBloc);

    final mockDraftRepo = MockDraftCartRepository();
    when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
    when(
      () => mockDraftRepo.listDrafts(
        includeArchived: any(named: 'includeArchived'),
      ),
    ).thenAnswer((_) async => []);
    when(() => mockDraftRepo.listDrafts()).thenAnswer((_) async => []);
    if (GetIt.I.isRegistered<DraftCartRepository>()) {
      GetIt.I.unregister<DraftCartRepository>();
    }
    GetIt.I.registerSingleton<DraftCartRepository>(mockDraftRepo);
  });

  tearDown(() {
    searchController.dispose();
    if (GetIt.I.isRegistered<ProductBloc>()) {
      GetIt.I.unregister<ProductBloc>();
    }
    if (GetIt.I.isRegistered<CategoryBloc>()) {
      GetIt.I.unregister<CategoryBloc>();
    }
    if (GetIt.I.isRegistered<DraftCartRepository>()) {
      GetIt.I.unregister<DraftCartRepository>();
    }
  });

  Future<void> pumpCatalog(WidgetTester tester) async {
    await tester.pumpApp(
      SaleCatalog(
        searchController: searchController,
        viewMode: ViewMode.list,
        onViewModeChanged: (_) {},
        onClearFilters: () {},
      ),
      productBloc: mockProductBloc,
      categoryBloc: mockCategoryBloc,
      draftBloc: mockDraftBloc,
      cartBloc: mockCartBloc,
      settingsCubit: mockSettingsCubit,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hides multi-bill chrome when openBillCount <= 1', (
    tester,
  ) async {
    when(
      () => mockDraftBloc.state,
    ).thenReturn(const DraftState(openBillCount: 1, draftCount: 1));
    await pumpCatalog(tester);

    expect(find.byType(SaleModeSwitcher), findsNothing);
    expect(find.byKey(const ValueKey('sale_catalog_park_cta')), findsNothing);
  });

  testWidgets('shows multi-bill chrome when openBillCount > 1', (tester) async {
    when(
      () => mockDraftBloc.state,
    ).thenReturn(const DraftState(openBillCount: 2, draftCount: 2));
    await pumpCatalog(tester);

    expect(find.byType(SaleModeSwitcher), findsOneWidget);
    expect(find.byKey(const ValueKey('sale_catalog_park_cta')), findsOneWidget);
  });
}
