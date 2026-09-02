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

    test('header non-cash tender total is zero', () {
      final sale = Sale(
        id: '3',
        totalAmount: Money.fromDouble(50),
        paymentMethod: 'card',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(saleCashTenderTotal(sale), Money.zero);
    });

    test('header promptpay detected without payment rows', () {
      final sale = Sale(
        id: '4',
        totalAmount: Money.fromDouble(50),
        paymentMethod: 'promptpay',
        createdAt: DateTime(2026, 1, 1),
      );
      expect(saleIncludesPromptPay(sale), isTrue);
    });
  });

  group('formatSalePaymentSummary / formatSalePaymentLines', () {
    testWidgets('single payment row uses localized method only', (
      tester,
    ) async {
      final sale = Sale(
        id: '5',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'mixed',
        payments: [SalePayment(method: 'cash', amount: Money.fromDouble(100))],
        createdAt: DateTime(2026, 1, 1),
      );
      await tester.pumpApp(
        Builder(
          builder: (context) => Text(formatSalePaymentSummary(context, sale)),
        ),
      );
      expect(find.text('Cash'), findsOneWidget);
    });

    testWidgets('multi payment summary joins labels and amounts', (
      tester,
    ) async {
      final sale = Sale(
        id: '6',
        totalAmount: Money.fromDouble(100),
        paymentMethod: 'mixed',
        payments: [
          SalePayment(method: 'cash', amount: Money.fromDouble(40)),
          SalePayment(method: 'card', amount: Money.fromDouble(60)),
        ],
        createdAt: DateTime(2026, 1, 1),
      );
      late String summary;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            summary = formatSalePaymentSummary(context, sale);
            return Text(summary);
          },
        ),
      );
      expect(summary, contains('Cash'));
      expect(summary, contains('Card'));
      expect(summary, contains('+'));
    });

    testWidgets('payment lines include reference when present', (tester) async {
      final sale = Sale(
        id: '7',
        totalAmount: Money.fromDouble(60),
        paymentMethod: 'promptpay',
        payments: [
          SalePayment(
            method: 'promptpay',
            amount: Money.fromDouble(60),
            reference: 'REF1',
          ),
        ],
        createdAt: DateTime(2026, 1, 1),
      );
      late List<String> lines;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            lines = formatSalePaymentLines(context, sale);
            return Text(lines.join('|'));
          },
        ),
      );
      expect(lines, hasLength(1));
      expect(lines.single, contains('••••'));
    });

    testWidgets('empty payments falls back to header method', (tester) async {
      final sale = Sale(
        id: '8',
        totalAmount: Money.fromDouble(10),
        paymentMethod: 'transfer',
        createdAt: DateTime(2026, 1, 1),
      );
      late List<String> lines;
      await tester.pumpApp(
        Builder(
          builder: (context) {
            lines = formatSalePaymentLines(context, sale);
            return Text(lines.single);
          },
        ),
      );
      expect(find.text('Transfer'), findsOneWidget);
      expect(lines, hasLength(1));
    });
  });
}
