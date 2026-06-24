import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('normalizePaymentMethod', () {
    test('normalizes Thai cash to "cash"', () {
      expect(normalizePaymentMethod('เงินสด'), 'cash');
    });

    test('normalizes English cash to "cash"', () {
      expect(normalizePaymentMethod('cash'), 'cash');
    });

    test('normalizes Thai transfer to "transfer"', () {
      expect(normalizePaymentMethod('โอน'), 'transfer');
    });

    test('normalizes English transfer to "transfer"', () {
      expect(normalizePaymentMethod('transfer'), 'transfer');
    });

    test('normalizes Thai card to "card"', () {
      expect(normalizePaymentMethod('บัตร'), 'card');
    });

    test('normalizes English card to "card"', () {
      expect(normalizePaymentMethod('card'), 'card');
    });

    test('returns unknown method as-is', () {
      expect(normalizePaymentMethod('bitcoin'), 'bitcoin');
    });
  });

  group('localizePaymentMethod', () {
    testWidgets('localizes cash', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Text(localizePaymentMethod(context, 'cash')),
        ),
      );

      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('localizes transfer', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) =>
              Text(localizePaymentMethod(context, 'transfer')),
        ),
      );

      expect(find.text('Transfer'), findsOneWidget);
    });
  });
}
