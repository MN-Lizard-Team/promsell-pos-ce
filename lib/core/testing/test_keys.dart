import 'package:flutter/material.dart';

/// Central catalog of stable widget keys for E2E (device) and host tests.
///
/// Single source of truth (V092-D.5 / B4 continuation): production widgets
/// attach `key: Key(TestKeys.xxx)` and robots find them with
/// `find.byKey(Key(TestKeys.xxx))` instead of EN-string selectors so journeys
/// survive l10n changes and are not flaky on Thai locale.
///
/// Rules:
/// - Keys are ADDITIVE — attaching one never changes widget behavior.
/// - Prefer reusing an already-wired production `ValueKey` (e.g.
///   [cartCheckoutCta]) over inventing a second key for the same widget.
/// - Never remove or rename a wired key without grepping this repo for usages.
///
/// This file intentionally imports only Flutter (no flutter_test) so any
/// production widget can reference it.
abstract final class TestKeys {
  // ---------------------------------------------------------------------
  // Case 1: Add product -> exact cash -> stock down
  // ---------------------------------------------------------------------

  /// Wired on the AppEmptyState action in product_sliver_content.dart
  /// (empty-catalog CTA).
  static const addProductFab = 'test_add_product_fab';

  /// Wired on the real add-product FAB in product_list_page.dart.
  /// Shares the value with [addProductFab] because at most one of the two
  /// (empty-state CTA / FAB) is visible at a time.
  static const addProductEntry = 'test_add_product_entry';

  static const productNameField = 'product-form-name';
  static const productSkuField = 'product-form-sku';
  static const productBarcodeField = 'product-form-barcode';
  static const productPriceField = 'product-form-price';
  static const productCostField = 'product-form-cost';
  static const productCategoryField = 'product-form-category';

  /// Stock is edited via the adjust-stock sheet button in
  /// product_form_stock_section.dart, not a direct field.
  static const productStockField = 'product-form-adjust-stock';

  static const productSaveButton = 'product-form-save';

  /// Adjust-stock sheet (adjust_stock_sheet.dart) inputs.
  static const adjustStockModeIn = 'test_adjust_stock_mode_in';
  static const adjustStockModeOut = 'test_adjust_stock_mode_out';
  static const adjustStockQtyField = 'test_adjust_stock_qty_field';
  static const adjustStockReasonField = 'test_adjust_stock_reason_field';
  static const adjustStockSaveButton = 'adjust-stock-save';

  // ---------------------------------------------------------------------
  // Case 2: History void + PIN -> stock back
  // ---------------------------------------------------------------------

  /// History tab is reached via the Report shell tab -> History sub-tab;
  /// see [historySubTabButton].
  ///
  /// Wired on the void FilledButton in sale_expansion_tile.dart.
  static const voidButton = 'test_void_button';
  static String voidButtonForSale(String saleId) => 'test_void_button_$saleId';
  static const voidReasonField = 'test_void_reason_field';
  static const voidConfirmButton = 'test_void_confirm_button';

  static const pinEntryField = 'test_pin_entry_field';
  static const pinConfirmButton = 'test_pin_confirm_button';

  // ---------------------------------------------------------------------
  // Case 3: Discount -> on-screen total = DB total
  // ---------------------------------------------------------------------

  /// Cart discount sheet entry — NOT yet wired in production; kept as a
  /// documented sentinel until the discount sheet gains a stable anchor.
  static const discountField = 'test_discount_field';

  /// Amount-due hero MoneyText in checkout_sticky_payable.dart.
  static const checkoutTotalLabel = 'test_checkout_total_label';
  static const checkoutStickyPayable = 'sale_checkout_sticky_payable';

  /// Payment method grid cells — built per method id:
  /// cash | transfer | card | promptpay (see [payMethod]).
  static const payMethodCash = 'cash';
  static const payMethodTransfer = 'transfer';
  static const payMethodCard = 'card';
  static const payMethodPromptPay = 'promptpay';

  /// Key builder matching payment_method_selector.dart cell wiring.
  static Key payMethod(String methodId) => Key('test_pay_method_$methodId');

  /// Received-cash TextFormField in cash_input_section.dart.
  static const cashReceivedField = 'test_cash_received_field';

  /// Confirm-payment CTA in checkout_confirm_dock.dart.
  static const checkoutConfirmButton = 'test_checkout_confirm_button';
  static const promptPayConfirmButton = 'test_promptpay_confirm_button';

  /// Receipt success hero (sale_success_hero.dart).
  static const saleSuccessActions = 'sale_success_actions';
  static const saleSuccessNextCta = 'sale_success_next_cta';

  // ---------------------------------------------------------------------
  // Case 4: Day-close + lock -> cannot pay
  // ---------------------------------------------------------------------

  /// Home menu tile that pushes DailyClosePage (home_menu_grid.dart).
  static const homeCloseDayTile = 'test_home_close_day_tile';

  /// Close-day FilledButton in daily_close_page.dart (pre-close state).
  static const closeDayButton = 'test_close_day_button';

  /// Reopen-day OutlinedButton in daily_close_page.dart (post-close state);
  /// its presence proves the day row flipped to closed/read-only.
  static const reopenDayButton = 'test_reopen_day_button';

  /// Daily-close lock Switch in sales_daily_close_section.dart via
  /// buildSwitchTile(switchKey:).
  static const dayCloseLockToggle = 'test_day_close_lock_toggle';

  /// Cash reconciliation card anchors (daily_close_reconciliation_card.dart).
  static const openingCashField = 'test_opening_cash_field';
  static const countedCashField = 'test_counted_cash_field';
  static const expectedCashValue = 'test_expected_cash_value';
  static const overShortValue = 'test_over_short_value';

  /// Post-close summary card root (daily_close_summary_card.dart).
  static const dailyCloseSummaryCard = 'test_daily_close_summary_card';
  static const saleDayClosedBanner = 'test_sale_day_closed_banner';
  static const appConfirmDialogConfirm = 'test_app_confirm_dialog_confirm';

  // ---------------------------------------------------------------------
  // Case 5: Park bill -> reopen, same total
  // ---------------------------------------------------------------------

  /// Park CTA in cart_review_footer.dart.
  static const parkBillButton = 'sale_cart_park_cta';

  /// Checkout entry CTA in cart_review_footer.dart.
  static const cartCheckoutCta = 'sale_cart_checkout_cta';

  /// Draft tiles use `sale_bill_tile_<id>`; robots find the first match by
  /// prefix. This constant documents the prefix — use
  /// `find.byWidgetPredicate((w) => w.key is ValueKey && (w.key as ValueKey).value.toString().startsWith(prefix))`.
  static const draftListTilePrefix = 'sale_bill_tile_';

  // ---------------------------------------------------------------------
  // Shell navigation / shared surfaces
  // ---------------------------------------------------------------------

  /// History sub-tab button inside the Report page tab selector
  /// (report_page.dart `_ReportTabSelector`).
  static const historySubTabButton = 'test_history_sub_tab_button';

  /// Table dropdown field on checkout (table_selector.dart).
  /// Dropdown menu ITEMS stay text-based: rows come from TableBloc state
  /// (dynamic content), only the field itself gets a key.
  static const tableSelectorField = 'test_table_selector_field';
}
