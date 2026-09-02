import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_hero_section.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingHeroSection', () {
    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpApp(
        const OnboardingHeroSection(
          isDark: false,
          subtitle: 'Welcome to the app',
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(OnboardingHeroSection), findsOneWidget);
      expect(find.text('Welcome to the app'), findsOneWidget);
    });

    testWidgets('does not show dismiss button when onDismiss is null', (
      tester,
    ) async {
      await tester.pumpApp(
        const OnboardingHeroSection(isDark: false, subtitle: 'Welcome'),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(TablerIcons.x), findsNothing);
    });

    testWidgets('calls onDismiss when close button is tapped', (tester) async {
      var dismissed = false;
      await tester.pumpApp(
        OnboardingHeroSection(
          isDark: false,
          subtitle: 'Welcome',
          onDismiss: () => dismissed = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(TablerIcons.x), findsOneWidget);
      await tester.tap(find.byIcon(TablerIcons.x));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('does not overflow on narrow screen with long Thai subtitle', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpApp(
        const OnboardingHeroSection(
          isDark: false,
          subtitle:
              'ยินดีต้อนรับสู่ระบบขายสินค้าออฟไลน์สำหรับร้านค้าขนาดย่อมที่ต้องการจัดการร้านค้าได้ง่าย',
        ),
        locale: const Locale('th'),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Image.asset errorBuilder shows fallback icon on missing asset',
      (tester) async {
        await tester.pumpApp(
          Image.asset(
            'assets/nonexistent/missing.png',
            errorBuilder: (_, _, _) => const Icon(Icons.store),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.store), findsOneWidget);
      },
    );
  });
}
