import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

import '../../../../helpers/mocks.dart';
import '../../../../helpers/pump_app.dart';

void main() {
  late MockSettingsCubit settingsCubit;

  setUp(() {
    settingsCubit = MockSettingsCubit();
    when(
      () => settingsCubit.state,
    ).thenReturn(const SettingsState(status: SettingsStatus.loaded));
  });

  testWidgets('keeps onboarding content in a four-step flow', (tester) async {
    await tester.pumpApp(const OnboardingPage(), settingsCubit: settingsCubit);

    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.text('Shop Info'), findsAtLeastNWidgets(1));
    expect(find.byType(OnboardingPage), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 4'), findsOneWidget);
    expect(find.text('Locale & Currency'), findsAtLeastNWidgets(1));
    expect(find.text('Skip Setup'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('3 / 4'), findsOneWidget);
    expect(find.text('Tax Setup'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('4 / 4'), findsOneWidget);
    expect(find.text('All set!'), findsOneWidget);
    expect(find.text('Start Selling'), findsOneWidget);
  });

  testWidgets('allows returning to the previous onboarding step', (
    tester,
  ) async {
    await tester.pumpApp(const OnboardingPage(), settingsCubit: settingsCubit);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('1 / 4'), findsOneWidget);
    expect(find.text('Shop Info'), findsAtLeastNWidgets(1));
  });
}
