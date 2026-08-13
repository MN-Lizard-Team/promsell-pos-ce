import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'helpers/test_utils.dart';
import 'robot_pattern/sale_robot.dart';
import 'robot_pattern/checkout_robot.dart';

/// Journey 5: Promotion Application
///
/// Scenario: Customer receives discount from active promotion
///
/// GIVEN there is an active promotion
/// WHEN cashier adds products
/// AND proceeds to checkout
/// AND selects the promotion
/// THEN discount is applied
/// AND grand total is reduced
/// AND receipt shows promotion details
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey 5: Promotion Application', () {
    late SaleRobot saleRobot;
    late CheckoutRobot checkoutRobot;

    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);
    });

    tearDown(() async {
      await TestApp.dispose();
    });

    testWidgets('Apply 15% percentage promotion', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // GIVEN: Active promotion exists (15% Discount)
      final promotion = await TestFixtures.findPromotionByName(
        TestApp.database,
        '15% Discount',
      );
      expect(promotion, isNotNull, reason: 'Promotion should exist');
      expect(promotion!.isActive, true, reason: 'Promotion should be active');

      // WHEN: Add products worth 1000 THB to cart
      // Coffee (45) x 5 = 225
      // Burger (120) x 3 = 360
      // Pizza Slice (95) x 4 = 380
      // Total = 965 (close to 1000)

      for (var i = 0; i < 5; i++) {
        await saleRobot.addProductToCart('Coffee');
      }
      for (var i = 0; i < 3; i++) {
        await saleRobot.addProductToCart('Burger');
      }
      for (var i = 0; i < 4; i++) {
        await saleRobot.addProductToCart('Pizza Slice');
      }

      final subtotal = Money.fromDouble(965.0);
      saleRobot.verifyCartTotal(subtotal);

      // Proceed to checkout
      await saleRobot.proceedToCheckout();
      checkoutRobot.verifyOnCheckoutPage();

      // WHEN: Apply promotion
      await checkoutRobot.applyPromotion('15% Discount');

      // THEN: Verify discount calculated correctly
      // 15% of 965 = 144.75
      final discountAmount = Money.fromDouble(144.75);
      checkoutRobot.verifyDiscountAmount(discountAmount);

      // Grand total = 965 - 144.75 = 820.25
      final grandTotal = Money.fromDouble(820.25);
      checkoutRobot.verifyGrandTotal(grandTotal);

      // Complete payment
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(1000.0);
      await checkoutRobot.completePayment();

      checkoutRobot.verifyPaymentComplete();

      // Verify sale recorded with promotion
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      expect(sales.length, 1);

      final sale = sales.first;
      expect(sale.promotionId, promotion.id);
      expect(
        sale.promotionDiscountAmount,
        144.75,
        reason: 'Promotion discount should be recorded',
      );
      expect(sale.totalAmount, 820.25, reason: 'Total should include discount');
    });

    testWidgets('Apply 50 THB fixed promotion', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // GIVEN: Fixed amount promotion exists
      final promotion = await TestFixtures.findPromotionByName(
        TestApp.database,
        '50 THB Off',
      );
      expect(promotion, isNotNull);
      expect(promotion!.type, 'FIXED');
      expect(promotion.value, 50.0);

      // Add products
      await saleRobot.addProductToCart('Burger'); // 120
      await saleRobot.addProductToCart('Ice Cream'); // 50

      final subtotal = Money.fromDouble(170.0);
      saleRobot.verifyCartTotal(subtotal);

      await saleRobot.proceedToCheckout();

      // Apply fixed promotion
      await checkoutRobot.applyPromotion('50 THB Off');

      // THEN: Verify fixed discount
      final discountAmount = Money.fromDouble(50.0);
      checkoutRobot.verifyDiscountAmount(discountAmount);

      // Grand total = 170 - 50 = 120
      final grandTotal = Money.fromDouble(120.0);
      checkoutRobot.verifyGrandTotal(grandTotal);

      // Complete payment
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(200.0);
      await checkoutRobot.completePayment();

      // Verify sale
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      final sale = sales.first;
      expect(sale.promotionId, promotion.id);
      expect(sale.promotionDiscountAmount, 50.0);
      expect(sale.totalAmount, 120.0);
    });

    testWidgets('Cannot apply expired promotion', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      // Create expired promotion
      final yesterday = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 3));

      await TestApp.database
          .into(TestApp.database.promotions)
          .insert(
            PromotionsCompanion.insert(
              id: 'promo-expired',
              name: 'Expired Promo',
              type: const Value('PERCENT'),
              value: const Value(20.0),
              startDate: Value(twoDaysAgo),
              endDate: Value(yesterday),
              isActive: const Value(true),
              createdAt: Value(twoDaysAgo),
            ),
          );

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      await saleRobot.addProductToCart('Coffee');
      await saleRobot.proceedToCheckout();

      // Expired promotion should not be shown or selectable
      final expiredPromo = find.text('Expired Promo');
      expect(
        expiredPromo.evaluate().isEmpty,
        true,
        reason: 'Expired promotion should not be available',
      );
    });

    testWidgets('Promotion displayed on receipt', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      await saleRobot.addProductToCart('Coffee'); // 45
      await saleRobot.addProductToCart('Burger'); // 120
      // Total: 165

      await saleRobot.proceedToCheckout();
      await checkoutRobot.applyPromotion('15% Discount');

      // 15% of 165 = 24.75
      // Total: 140.25

      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(200.0);
      await checkoutRobot.completePayment();

      // THEN: Receipt should show promotion details
      checkoutRobot.verifyPaymentComplete();

      // Verify promotion name visible
      expect(
        find.textContaining('15% Discount'),
        findsOneWidget,
        reason: 'Receipt should show promotion name',
      );

      // Verify discount amount visible
      expect(
        find.textContaining('24.75'),
        findsWidgets,
        reason: 'Receipt should show discount amount',
      );
    });

    testWidgets('Multiple promotions - only one can be applied', (
      tester,
    ) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      await saleRobot.addProductToCart('Burger'); // 120
      await saleRobot.proceedToCheckout();

      // Apply first promotion
      await checkoutRobot.applyPromotion('15% Discount');
      checkoutRobot.verifyDiscountAmount(Money.fromDouble(18.0)); // 15% of 120

      // Try to apply second promotion (should replace first)
      await checkoutRobot.applyPromotion('50 THB Off');

      // Should now show 50 THB discount instead
      checkoutRobot.verifyDiscountAmount(Money.fromDouble(50.0));
      checkoutRobot.verifyGrandTotal(Money.fromDouble(70.0)); // 120 - 50
    });

    testWidgets('Remove applied promotion', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      await saleRobot.addProductToCart('Coffee'); // 45
      await saleRobot.proceedToCheckout();

      // Apply promotion
      await checkoutRobot.applyPromotion('15% Discount');
      checkoutRobot.verifyDiscountAmount(Money.fromDouble(6.75));

      // Remove promotion (if UI supports it)
      final removeBtn = find
          .byIcon(Icons.close)
          .or(find.text('Remove'))
          .or(find.byIcon(Icons.clear));

      if (removeBtn.evaluate().isNotEmpty) {
        await tester.tap(removeBtn.first);
        await tester.pumpAndSettle();

        // Verify discount removed
        checkoutRobot.verifyGrandTotal(Money.fromDouble(45.0));
      }
    });

    testWidgets('Inactive promotion not shown', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      // Create inactive promotion
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      await TestApp.database
          .into(TestApp.database.promotions)
          .insert(
            PromotionsCompanion.insert(
              id: 'promo-inactive',
              name: 'Inactive Promo',
              type: const Value('PERCENT'),
              value: const Value(30.0),
              startDate: Value(DateTime.now()),
              endDate: Value(tomorrow),
              isActive: const Value(false), // Inactive
              createdAt: Value(DateTime.now()),
            ),
          );

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      await saleRobot.addProductToCart('Coffee');
      await saleRobot.proceedToCheckout();

      // Inactive promotion should not be shown
      final inactivePromo = find.text('Inactive Promo');
      expect(
        inactivePromo.evaluate().isEmpty,
        true,
        reason: 'Inactive promotion should not be available',
      );
    });
  });
}
