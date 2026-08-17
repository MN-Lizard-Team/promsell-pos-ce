# Testing — Promsell POS CE v0.9.2

Automated tests across unit, widget, and integration layers. Run with `flutter test` (use `--exclude-tags stress` to skip stress tests). Coverage and counts drift with the suite — prefer CI.

> **Main reference:** [`CODEBASE.md`](../../CODEBASE.md) — system overview, architecture, links

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
│   ├── database/               # Schema migrations, satang backfill, legacy fixtures, migration safety, WAL checkpoint, health report, recovery kit
│   ├── di/                     # DI graph test
│   ├── image/                  # UnifiedImageWidget, ImageSkeleton, ImageErrorPlaceholder
│   ├── services/               # CrashLogService, ReceiptPdfService
│   ├── utils/                  # MoneyUtils, Ean13Generator, Validators, PaymentMethodHelper, SlipVerifier, CurrencyFormatter, CustomerQrDecoder, AppLogger
│   └── widgets/
│       ├── barcode/            # BarcodeFormatHelper, BarcodeManualEntry, BarcodeScannerWidgets, ScanOverlayPainter
│       ├── image/              # ImageSourceSheet, ImageViewerUtils, ImageViewerWidgets
│       ├── layout/             # AdaptiveBreakpoints, LayoutWidgets, StickyActionBar
│       ├── nav/                # BottomNavigationBar, IconWithBadge, NavBarShell, NavSwipeHelper
│       ├── primitives/         # AppBadgeEmptyState, AppLoadingOverlay, AppTextDialog, MoneyText, SkeletonCard
│       ├── receipt_preview_test.dart
│       ├── search/             # SearchEmptyState, SearchHistoryCubit, SearchResultTile
│       ├── shared_ui_widgets_test.dart
│       └── stock/              # StockStepper
├── features/
│   ├── sale/                   # Use case, BLoC, repo, datasource, widget tests
│   │   └── presentation/
│   │       ├── pages/          # SalePage, CartReviewPage, CheckoutPage, PaymentPage, SavedBillsPage, SaleFilterPage, SaleProductSearchPage
│   │       └── widgets/
│   │           ├── cart/       # CartItemCard, CartQtyButton, CartDetailRow, CartDottedLineRow, CompactCartFab, CartReviewFooter, CartLineActions lock, DockedCartPanel
│   │           ├── catalog/    # SaleProductCard
│   │           ├── checkout/   # CheckoutTotalCard
│   │           ├── drafts/     # DraftTile, DraftSearchBar, park actions, drafts_bottom_sheet
│   │           ├── payment/    # PaymentWidgets
│   │           ├── promptpay/  # PaymentStatusCard
│   │           └── shared/
│   ├── product/                # Use case, BLoC, repo, datasource, widget tests
│   │   └── presentation/widgets/  # CategoryPicker, CategoryFilterBar, ProductCardShell, ProductFormCubit, ProductHeroImage
│   ├── history/                # Use case, BLoC, repo tests
│   ├── inventory/              # InventoryLog entity, use case, cubit, repo, service tests
│   ├── report/                 # ReportCubit + ReportCalculatorService + ReportSummary + streaming CSV export tests
│   │   └── domain/services/     # ReportCalculatorService_test.dart
│   ├── settings/               # Cubit, repo, widget tests, backup export/restore services
│   │   └── presentation/widgets/
│   │       ├── about/          # AboutWidgets
│   │       ├── backup/         # BackupStatusCard, BackupInfoCard
│   │       ├── barcode/        # BarcodePrefixTile, BarcodeWidgets
│   │       ├── discount/       # DiscountPolicySettingsForm (DiscountSections, DiscountSharedWidgets), DiscountPolicySummaryCard
│   │       ├── general/        # GeneralAppearanceTiles, GeneralLanguageResetTiles, GeneralSummaryCard, GeneralThemeTile, GeneralSettingsForm
│   │       ├── image/          # ImagePreviewCard, ImageSettingsTiles
│   │       ├── promptpay/      # PromptpayPreviewCard, PromptpayInfoCard, PromptpaySettingsTiles
│   │       ├── receipt/        # ReceiptSettingsForm (ReceiptContentSection)
│   │       ├── shop/           # ShopInfoForm (ShopContactField)
│   │       └── tiles/          # SettingsTextTile
│   ├── daily_close/            # Cubit, repo, widget tests
│   │   └── presentation/widgets/  # DailyCloseDateCard, DailyCloseSummaryCard, DailyCloseReconciliationCard, DailyCloseSummaryRow, DailyCloseReadOnlyRow
│   └── onboarding/             # Widget tests
│       └── presentation/widgets/  # OnboardingHeroSection, OnboardingSection, BrandChoiceChip, OnboardingSheetOption
├── integration/
│   ├── checkout_flow_test.dart  # End-to-end data layer checkout
│   ├── sale_integrity_test.dart # Void sale, adjust stock, full audit trail
│   ├── sale_vat_discount_void_close_test.dart # V092-D.1: full VAT + discount + void + day-close
│   ├── void_after_day_close_test.dart # V092-D.4: VoidSale use case + dailyCloseLock + daily_closes row
│   ├── multi_tender_daily_close_test.dart # Multi-tender → CloseDay expected cash
│   ├── backup_money_continuity_test.dart  # Backup restore reads money back
│   └── onboarding_first_sale_test.dart # Onboarding → sale → settings persist
├── tool/
│   └── seed_integration_test.dart  # Stress test (10k products, 50k sales) — @Tags(['stress'])
└── l10n/
    └── l10n_parity_test.dart   # EN/TH key parity and non-empty validation
```

### Test command notes

> **`-t` is `--tags`, not `--target`.** In `flutter test`, the short flag `-t`
> maps to `--tags` (tag selection), **not** `--target` (entrypoint). To specify
> a target file, use `--target lib/main_dev.dart` (or the long form). The
> `release-trust.yml` and `screenshots.yml` workflows previously passed
> `-t lib/main_dev.dart` to `flutter test`, which was silently interpreted as a
> tag filter rather than a target — this has been corrected by removing the
> incorrect flag.

### Performance & capacity tests (v0.9.2)

- **Cursor pagination** — `ProductLocalDatasource.getProductsPage()` /
  `searchProductsPage()` and `SaleQueryLocalDatasource.querySalesPage()` are
  covered by tests that verify `nextCursor` boundary conditions, `hasMore`
  semantics, and `totalCount` independence from pagination.
- **SQL report summary** — `SaleQueryLocalDatasource.queryReportSummary()` is
  tested for satang-SSOT aggregation, payment breakdown (multi-tender +
  legacy header fallback), and void-reason grouping.
- **Bounded streaming CSV export** — `ReportExportService.exportCsvStream()`
  is tested for the `kExportMaxRows = 10000` hard cap, `CsvExportResult.truncated`
  flag, `startSignal` future resolution, and chunked sink writes.
- **Stress test** — `test/tool/seed_integration_test.dart` (10k products, 50k
  sales) exercises large-list cursor pagination paths under `@Tags(['stress'])`.


## Integration Tests (E2E)

**Location:** `integration_test/`  
**Status (honest, 2026-08-17):** Scaffold + analyze on main CI. Runtime is **not** on `ci.yml`. Trust **blocks** emulator `--flavor dev` on tags / money-path PRs. Not “E2E ready.”<br>
**Map:** [`docs/testing/CI.md`](../testing/CI.md)

| Layer | Path | CI | Notes |
|-------|------|----|-------|
| **Host integration (money net)** | `test/integration/` | **Fail-closed** via `release-trust.yml` | Real repos + in-memory Drift. V092-D.1 + D.4 added. |
| **Device E2E (UI journeys)** | `integration_test/` | Main CI = **format + analyze only**. Trust = **blocking** `all_tests.dart --flavor dev` | Scaffold / flake; flavor is **dev**. V092-D.5: `pumpAndSettle` dropped in `restartApp`, `TestKeys` added. |
| **Manual smoke** | `RELEASE_0.9.2_SMOKE.md` · `RELEASE_1.0_SMOKE.md` | Human | 1.0 sheet is still **No-Go**. 0.9.2 sheet covers cold-start + PIN + void. |

### Device E2E — what is true (2026-08-17)

- Robot pattern + fixtures exist under `integration_test/`
- `ci.yml` does **not** run device tests (`continue-on-error` is gone)
- Tags `v*` and money-path PRs **block** on the emulator job — green smoke ≠ 1.0 Go
- `release-trust.yml` runs `integration_test/all_tests.dart --flavor dev` **blocking** on money paths and tags
- `screenshots.yml` is visual; does not assert money
- Known risks (V092-D.5 partial fix): `TestApp.restartApp` no longer uses `pumpAndSettle`; `TestKeys` constants added for the 5 core cases. EN-string finders still exist in older tests — migrate to `TestKeys` when touching those files.
- Do **not** market “E2E ready” until a hard-gated smoke subset is green 3× (POST-090 B4 / V092-D)

### Architecture (scaffold)

```
integration_test/
├── helpers/          # test_app, fixtures, utils
├── robot_pattern/    # sale, checkout, product, restaurant robots
├── sale_happy_path_test.dart
├── draft_recovery_test.dart
├── product_management_test.dart
├── promotion_application_test.dart
├── restaurant_order_test.dart
└── all_tests.dart
```

### Running device E2E (requires device/emulator)

```bash
flutter analyze integration_test/
# Requires supported device — will fail with "No supported devices" on desktop-only hosts:
flutter test integration_test/sale_happy_path_test.dart
```

### Prefer for money-path automation

```bash
flutter test test/integration/
# or full trust list:
# .github/workflows/release-trust.yml
```

Details: [E2E_TEST_GUIDE.md](../testing/E2E_TEST_GUIDE.md) · [E2E_IMPLEMENTATION_STATUS.md](../testing/E2E_IMPLEMENTATION_STATUS.md)

## Test layers

| Layer | Technique | Dependencies |
|-------|-----------|-------------|
| Domain | Unit test | None (pure Dart) |
| BLoC / Cubit | `bloc_test` | Mocked use cases |
| Repository | Unit test with `mocktail` | Mocked datasources |
| Datasource | In-memory Drift DB | `sqlcipher_flutter_libs (production) / in-memory Drift for tests` (FFI) |
| Widget | `pumpApp` + `MockBloc` | Mocked BLoC states |
| Integration | In-memory DB end-to-end | Real repos + datasources |
| Stress | `@Tags(['stress'])` — excluded from CI | In-memory Drift DB, 10k+ rows |
| L10n | Direct class instantiation | None |

### Coverage

**CI gates**

| Gate | Value | Enforcement |
|------|------:|-------------|
| Global (excludes generated/l10n) | **60%** → ladder 70 → 80 | Hard via `tool/check_path_coverage.dart` on `ci.yml` |
| **sale-logic** = sale `domain/` + `data/` + `lib/core/domain/` | **≥80%** | Hard `--fail` via `tool/check_path_coverage.dart` |
| Full sale tree + `core/domain` (incl. presentation) | report only | Soft until ≥80 + buffer |

```bash
flutter test --coverage --exclude-tags stress
dart run tool/check_path_coverage.dart --fail --min-global=60 --min-sale-logic=80
```

**Measured snapshot (2026-08-13, after excludes):**

| Bucket | Coverage |
|--------|----------|
| global | **63.7%** |
| sale-logic (money path) | **92.4%** |
| sale/domain | 90.0% |
| sale/data | 93.6% |
| sale/presentation | 58.1% |
| sale+domain full tree | 62.4% |

> Prefer money-path tests + **sale-logic** hard gate over covering PDF/camera/UI chrome for vanity %.  
> Policy: `docs/plan/UN-COMPLETE/POST-090-MANAGE/WS-B-QA-HARDENING.md` §B3.

---

<sub>Promsell POS CE · v0.9.2 · Testing</sub>
