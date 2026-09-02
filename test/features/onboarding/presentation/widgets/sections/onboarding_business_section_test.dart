import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_business_section.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingBusinessSection', () {
    testWidgets('renders VAT mode chips', (tester) async {
      await tester.pumpApp(
        OnboardingBusinessSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          vatMode: 'NONE',
          vatRateController: TextEditingController(text: '7'),
          promptPayController: TextEditingController(),
          onVatModeChanged: (_) {},
        ),
      );

      expect(find.byIcon(TablerIcons.receipt), findsOneWidget);
      expect(find.byType(RadioGroup<String>), findsOneWidget);
    });

    testWidgets('does not show VAT rate field when mode is NONE', (
      tester,
    ) async {
      final vatRateCtrl = TextEditingController(text: '7');
      await tester.pumpApp(
        OnboardingBusinessSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          vatMode: 'NONE',
          vatRateController: vatRateCtrl,
          promptPayController: TextEditingController(),
          onVatModeChanged: (_) {},
        ),
      );

      expect(find.text('%'), findsNothing);
    });

    testWidgets('shows VAT rate field when mode is INCLUSIVE', (tester) async {
      await tester.pumpApp(
        SingleChildScrollView(
          child: OnboardingBusinessSection(
            cardBg: Colors.white,
            accentBrand: Colors.blue,
            vatMode: 'INCLUSIVE',
            vatRateController: TextEditingController(text: '7'),
            promptPayController: TextEditingController(),
            onVatModeChanged: (_) {},
          ),
        ),
      );

      expect(find.text('%'), findsOneWidget);
    });

    testWidgets('calls onVatModeChanged when chip tapped', (tester) async {
      String? selectedMode;
      await tester.pumpApp(
        OnboardingBusinessSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          vatMode: 'NONE',
          vatRateController: TextEditingController(text: '7'),
          promptPayController: TextEditingController(),
          onVatModeChanged: (v) => selectedMode = v,
        ),
      );

      await tester.tap(find.text('Inclusive'));
      await tester.pump();

      expect(selectedMode, 'INCLUSIVE');
    });

    testWidgets('renders PromptPay field', (tester) async {
      await tester.pumpApp(
        OnboardingBusinessSection(
          cardBg: Colors.white,
          accentBrand: Colors.blue,
          vatMode: 'NONE',
          vatRateController: TextEditingController(text: '7'),
          promptPayController: TextEditingController(text: '0812345678'),
          onVatModeChanged: (_) {},
        ),
      );

      expect(find.byIcon(TablerIcons.qrcode), findsOneWidget);
      expect(find.text('0812345678'), findsOneWidget);
    });
  });
}
