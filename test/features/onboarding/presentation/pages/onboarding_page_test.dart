import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_hero_section.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

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
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpApp(const OnboardingPage(), settingsCubit: settingsCubit);

    expect(find.text('Shop Info'), findsAtLeastNWidgets(1));
    expect(find.byType(OnboardingPage), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Locale & Currency'), findsAtLeastNWidgets(1));
    expect(find.text('Skip Setup'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Tax Setup'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('All set!'), findsOneWidget);
    expect(find.text('Start Selling'), findsOneWidget);
  });

  testWidgets('allows returning to the previous onboarding step', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpApp(const OnboardingPage(), settingsCubit: settingsCubit);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(TablerIcons.chevronLeft));
    await tester.pumpAndSettle();

    expect(find.text('Shop Info'), findsAtLeastNWidgets(1));
  });

  testWidgets('dismisses the hero card on step 0 when close button is tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpApp(const OnboardingPage(), settingsCubit: settingsCubit);

    // Hero is visible on step 0.
    expect(find.byType(OnboardingHeroSection), findsOneWidget);

    // Tap the hero close (X) button — the only X icon on step 0.
    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pumpAndSettle();

    // Hero is gone but step 0 content (Shop Info) remains.
    expect(find.byType(OnboardingHeroSection), findsNothing);
    expect(find.text('Shop Info'), findsAtLeastNWidgets(1));
  });
}
