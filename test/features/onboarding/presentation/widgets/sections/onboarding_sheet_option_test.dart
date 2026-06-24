import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_sheet_option.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingSheetOption', () {
    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpApp(
        OnboardingSheetOption(
          icon: Icons.credit_card,
          label: 'Credit Card',
          selected: false,
          accentColor: Colors.blue,
          isDark: false,
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.byType(OnboardingSheetOption));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders label text', (tester) async {
      await tester.pumpApp(
        OnboardingSheetOption(
          icon: Icons.payments,
          label: 'Cash',
          selected: true,
          accentColor: Colors.green,
          isDark: false,
          onTap: () {},
        ),
      );

      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('shows check icon when selected', (tester) async {
      await tester.pumpApp(
        OnboardingSheetOption(
          icon: Icons.payments,
          label: 'Cash',
          selected: true,
          accentColor: Colors.green,
          isDark: false,
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
