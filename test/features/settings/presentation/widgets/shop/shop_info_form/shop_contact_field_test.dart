import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_info_form/shop_contact_field.dart';

import '../../../../../../helpers/pump_app.dart';

void main() {
  group('ShopContactField', () {
    testWidgets('renders address and phone tiles', (tester) async {
      await tester.pumpApp(
        ShopContactField(
          initialAddress: '123 Main St',
          initialPhone: '0812345678',
          onSaveAddress: (v) {},
          onSavePhone: (v) {},
        ),
      );

      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.text('081-234-5678'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets('renders dash when empty', (tester) async {
      await tester.pumpApp(
        ShopContactField(
          initialAddress: '',
          initialPhone: '',
          onSaveAddress: (v) {},
          onSavePhone: (v) {},
        ),
      );

      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets('opens address dialog', (tester) async {
      await tester.pumpApp(
        ShopContactField(
          initialAddress: '',
          initialPhone: '',
          onSaveAddress: (v) {},
          onSavePhone: (v) {},
        ),
      );

      await tester.tap(find.byType(ListTile).first);
      await tester.pump();

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('opens phone dialog', (tester) async {
      await tester.pumpApp(
        ShopContactField(
          initialAddress: '',
          initialPhone: '',
          onSaveAddress: (v) {},
          onSavePhone: (v) {},
        ),
      );

      await tester.tap(find.byType(ListTile).last);
      await tester.pump();

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}
