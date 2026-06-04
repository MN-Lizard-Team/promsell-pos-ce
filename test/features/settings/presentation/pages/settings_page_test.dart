import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_category_tile.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.loaded,
        settings: AppSettings(),
      ),
    );
    when(() => mockSettingsCubit.update(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(const AppSettings());
  });

  group('SettingsPage', () {
    testWidgets('renders category list', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders at least 6 category tiles', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(SettingsCategoryTile), findsAtLeastNWidgets(6));
    });

    testWidgets('has no inline text fields or save button', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TextField), findsNothing);
      expect(find.byType(TextButton), findsNothing);
    });
  });
}
