# Testing — Promsell POS CE

> **Main reference:** [`README.md`](../../README.md) — project overview, quick start, links

---

**1302 tests** covering every application layer — **56% line coverage** (11,978 / 21,392 executable lines across 387 files):

| Layer | What's tested | Count |
|-------|--------------|-------|
| **Domain** | Entity equality, use case delegation, discount math, `InventoryLog` domain, `ReportCalculator` extension, `Ean13Generator` Luhn check digit, `Validators.barcode` length, `CartItem` discount, `DraftCart`, `Sale` entity, `Category` entity, `Settings`/`ShopInfo`/`ConfigEntities`/`DiscountConfig`/`TaxPaymentConfig` | ~228 |
| **BLoC / Cubit** | Event→state transitions, discount events, draft events, cart discount persistence, stock policy, `InventoryLogCubit`, `ReportCubit`, `ProductFormCubit` (draft init, sync, save, clear, restore), `SettingsCubit`, `HistoryBloc`, `DailyCloseCubit`, `SearchHistoryCubit` | ~80 |
| **Repository** | Impl with mocked datasources (sale, product, category, history, settings, daily_close, draft_cart) | ~50 |
| **Datasource** | Real in-memory SQLite (Drift) — sale, product, draft_cart, settings, daily_close | ~50 |
| **Services** | ReceiptNumberService, InventoryLogService, ReceiptPdfService, ProductImageService, BackupEncryptionService, DI graph, crash logging, PDF receipt | ~190 |
| **Widget** | Page tests (SalePage, CartReviewPage, CheckoutPage, PaymentSheet, SettingsPage, StockSettingsPage) + 60+ extracted widget tests across core (barcode, image, layout, nav, primitives, search, stock), sale (cart, catalog, checkout, drafts, payment, promptpay), product, settings (about, backup, barcode, discount, general, image, promptpay, receipt, shop, tiles), daily_close, onboarding | ~643 |
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
            │      Widget + L10n        │  ~650 tests (pumpApp + mock BLoC)
            └─────────────┬─────────────┘
        ┌─────────────────┴──────────────────┐
        │   BLoC + Services + Repository     │  ~320 tests (mocktail + mock DS)
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

### Coverage by feature

Coverage measured via `flutter test --coverage --exclude-tags stress` (lcov.info).

| Feature | Lines hit / total | Coverage |
|---------|-------------------|----------|
| **inventory** | 104 / 108 | 96.3% |
| **report** | 77 / 87 | 88.5% |
| **onboarding** | 87 / 106 | 82.1% |
| **history** | 76 / 99 | 76.8% |
| **product** | 2,876 / 4,094 | 70.2% |
| **daily_close** | 284 / 472 | 60.2% |
| **settings** | 3,122 / 5,041 | 61.9% |
| **sale** | 2,273 / 4,290 | 53.0% |
| **core** | 2,613 / 5,518 | 47.4% |
| **l10n** | 437 / 1,429 | 30.6% |
| **receipt** | 29 / 148 | 19.6% |
| **Total** | **11,978 / 21,392** | **56.0%** |

> **Note:** `l10n` coverage is low because generated `app_localizations.dart` has many unused getter branches. `receipt` coverage is low due to PDF rendering paths requiring platform plugins. `core` includes generated DI config and database code with low testability.

---

<sub>Promsell POS Community Edition · v0.8.8 · AGPL-3.0</sub>
