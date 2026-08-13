import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/onboarding/presentation/widgets/sections/onboarding_shop_section.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('OnboardingShopSection', () {
    testWidgets('renders all input fields', (tester) async {
      final shopCtrl = TextEditingController();
      final addrCtrl = TextEditingController();
      final phoneCtrl = TextEditingController();
      final taxIdCtrl = TextEditingController();

      await tester.pumpApp(
        SingleChildScrollView(
          child: OnboardingShopSection(
            cardBg: Colors.white,
            accentBrand: Colors.blue,
            shopNameController: shopCtrl,
            addressController: addrCtrl,
            phoneController: phoneCtrl,
            taxIdController: taxIdCtrl,
          ),
        ),
      );

      expect(find.byIcon(Icons.storefront), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
      expect(find.byIcon(Icons.badge_outlined), findsOneWidget);
      expect(find.text('Receipt header preview'), findsOneWidget);
      expect(find.text('Your shop name will appear here'), findsOneWidget);
    });

    testWidgets('displays existing controller values', (tester) async {
      final shopCtrl = TextEditingController(text: 'My Shop');
      final addrCtrl = TextEditingController(text: '123 Road');
      final phoneCtrl = TextEditingController(text: '0801234567');
      final taxIdCtrl = TextEditingController(text: '1234567890123');

      await tester.pumpApp(
        SingleChildScrollView(
          child: OnboardingShopSection(
            cardBg: Colors.white,
            accentBrand: Colors.blue,
            shopNameController: shopCtrl,
            addressController: addrCtrl,
            phoneController: phoneCtrl,
            taxIdController: taxIdCtrl,
          ),
        ),
      );

      expect(shopCtrl.text, 'My Shop');
      expect(addrCtrl.text, '123 Road');
      expect(phoneCtrl.text, '0801234567');
      expect(taxIdCtrl.text, '1234567890123');
    });
  });
}
