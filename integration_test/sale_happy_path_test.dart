import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'robot_pattern/sale_robot.dart';
import 'robot_pattern/checkout_robot.dart';

/// Journey 1: Happy Path Sale (Retail Mode)
/// 
/// Scenario: Cashier completes a simple cash sale
/// 
/// GIVEN the app is in retail mode
/// AND there are products in inventory
/// WHEN cashier opens sale page
/// AND adds 2 products to cart
/// AND proceeds to checkout
/// AND selects cash payment
/// AND completes the sale
/// THEN receipt is generated
/// AND inventory is decremented
/// AND sale is recorded in database
/// AND cart is cleared
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey 1: Happy Path Sale (Retail Mode)', () {
    late SaleRobot saleRobot;
    late CheckoutRobot checkoutRobot;

    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);
    });

    tearDown(() async {
      await TestApp.dispose();
    });

    testWidgets('Complete a simple cash sale with 2 products', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      // GIVEN: App is running and on sale page
      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Get initial stock levels
      final coffee = await TestFixtures.findProductByName(
        TestApp.database,
        'Coffee',
      );
      final burger = await TestFixtures.findProductByName(
        TestApp.database,
        'Burger',
      );
      
      expect(coffee, isNotNull, reason: 'Coffee product should exist');
      expect(burger, isNotNull, reason: 'Burger product should exist');
      
      final coffeeInitialStock = coffee!.stock;
      final burgerInitialStock = burger!.stock;

      // WHEN: Add 2 products to cart
      await saleRobot.addProductToCart('Coffee');
      saleRobot.verifyCartItem('Coffee', quantity: 1);

      await saleRobot.addProductToCart('Burger');
      saleRobot.verifyCartItem('Burger', quantity: 1);

      // Verify cart total: Coffee (45) + Burger (120) = 165
      final expectedTotal = Money.fromDouble(165.0);
      saleRobot.verifyCartTotal(expectedTotal);

      // WHEN: Proceed to checkout
      await saleRobot.proceedToCheckout();
      checkoutRobot.verifyOnCheckoutPage();
      checkoutRobot.verifyGrandTotal(expectedTotal);

      // WHEN: Select cash payment
      await checkoutRobot.selectPaymentMethod('Cash');
      
      // Enter cash received (500 THB)
      await checkoutRobot.enterCashReceived(500.0);
      
      // Verify change: 500 - 165 = 335
      final expectedChange = Money.fromDouble(335.0);
      checkoutRobot.verifyChange(expectedChange);

      // WHEN: Complete the sale
      await checkoutRobot.completePayment();

      // THEN: Verify payment complete
      checkoutRobot.verifyPaymentComplete();

      // Verify sale recorded in database
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      expect(sales.length, 1, reason: 'One sale should be recorded');
      
      final sale = sales.first;
      expect(
        sale.totalAmount,
        165.0,
        reason: 'Sale total should be 165.00',
      );
      expect(
        sale.paymentMethod,
        'cash',
        reason: 'Payment method should be cash',
      );
      expect(
        sale.amountReceived,
        500.0,
        reason: 'Amount received should be 500.00',
      );
      expect(
        sale.changeAmount,
        335.0,
        reason: 'Change should be 335.00',
      );

      // Verify sale items
      final saleItems = await TestApp.database.select(
        TestApp.database.saleItems,
      ).get();
      expect(saleItems.length, 2, reason: 'Should have 2 sale items');

      // Verify inventory decremented
      final coffeeAfter = await TestFixtures.findProductByName(
        TestApp.database,
        'Coffee',
      );
      final burgerAfter = await TestFixtures.findProductByName(
        TestApp.database,
        'Burger',
      );
      
      expect(
        coffeeAfter!.stock,
        coffeeInitialStock - 1,
        reason: 'Coffee stock should decrease by 1',
      );
      expect(
        burgerAfter!.stock,
        burgerInitialStock - 1,
        reason: 'Burger stock should decrease by 1',
      );

      // Verify inventory logs created
      final logs = await TestApp.database.select(
        TestApp.database.inventoryLogs,
      ).get();
      expect(
        logs.length,
        2,
        reason: 'Should have 2 inventory log entries',
      );
      expect(
        logs.where((l) => l.type == 'SALE').length,
        2,
        reason: 'Both logs should be SALE type',
      );

      // THEN: Close receipt and verify cart is cleared
      await checkoutRobot.closeReceipt();
      await tester.pumpAndSettle();
      
      saleRobot.verifyCartEmpty();

      // Verify draft cart cleared
      final draftCarts = await TestApp.database.select(
        TestApp.database.draftCarts,
      ).get();
      expect(
        draftCarts.where((d) => !d.isArchived).isEmpty,
        true,
        reason: 'No active draft carts should exist',
      );
    });

    testWidgets('Reject checkout with empty cart', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // GIVEN: Cart is empty
      saleRobot.verifyCartEmpty();

      // WHEN: Try to checkout with empty cart
      final checkoutBtn = find.text('Checkout');
      
      // Button should be disabled or not visible
      if (checkoutBtn.evaluate().isNotEmpty) {
        await tester.tap(checkoutBtn);
        await tester.pumpAndSettle();
        
        // Should show error or stay on sale page
        final onCheckout = find.text('Payment').evaluate().isNotEmpty;
        expect(
          onCheckout,
          false,
          reason: 'Should not proceed to checkout with empty cart',
        );
      }
    });

    testWidgets('Complete sale with quantity adjustment', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add Coffee 3 times
      await saleRobot.addProductToCart('Coffee');
      await saleRobot.addProductToCart('Coffee');
      await saleRobot.addProductToCart('Coffee');

      saleRobot.verifyCartItem('Coffee', quantity: 3);

      // Verify total: 45 * 3 = 135
      saleRobot.verifyCartTotal(Money.fromDouble(135.0));

      // Complete checkout
      await saleRobot.proceedToCheckout();
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(200.0);
      await checkoutRobot.completePayment();

      checkoutRobot.verifyPaymentComplete();

      // Verify inventory: 100 - 3 = 97
      final coffee = await TestFixtures.findProductByName(
        TestApp.database,
        'Coffee',
      );
      expect(coffee!.stock, 97, reason: 'Coffee stock should be 97');
    });
  });
}
