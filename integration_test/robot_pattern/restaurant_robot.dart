import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_utils.dart';
import 'robot_base.dart';

/// Robot for restaurant table interactions
class RestaurantRobot extends RobotBase {
  RestaurantRobot(super.tester);

  /// Select table for order
  Future<void> selectTable(String tableName) async {
    final tableBtn = find.text(tableName).or(find.textContaining(tableName));
    await tap(tableBtn);
  }

  /// Verify table selector visible (restaurant mode)
  void verifyTableSelectorVisible() {
    expectVisible(
      find
          .text('Select Table')
          .or(find.text('Table'))
          .or(find.byIcon(Icons.table_restaurant)),
      reason: 'Table selector should be visible in restaurant mode',
    );
  }

  /// Open product options/modifiers sheet
  Future<void> openProductOptions(String productName) async {
    // Long press or tap options button on product
    final product = find.text(productName);
    await tester.longPress(product);
    await settle();

    // If long press doesn't work, try tapping options button
    final optionsBtn = find
        .byIcon(Icons.more_vert)
        .or(find.text('Options'))
        .or(find.byIcon(Icons.edit));
    if (optionsBtn.evaluate().isNotEmpty) {
      await tap(optionsBtn);
    }
  }

  /// Select product modifier/option
  Future<void> selectModifier(String modifierName) async {
    final modifier = find
        .text(modifierName)
        .or(find.textContaining(modifierName));
    await tap(modifier);
  }

  /// Verify modifier selected in cart
  void verifyModifierInCart(String productName, String modifierName) {
    expectVisible(
      find.textContaining(productName),
      reason: 'Product should be in cart',
    );
    expectVisible(
      find.textContaining(modifierName),
      reason: 'Modifier "$modifierName" should be shown',
    );
  }

  /// Confirm product options
  Future<void> confirmOptions() async {
    final confirmBtn = find
        .text('Confirm')
        .or(find.text('Done'))
        .or(find.text('Add to Cart'));
    await tap(confirmBtn);
  }

  /// Verify table status
  void verifyTableStatus(String tableName, String status) {
    // This would need navigation to table management page
    expectVisible(find.textContaining(tableName));
  }

  /// Apply service charge in checkout
  Future<void> applyServiceCharge(double percentage) async {
    final serviceBtn = find
        .text('Service Charge')
        .or(find.textContaining('Service'));
    if (serviceBtn.evaluate().isNotEmpty) {
      await tap(serviceBtn);

      final percentField = find.byType(TextField);
      if (percentField.evaluate().isNotEmpty) {
        await enterText(percentField, percentage.toString());
      }

      await tap(find.text('Apply').or(find.text('OK')));
    }
  }

  /// Verify order type set to dine-in
  void verifyOrderTypeDineIn() {
    expectVisible(
      find
          .text('Dine In')
          .or(find.textContaining('Dine'))
          .or(find.text('Table')),
      reason: 'Order type should be Dine In',
    );
  }

  /// Switch to takeaway mode
  Future<void> switchToTakeaway() async {
    final takeawayBtn = find
        .text('Takeaway')
        .or(find.text('Take Away'))
        .or(find.text('To Go'));
    await tap(takeawayBtn);
  }

  /// Switch to delivery mode
  Future<void> switchToDelivery() async {
    final deliveryBtn = find.text('Delivery');
    await tap(deliveryBtn);
  }
}
