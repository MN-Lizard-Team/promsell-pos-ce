# Testing — Promsell POS CE

> **Main reference:** [`README.md`](../../README.md) · CI map: [`docs/testing/CI.md`](../testing/CI.md)

---

**tests** (see CI / `flutter test`) — **~2040** host tests green on 2026-08-14 (`--exclude-tags stress`); line coverage **~64%** overall (CI floor **60%**). Money-path suites fail-closed via `.github/workflows/release-trust.yml`.

| Layer | What's tested | Notes |
|-------|--------------|-------|
| **Domain / Money** | `Money` satang VO, payable calculator, entities, validators | High trust value |
| **BLoC / Cubit** | Cart freeze/payment lock, checkout, draft, settings, daily close, history | Checkout unlock-on-failure covered |
| **Repository / Datasource** | Sale insert/void stock integrity, products, drafts, settings | In-memory Drift |
| **Services** | App lock (PBKDF2 + persisted lockout), backup encrypt/restore, receipt PDF, crash log | |
| **Widget** | Sale/cart/settings/product/pages + shared primitives | Largest layer by count |
| **Host integration** | Checkout flow, sale integrity, **V092-D.1 VAT+discount+void+close**, **V092-D.4 void after day-close**, multi-tender daily close, backup money continuity, onboarding first sale | Under `test/integration/` — fail-closed in trust |
| **Device E2E** | Happy path / draft / product / promo / restaurant | Main CI: format/analyze only. Trust: blocking `--flavor dev`. V092-D.5: `TestKeys` + no `pumpAndSettle` in `restartApp`. |
| **Stress** | Large seed + timing (`@Tags(['stress'])`) | Weekly / label workflow |
| **L10n parity** | EN/TH keys | |

### Test pyramid

```
                    ┌───────────┐
                    │  Stress   │  tagged suite (not every PR)
                    └─────┬─────┘
                ┌─────────┴─────────┐
                │ Device E2E        │  not on ci.yml; trust blocks emulator
                └─────────┬─────────┘
            ┌─────────────┴─────────────┐
            │ Host integration          │  sale integrity / checkout
            └─────────────┬─────────────┘
        ┌─────────────────┴──────────────────┐
        │ Widget + BLoC + Services           │  bulk of suite
        └─────────────────┬──────────────────┘
    ┌─────────────────────┴──────────────────────┐
    │ Domain + Datasource (incl. Money path)     │  Release Trust hard gate
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
| **Total** | **21,726 / 34,129** | **63.7%** |

> **Note:** Per-feature rows are from a 2026-07-23 snapshot; the **Total** row reflects the 2026-08-13 measurement (`tool/check_path_coverage.dart`). `l10n` coverage is low because generated `app_localizations.dart` has many unused getter branches. `receipt` coverage is low due to PDF rendering paths requiring platform plugins. `core` includes generated DI config and database code with low testability.

---

<sub>Promsell POS Community Edition · v0.9.2 · AGPL-3.0</sub>
