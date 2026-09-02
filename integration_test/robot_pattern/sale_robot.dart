import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_item_card.dart';
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

  /// Add product to cart by tapping product card.
  ///
  /// The sale catalog is a lazily-built [CustomScrollView], so products below
  /// the viewport do not exist in the widget tree until the catalog is scrolled.
  Future<void> addProductToCart(String productName) async {
    final productCard = findProductCard(productName);
    if (productCard.evaluate().isEmpty) {
      final catalog = find.byType(CustomScrollView);
      // A previous product may have left the catalog near its end. Return to
      // the top before searching downward through the lazily-built sliver.
      await tester.drag(catalog, const Offset(0, 5000));
      await tester.pump(const Duration(milliseconds: 300));
      await TestUtils.scrollUntilVisible(
        tester,
        productCard,
        catalog,
        delta: 320,
      );
    }
    expectVisible(
      productCard,
      reason: 'Product "$productName" should be visible',
    );
    await tap(productCard);
  }

  /// Find cart item by product name in the cart review page.
  Finder findCartItem(String productName) {
    return find.ancestor(
      of: find.text(productName),
      matching: find.byType(CartItemCard),
    );
  }

  /// Verify cart state without depending on responsive cart rendering.
  void verifyCartItem(String productName, {int? quantity}) {
    final matches = _cartBloc.state.items.where(
      (item) => item.product.name == productName,
    );
    expect(matches, isNotEmpty, reason: 'Cart should contain "$productName"');
    if (quantity != null) {
      expect(matches.fold<int>(0, (sum, item) => sum + item.qty), quantity);
    }
  }

  CartBloc get _cartBloc => sl<CartBloc>();

  /// Tap on cart item to open quantity selector.
  ///
  /// Works in both layouts: dual-pane shows [CartItemCard] directly, while
  /// the compact/bottom-bar layout needs one tap on the cart entry first.
  Future<void> tapCartItem(String productName) async {
    if (findCartItem(productName).evaluate().isEmpty) {
      final entry = find.byKey(const ValueKey('sale_cart_entry'));
      if (entry.evaluate().isNotEmpty) await tap(entry);
    }
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

  /// Remove item from cart via swipe-to-dismiss (the real UX — cart lines
  /// are [Dismissible]s that delete on an end-to-start swipe).
  Future<void> removeFromCart(String productName) async {
    if (findCartItem(productName).evaluate().isEmpty) {
      final entry = find.byKey(const ValueKey('sale_cart_entry'));
      if (entry.evaluate().isNotEmpty) await tap(entry);
    }
    final item = findCartItem(productName);
    expectVisible(item);
    await tester.drag(item.first, const Offset(-600, 0));
    await settle();
  }

  /// Verify cart total amount (value may appear in several places).
  void verifyCartTotal(Money expectedTotal) {
    final totalText = CurrencyFormatter.formatMoney(expectedTotal);
    expect(
      find.textContaining(totalText).evaluate().isNotEmpty,
      isTrue,
      reason: 'Cart total should be $totalText',
    );
  }

  /// Proceed to checkout.
  ///
  /// The compact bottom bar and cart review intentionally share the checkout
  /// key, but the compact action performs express payment. Open the full cart
  /// review first so the key resolves to the navigation CTA.
  Future<void> proceedToCheckout() async {
    final cartReview = find.byKey(const ValueKey('sale_cart_review_page'));
    if (cartReview.evaluate().isEmpty) {
      final cartEntry = find.byKey(const ValueKey('sale_cart_entry'));
      await tap(cartEntry);
    }

    final checkoutBtn = find.byKey(const ValueKey('sale_cart_checkout_cta'));
    await tester.ensureVisible(checkoutBtn);
    await tap(checkoutBtn);
  }

  /// Verify cart is empty (source of truth: [CartBloc] state).
  void verifyCartEmpty() {
    expect(_cartBloc.state.isEmpty, isTrue, reason: 'Cart should be empty');
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
