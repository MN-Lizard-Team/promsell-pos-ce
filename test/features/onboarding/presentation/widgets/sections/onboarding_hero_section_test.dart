import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_hero_section.dart';

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
