import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_bloc.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_event.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/bloc/table_state.dart';
import 'package:promsell_pos_ce/features/restaurant_table/presentation/pages/table_management_page.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockTableBloc mockTableBloc;

  setUpAll(() {
    registerFallbackValue(const TablesLoaded());
  });

  setUp(() async {
    await GetIt.I.reset();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: Settings(
          businessConfig: BusinessConfig(businessType: BusinessType.restaurant),
        ),
      ),
    );

    mockTableBloc = MockTableBloc();
    when(() => mockTableBloc.state).thenReturn(
      TableState(
        status: TableBlocStatus.loaded,
        tables: [
          RestaurantTable(
            id: 't1',
            name: 'A-01',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
          ),
        ],
      ),
    );
    GetIt.I.registerSingleton<TableBloc>(mockTableBloc);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('Settings → Table Management route', () {
    testWidgets('opens TableManagementPage without ProviderNotFoundException', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Table Management'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Table Management'));
      await tester.pumpAndSettle();

      // Route content got the shared TableBloc — page rendered its rows.
      expect(find.byType(TableManagementPage), findsOneWidget);
      expect(find.text('A-01'), findsOneWidget);
      expect(tester.takeException(), isNull);
      // Initial load fired (provider and/or page initState).
      verify(
        () => mockTableBloc.add(any(that: isA<TablesLoaded>())),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
