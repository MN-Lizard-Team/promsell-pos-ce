import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';

/// Fail-closed golden matrix for payable SSOT (POST-090 B1).
///
/// Order locked: items → cart disc → promo → net floor 0 → SC → VAT mode → payable.
void main() {
  group('SalePayableCalculator golden matrix', () {
    final cases = <_GoldenCase>[
      _GoldenCase(
        name: 'retail plain NONE',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          vatMode: 'NONE',
        ),
        expectNet: Money.fromDouble(100),
        expectSc: Money.zero,
        expectPreTax: Money.fromDouble(100),
        expectVat: Money.zero,
        expectPayable: Money.fromDouble(100),
      ),
      _GoldenCase(
        name: 'retail EXCLUSIVE 7%',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
        expectNet: Money.fromDouble(100),
        expectSc: Money.zero,
        expectPreTax: Money.fromDouble(100),
        expectVat: Money.fromDouble(7),
        expectPayable: Money.fromDouble(107),
      ),
      _GoldenCase(
        name: 'retail INCLUSIVE 7% on 107',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(107),
          vatMode: 'INCLUSIVE',
          vatRate: 7,
        ),
        expectNet: Money.fromDouble(107),
        expectSc: Money.zero,
        expectPreTax: Money.fromDouble(107),
        expectVat: Money.fromDouble(7),
        expectPayable: Money.fromDouble(107),
        expectNetOfVat: Money.fromDouble(100),
      ),
      _GoldenCase(
        name: 'cart+promo then SC 10% EXCLUSIVE 7%',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(200),
          cartDiscountAmount: Money.fromDouble(20),
          promotionDiscountAmount: Money.fromDouble(10),
          serviceChargeRate: 10,
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
        // net 170, SC 17, preTax 187, VAT half-up 13.09, payable 200.09
        expectNet: Money.fromDouble(170),
        expectSc: Money.fromDouble(17),
        expectPreTax: Money.fromDouble(187),
        expectVat: Money.fromDouble(187) * 0.07,
        expectPayable: Money.fromDouble(187) + (Money.fromDouble(187) * 0.07),
      ),
      _GoldenCase(
        name: 'SC rate then NONE',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          serviceChargeRate: 10,
          vatMode: 'NONE',
        ),
        expectNet: Money.fromDouble(100),
        expectSc: Money.fromDouble(10),
        expectPreTax: Money.fromDouble(110),
        expectVat: Money.zero,
        expectPayable: Money.fromDouble(110),
      ),
      _GoldenCase(
        name: 'SC + EXCLUSIVE 7%',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          serviceChargeRate: 10,
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
        expectNet: Money.fromDouble(100),
        expectSc: Money.fromDouble(10),
        expectPreTax: Money.fromDouble(110),
        expectVat: Money.fromDouble(7.7),
        expectPayable: Money.fromDouble(117.7),
      ),
      _GoldenCase(
        name: 'SC + INCLUSIVE 7% on preTax 110',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          serviceChargeRate: 10,
          vatMode: 'INCLUSIVE',
          vatRate: 7,
        ),
        expectNet: Money.fromDouble(100),
        expectSc: Money.fromDouble(10),
        expectPreTax: Money.fromDouble(110),
        // payable stays preTax; VAT extracted
        expectPayable: Money.fromDouble(110),
        expectVatFromInclusive: true,
      ),
      _GoldenCase(
        name: 'discounts wipe net before SC/VAT',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(50),
          cartDiscountAmount: Money.fromDouble(80),
          serviceChargeRate: 10,
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
        expectNet: Money.zero,
        expectSc: Money.zero,
        expectPreTax: Money.zero,
        expectVat: Money.zero,
        expectPayable: Money.zero,
      ),
      _GoldenCase(
        name: 'promo only then EXCLUSIVE',
        input: SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          promotionDiscountAmount: Money.fromDouble(10),
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
        expectNet: Money.fromDouble(90),
        expectSc: Money.zero,
        expectPreTax: Money.fromDouble(90),
        expectVat: Money.fromDouble(6.3),
        expectPayable: Money.fromDouble(96.3),
      ),
      _GoldenCase(
        name: 'zero items',
        input: const SalePayableInput(
          itemsSubtotal: Money.zero,
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
        expectNet: Money.zero,
        expectSc: Money.zero,
        expectPreTax: Money.zero,
        expectVat: Money.zero,
        expectPayable: Money.zero,
      ),
    ];

    for (final c in cases) {
      test(c.name, () {
        final t = SalePayableCalculator.compute(c.input);
        expect(t.netAfterDiscounts, c.expectNet, reason: 'net');
        expect(t.serviceChargeAmount, c.expectSc, reason: 'sc');
        expect(t.preTaxTotal, c.expectPreTax, reason: 'preTax');
        if (c.expectVatFromInclusive) {
          expect(t.payableTotal, c.expectPayable, reason: 'payable inclusive');
          expect(t.netOfVat + t.vatAmount, t.preTaxTotal, reason: 'vat split');
          expect(t.isVatInclusive, isTrue);
        } else {
          if (c.expectVat != null) {
            expect(t.vatAmount, c.expectVat, reason: 'vat');
          }
          expect(t.payableTotal, c.expectPayable, reason: 'payable');
        }
        if (c.expectNetOfVat != null) {
          expect(t.netOfVat, c.expectNetOfVat, reason: 'netOfVat');
        }
        // Invariants
        expect(t.netAfterDiscounts.satang, greaterThanOrEqualTo(0));
        if (c.input.vatMode == 'EXCLUSIVE') {
          expect(
            t.payableTotal.satang,
            t.preTaxTotal.satang + t.vatAmount.satang,
          );
        }
        if (c.input.vatMode == 'NONE') {
          expect(t.vatAmount, Money.zero);
          expect(t.payableTotal, t.preTaxTotal);
        }
        if (c.input.vatMode == 'INCLUSIVE') {
          expect(t.payableTotal, t.preTaxTotal);
        }
      });
    }

    test('fixed SC amount golden (computeWithServiceChargeAmount)', () {
      final t = SalePayableCalculator.computeWithServiceChargeAmount(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(200),
          cartDiscountAmount: Money.fromDouble(50),
          serviceChargeRate: 10,
          vatMode: 'NONE',
        ),
        serviceChargeAmount: Money.fromDouble(15),
      );
      expect(t.netAfterDiscounts, Money.fromDouble(150));
      expect(t.serviceChargeAmount, Money.fromDouble(15));
      expect(t.payableTotal, Money.fromDouble(165));
    });

    test('satang identity: 99.99 * 7% exclusive half-up stable', () {
      final t = SalePayableCalculator.compute(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(99.99),
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
      );
      expect(t.preTaxTotal.satang, 9999);
      expect(t.vatAmount, t.preTaxTotal * 0.07);
      expect(t.payableTotal.satang, t.preTaxTotal.satang + t.vatAmount.satang);
    });
  });
}

class _GoldenCase {
  _GoldenCase({
    required this.name,
    required this.input,
    required this.expectNet,
    required this.expectSc,
    required this.expectPreTax,
    required this.expectPayable,
    this.expectVat,
    this.expectNetOfVat,
    this.expectVatFromInclusive = false,
  });

  final String name;
  final SalePayableInput input;
  final Money expectNet;
  final Money expectSc;
  final Money expectPreTax;
  final Money? expectVat;
  final Money expectPayable;
  final Money? expectNetOfVat;
  final bool expectVatFromInclusive;
}
