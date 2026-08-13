# Integration Tests (device E2E)

Robot-pattern UI journeys for PromSell POS CE.

## Honesty first

| Claim | Reality |
|-------|---------|
| Always green on CI | **No** — `ci.yml` only formats/analyzes this folder. `release-trust.yml` **blocks** `all_tests.dart --flavor dev` on tags / money-path PRs |
| Money-path gate | **Host** `test/integration/` + `release-trust.yml` |
| Device required | **Yes** — Android/iOS emulator or hardware |

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

## Journeys (scaffold)

| Journey | File |
|---------|------|
| Happy path sale | `sale_happy_path_test.dart` |
| Restaurant order | `restaurant_order_test.dart` |
| Draft recovery | `draft_recovery_test.dart` |
| Product management | `product_management_test.dart` |
| Promotion application | `promotion_application_test.dart` |

## Architecture

- **Robot pattern** — semantic UI helpers  
- **Fixtures** — seeded catalog / tables / promos  
- **In-memory DB** — intended isolation (see status for DI risks)  

## Prefer for automated integrity

```bash
flutter test test/integration/
```
