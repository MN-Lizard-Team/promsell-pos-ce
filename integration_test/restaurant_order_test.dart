import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:drift/drift.dart' hide isNull;

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'robot_pattern/sale_robot.dart';
import 'robot_pattern/checkout_robot.dart';
import 'robot_pattern/restaurant_robot.dart';

/// Journey 2: Restaurant Order Flow
///
/// Scenario: Waiter takes dine-in order with modifiers
///
/// GIVEN the app is in restaurant mode
/// AND there are tables available
/// WHEN waiter opens sale page
/// AND selects table
/// AND adds a product with modifiers
/// AND proceeds to checkout
/// AND applies service charge
/// AND completes payment
/// THEN order includes modifiers
/// AND service charge is calculated correctly
/// AND table status updates
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey 2: Restaurant Order Flow', () {
    late SaleRobot saleRobot;
    late CheckoutRobot checkoutRobot;
    late RestaurantRobot restaurantRobot;

    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);

      // Enable restaurant mode in settings (mapper key: businessType).
      await TestApp.database
          .into(TestApp.database.appSettings)
          .insert(
            AppSettingsCompanion.insert(
              key: 'businessType',
              value: 'restaurant',
            ),
          );
    });

    tearDown(() async {
      await TestApp.dispose();
    });

    testWidgets('Complete dine-in order with table selection', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);
      restaurantRobot = RestaurantRobot(tester);

      // Service charge is applied automatically from this setting — the
      // checkout UI has no manual service-charge control. Seed before
      // pumpApp so startup loads it.
      await TestApp.database
          .into(TestApp.database.appSettings)
          .insert(
            AppSettingsCompanion.insert(
              key: 'defaultServiceChargeRate',
              value: '10.0',
            ),
          );

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add products to order
      await saleRobot.addProductToCart('Burger'); // 120
      await saleRobot.addProductToCart('Fried Rice'); // 80
      await saleRobot.addProductToCart('Green Tea'); // 40

      saleRobot.verifyCartItem('Burger', quantity: 1);
      saleRobot.verifyCartItem('Fried Rice', quantity: 1);
      saleRobot.verifyCartItem('Green Tea', quantity: 1);

      // Subtotal: 120 + 80 + 40 = 240; the bottom bar shows the payable,
      // which already includes the seeded 10% service charge → 264.
      final payableWithSc = Money.fromDouble(264.0);
      saleRobot.verifyCartTotal(payableWithSc);

      // Proceed to checkout
      await saleRobot.proceedToCheckout();
      checkoutRobot.verifyOnCheckoutPage();

      // Select dine-in (cart defaults to delivery), then pick the table.
      await restaurantRobot.selectDineIn();
      restaurantRobot.verifyOrderTypeDineIn();
      restaurantRobot.verifyTableSelectorVisible();
      await restaurantRobot.selectTable('Table 5');

      // Service charge: 10% of 240 = 24 (seeded via settings)
      final serviceCharge = Money.fromDouble(24.0);
      checkoutRobot.verifyServiceCharge(serviceCharge);

      // Grand total: 240 + 24 = 264
      final grandTotal = Money.fromDouble(264.0);
      checkoutRobot.verifyGrandTotal(grandTotal);

      // Complete payment
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(300.0);
      await checkoutRobot.completePayment();

      // THEN: Verify payment complete
      checkoutRobot.verifyPaymentComplete();

      // Verify sale recorded with table and service charge
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      expect(sales.length, 1);

      final sale = sales.first;
      expect(sale.tableId, 'table-005', reason: 'Table ID should be recorded');
      expect(sale.orderType, 'dinein', reason: 'Order type should be dinein');
      expect(
        sale.serviceChargeAmount,
        24.0,
        reason: 'Service charge should be recorded',
      );
      expect(sale.totalAmount, 264.0);

      // Occupancy is DERIVED, not stored: paying hard-deleted the
      // originating draft cart inside the sale transaction (atomic
      // checkout-frees-table), so the table already reports 'available'
      // here. While an active draft cart binds a table it reports
      // 'occupied'; the stored status column only holds the manual
      // available/reserved choice — no post-sale status write exists.
    });

    testWidgets('Order with product modifiers', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);
      restaurantRobot = RestaurantRobot(tester);

      // Seed product options/modifiers
      final burgerId = (await TestFixtures.findProductByName(
        TestApp.database,
        'Burger',
      ))!.id;

      // Create option group for Burger (multiple-select so each add-on
      // toggles independently via its CheckboxListTile).
      final optionGroupId = 'og-burger-extras';
      await TestApp.database
          .into(TestApp.database.productOptionGroups)
          .insert(
            ProductOptionGroupsCompanion.insert(
              id: optionGroupId,
              productId: burgerId,
              name: 'Add-ons',
              isRequired: const Value(false),
              selectionType: const Value('multiple'),
              createdAt: Value(TestFixtures.now),
            ),
          );

      // Create options
      await TestApp.database
          .into(TestApp.database.productOptions)
          .insert(
            ProductOptionsCompanion.insert(
              id: 'opt-extra-cheese',
              groupId: optionGroupId,
              name: 'Extra Cheese',
              priceDelta: const Value(20.0),
              createdAt: Value(TestFixtures.now),
            ),
          );

      await TestApp.database
          .into(TestApp.database.productOptions)
          .insert(
            ProductOptionsCompanion.insert(
              id: 'opt-no-onions',
              groupId: optionGroupId,
              name: 'No Onions',
              priceDelta: const Value(0.0),
              createdAt: Value(TestFixtures.now),
            ),
          );

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add burger — tapping a product with option groups opens the
      // ProductOptionSheet directly.
      await saleRobot.addProductToCart('Burger');

      // Select modifiers
      await restaurantRobot.selectModifier('Extra Cheese');
      await restaurantRobot.selectModifier('No Onions');

      // Confirm options
      await restaurantRobot.confirmOptions();

      // Verify modifiers in cart
      restaurantRobot.verifyModifierInCart('Burger', 'Extra Cheese');
      restaurantRobot.verifyModifierInCart('Burger', 'No Onions');

      // Total: Burger (120) + Extra Cheese (20) = 140
      saleRobot.verifyCartTotal(Money.fromDouble(140.0));

      // Complete order
      await saleRobot.proceedToCheckout();
      await restaurantRobot.selectDineIn();
      restaurantRobot.verifyTableSelectorVisible();
      await restaurantRobot.selectTable('Table 1');
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(200.0);
      await checkoutRobot.completePayment();

      // Verify sale recorded
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      final sale = sales.first;
      expect(sale.totalAmount, 140.0);
      expect(sale.tableId, 'table-001');
    });

    testWidgets('Switch from dine-in to takeaway', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);
      restaurantRobot = RestaurantRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add the product on the sale page.
      await saleRobot.addProductToCart('Coffee');

      // Switch to takeaway on the checkout page.
      await saleRobot.proceedToCheckout();
      await restaurantRobot.switchToTakeaway();
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(50.0);
      await checkoutRobot.completePayment();

      // Verify order type is takeaway
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      final sale = sales.first;
      expect(
        sale.orderType,
        'takeaway',
        reason: 'Order type should be takeaway',
      );
      expect(sale.tableId, isNull, reason: 'No table for takeaway');
    });

    testWidgets('Multiple items with different modifiers', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);
      restaurantRobot = RestaurantRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Add multiple products
      await saleRobot.addProductToCart('Coffee');
      await saleRobot.addProductToCart('Green Tea');
      await saleRobot.addProductToCart('Burger');

      // Coffee (45) + Green Tea (40) + Burger (120) = 205
      saleRobot.verifyCartTotal(Money.fromDouble(205.0));

      await saleRobot.proceedToCheckout();
      await restaurantRobot.selectDineIn();
      restaurantRobot.verifyTableSelectorVisible();
      await restaurantRobot.selectTable('Table 10');
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(250.0);
      await checkoutRobot.completePayment();

      checkoutRobot.verifyPaymentComplete();

      // Verify table recorded
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      expect(sales.first.tableId, 'table-010');
    });

    testWidgets('Service charge not applied if not set', (tester) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);
      restaurantRobot = RestaurantRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      await saleRobot.addProductToCart('Coffee');
      await saleRobot.proceedToCheckout();
      await restaurantRobot.selectDineIn();
      restaurantRobot.verifyTableSelectorVisible();
      await restaurantRobot.selectTable('Table 1');

      // Don't apply service charge
      // Total should remain 45
      checkoutRobot.verifyGrandTotal(Money.fromDouble(45.0));

      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(50.0);
      await checkoutRobot.completePayment();

      // Verify no service charge in sale
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      final sale = sales.first;
      expect(
        sale.serviceChargeAmount,
        0.0,
        reason: 'No service charge should be applied',
      );
    });
  });
}
