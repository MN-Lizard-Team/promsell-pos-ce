import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_info_form.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ShopInfoForm', () {
    testWidgets('renders FormSectionCard and AppTextFields', (tester) async {
      await tester.pumpApp(
        ShopInfoForm(
          initialShopName: 'My Shop',
          initialAddress: '123 Street',
          initialPhone: '0812345678',
          onSave: (_) {},
        ),
      );

      expect(find.byType(FormSectionCard), findsOneWidget);
      expect(find.byType(AppTextField), findsNWidgets(3));
      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('submit calls onSave with edited values', (tester) async {
      ShopInfoValues? saved;
      final key = GlobalKey<ShopInfoFormState>();

      await tester.pumpApp(
        ShopInfoForm(
          key: key,
          initialShopName: 'My Shop',
          initialAddress: '123 Street',
          initialPhone: '0812345678',
          onSave: (v) => saved = v,
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'New Shop');
      final ok = key.currentState!.submit();
      await tester.pump();

      expect(ok, isTrue);
      expect(saved?.shopName, 'New Shop');
      expect(saved?.address, '123 Street');
      expect(saved?.phone, '0812345678');
    });

    testWidgets('submit fails when shop name empty', (tester) async {
      var called = false;
      final key = GlobalKey<ShopInfoFormState>();

      await tester.pumpApp(
        ShopInfoForm(
          key: key,
          initialShopName: 'My Shop',
          initialAddress: '',
          initialPhone: '',
          onSave: (_) => called = true,
        ),
      );

      await tester.enterText(find.byType(TextField).first, '   ');
      final ok = key.currentState!.submit();
      await tester.pump();

      expect(ok, isFalse);
      expect(called, isFalse);
    });

    testWidgets('survives parent rebuild with new initials after submit', (
      tester,
    ) async {
      final key = GlobalKey<ShopInfoFormState>();
      var name = 'My Shop';
      var address = '123 Street';
      var phone = '0812345678';

      Future<void> pumpForm() async {
        await tester.pumpApp(
          ShopInfoForm(
            key: key,
            initialShopName: name,
            initialAddress: address,
            initialPhone: phone,
            onSave: (v) {
              name = v.shopName;
              address = v.address;
              phone = v.phone;
            },
          ),
        );
      }

      await pumpForm();
      await tester.enterText(find.byType(TextField).first, 'Saved Shop');
      expect(key.currentState!.submit(), isTrue);
      await tester.pump();

      // Simulate settings cubit rebuild pushing new initials (same form key).
      await pumpForm();
      await tester.pump();

      expect(find.text('Saved Shop'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
