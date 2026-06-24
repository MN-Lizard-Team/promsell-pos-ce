import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_info_form.dart';

import '../../../../../helpers/pump_app.dart';

void main() {
  group('ShopInfoForm', () {
    testWidgets('renders DETAILS title and input fields', (tester) async {
      await tester.pumpApp(
        ShopInfoForm(
          initialShopName: 'My Shop',
          initialAddress: '123 Street',
          initialPhone: '0812345678',
          onSave: (_) {},
        ),
      );

      expect(find.text('DETAILS'), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('calls onSave with shop name when edited', (tester) async {
      String? savedName;
      await tester.pumpApp(
        ShopInfoForm(
          initialShopName: 'My Shop',
          initialAddress: '123 Street',
          initialPhone: '0812345678',
          onSave: (v) => savedName = v.shopName,
        ),
      );

      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'New Shop');
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(savedName, 'New Shop');
    });
  });
}
