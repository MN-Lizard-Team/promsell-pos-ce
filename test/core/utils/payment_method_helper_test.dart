import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/payment_method_helper.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/sale_payment.dart';

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

    test('normalizes mixed', () {
      expect(normalizePaymentMethod('mixed'), 'mixed');
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

    testWidgets('localizes mixed', (tester) async {
      await tester.pumpApp(
        Builder(
          builder: (context) => Text(localizePaymentMethod(context, 'mixed')),
        ),
      );

      expect(find.text('Split payment'), findsOneWidget);
    });
  });

  group('saleCashTenderTotal / saleIncludesPromptPay', () {
    test('header cash without payment rows', () {
      final sale = Sale(
        id: '1',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'cash',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(saleCashTenderTotal(sale), Money.fromDouble(100));
      expect(saleIncludesPromptPay(sale), isFalse);
    });

    test('multi-tender cash + promptpay', () {
      final sale = Sale(
        id: '2',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'mixed',
        payments: [
          SalePayment(method: 'cash', amount: Money.fromDouble(40)),
          SalePayment(method: 'promptpay', amount: Money.fromDouble(60)),
        ],
        createdAt: DateTime(2026, 1, 1),
      );
      expect(saleCashTenderTotal(sale), Money.fromDouble(40));
      expect(saleIncludesPromptPay(sale), isTrue);
    });
  });
}
