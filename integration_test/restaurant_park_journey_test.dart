import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'robot_pattern/checkout_robot.dart';
import 'robot_pattern/restaurant_robot.dart';
import 'robot_pattern/sale_robot.dart';

/// Journey 7: Restaurant Park → Reopen → Pay Frees Table
///
/// Scenario: Dine-in bill is parked, reopened from the open-bills board,
/// then paid — the table must free the instant the sale commits.
///
/// GIVEN restaurant mode with seeded tables
/// WHEN waiter adds items and binds the cart to a table
/// AND parks the bill
/// THEN the table is effectively occupied (derived from the active draft)
/// WHEN the parked bill is reopened for that table
/// THEN the cart holds exactly the parked lines
/// WHEN the bill is paid
/// THEN the sale is recorded with the table id
/// AND the table reports available again (atomic checkout-frees-table)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey 7: Restaurant Park-Reopen-Pay', () {
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

    testWidgets('Park dine-in bill → reopen → pay frees the table', (
      tester,
    ) async {
      saleRobot = SaleRobot(tester);
      checkoutRobot = CheckoutRobot(tester);
      restaurantRobot = RestaurantRobot(tester);

      await TestApp.pumpApp(tester);
      await saleRobot.navigateToSalePage();

      // Take the order: Burger (120) + Green Tea (40).
      await saleRobot.addProductToCart('Burger');
      await saleRobot.addProductToCart('Green Tea');
      saleRobot.verifyCartItem('Burger', quantity: 1);
      saleRobot.verifyCartItem('Green Tea', quantity: 1);

      // Bind to Table 5 on checkout.
      await saleRobot.proceedToCheckout();
      await restaurantRobot.selectDineIn();
      restaurantRobot.verifyTableSelectorVisible();
      await restaurantRobot.selectTable('Table 5');

      // Park the bound bill; step back off checkout first.
      await restaurantRobot.parkCurrentCart();
      await tester.pump(const Duration(milliseconds: 1600));
      await restaurantRobot.assertTableStatusViaDb(
        'Table 5',
        TableStatus.occupied,
      );

      // Reopen the parked bill for the table.
      await restaurantRobot.reopenDraftForTable('Table 5');
      saleRobot.verifyCartItem('Burger', quantity: 1);
      saleRobot.verifyCartItem('Green Tea', quantity: 1);
      saleRobot.verifyCartTotal(Money.fromDouble(160.0)); // 120 + 40

      // Pay — no service-charge setting seeded, payable = 160.
      await saleRobot.proceedToCheckout();
      await checkoutRobot.selectPaymentMethod('Cash');
      await checkoutRobot.enterCashReceived(200.0);
      await checkoutRobot.completePayment();
      checkoutRobot.verifyPaymentComplete();

      // The sale carries the table id…
      final sales = await TestApp.database.select(TestApp.database.sales).get();
      expect(sales.single.tableId, 'table-005');

      // …and the table is free again without any manual status write.
      await restaurantRobot.assertTableStatusViaDb(
        'Table 5',
        TableStatus.available,
      );
    });
  });
}
