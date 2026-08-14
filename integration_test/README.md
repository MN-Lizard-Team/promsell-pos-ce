# Integration Tests (device E2E)

Robot-pattern UI journeys for PromSell POS CE.

## Honesty first (2026-08-14)

| Claim | Reality |
|-------|---------|
| Always green on CI | **No** — `ci.yml` only formats/analyzes this folder. `release-trust.yml` **blocks** `all_tests.dart --flavor dev` on tags / money-path PRs |
| Money-path gate | **Host** `test/integration/` + `release-trust.yml` (V092-D.1 + D.4 added) |
| Device required | **Yes** — Android/iOS emulator or hardware |
| E2E ready | **No** — scaffold / flake. V092-D.5: `pumpAndSettle` dropped in `restartApp`, `TestKeys` constants added. Do not market as ready until 5 core cases green 3×. |

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
- **TestKeys** (`test_app.dart`) — stable `Key` constants for the 5 core cases (V092-D.5). Prefer these over EN-string finders.

## Prefer for automated integrity

```bash
flutter test test/integration/
```
