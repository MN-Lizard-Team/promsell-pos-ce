import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/database/app_database.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:sqlite3/open.dart' as sqlite3_open;
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:promsell_pos_ce/main.dart' as app;

/// Test app wrapper that provides isolated in-memory database
/// and proper dependency injection for E2E tests
class TestApp {
  TestApp._();

  static AppDatabase? _database;
  static bool _isConfigured = false;

  /// Initialize the test app with fresh in-memory database
  static Future<void> initialize() async {
    if (_isConfigured) {
      await reset();
      return;
    }

    if (Platform.isAndroid) {
      sqlite3_open.open.overrideFor(
        sqlite3_open.OperatingSystem.android,
        openCipherOnAndroid,
      );
    }

    _database = AppDatabase.forTesting(NativeDatabase.memory());
    await _database!
        .into(_database!.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'onboardingCompleted',
            value: 'true',
          ),
        );

    // Configure DI with test database
    await _configureDependenciesForTesting();

    _isConfigured = true;
  }

  /// Reset database state between tests
  static Future<void> reset() async {
    if (_database != null) {
      // Clear all tables
      await _database!.delete(_database!.products).go();
      await _database!.delete(_database!.categories).go();
      await _database!.delete(_database!.sales).go();
      await _database!.delete(_database!.saleItems).go();
      await _database!.delete(_database!.draftCarts).go();
      await _database!.delete(_database!.draftCartItems).go();
      await _database!.delete(_database!.inventoryLogs).go();
      await _database!.delete(_database!.restaurantTables).go();
      await _database!.delete(_database!.promotions).go();
      await _database!.delete(_database!.customers).go();
      await _database!.delete(_database!.productOptionGroups).go();
      await _database!.delete(_database!.productOptions).go();
    }
  }

  /// Get the test database instance
  static AppDatabase get database {
    if (_database == null) {
      throw StateError('TestApp not initialized. Call initialize() first.');
    }
    return _database!;
  }

  /// Clean up resources
  static Future<void> dispose() async {
    await _database?.close();
    _database = null;
    _isConfigured = false;

    // Reset GetIt
    await sl.reset();
  }

  /// Configure dependencies with test database
  static Future<void> _configureDependenciesForTesting() async {
    // Start from a clean container, then replace the generated database
    // registration with the isolated in-memory test database.
    await sl.reset();
    configureDependencies();
    await sl.unregister<AppDatabase>();
    sl.registerSingleton<AppDatabase>(_database!);
  }

  /// Pump the full app for integration testing.
  ///
  /// Uses `pump` (not `pumpAndSettle`) because the app has continuous timers
  /// (clock, auto-refresh streams) that never settle — `pumpAndSettle` would
  /// block for the 10s default timeout on every call.
  ///
  /// Skips [initialize] if already configured — callers that seed data in
  /// `setUp` must call `initialize()` + `seedAll()` themselves, then call
  /// `pumpApp()` which will NOT wipe the seeded rows.
  static Future<void> pumpApp(WidgetTester tester) async {
    if (!_isConfigured) await initialize();
    app.runPromsellApp(configure: false);
    await tester.pump(const Duration(seconds: 3));
  }

  /// Restart the app (for testing persistence scenarios)
  ///
  /// Uses `pump` (not `pumpAndSettle`) — same rationale as [pumpApp]:
  /// the app has continuous timers (clock, auto-refresh streams) that
  /// never settle, so `pumpAndSettle` would block for the 10s timeout.
  static Future<void> restartApp(WidgetTester tester) async {
    // Clear widget tree
    await tester.pumpWidget(Container());
    await tester.pump();

    // Restart app
    app.runPromsellApp(configure: false);
    await tester.pump(const Duration(seconds: 3));
  }
}

/// Stable Keys for the 5 core E2E cases (V092-D.5 / B4).
///
/// Use these instead of EN string selectors (`Cash`, `Coffee`) so tests
/// survive l10n changes and are not flaky on Thai locale.
///
/// Naming: where a widget already exposes a stable `ValueKey` for production
/// use (e.g. `sale_cart_checkout_cta`, `product-form-save`), the TestKey
/// constant below is set to that same key so the robot finds the same widget
/// without a separate test-only key. Where no production key existed, a
/// `test_*` key was wired into the widget (see B4 changelog).
abstract final class TestKeys {
  // Case 1: Add product → exact cash → stock down
  // `test_add_product_fab` is wired on AppEmptyState action in
  // product_sliver_content.dart (empty-catalog CTA).
  static const addProductFab = Key('test_add_product_fab');
  static const productNameField = Key('product-form-name');
  static const productPriceField = Key('product-form-price');
  // Stock is edited via the adjust-stock dialog button, not a direct field.
  static const productStockField = Key('product-form-adjust-stock');
  static const productSaveButton = Key('product-form-save');

  // Case 2: History void + PIN → stock back
  // History tab is reached via the bottom-nav icon; no dedicated key yet.
  // `test_void_button` is wired on the void FilledButton in sale_expansion_tile.
  static const voidButton = Key('test_void_button');
  static const pinEntryField = Key('test_pin_entry_field');
  static const pinConfirmButton = Key('test_pin_confirm_button');

  // Case 3: Discount → on-screen total = DB total
  // Discount entry uses the cart discount sheet; no dedicated key yet.
  static const discountField = Key('test_discount_field');
  // `test_checkout_total_label` is wired on the MoneyText in
  // checkout_sticky_payable.dart (amount-due hero).
  static const checkoutTotalLabel = Key('test_checkout_total_label');

  // Case 4: Day-close + lock → cannot pay
  // `test_close_day_button` is wired on the close-day FilledButton in
  // daily_close_page.dart.
  static const closeDayButton = Key('test_close_day_button');
  // `test_day_close_lock_toggle` is wired on the Switch in
  // sales_daily_close_section.dart via buildSwitchTile(switchKey:).
  static const dayCloseLockToggle = Key('test_day_close_lock_toggle');

  // Case 5: Park bill → reopen, same total
  // Park CTA already exposes `sale_cart_park_cta` in cart_review_footer.dart.
  static const parkBillButton = Key('sale_cart_park_cta');
  // Draft tiles use `sale_bill_tile_<id>`; robots find the first match by
  // prefix. This constant is a sentinel for documentation — robots should
  // use `find.byKey(ValueKey('sale_bill_tile_...'))` or find descendants.
  static const draftListTilePrefix = 'sale_bill_tile_';
  static const draftListTile = Key('sale_bill_tile_');
}
