import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'robot_pattern/product_robot.dart';

/// Journey 4: Product Management Flow
/// 
/// Scenario: Shop owner creates product, adjusts stock, verifies history
/// 
/// GIVEN shop owner opens product page
/// WHEN taps "Add Product"
/// AND enters product details
/// AND saves product
/// THEN product appears in product list
/// WHEN taps on product
/// AND opens stock tab
/// AND adjusts stock
/// THEN stock is updated
/// AND history tab shows adjustment entry
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey 4: Product Management Flow', () {
    late ProductRobot productRobot;

    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);
    });

    tearDown(() async {
      await TestApp.dispose();
    });

    testWidgets('Create new product with full details', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);

      // GIVEN: Navigate to products page
      await productRobot.navigateToProductsPage();

      // WHEN: Open add product form
      await productRobot.openAddProductForm();

      // Fill product details
      await productRobot.fillProductForm(
        name: 'Test Widget',
        sku: 'TWD-001',
        barcode: '9999999999999',
        price: 299.0,
        cost: 150.0,
        initialStock: 50,
        category: 'Snacks',
        trackStock: true,
      );

      // Save product
      await productRobot.saveProduct();

      // THEN: Product should appear in list
      await tester.pumpAndSettle();
      await productRobot.searchProduct('Test Widget');
      productRobot.verifyProductInList('Test Widget');

      // Verify product saved to database
      final product = await TestFixtures.findProductByName(
        TestApp.database,
        'Test Widget',
      );
      
      expect(product, isNotNull, reason: 'Product should be saved');
      expect(product!.price, 299.0, reason: 'Price should be 299.00');
      expect(product.stock, 50, reason: 'Initial stock should be 50');
      expect(product.barcode, '9999999999999');
      expect(product.categoryId, isNotNull);
      expect(product.isActive, true);
      expect(product.trackStock, true);
    });

    testWidgets('Adjust stock and verify inventory log', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();

      // Get initial stock of Coffee
      final coffeeInitial = await TestFixtures.findProductByName(
        TestApp.database,
        'Coffee',
      );
      expect(coffeeInitial, isNotNull);
      final initialStock = coffeeInitial!.stock;

      // WHEN: Open Coffee product details
      await productRobot.searchProduct('Coffee');
      await productRobot.openProductDetails('Coffee');

      // Navigate to stock tab
      await productRobot.openStockTab();

      // Adjust stock: Add 25 units
      await productRobot.adjustStock(
        quantity: 25,
        type: 'In',
        reason: 'Restock',
      );

      await tester.pumpAndSettle();

      // THEN: Verify stock updated to 125 (100 + 25)
      final coffeeAfter = await TestFixtures.findProductByName(
        TestApp.database,
        'Coffee',
      );
      expect(
        coffeeAfter!.stock,
        initialStock + 25,
        reason: 'Stock should increase by 25',
      );

      // Verify inventory log entry
      final logs = await (TestApp.database.select(
        TestApp.database.inventoryLogs,
      )..where((log) => log.productId.equals(coffeeInitial.id))).get();
      
      expect(logs.isNotEmpty, true, reason: 'Should have inventory log');
      
      final latestLog = logs.last;
      expect(latestLog.type, 'ADJUSTMENT_IN');
      expect(latestLog.qtyChange, 25);
      expect(latestLog.balanceAfter, initialStock + 25);
      expect(latestLog.reason, 'Restock');

      // Navigate to history tab to verify UI shows log
      await productRobot.openHistoryTab();
      
      productRobot.verifyInventoryLog(
        type: 'ADJUSTMENT_IN',
        quantity: 25,
        reason: 'Restock',
      );
    });

    testWidgets('Product form validation - required fields', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();
      await productRobot.openAddProductForm();

      // Try to save without filling required fields
      await productRobot.saveProduct();

      // Should show validation errors
      productRobot.verifyValidationError('required');
    });

    testWidgets('Product form validation - invalid price', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();
      await productRobot.openAddProductForm();

      // Fill with invalid price
      await productRobot.fillProductForm(
        name: 'Invalid Product',
        price: -10.0, // Negative price
      );

      await productRobot.saveProduct();

      // Should either reject or show error
      final product = await TestFixtures.findProductByName(
        TestApp.database,
        'Invalid Product',
      );
      
      // Product should not be created with invalid price
      expect(
        product == null || product.price >= 0,
        true,
        reason: 'Negative price should be rejected',
      );
    });

    testWidgets('Adjust stock OUT and verify reduction', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();

      final burgerInitial = await TestFixtures.findProductByName(
        TestApp.database,
        'Burger',
      );
      final initialStock = burgerInitial!.stock;

      await productRobot.searchProduct('Burger');
      await productRobot.openProductDetails('Burger');
      await productRobot.openStockTab();

      // Adjust stock OUT: Remove 10 units
      await productRobot.adjustStock(
        quantity: 10,
        type: 'Out',
        reason: 'Damaged goods',
      );

      await tester.pumpAndSettle();

      // Verify stock reduced
      final burgerAfter = await TestFixtures.findProductByName(
        TestApp.database,
        'Burger',
      );
      expect(
        burgerAfter!.stock,
        initialStock - 10,
        reason: 'Stock should decrease by 10',
      );

      // Verify log entry
      final logs = await (TestApp.database.select(
        TestApp.database.inventoryLogs,
      )..where((log) => log.productId.equals(burgerInitial.id))).get();
      
      final latestLog = logs.last;
      expect(latestLog.type, 'ADJUSTMENT_OUT');
      expect(latestLog.qtyChange, -10);
      expect(latestLog.reason, 'Damaged goods');
    });

    testWidgets('Edit existing product', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();

      // Find and edit Coffee
      await productRobot.searchProduct('Coffee');
      await productRobot.editProduct('Coffee');

      // Update price
      await productRobot.fillProductForm(
        name: 'Coffee Premium',
        price: 55.0,
      );

      await productRobot.saveProduct();
      await tester.pumpAndSettle();

      // Verify product updated
      final coffee = await TestFixtures.findProductByName(
        TestApp.database,
        'Coffee Premium',
      );
      
      expect(coffee, isNotNull, reason: 'Updated product should exist');
      expect(coffee!.price, 55.0, reason: 'Price should be updated');
    });

    testWidgets('Service product without stock tracking', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();
      await productRobot.openAddProductForm();

      // Create service product
      await productRobot.fillProductForm(
        name: 'Delivery Fee',
        price: 30.0,
        trackStock: false,
      );

      await productRobot.saveProduct();
      await tester.pumpAndSettle();

      // Verify product created
      final service = await TestFixtures.findProductByName(
        TestApp.database,
        'Delivery Fee',
      );
      
      expect(service, isNotNull);
      expect(service!.trackStock, false, reason: 'Should not track stock');
      expect(service.stock, 0, reason: 'Stock should be 0 for service items');
    });

    testWidgets('Filter products by category', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();

      // Filter by Drinks category
      await productRobot.filterByCategory('Drinks');

      // Should show drinks products
      productRobot.verifyProductInList('Coffee');
      productRobot.verifyProductInList('Green Tea');

      // Should not show food products
      productRobot.verifyProductNotVisible('Burger');
    });

    testWidgets('Toggle product active status', (tester) async {
      productRobot = ProductRobot(tester);

      await TestApp.pumpApp(tester);
      await productRobot.navigateToProductsPage();

      final pizzaInitial = await TestFixtures.findProductByName(
        TestApp.database,
        'Pizza Slice',
      );
      expect(pizzaInitial!.isActive, true);

      // Open product and toggle active status
      await productRobot.searchProduct('Pizza Slice');
      await productRobot.openProductDetails('Pizza Slice');
      await productRobot.toggleActiveStatus();

      await productRobot.saveProduct();
      await tester.pumpAndSettle();

      // Verify status changed
      final pizzaAfter = await TestFixtures.findProductByName(
        TestApp.database,
        'Pizza Slice',
      );
      expect(
        pizzaAfter!.isActive,
        false,
        reason: 'Product should be inactive',
      );
    });
  });
}
