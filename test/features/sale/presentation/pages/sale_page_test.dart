import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/pages/sale_page_redesign.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';

void main() {
  late MockSaleBloc mockSaleBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockProductBloc mockProductBloc;

  setUp(() {
    mockSaleBloc = MockSaleBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockProductBloc = MockProductBloc();
    when(() => mockSaleBloc.state).thenReturn(const SaleState(items: []));
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: AppSettings(),
      ),
    );
    when(() => mockProductBloc.state).thenReturn(
      const ProductState(status: ProductStatus.success, products: []),
    );

    if (GetIt.I.isRegistered<ProductBloc>()) {
      GetIt.I.unregister<ProductBloc>();
    }
    GetIt.I.registerSingleton<ProductBloc>(mockProductBloc);

    if (GetIt.I.isRegistered<SaleBloc>()) {
      GetIt.I.unregister<SaleBloc>();
    }
    GetIt.I.registerSingleton<SaleBloc>(mockSaleBloc);

    final mockDraftRepo = MockDraftCartRepository();
    when(() => mockDraftRepo.countDrafts()).thenAnswer((_) async => 0);
    if (GetIt.I.isRegistered<DraftCartRepository>()) {
      GetIt.I.unregister<DraftCartRepository>();
    }
    GetIt.I.registerSingleton<DraftCartRepository>(mockDraftRepo);
  });

  tearDown(() {
    if (GetIt.I.isRegistered<ProductBloc>()) {
      GetIt.I.unregister<ProductBloc>();
    }
    if (GetIt.I.isRegistered<SaleBloc>()) {
      GetIt.I.unregister<SaleBloc>();
    }
    if (GetIt.I.isRegistered<DraftCartRepository>()) {
      GetIt.I.unregister<DraftCartRepository>();
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
        saleBloc: mockSaleBloc,
        productBloc: mockProductBloc,
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
        saleBloc: mockSaleBloc,
        productBloc: mockProductBloc,
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
