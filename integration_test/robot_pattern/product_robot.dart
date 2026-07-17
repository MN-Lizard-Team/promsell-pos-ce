import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_utils.dart';
import 'robot_base.dart';

/// Robot for product management interactions
class ProductRobot extends RobotBase {
  ProductRobot(super.tester);

  /// Navigate to products page
  Future<void> navigateToProductsPage() async {
    await tap(find.byIcon(Icons.inventory_2_outlined));
  }

  /// Open add product form
  Future<void> openAddProductForm() async {
    final addBtn = find.byIcon(Icons.add)
        .or(find.text('Add Product'))
        .or(find.byType(FloatingActionButton));
    await tap(addBtn);
  }

  /// Fill product form
  Future<void> fillProductForm({
    required String name,
    String? sku,
    String? barcode,
    required double price,
    double? cost,
    int? initialStock,
    String? category,
    bool trackStock = true,
  }) async {
    // Name
    final nameField = find.widgetWithText(TextFormField, 'Name')
        .or(find.widgetWithText(TextField, 'Name'));
    await enterText(nameField, name);

    // SKU
    if (sku != null) {
      final skuField = find.widgetWithText(TextFormField, 'SKU')
          .or(find.widgetWithText(TextField, 'SKU'));
      if (skuField.evaluate().isNotEmpty) {
        await enterText(skuField, sku);
      }
    }

    // Barcode
    if (barcode != null) {
      final barcodeField = find.widgetWithText(TextFormField, 'Barcode')
          .or(find.widgetWithText(TextField, 'Barcode'));
      if (barcodeField.evaluate().isNotEmpty) {
        await enterText(barcodeField, barcode);
      }
    }

    // Price
    final priceField = find.widgetWithText(TextFormField, 'Price')
        .or(find.widgetWithText(TextField, 'Price'));
    await enterText(priceField, price.toString());

    // Cost
    if (cost != null) {
      final costField = find.widgetWithText(TextFormField, 'Cost')
          .or(find.widgetWithText(TextField, 'Cost'));
      if (costField.evaluate().isNotEmpty) {
        await enterText(costField, cost.toString());
      }
    }

    // Initial stock
    if (initialStock != null) {
      final stockField = find.widgetWithText(TextFormField, 'Stock')
          .or(find.widgetWithText(TextField, 'Stock'))
          .or(find.widgetWithText(TextFormField, 'Initial Stock'));
      if (stockField.evaluate().isNotEmpty) {
        await enterText(stockField, initialStock.toString());
      }
    }

    // Category
    if (category != null) {
      final categoryField = find.text('Category')
          .or(find.text('Select Category'));
      if (categoryField.evaluate().isNotEmpty) {
        await tap(categoryField);
        await tap(find.text(category));
      }
    }

    // Track stock toggle
    if (!trackStock) {
      final trackStockSwitch = find.byType(Switch);
      if (trackStockSwitch.evaluate().isNotEmpty) {
        await tap(trackStockSwitch);
      }
    }
  }

  /// Save product form
  Future<void> saveProduct() async {
    final saveBtn = find.text('Save')
        .or(find.text('Create'))
        .or(find.byIcon(Icons.check));
    await tap(saveBtn);
  }

  /// Search for product by name
  Future<void> searchProduct(String name) async {
    final searchField = find.byType(TextField);
    await enterText(searchField, name);
  }

  /// Find product in list by name
  Finder findProductInList(String name) {
    return find.textContaining(name);
  }

  /// Verify product exists in list
  void verifyProductInList(String name) {
    expectVisible(
      findProductInList(name),
      reason: 'Product "$name" should be in list',
    );
  }

  /// Verify product is not visible in list
  void verifyProductNotVisible(String productName) {
    expectNotVisible(
      findProductInList(productName),
      reason: 'Product "$productName" should not be visible',
    );
  }

  /// Open product details
  Future<void> openProductDetails(String name) async {
    await tap(findProductInList(name));
  }

  /// Navigate to stock tab (in product details)
  Future<void> openStockTab() async {
    final stockTab = find.text('Stock')
        .or(find.text('Inventory'));
    await tap(stockTab);
  }

  /// Navigate to history tab (in product details)
  Future<void> openHistoryTab() async {
    final historyTab = find.text('History')
        .or(find.text('Logs'));
    await tap(historyTab);
  }

  /// Open stock adjustment dialog
  Future<void> openStockAdjustment() async {
    final adjustBtn = find.text('Adjust Stock')
        .or(find.text('Adjust'))
        .or(find.byIcon(Icons.edit));
    await tap(adjustBtn);
  }

  /// Adjust stock
  Future<void> adjustStock({
    required int quantity,
    required String type,
    String? reason,
  }) async {
    await openStockAdjustment();

    // Select adjustment type (In/Out)
    await tap(find.text(type));

    // Enter quantity
    final qtyField = find.widgetWithText(TextField, 'Quantity')
        .or(find.byType(TextField));
    await enterText(qtyField, quantity.toString());

    // Enter reason
    if (reason != null) {
      final reasonField = find.widgetWithText(TextField, 'Reason')
          .or(find.widgetWithText(TextFormField, 'Reason'));
      if (reasonField.evaluate().isNotEmpty) {
        await enterText(reasonField, reason);
      }
    }

    // Confirm
    await tap(find.text('Confirm').or(find.text('Save')));
  }

  /// Verify stock level
  void verifyStockLevel(int expectedStock) {
    expectVisible(
      find.textContaining('Stock').and(find.textContaining(expectedStock.toString())),
      reason: 'Stock should be $expectedStock',
    );
  }

  /// Verify inventory log entry exists
  void verifyInventoryLog({
    required String type,
    required int quantity,
    String? reason,
  }) {
    expectVisible(find.text(type));
    expectVisible(find.textContaining(quantity.toString()));
    if (reason != null) {
      expectVisible(find.textContaining(reason));
    }
  }

  /// Delete product
  Future<void> deleteProduct(String name) async {
    await openProductDetails(name);
    final deleteBtn = find.byIcon(Icons.delete)
        .or(find.text('Delete'));
    await tap(deleteBtn);
    
    // Confirm deletion
    final confirmBtn = find.text('Delete')
        .or(find.text('Confirm'))
        .or(find.text('Yes'));
    await tap(confirmBtn);
  }

  /// Edit product
  Future<void> editProduct(String name) async {
    await openProductDetails(name);
    final editBtn = find.byIcon(Icons.edit)
        .or(find.text('Edit'));
    await tap(editBtn);
  }

  /// Verify product form validation error
  void verifyValidationError(String message) {
    expectVisible(
      find.textContaining(message),
      reason: 'Validation error should show: $message',
    );
  }

  /// Close product details
  Future<void> closeProductDetails() async {
    final backBtn = find.byIcon(Icons.arrow_back)
        .or(find.byIcon(Icons.close));
    await tap(backBtn);
  }

  /// Filter by category
  Future<void> filterByCategory(String categoryName) async {
    final filterBtn = find.byIcon(Icons.filter_list)
        .or(find.text('Filter'));
    if (filterBtn.evaluate().isNotEmpty) {
      await tap(filterBtn);
    }
    await tap(find.text(categoryName));
  }

  /// Toggle product active status
  Future<void> toggleActiveStatus() async {
    final activeSwitch = find.byType(Switch);
    await tap(activeSwitch);
  }
}
