import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import '../helpers/test_utils.dart';
import 'robot_base.dart';

/// Robot for sale/POS page interactions
class SaleRobot extends RobotBase {
  SaleRobot(super.tester);

  /// Navigate to sale page.
  ///
  /// Taps the Sale tab in the bottom navigation. Uses `find.byIcon` with
  /// `.first` because both active and inactive icons may be present.
  Future<void> navigateToSalePage() async {
    final saleIcon = find.byIcon(TablerIcons.buildingStore);
    if (saleIcon.evaluate().isNotEmpty) {
      await tester.tap(saleIcon.first);
      await tester.pump(const Duration(milliseconds: 800));
    }
  }

  /// Find product card by name
  Finder findProductCard(String productName) {
    return find.text(productName);
  }

  /// Add product to cart by tapping product card
  Future<void> addProductToCart(String productName) async {
    final productCard = findProductCard(productName);
    expectVisible(
      productCard,
      reason: 'Product "$productName" should be visible',
    );
    await tap(productCard);
  }

  /// Find cart item by product name
  Finder findCartItem(String productName) {
    return find.textContaining(productName);
  }

  /// Verify cart item exists with quantity
  void verifyCartItem(String productName, {int? quantity}) {
    expectVisible(findCartItem(productName));
    if (quantity != null) {
      expectText('×$quantity');
    }
  }

  /// Tap on cart item to open quantity selector
  Future<void> tapCartItem(String productName) async {
    await tap(findCartItem(productName));
  }

  /// Set quantity using number pad (if quantity dialog opens)
  Future<void> setQuantity(int qty) async {
    // Clear existing quantity
    final clearButton = find.byIcon(Icons.backspace);
    if (clearButton.evaluate().isNotEmpty) {
      await tap(clearButton);
    }

    // Enter new quantity
    for (var digit in qty.toString().split('')) {
      await tap(find.text(digit));
    }

    // Confirm
    final okButton = find.text('OK').or(find.text('Confirm'));
    if (okButton.evaluate().isNotEmpty) {
      await tap(okButton);
    }
  }

  /// Increase quantity using + button
  Future<void> increaseQuantity(String productName) async {
    await tapCartItem(productName);
    // Look for increment button (could be + icon or text)
    final incrementBtn = find.byIcon(Icons.add).or(find.text('+'));
    await tap(incrementBtn);
  }

  /// Decrease quantity using - button
  Future<void> decreaseQuantity(String productName) async {
    await tapCartItem(productName);
    final decrementBtn = find.byIcon(Icons.remove).or(find.text('-'));
    await tap(decrementBtn);
  }

  /// Remove item from cart
  Future<void> removeFromCart(String productName) async {
    await tapCartItem(productName);
    final removeBtn = find.byIcon(Icons.delete).or(find.text('Remove'));
    await tap(removeBtn);
  }

  /// Verify cart total amount
  void verifyCartTotal(Money expectedTotal) {
    final totalText = expectedTotal.toString();
    expectVisible(
      find.textContaining(totalText),
      reason: 'Cart total should be $totalText',
    );
  }

  /// Proceed to checkout
  Future<void> proceedToCheckout() async {
    // Prefer the stable ValueKey used by cart_review_footer; fall back to
    // localized text for older layouts.
    final checkoutBtn = find
        .byKey(const ValueKey('sale_cart_checkout_cta'))
        .or(find.text('Checkout'))
        .or(find.text('Pay'))
        .or(find.text('ชำระเงิน'))
        .or(find.text('Next'))
        .or(find.byIcon(Icons.arrow_forward));
    await tap(checkoutBtn);
  }

  /// Verify cart is empty
  void verifyCartEmpty() {
    expectVisible(
      find.text('Cart is empty').or(find.text('No items')),
      reason: 'Cart should be empty',
    );
  }

  /// Search for product
  Future<void> searchProduct(String query) async {
    final searchField = find.byType(TextField);
    await enterText(searchField, query);
  }

  /// Clear search
  Future<void> clearSearch() async {
    final clearBtn = find.byIcon(Icons.clear);
    if (clearBtn.evaluate().isNotEmpty) {
      await tap(clearBtn);
    }
  }

  /// Filter by category
  Future<void> filterByCategory(String categoryName) async {
    await tap(find.text(categoryName));
  }

  /// Verify product visible in grid
  void verifyProductVisible(String productName) {
    expectVisible(
      findProductCard(productName),
      reason: 'Product "$productName" should be visible in grid',
    );
  }

  /// Verify product not visible
  void verifyProductNotVisible(String productName) {
    expectNotVisible(
      findProductCard(productName),
      reason: 'Product "$productName" should not be visible',
    );
  }

  /// Open draft cart menu (if exists)
  Future<void> openDraftMenu() async {
    final draftBtn = find
        .byIcon(Icons.drafts)
        .or(find.text('Drafts'))
        .or(find.byIcon(Icons.bookmark_border));
    if (draftBtn.evaluate().isNotEmpty) {
      await tap(draftBtn);
    }
  }

  /// Save current cart as draft
  Future<void> saveDraft() async {
    final saveBtn = find
        .text('Save Draft')
        .or(find.byIcon(Icons.save))
        .or(find.text('Hold'));
    await tap(saveBtn);
  }

  /// Load draft by index
  Future<void> loadDraft({int index = 0}) async {
    await openDraftMenu();
    final draftItems = find.byType(ListTile);
    if (draftItems.evaluate().length > index) {
      await tap(draftItems.at(index));
    }
  }
}
