import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_preferences_section.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_selection_sheet.dart';
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

  group('OnboardingPreferencesSection', () {
    testWidgets('renders locale and theme chips', (tester) async {
      await tester.pumpApp(
        OnboardingPreferencesSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          settings: const Settings(),
          dateFormat: 'dd/MM/yyyy',
          onDateFormatChanged: (_) {},
        ),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is SegmentedButton),
        findsNWidgets(2),
      );
    });

    testWidgets('renders date format dropdown with current value', (
      tester,
    ) async {
      await tester.pumpApp(
        OnboardingPreferencesSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          settings: const Settings(),
          dateFormat: 'yyyy-MM-dd',
          onDateFormatChanged: (_) {},
        ),
        settingsCubit: mockSettingsCubit,
      );

      expect(find.text('yyyy-MM-dd'), findsOneWidget);
      expect(find.byType(OnboardingSelectionField<String>), findsOneWidget);
    });

    testWidgets('calls onDateFormatChanged when dropdown changes', (
      tester,
    ) async {
      String? selectedFormat;
      await tester.pumpApp(
        OnboardingPreferencesSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          settings: const Settings(),
          dateFormat: 'dd/MM/yyyy',
          onDateFormatChanged: (v) => selectedFormat = v,
        ),
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(find.text('dd/MM/yyyy'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('MM/dd/yyyy').last);
      await tester.pumpAndSettle();

      expect(selectedFormat, 'MM/dd/yyyy');
    });

    testWidgets('calls cubit updateField when Thai locale tapped', (
      tester,
    ) async {
      await tester.pumpApp(
        OnboardingPreferencesSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          settings: const Settings(),
          dateFormat: 'dd/MM/yyyy',
          onDateFormatChanged: (_) {},
        ),
        settingsCubit: mockSettingsCubit,
      );

      await tester.tap(
        find.byWidgetPredicate((widget) => widget is SegmentedButton).first,
      );
      await tester.pump();

      verify(() => mockSettingsCubit.updateField(any())).called(1);
    });
  });
}
