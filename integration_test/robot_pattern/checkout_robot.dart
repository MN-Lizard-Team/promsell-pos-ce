import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/testing/test_keys.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import '../helpers/test_utils.dart';
import 'robot_base.dart';

/// Robot for checkout page interactions
class CheckoutRobot extends RobotBase {
  CheckoutRobot(super.tester);

  /// Verify on checkout/payment page.
  void verifyOnCheckoutPage() {
    final shell = find
        .byKey(const ValueKey('sale_payment_page'))
        .or(find.byKey(const ValueKey('sale_checkout_page')));
    if (shell.evaluate().isNotEmpty) return;
    expectVisible(
      find.text('Checkout').or(find.text('Payment')),
      reason: 'Should be on checkout page',
    );
  }

  /// Select payment method
  Future<void> selectPaymentMethod(String method) async {
    // Match EN, TH, or widget-with-text for resilience across locales.
    final thMethod = method == 'Cash'
        ? 'เงินสด'
        : method == 'PromptPay'
        ? 'พร้อมเพย์'
        : method;
    final methodId = switch (method) {
      'Cash' => TestKeys.payMethodCash,
      'PromptPay' => TestKeys.payMethodPromptPay,
      'Transfer' => TestKeys.payMethodTransfer,
      'Card' => TestKeys.payMethodCard,
      _ => method.toLowerCase(),
    };
    final keyedMethod = find.byKey(TestKeys.payMethod(methodId));
    if (keyedMethod.evaluate().isNotEmpty) {
      await tester.ensureVisible(keyedMethod);
      await settle();
      await tap(keyedMethod);
      return;
    }
    final methodBtn = find
        .text(method)
        .or(find.text(thMethod))
        .or(find.textContaining(method))
        .or(find.textContaining(thMethod))
        .or(find.widgetWithText(Card, method))
        .or(find.widgetWithText(Card, thMethod));
    await tap(methodBtn);
  }

  /// Enter cash received amount
  Future<void> enterCashReceived(double amount) async {
    final receivedField = find
        .byKey(const Key(TestKeys.cashReceivedField))
        .or(find.widgetWithText(TextField, 'Received'))
        .or(find.byType(TextField));
    await enterText(receivedField, amount.toString());
  }

  /// Use quick cash amount button
  Future<void> selectQuickCash(String amount) async {
    await tap(find.text(amount));
  }

  /// Apply discount
  Future<void> applyDiscount({
    required String type,
    required double value,
  }) async {
    final discountBtn = find
        .text('Discount')
        .or(find.byIcon(Icons.discount))
        .or(find.text('Add Discount'));
    await tap(discountBtn);

    // Select discount type (Percent or Fixed)
    await tap(find.text(type));

    // Enter value
    final valueField = find.byType(TextField);
    await enterText(valueField, value.toString());

    // Confirm
    await tap(find.text('Apply').or(find.text('OK')));
  }

  /// Apply promotion
  Future<void> applyPromotion(String promotionName) async {
    final promoBtn = find
        .text('Promotion')
        .or(find.text('Apply Promotion'))
        .or(find.byIcon(Icons.local_offer));

    if (promoBtn.evaluate().isNotEmpty) {
      await tap(promoBtn);
      await tap(find.text(promotionName));
    } else {
      // Try finding promotion directly in list
      await tap(find.text(promotionName));
    }
  }

  /// Add customer to sale
  Future<void> selectCustomer(String customerName) async {
    final customerBtn = find
        .text('Customer')
        .or(find.byIcon(Icons.person))
        .or(find.text('Add Customer'));
    await tap(customerBtn);
    await tap(find.text(customerName));
  }

  /// Add note to sale
  Future<void> addNote(String note) async {
    final noteField = find
        .widgetWithText(TextField, 'Note')
        .or(find.byType(TextField));
    await enterText(noteField, note);
  }

  /// Complete payment
  Future<void> completePayment() async {
    final completeBtn = find
        .byKey(const Key(TestKeys.checkoutConfirmButton))
        .or(find.text('Complete'))
        .or(find.text('Pay'))
        .or(find.text('ชำระเงิน'))
        .or(find.text('เสร็จสิ้น'))
        .or(find.text('Confirm Payment'))
        .or(find.byIcon(Icons.check));
    await tap(completeBtn);
  }

  /// Verify payment complete (receipt shown)
  void verifyPaymentComplete() {
    final success = find
        .byKey(const ValueKey('sale_success_hero'))
        .or(find.byKey(const ValueKey('sale_success_next_cta')));
    if (success.evaluate().isNotEmpty) return;
    expectVisible(
      find
          .text('Receipt')
          .or(find.text('Payment Complete'))
          .or(find.text('Success')),
      reason: 'Payment should be complete',
    );
  }

  /// Verify change amount
  void verifyChange(Money expectedChange) {
    final changeText = CurrencyFormatter.formatMoney(expectedChange);
    expect(
      find.textContaining(changeText).evaluate().isNotEmpty,
      isTrue,
      reason: 'Change should be $changeText',
    );
  }

  /// Verify grand total
  void verifyGrandTotal(Money expectedTotal) {
    final totalText = CurrencyFormatter.formatMoney(expectedTotal);
    expect(
      find.textContaining(totalText).evaluate().isNotEmpty,
      isTrue,
      reason: 'Grand total should be $totalText',
    );
  }

  /// Verify discount applied
  void verifyDiscountAmount(Money discountAmount) {
    final discountText = CurrencyFormatter.formatMoney(discountAmount);
    expectVisible(
      find.textContaining(discountText),
      reason: 'Discount should be $discountText',
    );
  }

  /// Close receipt / success hero and return to sale (Next sale primary).
  Future<void> closeReceipt() async {
    final closeBtn = find
        .byKey(const ValueKey('sale_success_next_cta'))
        .or(find.text('Next sale'))
        .or(find.text('ขายบิลถัดไป'))
        .or(find.text('Close'))
        .or(find.text('ปิด'))
        .or(find.text('Done'))
        .or(find.text('เสร็จ'))
        .or(find.text('New Sale'))
        .or(find.byIcon(Icons.close));
    await tap(closeBtn);
  }

  /// Print receipt
  Future<void> printReceipt() async {
    final printBtn = find.text('Print').or(find.byIcon(Icons.print));
    if (printBtn.evaluate().isNotEmpty) {
      await tap(printBtn);
    }
  }

  /// Share receipt
  Future<void> shareReceipt() async {
    final shareBtn = find.text('Share').or(find.byIcon(Icons.share));
    if (shareBtn.evaluate().isNotEmpty) {
      await tap(shareBtn);
    }
  }

  /// Go back to cart
  Future<void> backToCart() async {
    final backBtn = find.byIcon(Icons.arrow_back).or(find.text('Back'));
    await tap(backBtn);
  }

  /// Verify service charge applied
  void verifyServiceCharge(Money chargeAmount) {
    final chargeText = CurrencyFormatter.formatMoney(chargeAmount);
    expectVisible(
      find.textContaining(chargeText),
      reason: 'Service charge should be $chargeText',
    );
  }

  /// Verify VAT amount
  void verifyVAT(Money vatAmount) {
    final vatText = CurrencyFormatter.formatMoney(vatAmount);
    expectVisible(
      find.textContaining(vatText),
      reason: 'VAT should be $vatText',
    );
  }
}
