import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'robot_pattern/sale_robot.dart';
import 'robot_pattern/checkout_robot.dart';

/// Journey 3: Draft Cart Recovery
///
/// Scenario: Cashier starts a sale, app crashes, cart is recovered
///
/// GIVEN cashier has items in cart
/// WHEN app is force-closed (simulate crash)
/// AND app is reopened
/// THEN draft cart is recovered
/// AND all items are present
/// AND quantities are correct
/// AND cart total matches
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey 3: Draft Cart Recovery', () {
    late SaleRobot saleRobot;
    late CheckoutRobot checkoutRobot;

    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);
    });

    tearDown(() async {
      await TestApp.dispose();
    });

    testWidgets('Recover draft cart after app restart', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);

      // GIVEN: Start app and add items to cart
      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add products to cart
      await saleRobot.addProductToCart('Coffee');
      await saleRobot.addProductToCart('Burger');
      await saleRobot.addProductToCart('Ice Cream');

      saleRobot.verifyCartItem('Coffee', quantity: 1);
      saleRobot.verifyCartItem('Burger', quantity: 1);
      saleRobot.verifyCartItem('Ice Cream', quantity: 1);

      final expectedTotal = Money.fromDouble(215.0); // 45 + 120 + 50
      saleRobot.verifyCartTotal(expectedTotal);

      // Autosave debounce is 1.5s — wait past it before asserting DB (Wave B).
      await tester.pump(const Duration(milliseconds: 1600));
      var draftCarts = await TestApp.database
          .select(TestApp.database.draftCarts)
          .get();

      expect(
        draftCarts.where((d) => !d.isArchived).length,
        1,
        reason: 'Draft cart should be auto-saved',
      );

      final draftId = draftCarts.first.id;

      var draftItems = await (TestApp.database.select(
        TestApp.database.draftCartItems,
      )..where((item) => item.cartId.equals(draftId))).get();

      expect(draftItems.length, 3, reason: 'Should have 3 items in draft');

      // WHEN: Simulate app crash and restart
      await TestApp.restartApp(tester);
      await tester.pump(const Duration(seconds: 3));

      // Navigate to sale page
      await saleRobot.navigateToSalePage();

      // THEN: Verify draft cart recovered
      saleRobot.verifyCartItem('Coffee', quantity: 1);
      saleRobot.verifyCartItem('Burger', quantity: 1);
      saleRobot.verifyCartItem('Ice Cream', quantity: 1);

      // Verify total is correct after recovery
      saleRobot.verifyCartTotal(expectedTotal);

      // Complete the sale to verify cart works properly after recovery
      await saleRobot.proceedToCheckout();
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(300.0);
      await checkoutRobot.completePayment();

      checkoutRobot.verifyPaymentComplete();

      // Verify sale recorded
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      expect(sales.length, 1, reason: 'Sale should be recorded');

      // Close receipt
      await checkoutRobot.closeReceipt();

      // THEN: Verify draft is cleared after completing sale
      draftCarts = await TestApp.database
          .select(TestApp.database.draftCarts)
          .get();

      expect(
        draftCarts.where((d) => !d.isArchived).isEmpty,
        true,
        reason: 'Draft cart should be cleared after sale',
      );
    });

    testWidgets('Draft is NOT loaded if user explicitly cleared cart', (
      tester,
    ) async {
      saleRobot = SaleRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add items to cart
      await saleRobot.addProductToCart('Coffee');
      await saleRobot.addProductToCart('Burger');

      saleRobot.verifyCartItem('Coffee', quantity: 1);
      saleRobot.verifyCartItem('Burger', quantity: 1);

      // Wait for draft to save (autosave debounce 1.5s)
      await tester.pump(const Duration(milliseconds: 1600));

      // Remove items manually (user clears cart)
      await saleRobot.removeFromCart('Coffee');
      await saleRobot.removeFromCart('Burger');

      saleRobot.verifyCartEmpty();

      // Wait for draft to be marked as archived/cleared (autosave debounce)
      await tester.pump(const Duration(milliseconds: 1600));

      // Restart app
      await TestApp.restartApp(tester);
      await saleRobot.navigateToSalePage();

      // THEN: Cart should remain empty (draft not recovered)
      saleRobot.verifyCartEmpty();
    });

    testWidgets('Multiple draft carts do not duplicate items', (tester) async {
      saleRobot = SaleRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add first product
      await saleRobot.addProductToCart('Coffee');
      saleRobot.verifyCartItem('Coffee', quantity: 1);

      // Restart app
      await TestApp.restartApp(tester);
      await saleRobot.navigateToSalePage();

      // Verify only 1 coffee (no duplication)
      saleRobot.verifyCartItem('Coffee', quantity: 1);

      // Add another product
      await saleRobot.addProductToCart('Burger');

      // Restart again
      await TestApp.restartApp(tester);
      await saleRobot.navigateToSalePage();

      // THEN: Verify both items present, no duplication
      saleRobot.verifyCartItem('Coffee', quantity: 1);
      saleRobot.verifyCartItem('Burger', quantity: 1);

      // Verify total is correct
      saleRobot.verifyCartTotal(Money.fromDouble(165.0)); // 45 + 120
    });

    testWidgets('Draft persists with quantity changes', (tester) async {
      saleRobot = SaleRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add product multiple times
      await saleRobot.addProductToCart('Coffee');
      await saleRobot.addProductToCart('Coffee');
      await saleRobot.addProductToCart('Coffee');

      saleRobot.verifyCartItem('Coffee', quantity: 3);

      // Wait for draft save (autosave debounce 1.5s)
      await tester.pump(const Duration(milliseconds: 1600));

      // Restart app
      await TestApp.restartApp(tester);
      await saleRobot.navigateToSalePage();

      // THEN: Verify quantity persisted
      saleRobot.verifyCartItem('Coffee', quantity: 3);
      saleRobot.verifyCartTotal(Money.fromDouble(135.0)); // 45 * 3
    });

    testWidgets('Draft recovery with empty cart does not crash', (
      tester,
    ) async {
      saleRobot = SaleRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Start with empty cart
      saleRobot.verifyCartEmpty();

      // Restart app
      await TestApp.restartApp(tester);
      await saleRobot.navigateToSalePage();

      // THEN: Should still be empty, no crash
      saleRobot.verifyCartEmpty();

      // Add item to verify app still works
      await saleRobot.addProductToCart('Coffee');
      saleRobot.verifyCartItem('Coffee', quantity: 1);
    });
  });
}
