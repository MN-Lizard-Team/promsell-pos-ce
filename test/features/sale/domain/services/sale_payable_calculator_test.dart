import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/business_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('SalePayableCalculator.compute', () {
    test('NONE: payable = net + SC, no VAT', () {
      final t = SalePayableCalculator.compute(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          serviceChargeRate: 10,
          vatMode: 'NONE',
          vatRate: 7,
        ),
      );
      expect(t.netAfterDiscounts, Money.fromDouble(100));
      expect(t.serviceChargeAmount, Money.fromDouble(10));
      expect(t.preTaxTotal, Money.fromDouble(110));
      expect(t.vatAmount, Money.zero);
      expect(t.payableTotal, Money.fromDouble(110));
    });

    test('EXCLUSIVE: payable = preTax + VAT', () {
      final t = SalePayableCalculator.compute(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
      );
      expect(t.preTaxTotal, Money.fromDouble(100));
      expect(t.vatAmount, Money.fromDouble(7));
      expect(t.payableTotal, Money.fromDouble(107));
      expect(t.isVatInclusive, isFalse);
    });

    test('INCLUSIVE: payable = preTax, VAT extracted', () {
      final t = SalePayableCalculator.compute(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(107),
          vatMode: 'INCLUSIVE',
          vatRate: 7,
        ),
      );
      expect(t.payableTotal, Money.fromDouble(107));
      expect(t.netOfVat + t.vatAmount, t.preTaxTotal);
      expect(t.isVatInclusive, isTrue);
      // 107 / 1.07 ≈ 100
      expect(t.netOfVat.value, closeTo(100.0, 0.01));
    });

    test('cart + promo discounts reduce net before SC', () {
      final t = SalePayableCalculator.compute(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(200),
          cartDiscountAmount: Money.fromDouble(20),
          promotionDiscountAmount: Money.fromDouble(10),
          serviceChargeRate: 10,
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
      );
      // net 170, SC 17, preTax 187, VAT 13.09, payable 200.09
      expect(t.netAfterDiscounts, Money.fromDouble(170));
      expect(t.serviceChargeAmount, Money.fromDouble(17));
      expect(t.preTaxTotal, Money.fromDouble(187));
      expect(t.vatAmount, t.preTaxTotal * 0.07);
      expect(t.payableTotal, t.preTaxTotal + t.vatAmount);
    });

    test('discounts clamp at zero net', () {
      final t = SalePayableCalculator.compute(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(50),
          cartDiscountAmount: Money.fromDouble(80),
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
      );
      expect(t.netAfterDiscounts, Money.zero);
      expect(t.payableTotal, Money.zero);
    });
  });

  group('SalePayableCalculator.computeWithServiceChargeAmount', () {
    test('uses fixed SC amount instead of rate-derived SC', () {
      final t = SalePayableCalculator.computeWithServiceChargeAmount(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(100),
          serviceChargeRate: 10,
          vatMode: 'EXCLUSIVE',
          vatRate: 7,
        ),
        serviceChargeAmount: Money.fromDouble(25),
      );
      expect(t.netAfterDiscounts, Money.fromDouble(100));
      expect(t.serviceChargeAmount, Money.fromDouble(25));
      expect(t.preTaxTotal, Money.fromDouble(125));
      expect(t.vatAmount, Money.fromDouble(8.75));
      expect(t.payableTotal, Money.fromDouble(133.75));
      expect(t.serviceChargeRate, 10);
    });

    test('fixed SC is applied after discounts', () {
      final t = SalePayableCalculator.computeWithServiceChargeAmount(
        SalePayableInput(
          itemsSubtotal: Money.fromDouble(200),
          cartDiscountAmount: Money.fromDouble(50),
          serviceChargeRate: 10,
          vatMode: 'NONE',
          vatRate: 0,
        ),
        serviceChargeAmount: Money.fromDouble(15),
      );
      expect(t.netAfterDiscounts, Money.fromDouble(150));
      expect(t.serviceChargeAmount, Money.fromDouble(15));
      expect(t.payableTotal, Money.fromDouble(165));
    });
  });

  group('SalePayableCalculator.fromCart / SC resolve', () {
    test('restaurant uses default SC when cart rate null', () {
      final settings = const Settings(
        businessConfig: BusinessConfig(
          businessType: BusinessType.restaurant,
          defaultServiceChargeRate: 10,
        ),
        taxConfig: TaxConfig(vatMode: 'EXCLUSIVE', vatRate: 7),
      );
      final cart = CartState(items: [tCartItem]); // 2 × 100 = 200
      final rate = SalePayableCalculator.resolvedServiceChargeRate(
        settings: settings,
        cartServiceChargeRate: cart.serviceChargeRate,
      );
      expect(rate, 10);
      final t = cart.payableTotals(settings);
      // net 200, SC 20, preTax 220, VAT 15.4, payable 235.4
      expect(t.serviceChargeAmount, Money.fromDouble(20));
      expect(t.payableTotal, t.preTaxTotal + t.vatAmount);
      expect(t.payableTotal, isNot(cart.total + cart.serviceChargeAmount));
    });

    test('retail ignores default SC', () {
      final settings = const Settings(
        taxConfig: TaxConfig(vatMode: 'EXCLUSIVE', vatRate: 7),
      );
      final cart = CartState(items: [tCartItem]);
      expect(
        SalePayableCalculator.resolvedServiceChargeRate(
          settings: settings,
          cartServiceChargeRate: cart.serviceChargeRate,
        ),
        0,
      );
      final t = cart.payableTotals(settings);
      expect(t.serviceChargeAmount, Money.zero);
      expect(t.payableTotal, Money.fromDouble(214)); // 200 + 7%
    });
  });
}
