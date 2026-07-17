# E2E Test Guide

## Overview

This guide covers the End-to-End (E2E) integration test suite for PromSell POS CE. The E2E tests verify critical user journeys from start to finish using the robot pattern for maintainability.

## Test Architecture

### Directory Structure

```
integration_test/
├── helpers/
│   ├── test_app.dart          # Test app wrapper with in-memory DB
│   ├── test_fixtures.dart     # Pre-seed test data
│   └── test_utils.dart        # Common utilities
├── robot_pattern/
│   ├── robot_base.dart        # Base robot class
│   ├── sale_robot.dart        # Sale/POS interactions
│   ├── checkout_robot.dart    # Checkout/payment interactions
│   ├── product_robot.dart     # Product management interactions
│   └── restaurant_robot.dart  # Restaurant mode interactions
├── sale_happy_path_test.dart
├── restaurant_order_test.dart
├── draft_recovery_test.dart
├── product_management_test.dart
├── promotion_application_test.dart
└── all_tests.dart             # Test entry point
```

## Critical User Journeys

### Journey 1: Happy Path Sale (Retail Mode)
**Scenario:** Cashier completes a simple cash sale

**Coverage:**
- Add products to cart
- Verify cart totals
- Cash payment
- Receipt generation
- Inventory decrement
- Sale recording

**Run:** `flutter test integration_test/sale_happy_path_test.dart`

---

### Journey 2: Restaurant Order Flow
**Scenario:** Waiter takes dine-in order with table selection

**Coverage:**
- Table selection
- Product ordering
- Product modifiers/options
- Service charge application
- Table status updates
- Order type (Dine-in/Takeaway/Delivery)

**Run:** `flutter test integration_test/restaurant_order_test.dart`

---

### Journey 3: Draft Cart Recovery
**Scenario:** Cart persistence and recovery after app restart

**Coverage:**
- Auto-save draft carts
- App restart simulation
- Draft recovery
- Cart state consistency
- Manual cart clearing

**Run:** `flutter test integration_test/draft_recovery_test.dart`

---

### Journey 4: Product Management
**Scenario:** Product CRUD operations and stock management

**Coverage:**
- Create product with validation
- Edit product details
- Stock adjustments (In/Out)
- Inventory log history
- Category filtering
- Active/inactive toggle

**Run:** `flutter test integration_test/product_management_test.dart`

---

### Journey 5: Promotion Application
**Scenario:** Apply discounts via active promotions

**Coverage:**
- Percent-based promotions
- Fixed-amount promotions
- Promotion validation (active/expired)
- Discount calculations
- Receipt display

**Run:** `flutter test integration_test/promotion_application_test.dart`

---

## Robot Pattern

The robot pattern encapsulates UI interactions into semantic, reusable methods. This keeps tests readable and maintainable.

### Example Usage

```dart
// Bad: Direct widget interaction
await tester.tap(find.text('Coffee'));
await tester.pumpAndSettle();
await tester.tap(find.text('Checkout'));
await tester.pumpAndSettle();

// Good: Robot pattern
await saleRobot.addProductToCart('Coffee');
await saleRobot.proceedToCheckout();
```

### Creating a New Robot

1. Extend `RobotBase`
2. Add semantic methods for user actions
3. Include verification methods

```dart
class MyFeatureRobot extends RobotBase {
  MyFeatureRobot(super.tester);

  Future<void> performAction() async {
    await tap(find.text('Action'));
  }

  void verifyResult(String expected) {
    expectText(expected);
  }
}
```

---

## Running Tests

### Run All E2E Tests
```bash
flutter test integration_test/
```

### Run Specific Journey
```bash
flutter test integration_test/sale_happy_path_test.dart
```

### Run with Verbose Output
```bash
flutter test integration_test/ --verbose
```

### Run in CI
```bash
flutter test integration_test/ --coverage
```

---

## Test Data Management

### Test Fixtures

`TestFixtures` provides pre-seeded data for tests:
- 20 products across 5 categories
- 3 restaurant tables
- 2 active promotions
- 3 customers

### In-Memory Database

Each test uses an isolated in-memory SQLite database:
- Fast execution (no disk I/O)
- Clean state per test
- No cross-test pollution

### Setup/Teardown

```dart
setUp(() async {
  await TestApp.initialize();
  await TestFixtures.seedAll(TestApp.database);
});

tearDown(() async {
  await TestApp.dispose();
});
```

---

## Writing New Tests

### 1. Identify User Journey

Define the scenario in BDD format:
```gherkin
GIVEN user is on sale page
WHEN adds product to cart
AND proceeds to checkout
THEN payment completes successfully
```

### 2. Create Test File

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_app.dart';
import 'helpers/test_fixtures.dart';
import 'robot_pattern/sale_robot.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Journey: My Feature', () {
    late SaleRobot saleRobot;

    setUp(() async {
      await TestApp.initialize();
      await TestFixtures.seedAll(TestApp.database);
    });

    tearDown(() async {
      await TestApp.dispose();
    });

    testWidgets('Test scenario', (tester) async {
      saleRobot = SaleRobot(tester);
      
      await TestApp.pumpApp(tester);
      
      // GIVEN
      await saleRobot.navigateToSalePage();
      
      // WHEN
      await saleRobot.addProductToCart('Coffee');
      
      // THEN
      saleRobot.verifyCartItem('Coffee');
    });
  });
}
```

### 3. Add to Test Suite

Update `integration_test/all_tests.dart`:
```dart
import 'my_feature_test.dart' as my_feature;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  my_feature.main();
  // ... other tests
}
```

---

## Debugging Failed Tests

### 1. Check Test Output
```bash
flutter test integration_test/sale_happy_path_test.dart --verbose
```

### 2. Print Widget Tree
```dart
import 'helpers/test_utils.dart';

TestUtils.debugPrintWidgetTree(tester);
```

### 3. Add Screenshots (Manual)
```dart
await tester.pump(Duration(seconds: 5)); // Pause to see UI
```

### 4. Check Database State
```dart
final products = await TestApp.database.select(
  TestApp.database.products,
).get();
print('Products in DB: ${products.length}');
```

### 5. Isolate Test
Comment out other tests to run only the failing one.

---

## Best Practices

### DO
- Use robot pattern for all interactions
- Verify database state after operations
- Use semantic finder names (`find.text('Coffee')`)
- Keep tests independent (no shared state)
- Seed fresh data in `setUp()`
- Clean up in `tearDown()`

### DON'T
- Use hard-coded delays (`await Future.delay()`)
- Share mutable state between tests
- Test implementation details
- Skip assertions
- Ignore flaky tests (fix them!)

---

## Performance

### Current Execution Time
- **All 5 journeys:** ~3-4 minutes
- **Single journey:** ~30-60 seconds

### Optimization Tips
- Use `pumpAndSettle()` instead of `pump()` with long durations
- Minimize navigation between pages
- Seed only necessary data
- Run tests in parallel when possible

---

## CI Integration

E2E tests run in GitHub Actions CI pipeline after unit tests:

```yaml
- name: Run integration tests
  run: flutter test integration_test/
```

**Current status:** `continue-on-error: true` (for initial rollout)

**Target:** Remove `continue-on-error` once all tests are stable

---

## Troubleshooting

### Issue: Test times out
**Solution:** Increase timeout or check for blocking operations
```dart
testWidgets('scenario', (tester) async {
  // ...
}, timeout: Timeout(Duration(minutes: 2)));
```

### Issue: Widget not found
**Solution:** Use `waitFor` helper
```dart
await TestUtils.waitFor(tester, find.text('Expected'));
```

### Issue: Database not reset
**Solution:** Ensure `tearDown` is called
```dart
tearDown(() async {
  await TestApp.dispose();
});
```

### Issue: Flaky test
**Solution:** 
1. Add explicit waits after state changes
2. Verify BLoC emits expected states
3. Check for race conditions

---

## Future Enhancements

- [ ] Add screenshot capture on failure
- [ ] Parallel test execution
- [ ] Performance benchmarking
- [ ] Visual regression testing
- [ ] Multi-device testing (tablet layouts)
- [ ] Accessibility testing integration

---

## Resources

- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Robot Pattern](https://dev.to/mjablecnik/robot-pattern-in-flutter-1h7)
- [Testing Best Practices](https://flutter.dev/docs/cookbook/testing)

---

## Support

For questions or issues with E2E tests:
1. Check this guide
2. Review existing test files
3. Consult robot pattern implementations
4. Ask in project chat/issues
