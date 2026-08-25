import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_done_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingDoneSection', () {
    testWidgets('renders celebration with check icon and title', (
      tester,
    ) async {
      await tester.pumpApp(
        OnboardingDoneSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          onFinish: () {},
          onSkip: () {},
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('All set!'), findsOneWidget);
    });

    testWidgets('shows setup summary when data provided', (tester) async {
      await tester.pumpApp(
        OnboardingDoneSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          onFinish: () {},
          onSkip: () {},
          shopName: 'My Shop',
          currencyLabel: '฿ THB',
          vatLabel: 'Inclusive (7%)',
        ),
      );

      expect(find.text('My Shop'), findsOneWidget);
      expect(find.text('Store'), findsOneWidget);
      expect(find.text('Setup complete'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('security row reflects the real store-PIN state', (
      tester,
    ) async {
      Future<void> pumpWith({required bool pinProtected}) async {
        await tester.pumpApp(
          OnboardingDoneSection(
            cardBg: Colors.white,
            accentBrand: Colors.blue,
            onFinish: () {},
            onSkip: () {},
            pinProtected: pinProtected,
          ),
        );
        await tester.pump();
      }

      await pumpWith(pinProtected: true);
      expect(find.text('✓'), findsOneWidget);

      await pumpWith(pinProtected: false);
      expect(find.text('✓'), findsNothing);
      expect(find.text('No store PIN set'), findsOneWidget);
    });

    testWidgets('shows summary placeholders when no data provided', (
      tester,
    ) async {
      await tester.pumpApp(
        OnboardingDoneSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          onFinish: () {},
          onSkip: () {},
        ),
      );

      expect(find.text('Setup complete'), findsOneWidget);
      expect(find.text('—'), findsNWidgets(3));
    });
  });
}
