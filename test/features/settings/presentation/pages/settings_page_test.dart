import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_root_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_category_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockSettingsCubit.update(any())).thenAnswer((_) async {});
  });

  setUpAll(() {
    registerFallbackValue(const Settings());
  });

  group('SettingsPage', () {
    testWidgets('renders settings list', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('renders 13 setting tiles across 6 sections', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );
      await tester.pumpAndSettle();

      expect(find.byType(SettingsCategoryTile), findsNWidgets(13));
      expect(find.byType(SettingsSectionCard), findsNWidgets(6));
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
