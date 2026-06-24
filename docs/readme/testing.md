# Testing — Promsell POS CE

> **Main reference:** [`README.md`](../../README.md) — project overview, quick start, links

---

**1121 tests** covering every application layer:

| Layer | What's tested | Count |
|-------|--------------|-------|
| **Domain** | Entity equality, use case delegation, discount math, `InventoryLog` domain, `ReportCalculator` extension, `Ean13Generator` Luhn check digit, `Validators.barcode` length | ~228 |
| **BLoC / Cubit** | Event→state transitions, discount events, draft events, cart discount persistence, stock policy, `InventoryLogCubit`, `ReportCubit` | ~70 |
| **Repository** | Impl with mocked datasources | ~50 |
| **Datasource** | Real in-memory SQLite (Drift) | ~50 |
| **Services** | ReceiptNumberService, InventoryLogService, ReceiptPdfService, DI graph, crash logging, PDF receipt | ~190 |
| **Widget** | Page tests + 40+ extracted widget tests across core, product, sale, and settings | ~510 |
| **Integration** | Checkout flow, sale integrity (void + adjust), onboarding → first sale | 14 |
| **Stress** | 10k products / 50k sales seed + query timing (`@Tags(['stress'])`) | 2 |
| **L10n parity** | EN/TH key coverage, non-empty values, params | 7 |

### Test pyramid

```
                    ┌───────────┐
                    │  Stress   │  2 tests (10k+ rows, @Tags(['stress']))
                    └─────┬─────┘
                ┌─────────┴─────────┐
                │   Integration     │  14 tests (in-memory DB end-to-end)
                └─────────┬─────────┘
            ┌─────────────┴─────────────┐
            │      Widget + L10n        │  ~517 tests (pumpApp + mock BLoC)
            └─────────────┬─────────────┘
        ┌─────────────────┴──────────────────┐
        │   BLoC + Services + Repository     │  ~310 tests (mocktail + mock DS)
        └─────────────────┬──────────────────┘
    ┌─────────────────────┴──────────────────────┐
    │              Domain + Datasource           │  ~278 tests (pure Dart + in-mem DB)
    └────────────────────────────────────────────┘
```

### Running tests

```bash
# All tests (includes stress tests)
flutter test

# Exclude stress tests (faster — recommended for regular development)
flutter test --exclude-tags stress

# Stress tests only (10k products, 50k sales — may take several minutes)
flutter test --tags stress --timeout 600s

# With coverage
flutter test --coverage

# Single file
flutter test test/integration/checkout_flow_test.dart
```

### Test helpers

| File | Purpose |
|------|---------|
| `test/helpers/mocks.dart` | All mock classes (repos, datasources, use cases, BLoCs) |
| `test/helpers/pump_app.dart` | `pumpApp` extension with BlocProviders + l10n |
| `test/helpers/fake_database.dart` | In-memory Drift DB factory |

---

<sub>Promsell POS Community Edition · v0.8.5 · AGPL-3.0</sub>
