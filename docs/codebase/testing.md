# Testing — Promsell POS CE v0.9.0

Automated tests across unit, widget, and integration layers. Run with `flutter test` (use `--exclude-tags stress` to skip stress tests). Coverage and counts drift with the suite — prefer CI.

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
│   │           ├── drafts/     # DraftTile, DraftSearchBar, park actions
│   │       ├── pages/          # + SavedBillsPage (full-page saved bills)
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


## Integration Tests (E2E)

**Location:** `integration_test/`
**Status:** ✅ 30 tests compiling, ready for runtime validation
**Updated:** 2026-07-10

### Test Architecture

**Robot Pattern** - Maintainable test helpers:
```
integration_test/
├── helpers/
│   ├── test_app.dart              # Test app wrapper with in-memory DB
│   ├── test_fixtures.dart          # 20 products, 5 categories, realistic data
│   └── test_utils.dart             # Common assertions and Finder extensions
├── robot_pattern/
│   ├── robot_base.dart             # Base robot class
│   ├── sale_robot.dart             # Sale flow helpers
│   ├── checkout_robot.dart         # Checkout helpers
│   ├── product_robot.dart          # Product CRUD helpers
│   └── restaurant_robot.dart       # Restaurant flow helpers
├── sale_happy_path_test.dart       # 3 test cases - Cash sale flow
├── draft_recovery_test.dart        # 5 test cases - Cart persistence
├── product_management_test.dart    # 9 test cases - CRUD + stock
├── promotion_application_test.dart # 8 test cases - Discount system
├── restaurant_order_test.dart      # 5 test cases - Dine-in + modifiers
└── all_tests.dart                  # Test entry point
```

### Critical User Journeys Covered

1. **Happy Path Sale** (3 tests)
   - Add products to cart → checkout → cash payment → receipt generation
   - Inventory decremented correctly
   - Sale recorded in database

2. **Restaurant Order Flow** (5 tests)
   - Table selection → add items with modifiers → service charge calculation
   - Order type (dine-in/takeaway/delivery)
   - Table status management

3. **Draft Cart Recovery** (5 tests)
   - Cart persistence across app restart
   - Auto-save on modifications
   - Recovery after force close

4. **Product Management** (9 tests)
   - Create/update/delete products
   - Stock adjustments with reason tracking
   - Barcode generation and validation
   - Product history logs

5. **Promotion Application** (8 tests)
   - Percent and fixed discounts
   - Date-based activation
   - Receipt showing promotion details

### Running E2E Tests

```bash
# Run all integration tests
flutter test integration_test/

# Run specific journey
flutter test integration_test/sale_happy_path_test.dart

# Analyze test code
flutter analyze integration_test/
```

### Test Data
- 20 products (Coffee, Thai Milk Tea, Pad Thai, etc.)
- 5 categories (Drinks, Food, Snacks, Desserts, Merchandise)
- 3 restaurant tables
- 2 active promotions
- 3 customer records

For detailed E2E test guide, see [docs/testing/E2E_TEST_GUIDE.md](../testing/E2E_TEST_GUIDE.md).

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

<sub>Promsell POS CE · v0.9.0 · Testing</sub>
