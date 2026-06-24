import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingSection', () {
    testWidgets('renders title and child', (tester) async {
      await tester.pumpApp(
        const OnboardingSection(
          cardBg: Colors.white,
          icon: Icons.store,
          iconColor: Colors.green,
          title: 'Shop Info',
          child: Text('Content here'),
        ),
      );

      expect(find.text('Shop Info'), findsOneWidget);
      expect(find.text('Content here'), findsOneWidget);
      expect(find.byIcon(Icons.store), findsOneWidget);
    });
  });
}
