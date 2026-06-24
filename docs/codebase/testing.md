# Testing — Promsell POS CE v0.8.5

1121 automated tests across 8 layers. Run with `flutter test` (use `--exclude-tags stress` to skip stress tests).

> **Main reference:** [`CODEBASE.md`](../CODEBASE.md) — system overview, architecture, links

---

## Test directory structure

```
test/
├── helpers/
│   ├── mocks.dart              # All mock classes (repos, datasources, use cases, BLoCs/Cubits)
│   ├── fixtures.dart           # Test entity fixtures
│   ├── pump_app.dart           # pumpApp extension for widget tests
│   └── fake_database.dart      # In-memory Drift DB factory
├── core/
│   └── utils/                  # Core utility tests (MoneyUtils, Ean13Generator, Validators)
├── features/
│   ├── sale/                   # Use case, BLoC, repo, datasource, widget tests
│   │   └── presentation/widgets/  # CartItemCard, CartDetailRow, CartQtyButton, CartDottedLineRow, CompactCartFab
│   ├── product/                # Use case, BLoC, repo, datasource, widget tests
│   │   └── presentation/widgets/  # CategoryPicker, CategoryFilterBar
│   ├── history/                # Use case, BLoC, repo tests
│   ├── inventory/              # InventoryLog entity, use case, cubit, repo tests
│   ├── report/                 # ReportCubit tests + ReportCalculator domain tests
│   │   └── domain/extensions/   # ReportCalculator_test.dart
│   ├── settings/               # Cubit, repo, widget tests
│   │   └── presentation/widgets/  # ImagePreviewCard, DemoImagePreview, BackupStatusCard, BackupInfoCard, PromptpayPreviewCard, PromptpayInfoCard, image_settings_labels
│   ├── daily_close/            # Cubit, repo, widget tests
│   │   └── presentation/widgets/  # DailyCloseDateCard, DailyCloseSummaryCard, DailyCloseReconciliationCard, DailyCloseSummaryRow, DailyCloseReadOnlyRow
│   └── onboarding/             # Widget tests
│       └── presentation/widgets/  # OnboardingHeroSection, OnboardingSection, GreenChoiceChip, OnboardingSheetOption
├── integration/
│   ├── checkout_flow_test.dart  # End-to-end data layer checkout
│   ├── sale_integrity_test.dart # Void sale, adjust stock, full audit trail
│   └── onboarding_first_sale_test.dart # Onboarding → sale → settings persist
├── tool/
│   └── seed_integration_test.dart  # Stress test (10k products, 50k sales) — @Tags(['stress'])
└── l10n/
    └── l10n_parity_test.dart   # EN/TH key parity and non-empty validation
```

---

## Test layers

| Layer | Technique | Dependencies |
|-------|-----------|-------------|
| Domain | Unit test | None (pure Dart) |
| BLoC / Cubit | `bloc_test` | Mocked use cases |
| Repository | Unit test with `mocktail` | Mocked datasources |
| Datasource | In-memory Drift DB | `sqlite3_flutter_libs` (FFI) |
| Widget | `pumpApp` + `MockBloc` | Mocked BLoC states |
| Integration | In-memory DB end-to-end | Real repos + datasources |
| Stress | `@Tags(['stress'])` — excluded from CI | In-memory Drift DB, 10k+ rows |
| L10n | Direct class instantiation | None |

---

<sub>Promsell POS CE · v0.8.5 · Testing</sub>
