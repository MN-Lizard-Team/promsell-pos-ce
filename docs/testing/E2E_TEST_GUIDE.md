# E2E Test Guide

## Overview

This guide covers the **device** End-to-End (E2E) suite under `integration_test/` for PromSell POS CE (robot pattern).

### Prerequisites & honesty (read first)

| Requirement | Notes |
|-------------|--------|
| **Android or iOS device/emulator** | `flutter test integration_test/` needs a supported mobile target. Desktop-only hosts fail with *No supported devices*. |
| **Main CI** | Does **not** run device tests (format + analyze only). See [`CI.md`](./CI.md). |
| **Money integrity gate** | Use host suite: `test/integration/` + `.github/workflows/release-trust.yml` (fail-closed). |
| **Manual cashier evidence** | `docs/testing/RELEASE_0.9.2_SMOKE.md` (0.9.2 scope) · `RELEASE_0.9_SMOKE.md` (historical 0.9) · `RELEASE_1.0_SMOKE.md` (1.0 plan, still No-Go). |
| **Status SSOT** | [`E2E_IMPLEMENTATION_STATUS.md`](./E2E_IMPLEMENTATION_STATUS.md) — scaffold, not “always green”. |

**Known risks before debugging flakes:** test DI bootstrap, UI money format vs `Money.toString()`, EN-only finders, missing `Key`s. See POST-090 **B4**.

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
│   ├── restaurant_robot.dart  # Restaurant mode interactions
│   └── report_robot.dart      # Report/dashboard interactions
├── sale_happy_path_test.dart
├── restaurant_order_test.dart
├── draft_recovery_test.dart
├── product_management_test.dart
├── promotion_application_test.dart
├── report_flow_test.dart
├── screenshot_test.dart
├── README.md
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

`ci.yml` does **not** invoke `flutter test integration_test/`. `release-trust.yml` **blocks** on `all_tests.dart --flavor dev` for tags / money-path PRs. Green `ci.yml` is not device E2E. Green trust smoke is not 1.0 Go.

Money-path PRs should stay green on:

```bash
flutter test test/integration/
# plus the file list in .github/workflows/release-trust.yml
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
- **All 7 journey/scenario files:** ~4-6 minutes
- **Single journey:** ~30-60 seconds

### Optimization Tips
- Use `pumpAndSettle()` instead of `pump()` with long durations
- Minimize navigation between pages
- Seed only necessary data
- Run tests in parallel when possible

---

## CI Integration

SSOT: [`CI.md`](./CI.md)

- `ci.yml`: format + analyze `integration_test/` — **no** device run
- `release-trust.yml`: blocking `flutter test integration_test/all_tests.dart --flavor dev` (the `--flavor dev` flag selects the dev entry point; `flutter test` does not accept `-t`/`--target` — see [`CI.md`](./CI.md) for the `-t` flag fix note)

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
