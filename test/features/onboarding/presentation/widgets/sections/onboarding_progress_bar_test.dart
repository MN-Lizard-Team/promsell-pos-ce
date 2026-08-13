import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_progress_bar.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingProgressBar', () {
    testWidgets('renders step dots at step 2 of 4', (tester) async {
      await tester.pumpApp(
        const OnboardingProgressBar(
          currentStep: 2,
          totalSteps: 4,
          accentBrand: Colors.blue,
        ),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('renders at step 0', (tester) async {
      await tester.pumpApp(
        const OnboardingProgressBar(
          currentStep: 0,
          totalSteps: 4,
          accentBrand: Colors.blue,
        ),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });

    testWidgets('renders at final step', (tester) async {
      await tester.pumpApp(
        const OnboardingProgressBar(
          currentStep: 3,
          totalSteps: 4,
          accentBrand: Colors.green,
        ),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(4));
    });
  });
}
