# Testing — Promsell POS CE v0.8.8

1302 automated tests across 8 layers — 56% line coverage (11,978 / 21,392 lines). Run with `flutter test` (use `--exclude-tags stress` to skip stress tests).

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
│   ├── database/               # Barcode dedup migration test
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
│   │       ├── pages/          # SalePage, CartReviewPage, CheckoutPage, PaymentSheet
│   │       └── widgets/
│   │           ├── cart/       # CartItemCard, CartItemRow, CartQtyButton, CartQtyStepper, CartDetailRow, CartDottedLineRow, CartTotalBar, CompactCartFab, CartBottomSheet (CartItemTile, CartSummaryFooter), CartItemRow (CartItemPrice)
│   │           ├── catalog/    # SaleProductCard
│   │           ├── checkout/   # CheckoutTotalCard
│   │           ├── drafts/     # DraftsBottomSheet (DraftTile)
│   │           ├── payment/    # PaymentWidgets
│   │           └── promptpay/  # PaymentStatusCard
│   ├── product/                # Use case, BLoC, repo, datasource, widget tests
│   │   └── presentation/widgets/  # CategoryPicker, CategoryFilterBar, ProductCardShell, ProductFormCubit, ProductHeroImage
│   ├── history/                # Use case, BLoC, repo tests
│   ├── inventory/              # InventoryLog entity, use case, cubit, repo, service tests
│   ├── report/                 # ReportCubit tests + ReportCalculator domain tests
│   │   └── domain/extensions/   # ReportCalculator_test.dart
│   ├── settings/               # Cubit, repo, widget tests
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

### Coverage

| Feature | Coverage |
|---------|----------|
| inventory | 96.3% |
| report | 88.5% |
| onboarding | 82.1% |
| history | 76.8% |
| product | 70.2% |
| daily_close | 60.2% |
| settings | 61.9% |
| sale | 53.0% |
| core | 47.4% |
| l10n | 30.6% |
| receipt | 19.6% |
| **Total** | **56.0%** |

> Low-coverage areas: `l10n` (generated code), `receipt` (PDF platform plugins), `core` (generated DI/DB code).

---

<sub>Promsell POS CE · v0.8.8 · Testing</sub>
