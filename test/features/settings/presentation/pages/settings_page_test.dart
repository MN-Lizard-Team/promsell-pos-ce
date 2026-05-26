import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/settings_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';

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
    testWidgets('renders settings sections', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows save button in app bar', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('shows shop info text fields', (tester) async {
      await tester.pumpApp(
        const SettingsPage(),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byType(TextField), findsAtLeast(3));
    });
  });
}
