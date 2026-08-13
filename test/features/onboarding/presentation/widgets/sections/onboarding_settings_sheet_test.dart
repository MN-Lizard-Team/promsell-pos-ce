import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_settings_sheet.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_sheet_option.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../../helpers/mocks.dart';
import '../../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(status: SettingsStatus.loaded, settings: Settings()),
    );
    when(() => mockSettingsCubit.updateField(any())).thenAnswer((_) {});
  });

  group('OnboardingSettingsSheet', () {
    testWidgets('shows sheet with locale and theme options', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => OnboardingSettingsSheet.show(
                  context,
                  const Settings(),
                  Colors.blue,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingSheetOption), findsNWidgets(5));
    });

    testWidgets('calls cubit updateField when Thai locale selected', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpApp(
        Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => OnboardingSettingsSheet.show(
                  context,
                  const Settings(),
                  Colors.blue,
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OnboardingSheetOption).at(0));
      await tester.pumpAndSettle();

      verify(() => mockSettingsCubit.updateField(any())).called(1);
    });
  });
}
