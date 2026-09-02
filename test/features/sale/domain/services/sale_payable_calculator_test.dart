import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

void main() {
  group('SalePayableCalculator', () {
    group('resolvedServiceChargeRate', () {
      test('returns 0 when not restaurant mode', () {
        final settings = const Settings().copyWith(
          businessType: BusinessType.retail,
          defaultServiceChargeRate: 10,
        );
        expect(
          SalePayableCalculator.resolvedServiceChargeRate(
            settings: settings,
            cartServiceChargeRate: 5,
          ),
          0,
        );
      });

      test('returns cart rate when provided in restaurant mode', () {
        final settings = const Settings().copyWith(
          businessType: BusinessType.restaurant,
          defaultServiceChargeRate: 10,
        );
        expect(
          SalePayableCalculator.resolvedServiceChargeRate(
            settings: settings,
            cartServiceChargeRate: 5,
          ),
          5,
        );
      });

      test('falls back to settings default when cart rate is null', () {
        final settings = const Settings().copyWith(
          businessType: BusinessType.restaurant,
          defaultServiceChargeRate: 7,
        );
        expect(
          SalePayableCalculator.resolvedServiceChargeRate(
            settings: settings,
            cartServiceChargeRate: null,
          ),
          7,
        );
      });

      test('returns 0 when rate is negative', () {
        final settings = const Settings().copyWith(
          businessType: BusinessType.restaurant,
          defaultServiceChargeRate: -5,
        );
        expect(
          SalePayableCalculator.resolvedServiceChargeRate(settings: settings),
          0,
        );
      });
    });

    group('compute (VAT NONE)', () {
      test('net = items - cart discount - promo discount', () {
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(1000),
            cartDiscountAmount: Money.fromDouble(100),
            promotionDiscountAmount: Money.fromDouble(50),
            serviceChargeRate: 0,
            vatMode: 'NONE',
            vatRate: 0,
          ),
        );

        expect(totals.netAfterDiscounts, Money.fromDouble(850));
        expect(totals.serviceChargeAmount, Money.zero);
        expect(totals.preTaxTotal, Money.fromDouble(850));
        expect(totals.vatAmount, Money.zero);
        expect(totals.payableTotal, Money.fromDouble(850));
        expect(totals.isVatInclusive, isFalse);
      });

      test('net clamped to zero when discounts exceed subtotal', () {
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(100),
            cartDiscountAmount: Money.fromDouble(150),
            serviceChargeRate: 0,
            vatMode: 'NONE',
            vatRate: 0,
          ),
        );

        expect(totals.netAfterDiscounts, Money.zero);
        expect(totals.payableTotal, Money.zero);
      });
    });

    group('compute (VAT EXCLUSIVE)', () {
      test('vat = preTax × rate; payable = preTax + vat', () {
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(1000),
            serviceChargeRate: 10,
            vatMode: 'EXCLUSIVE',
            vatRate: 7,
          ),
        );

        // net = 1000, sc = 100, preTax = 1100
        // vat = 1100 × 0.07 = 77
        // payable = 1100 + 77 = 1177
        expect(totals.netAfterDiscounts, Money.fromDouble(1000));
        expect(totals.serviceChargeAmount, Money.fromDouble(100));
        expect(totals.preTaxTotal, Money.fromDouble(1100));
        expect(totals.vatAmount, Money.fromDouble(77));
        expect(totals.payableTotal, Money.fromDouble(1177));
        expect(totals.isVatInclusive, isFalse);
      });

      test('vat is zero when rate is 0 even in EXCLUSIVE mode', () {
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(500),
            vatMode: 'EXCLUSIVE',
            vatRate: 0,
          ),
        );

        expect(totals.vatAmount, Money.zero);
        expect(totals.payableTotal, Money.fromDouble(500));
      });
    });

    group('compute (VAT INCLUSIVE)', () {
      test(
        'netOfVat = preTax / (1+r); vat = preTax - netOfVat; payable = preTax',
        () {
          final totals = SalePayableCalculator.compute(
            SalePayableInput(
              itemsSubtotal: Money.fromDouble(1070),
              serviceChargeRate: 0,
              vatMode: 'INCLUSIVE',
              vatRate: 7,
            ),
          );

          // preTax = 1070
          // netOfVat = 1070 / 1.07 = 1000
          // vat = 1070 - 1000 = 70
          // payable = 1070
          expect(totals.preTaxTotal, Money.fromDouble(1070));
          expect(totals.netOfVat.satang, closeTo(100000, 1)); // ~1000.00
          expect(totals.vatAmount.satang, closeTo(7000, 1)); // ~70.00
          expect(totals.payableTotal, Money.fromDouble(1070));
          expect(totals.isVatInclusive, isTrue);
        },
      );

      test('inclusive with service charge: sc added before vat extraction', () {
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(1000),
            serviceChargeRate: 10,
            vatMode: 'INCLUSIVE',
            vatRate: 7,
          ),
        );

        // net = 1000, sc = 100, preTax = 1100
        // netOfVat = 1100 / 1.07 ≈ 1028.04
        // vat = 1100 - 1028.04 ≈ 71.96
        // payable = 1100
        expect(totals.preTaxTotal, Money.fromDouble(1100));
        expect(totals.payableTotal, Money.fromDouble(1100));
        expect(totals.isVatInclusive, isTrue);
      });
    });

    group('computeWithServiceChargeAmount', () {
      test('uses explicit SC amount instead of rate calculation', () {
        final totals = SalePayableCalculator.computeWithServiceChargeAmount(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(1000),
            serviceChargeRate:
                10, // would be 100, but explicit amount overrides
            vatMode: 'NONE',
            vatRate: 0,
          ),
          serviceChargeAmount: Money.fromDouble(50),
        );

        expect(totals.serviceChargeAmount, Money.fromDouble(50));
        expect(totals.preTaxTotal, Money.fromDouble(1050));
        expect(totals.payableTotal, Money.fromDouble(1050));
      });
    });

    group('forCartFields', () {
      test('resolves SC from settings and computes totals in one call', () {
        final settings = const Settings().copyWith(
          businessType: BusinessType.restaurant,
          defaultServiceChargeRate: 10,
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        );

        final totals = SalePayableCalculator.forCartFields(
          itemsSubtotal: Money.fromDouble(1000),
          cartDiscountAmount: Money.zero,
          promotionDiscountAmount: Money.zero,
          settings: settings,
        );

        // net = 1000, sc = 100, preTax = 1100, vat = 77, payable = 1177
        expect(totals.payableTotal, Money.fromDouble(1177));
      });

      test('returns 0 SC for retail mode', () {
        final settings = const Settings().copyWith(
          businessType: BusinessType.retail,
        );

        final totals = SalePayableCalculator.forCartFields(
          itemsSubtotal: Money.fromDouble(500),
          cartDiscountAmount: Money.zero,
          promotionDiscountAmount: Money.zero,
          settings: settings,
        );

        expect(totals.serviceChargeAmount, Money.zero);
        expect(totals.payableTotal, Money.fromDouble(500));
      });
    });

    group('edge cases', () {
      test('empty-string vatMode is treated as NONE', () {
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(100),
            vatMode: '',
            vatRate: 7,
          ),
        );

        expect(totals.vatMode, 'NONE');
        expect(totals.vatAmount, Money.zero);
      });

      test('lowercase vatmode is normalized', () {
        final totals = SalePayableCalculator.compute(
          SalePayableInput(
            itemsSubtotal: Money.fromDouble(1000),
            vatMode: 'exclusive',
            vatRate: 7,
          ),
        );

        expect(totals.vatMode, 'EXCLUSIVE');
        expect(totals.vatAmount, Money.fromDouble(70));
      });

      test('zero subtotal produces zero totals', () {
        final totals = SalePayableCalculator.compute(
          const SalePayableInput(
            itemsSubtotal: Money.zero,
            vatMode: 'EXCLUSIVE',
            vatRate: 7,
          ),
        );

        expect(totals.netAfterDiscounts, Money.zero);
        expect(totals.payableTotal, Money.zero);
      });
    });
  });

  group('equality', () {
    SalePayableTotals buildTotals({double vatRate = 7}) {
      return SalePayableCalculator.compute(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(1000),
          cartDiscountAmount: Money.fromDouble(100),
          promotionDiscountAmount: Money.zero,
          serviceChargeRate: 10,
          vatMode: 'EXCLUSIVE',
          vatRate: vatRate,
        ),
      );
    }

    test('SalePayableInput with identical fields is equal', () {
      final a = SalePayableInput(itemsSubtotal: Money.fromDouble(100));
      final b = SalePayableInput(itemsSubtotal: Money.fromDouble(100));

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('SalePayableInput with different vatRate is not equal', () {
      final a = SalePayableInput(
        itemsSubtotal: Money.fromDouble(100),
        vatRate: 7,
      );
      final b = SalePayableInput(
        itemsSubtotal: Money.fromDouble(100),
        vatRate: 10,
      );

      expect(a, isNot(equals(b)));
    });

    test('SalePayableInput null discount defaults equal zero discounts', () {
      final fromNull = SalePayableInput(itemsSubtotal: Money.fromDouble(100));
      final fromZero = SalePayableInput(
        itemsSubtotal: Money.fromDouble(100),
        cartDiscountAmount: Money.zero,
        promotionDiscountAmount: Money.zero,
      );

      expect(fromNull, equals(fromZero));
    });

    test('SalePayableTotals with identical fields is equal', () {
      expect(buildTotals(), equals(buildTotals()));
      expect(buildTotals().hashCode, buildTotals().hashCode);
    });

    test('SalePayableTotals with different vatRate is not equal', () {
      expect(buildTotals(vatRate: 7), isNot(equals(buildTotals(vatRate: 10))));
    });
  });
}
