# Integration Tests

End-to-end tests for PromSell POS CE covering critical user journeys.

## Quick Start

```bash
# Run all E2E tests
flutter test integration_test/

# Run specific journey
flutter test integration_test/sale_happy_path_test.dart
```

## Test Coverage

| Journey | File | Scenarios |
|---------|------|-----------|
| Happy Path Sale | `sale_happy_path_test.dart` | Cash sale, empty cart validation, quantity adjustment |
| Restaurant Order | `restaurant_order_test.dart` | Table selection, modifiers, service charge, order types |
| Draft Recovery | `draft_recovery_test.dart` | App restart, cart persistence, manual clear |
| Product Management | `product_management_test.dart` | CRUD operations, stock adjustment, validation |
| Promotion Application | `promotion_application_test.dart` | Percent/fixed discounts, expiry validation |

## Architecture

- **Robot Pattern:** Semantic UI interaction methods
- **Test Fixtures:** Pre-seeded database with realistic data
- **In-Memory DB:** Fast, isolated test execution

## Documentation

See [E2E Test Guide](../docs/testing/E2E_TEST_GUIDE.md) for complete documentation.

## Test Data

- 20 products (5 categories)
- 3 restaurant tables
- 2 active promotions
- 3 customers

All data is seeded automatically via `TestFixtures.seedAll()`.
