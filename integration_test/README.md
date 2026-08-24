# Integration Tests (device E2E)

Robot-pattern UI journeys for PromSell POS CE.

## Honesty first (2026-08-17)

| Claim | Reality |
|-------|---------|
| Always green on CI | **No** — `ci.yml` only formats/analyzes this folder. `release-trust.yml` **blocks** `all_tests.dart --flavor dev` on tags / money-path PRs |
| Money-path gate | **Host** `test/integration/` + `release-trust.yml` (V092-D.1 + D.4 added) |
| Device required | **Yes** — Android/iOS emulator or hardware |
| E2E ready | **No** — scaffold / flake. Stable keys now live in `lib/core/testing/test_keys.dart`, and the blocking set includes a sixth day-close reconciliation journey. Device runtime was not executed in this workspace; do not market as ready until the device suite is green 3×. |

Status: [`docs/testing/E2E_IMPLEMENTATION_STATUS.md`](../docs/testing/E2E_IMPLEMENTATION_STATUS.md)  
Guide: [`docs/testing/E2E_TEST_GUIDE.md`](../docs/testing/E2E_TEST_GUIDE.md)

## Quick start

```bash
# Analyze (no device)
flutter analyze integration_test/

# Runtime — needs supported device/emulator
flutter test integration_test/sale_happy_path_test.dart
flutter test integration_test/
```

## Journeys (device runtime required)

| Journey | File |
|---------|------|
| Happy path sale | `sale_happy_path_test.dart` |
| Restaurant order | `restaurant_order_test.dart` |
| Draft recovery | `draft_recovery_test.dart` |
| Product management | `product_management_test.dart` |
| Promotion application | `promotion_application_test.dart` |
| Day-close reconciliation | `day_close_journey_test.dart` |

## Architecture

- **Robot pattern** — semantic UI helpers  
- **Fixtures** — seeded catalog / tables / promos  
- **In-memory DB** — intended isolation (see status for DI risks)  
- **TestKeys** (`lib/core/testing/test_keys.dart`) — central stable key catalog for the six blocking journeys. Prefer these over EN-string finders.

## Prefer for automated integrity

```bash
flutter test test/integration/
```
