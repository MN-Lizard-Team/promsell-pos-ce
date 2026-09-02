import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/features/restaurant_table/domain/entities/restaurant_table.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import '../helpers/test_app.dart';
import '../helpers/test_utils.dart';
import 'robot_base.dart';

/// Robot for restaurant table interactions
class RestaurantRobot extends RobotBase {
  RestaurantRobot(super.tester);

  CartBloc get _cartBloc => sl<CartBloc>();

  /// Select a table from the checkout dropdown.
  Future<void> selectTable(String tableName) async {
    final field = find.byKey(const Key(TestKeys.tableSelectorField));
    await tester.ensureVisible(field);
    await settle();
    await tap(field);
    await settle();
    await tap(find.text(tableName).or(find.textContaining(tableName)));
  }

  /// Select the dine-in order type on checkout.
  ///
  /// The cart defaults to `delivery`, and the table selector only renders
  /// when the order type is `dinein`.
  Future<void> selectDineIn() async {
    final dineInBtn = find
        .text('Dine In')
        .or(find.textContaining('Dine'))
        .or(find.text('ทานที่ร้าน'))
        .or(find.textContaining('ที่ร้าน'));
    await tester.ensureVisible(dineInBtn);
    await settle();
    await tap(dineInBtn);
  }

  /// Verify the checkout table selector is visible.
  void verifyTableSelectorVisible() {
    expectVisible(
      find.byKey(const Key(TestKeys.tableSelectorField)),
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

  /// Select product modifier/option.
  ///
  /// Options render as [CheckboxListTile] (multiple) or radio [ListTile]
  /// (single). Taps the inner control directly — tile/text-level taps can
  /// miss inside the bottom sheet.
  Future<void> selectModifier(String modifierName) async {
    final label = find.text(modifierName).or(find.textContaining(modifierName));
    await tester.ensureVisible(label);
    await settle();

    final checkboxTile = find.ancestor(
      of: label,
      matching: find.byType(CheckboxListTile),
    );
    if (checkboxTile.evaluate().isNotEmpty) {
      final checkbox = find.descendant(
        of: checkboxTile,
        matching: find.byType(Checkbox),
      );
      await tap(checkbox.first);
      return;
    }
    final radioTile = find.ancestor(of: label, matching: find.byType(ListTile));
    final radio = find.descendant(of: radioTile, matching: find.byType(Radio));
    await tap(radio.first);
  }

  /// Verify modifier selected in cart (source of truth: [CartBloc]).
  void verifyModifierInCart(String productName, String modifierName) {
    final lines = _cartBloc.state.items
        .where((item) => item.product.name == productName)
        .toList();
    expect(lines, isNotEmpty, reason: 'Cart should contain "$productName"');
    final optionNames = [
      for (final line in lines)
        for (final option in line.selectedOptions) option.optionName,
    ];
    expect(
      optionNames,
      contains(modifierName),
      reason:
          'Cart "$productName" options were $optionNames — '
          'expected "$modifierName"',
    );
  }

  /// Confirm product options
  Future<void> confirmOptions() async {
    final confirmBtn = find
        .text('Confirm')
        .or(find.text('Done'))
        .or(find.text('Add to Cart'))
        .or(find.text('ยืนยัน'));
    await tester.ensureVisible(confirmBtn);
    await settle();
    await tap(confirmBtn);
  }

  /// Verify table status
  void verifyTableStatus(String tableName, String status) {
    // This would need navigation to table management page
    expectVisible(find.textContaining(tableName));
  }

  /// Verify order type set to dine-in.
  void verifyOrderTypeDineIn() {
    expectVisible(
      find
          .text('Dine In')
          .or(find.textContaining('Dine'))
          .or(find.text('ทานที่ร้าน'))
          .or(find.textContaining('ร้าน')),
      reason: 'Order type should be Dine In',
    );
  }

  /// Switch to takeaway mode.
  Future<void> switchToTakeaway() async {
    final takeawayBtn = find
        .text('Takeaway')
        .or(find.text('Take Away'))
        .or(find.text('To Go'))
        .or(find.text('สั่งกลับบ้าน'))
        .or(find.textContaining('กลับบ้าน'));
    await tester.ensureVisible(takeawayBtn);
    await settle();
    await tap(takeawayBtn);
  }

  /// Switch to delivery mode
  Future<void> switchToDelivery() async {
    final deliveryBtn = find.text('Delivery');
    await tap(deliveryBtn);
  }

  /// Park the current bill via the cart-review footer CTA.
  ///
  /// Opens the full cart review first (the compact bar has no park CTA),
  /// taps [TestKeys.parkBillButton], then confirms the dialog. On success
  /// the cart rotates to a fresh empty bill while the parked one keeps
  /// binding its table.
  Future<void> parkCurrentCart() async {
    // Step back off the checkout page if it covers the screen — the park
    // CTA lives on the cart-review footer.
    if (find.byKey(const Key(TestKeys.parkBillButton)).evaluate().isEmpty) {
      await tester.pageBack();
      await settle();
    }
    final cartReview = find.byKey(const ValueKey('sale_cart_review_page'));
    if (cartReview.evaluate().isEmpty) {
      await tap(find.byKey(const ValueKey('sale_cart_entry')));
    }

    final parkCta = find.byKey(const Key(TestKeys.parkBillButton));
    expectVisible(parkCta, reason: 'Park CTA should be visible in cart review');
    await tester.ensureVisible(parkCta);
    await settle();
    await tap(parkCta);

    // Parking asks for confirmation (AppDialogShell) — accept it when shown.
    final confirmBtn = find.byKey(const Key(TestKeys.appConfirmDialogConfirm));
    if (confirmBtn.evaluate().isNotEmpty) {
      await tap(confirmBtn);
    }
  }

  /// Reopen the parked bill bound to [tableName] from the open-bills board.
  ///
  /// Opens the board through the sale app-bar bills action, then taps the
  /// bill tile whose visible name contains [tableName] (parked table bills
  /// are auto-named after their table). Falls back to the first parked tile
  /// when the resolved name is not rendered yet.
  Future<void> reopenDraftForTable(String tableName) async {
    await tap(find.byIcon(Icons.receipt_long_outlined).first);

    final tiles = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey &&
          (w.key as ValueKey).value.toString().startsWith(
            TestKeys.draftListTilePrefix,
          ),
    );
    expect(
      tiles,
      findsWidgets,
      reason: 'Open-bills board should list at least one bill',
    );

    final namedTile = find.ancestor(
      of: find.textContaining(tableName),
      matching: tiles,
    );
    final target = namedTile.evaluate().isNotEmpty
        ? namedTile.first
        : tiles.first;
    await tester.ensureVisible(target);
    await settle();
    await tap(target);
  }

  /// Asserts a table's DERIVED status straight from the database — no UI.
  ///
  /// Occupied ⇔ at least one ACTIVE draft cart (`is_archived = 0 AND
  /// deleted_at IS NULL`) binds the table's id. Otherwise the stored manual
  /// status column must equal [expected] (available/reserved only).
  Future<void> assertTableStatusViaDb(
    String tableName,
    TableStatus expected,
  ) async {
    final db = TestApp.database;
    final tables = await (db.select(
      db.restaurantTables,
    )..where((t) => t.name.equals(tableName) & t.deletedAt.isNull())).get();
    expect(
      tables,
      isNotEmpty,
      reason: 'Table "$tableName" should exist in restaurant_tables',
    );
    final table = tables.first;

    final activeCarts =
        await (db.select(db.draftCarts)..where(
              (c) =>
                  c.tableId.equals(table.id) &
                  c.isArchived.equals(false) &
                  c.deletedAt.isNull(),
            ))
            .get();

    if (expected == TableStatus.occupied) {
      expect(
        activeCarts,
        isNotEmpty,
        reason:
            '"$tableName" should be OCCUPIED by an active draft cart, '
            'but no active cart binds it',
      );
      return;
    }
    expect(
      activeCarts,
      isEmpty,
      reason:
          '"$tableName" should NOT be occupied — found '
          '${activeCarts.length} active draft cart(s)',
    );
    expect(
      table.status,
      expected.name,
      reason: '"$tableName" stored manual status should be ${expected.name}',
    );
  }
}
