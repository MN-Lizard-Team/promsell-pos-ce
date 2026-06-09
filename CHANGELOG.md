# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added

### Changed

### Fixed

---

## [0.7.4] - 2026-06-09

PromptPay system overhaul, data loss prevention, settings atomicity, and UI polish.

### Highlights

- **Data Loss Prevention** — `SaleBloc.close()` and `SettingsPersistenceService.dispose()` await pending saves.
- **Settings Atomicity** — `save()` wrapped in Drift transaction.
- **PromptPay System** — EMVCo QR generation, slip verification, auto-confirm, configurable timeout/sound/QR-type.
- **PromptPayPaymentPage v2** — Responsive split-screen, timer progress bar, cart summary, status card, sticky footer.
- **SlipScannerDialog** — Camera lifecycle management, debounce, error overlays, colored borders.

### Added

- `SettingsLocalDatasource.setAll()` — atomic multi-key batch write.
- `Product` fields — `sku`, `barcode`, `cost`.
- `PromptPayQrCode` — EMVCo payload via `thai_promptpay` library.
- `PromptPayPaymentPage` — fullscreen payment page (replaces `AlertDialog`).
- `SlipScannerDialog` — QR camera scanner with slip verification.
- `SlipVerifier` + `SlipErrorType` — bank slip Mini-QR decoding.
- `SoundPlayer` — confirmation audio feedback.
- `PaymentConfig` settings — `defaultQrType`, `autoConfirmAfterSlip`, `qrOverlayIcon`.
- `Sale` fields — `paymentReference`, `sendingBankCode`.
- `ReportPromptPayCard` — Thai bank name chip.
- `Validators.promptpayId()` — mod-11 + mobile prefix validation.
- Tap QR → fullscreen view (320px, dark overlay).
- Customizable QR overlay icon — 8 choices, default none, 12% size for scannability.

### Changed

- `SaleBloc.close()` — awaits `_immediateSave()`.
- `SaleBloc._scheduleSave` — debounce 500ms → 1500ms.
- `SettingsRepositoryImpl.save()` — uses `setAll()` for atomic writes.
- `SettingsPersistenceService.dispose()` — `Future<void>`, saves before close.
- `DiscountConfig.activeDiscountPreset` — returns default on empty list.
- `voidSale` — `balanceAfter: -1` for deleted products.
- `CheckoutBody` — PromptPay pushes `PromptPayPaymentPage`; records `amountReceived` for non-cash.
- Theme colors — hardcoded `Colors.xxx` → `colorScheme`.
- All user-facing strings → l10n ARB keys.

### Fixed

- `sendingBankCode` missing from `Sales` Drift table.
- `sendingBankCode` not wired through `SalePaymentConfirmed` → DB.
- `PromptPayConfirmationDialog` `LayoutBuilder` crash → replaced with page.
- `buildPromptPayQrPayload` unhandled `FormatException` in `build()`.
- Duplicate QR in checkout (inline + dialog).
- `SlipScannerDialog` no camera permission error handling.
- Draft data loss on `SaleBloc.close()`.
- Settings partial write / data loss on `dispose()`.
- `AppSettings.copyWith` reset `receiptSize`.
- `ReportCalculator.topProducts()` merged duplicate names.
- `activeDiscountPreset` crash on empty list.
- Product form defaults to 0 on parse failure.
- `querySales` unnecessary transaction.
- `deleteDraft` orphaned items.
- Cart qty accepts `0` without feedback.
- PromptPay missing from checkout / QR not generated / ID unused.
- PromptPay ID validation (no mod-11, no prefix checks).
- Onboarding accepted invalid PromptPay ID.
- `SaleReceiptDialog` stale `context` after async print/share.
- Timer progress bar no animation (`_lastProgress`).
- Status card showed raw bank code → Thai bank name.
- Sticky footer overlapped keyboard.
- QR pulse `ScaleTransition` clip.
- Missing accessibility labels.
- AppBar redundant spacing.
- Status didn't reset on reference clear.
- Cart "Show more" with exactly 5 items.

`flutter analyze` → **0 issues** · `flutter test` → **339/339 passing**

---

## [0.7.3] - 2026-06-08

Settings Clean Architecture + widget decomposition of 9 largest presentation pages + domain logic extraction.

### Highlights

- **Settings Aggregate Root** — `Settings` with 12 typed group entities; `SettingsMapper` for serialization; `SettingsPersistenceService` owns debounce + save logic.
- **Domain Scaffolding** — Failure types for all 6 non-settings features; missing Sale Use Cases (`GetSales`, `GetSaleById`, `WatchSales`, `WatchRecentSales`).
- **Widget Decomposition** — 9 pages refactored, 16 widgets extracted (~3,800 lines moved from pages → widgets/domain).
- **Report Domain Logic** — `_completedSales`, `_netRevenue`, `_byMethod`, `_topProducts` moved to `ReportCalculator` extension on `List<Sale>`.

### Added

- `Settings` aggregate root + 12 typed group entities + `SettingsMapper` + `SettingsPersistenceService`.
- Settings Use Cases — `GetSettings`, `UpdateSettings`, `UpdateSettingGroup` with `SettingsFailure` types.
- Failure types — `SaleFailure`, `ProductFailure`, `DailyCloseFailure`, `InventoryFailure`, `HistoryFailure`, `ReportFailure`.
- Sale Use Cases — `GetSales`, `GetSaleById`, `WatchSales`, `WatchRecentSales`.
- Extracted widgets — `OnboardingHeroSection`, `OnboardingSection`, `GreenChoiceChip`, `OnboardingSheetOption`, `CartItemCard`, `CartDetailRow`, `CartQtyButton`, `CartDottedLineRow`, `CompactCartFab`, `ImagePreviewCard`, `DemoImagePreview`, `BackupStatusCard`, `BackupInfoCard`, `DailyCloseDateCard`, `DailyCloseSummaryCard`, `DailyCloseReconciliationCard`, `DailyCloseSummaryRow`, `DailyCloseReadOnlyRow`, `ProductCategoryAutocomplete`, `PromptpayPreviewCard`, `PromptpayInfoCard`, `ReportDateRangeCard`, `ReportPaymentMethodCard`, `ReportTopProductsCard`.
- Domain extension — `ReportCalculator` on `List<Sale>`.
- Widget tests for all 16 extracted widgets + `ReportCalculatorTest`.

### Changed

- `SettingsRepositoryImpl` — returns `Settings` aggregate via `SettingsMapper`; serialization delegated to mapper.
- `AppSettings` — marked `@Deprecated` as facade over `Settings`.
- `SettingsCubit` → delegates persistence to `SettingsPersistenceService`.
- `DailyCloseCubit`, `ProductImageService`, `SaleBloc` — updated to typed group accessors.
- 9 pages decomposed — `onboarding`, `cart_review`, `image_settings`, `backup_settings`, `daily_close`, `sale_page` (renamed from `sale_page_redesign`), `product_form`, `promptpay_settings`, `report_page`.

### Fixed

- Updated all consumers to typed group accessors or `@Deprecated` facade pattern.
- Removed dead code (old private widget classes) from 8 refactored pages.
- `SettingsRepositoryImplTest` — mocks `getAll()` instead of individual getters.

`flutter analyze` → **0 issues** · `flutter test` → **337/337 passing**

---

## [0.7.2] - 2026-06-08

Data resilience and cart UX — sync columns, backup encryption, settings hierarchy, and button animations

### Highlights

- **Sync Columns** — Schema v11→v12; all 6 tables carry `updatedAt`, `deletedAt`, `version`, `deviceId`.
- **Backup Encryption** — AES-256-GCM with PIN-derived PBKDF2 key; toggle in Settings → Backup.
- **Crash Recovery** — Immediate draft save on critical events; debounce 1500ms → 500ms.
- **Cart UX Polish** — Full-screen drag, pinned summary, larger touch targets, ultra-compact items, Normal↔Ultra toggle.
- **Settings Hierarchy** — 3-level navigation: topic groups → sub-topics → individual pages + cross-sub-topic search.

### Added

- `BackupEncryptionService` (AES-256-GCM, PBKDF2) + setting + UI toggle.
- `AppTextDialog` reusable widget with auto-managed `TextEditingController`.
- Sync columns on `SaleItem`, `DailyClose`, `InventoryLog`, `DraftCart` + schema v11→v12 migrations.
- `AppSplashScreen` + `AppSplashWrapper` animated loading with shimmer skeletons.
- 3-level Settings hierarchy (Root → SubTopic → Page) with flattened search.
- `PopScope` double-tap back-to-exit on `_MainShell`.
- `searchSettings`, `appTagline`, `loading` l10n keys.

### Changed

- `SaleBloc` — `_immediateSave()` on cart clear/restore/close; debounce 500ms.
- `SaleBloc._scheduleSave` / `_immediateSave` — `await` + `try-catch` + `debugPrint` (was fire-and-forget).
- Settings hierarchy — Flat 12 tiles → 3-level groups (General, Store, Payment, System).
- Onboarding `_skip()`/`_finish()` — Uses `SettingsCubit.updateField()` instead of direct `repo.save()`.
- `CartBottomSheet` — `CustomScrollView` → `Column` + `ListView.builder` with sheet `scrollController`; drag-to-expand now works.
- `CartBottomSheet` summary — Moved out of scroll into pinned bottom `Container` with `bottomInset` padding.
- `CartItemRow` redesign — Single-row 3-zone layout (info | stepper | price), `surfaceContainerLow` card, inline discount chip, removed top-right delete button & drag handle.
- `CartQtyStepper` — Height 48→36px, button 32×32px, font titleMedium, tighter container.
- `CartPanel` — Removed search/filter system (search field, query state, filter method).
- CartHeader toggle — `cubit.update()` → `cubit.updateField()`; cycles Normal↔Ultra only.
- `_CompactCartFab` — Added `onLongPress` to exit compact mode; bounce animation on count change, badge pulse, total cross-fade, press scale.
- `CartQtyStepper` — `_StepperButton`: press scale animation (0.85×), haptic feedback, `primaryContainer` background.
- `CartBottomSheet` — Background `surface`; summary background `surface` + shadow (matches `CartTotalBar`); discount button `TextButton.icon` (matches normal cart); checkout haptic; delete `IconButton.filledTonal` with `errorContainer`.
- `CheckoutBody` confirm — haptic feedback on press.
- `CartReviewPage._QtyButton` — press scale animation + haptic.
- Theme migration — hardcoded `Colors.xxx` → `AppColors` tokens in Settings module (5 files).
- All list pages use `AppEmptyState` consistently.

### Fixed

- N+1 queries → batch `IN` in `listDrafts`, `insertSaleWithItems`, `voidSale`.
- Dialog `TextEditingController` disposal crash — reverted `.whenComplete(() => ctrl.dispose())` (17 files).
- Silent failures → `debugPrint` in `HistoryBloc`, `DailyCloseCubit`, `AppDatabase`, `ReportCubit`, etc.
- `DailyCloseRepositoryImpl._toData` — `DateTime?` fallback for `updatedAt`.
- Unsafe parse crash → `double.tryParse`/`int.tryParse` in `ProductFormPage` and `AdjustStockDialog`.
- `DraftCart` getters — manual `double.parse` → `MoneyUtils.round()`.
- `CartBottomSheet` checkout — `ProviderNotFoundException` via `BlocProvider.value` wrapping.
- Schema v12 — v11 added DateTime as TEXT ISO8601; v12 converts to millisecondsSinceEpoch via `strftime('%s') * 1000`.
- Locale change — Pops back to `SettingsRootPage` to prevent stale language on sub-pages.

### Tests

- `BackupEncryptionService` — 7 tests (encrypt, decrypt, verify, error cases).

`flutter analyze` → **0 issues** · `flutter test` → **286/286 passing**

---

## [0.7.1] - 2026-06-05

Business operations — daily close, onboarding, DB health, and compact POS layout

### Highlights

- **Daily Close** — End-of-day cash reconciliation with sales summary, payment breakdown, and reopen support.
- **Onboarding Wizard** — First-launch setup flow for shop profile, locale, tax, and PromptPay with vertical card layout.
- **DB Health Dashboard** — File size, per-table row counts, and one-tap VACUUM in Settings.
- **Compact Cart Mode** — Floating cart icon with bottom sheet for compact POS layout (toggle in Settings → General).
- **Global Theme Unification** — Premium green/dark palette (`#00C853`) across the entire app.

### Added

- `DailyClose` domain entity, repository, use case, cubit, and DI wiring (full Clean Architecture stack).
- `DailyCloseListPage` / `DailyClosePage` with local `sl<T>()` + `BlocProvider.value` injection.
- `OnboardingPage` — 6-step first-launch flow generating `deviceId` (UUIDv4) and `devicePrefix` (3-char); skippable.
- `DbHealthPage` — Settings → Database Health with file size, row counts, large-DB warnings (>50MB), and VACUUM action.
- `CartBottomSheet` — Floating cart bottom sheet for Compact Cart Mode with +/- qty, delete, and checkout.
- 6 new `AppSettings` fields — `deviceId`, `devicePrefix`, `onboardingCompleted`, `dailyCloseLock`, `lastClosedDate`, `compactCartMode`.
- Schema migration v8→v10; `daily_closes` table gains `payment_breakdown` (JSON), `vat_amount`, `discount_amount`, nullable `closed_at`.
- Sales lock — `dailyCloseLock` blocks checkout when the current day is closed.
- l10n parity — All Daily Close, Onboarding, DB Health, and Compact Cart strings in Thai + English.
- Phase 4 Readiness Audit — Documented in `CODEBASE.md`; 4 of 9 tables sync-ready.

### Changed

- `OnboardingPage` UX — Vertical-scroll single-page layout with 4 card sections, theme-aware background, and consolidated language/theme bottom sheet. Shop name now optional. All colors now read from `Theme.of(context).colorScheme`.
- Settings dashboard quick toggles — Tap language badge to toggle TH/EN, tap theme badge to cycle light → dark → system.
- `SettingsPage` index numbering — Shifted to accommodate Daily Close and DB Health tiles in System & Data group.
- **Global theme unification** — `AppColors.primary` → `#00C853`, dark background `#0D1117`; card radius → 16px, button/input radius → 12px. `SettingsThemeExtension.softAccent` → `#00C853`/`#00E676`.
- Settings readability — Dashboard card gradient raised (0.18→0.35), badge backgrounds (0.12→0.20); icon container dark background → `#0D2B1A`.
- Cart panel — Empty state icon color → `onSurfaceVariant`; replaced `Card` wrapper with `Container` + border.
- Cart header — Reduced vertical padding (6px → 4px).
- `CODEBASE.md` — Updated to schema v10; added Daily Close, Onboarding, DB Health, and CartBottomSheet modules.

### Fixed

- `accessibilityMode` persistence — Present in `AppSettings` entity but never saved/loaded by `SettingsRepositoryImpl`; now persisted correctly.
- `DropdownButtonFormField` deprecation — Replaced deprecated `value` with `initialValue` in Onboarding locale step.
- `DailyCloseData` const analyzer info — Added `const` to test constructors.
- `DailyClose.copyWith` — Fixed nullable field clearing (`closedAt`, `note`, `deviceId`) when explicitly passed as `null`.
- Hardcoded colors — Removed all hardcoded `Color(0xFF...)` outside `lib/core/theme/`; `Colors.red/orange/green` replaced with `colorScheme.error/primaryContainer`.

### Tests

- `DailyClose` entity equality, repository data mapping, cubit state transitions.
- `CloseDay` and `ReopenDay` use cases.

`flutter analyze` → **0 issues** · `flutter test` → **279/279 passing**

---

## [0.7.0] - 2026-06-04

Full Settings UX overhaul — dashboard cards, visual pickers, validation, and grouped sections across all pages

### Highlights

- **Elderly-Friendly Settings Redesign** — Single soft-accent palette replaces 10 garish colors. Larger touch targets (48dp icons, 64dp tiles), bigger fonts (16px titles, 14px subtitles), and real-time search on root page.
- **Dashboard Cards on Every Page** — Gradient preview cards with status badges for Backup (Safe/Warning/Overdue), PromptPay (Active/Not set), and General (language, theme, accessibility).
- **Visual Dialog Pickers & Validation** — Language and theme selection moved from inline `ChoiceChip`s to icon-based dialog cards. PromptPay ID validated (phone 10 digits / citizen ID 13 digits). Shop Info inline form with phone auto-format.
- **Settings Root Dashboard** — At-a-glance dashboard with 5 summary badges; categories grouped into `Store & Business`, `Payments`, `System & Data`; colored status chips on every tile.

### Added

- `SettingsThemeExtension` — Single `softAccent` palette with accessibility sizing tokens (`tileMinHeight`, `iconSize`, `tilePadding`).
- `ShopPreviewCard` — Live receipt preview; `ShopInfoForm` — inline form with dirty-state tracking, counters, and phone auto-format.
- `SettingsCategoryTile` — Tap scale feedback, `InkWell` ripple, value preview below subtitle; `SettingsSectionCard` — softer borders, larger titles.
- `accessibilityMode` field — Added to `AppSettings` (bool, default false).
- Settings search — Real-time category filtering by title/subtitle on root page.
- Dashboard cards — Gradient status cards for Backup (Safe/Warning/Overdue), PromptPay (Active/Not set), General (language/theme/badges), and root page (5-summary dashboard).
- Info cards — `_BackupInfoCard`, `_PromptpayInfoCard`, `_GeneralInfoCard` explaining feature usage.
- Visual dialog pickers — `_DialogOptionTile` for language/theme selection with icon, label, and selected highlight. PromptPay ID validation dialog (phone 10 digits / citizen ID 13 digits).
- Backup reminder Switch + frequency picker — `SwitchListTile` with dialog of preset `ChoiceChip` options (3/7/14/30 days) + custom input. "Backup Now" action tile.
- "Reset to Defaults" tile — Confirmation dialog restoring `locale: th`, `themeMode: system`, `accessibilityMode: false`.
- `_StatusChip` — Reusable colored badge; `SettingsCategoryTile.statusChip` parameter. Category grouping into `Store & Business`, `Payments`, `System & Data` sections.
- 32 new l10n keys — Backup, PromptPay, General, and Settings Root labels.

### Changed

- **Palette & touch targets** — 10 saturated category colors replaced by single `softAccent`. Titles 14→16px, subtitles 12→14px; icons 40→48dp, tile minHeight 64dp.
- **Settings pages rewritten** — Shop Info (inline form + preview), Backup (`SwitchListTile` + dialog picker), PromptPay (preview card + validation dialog), General (dialog pickers + reset tile), Root (dashboard + grouped sections + status chips).
- **Dropdown tiles** — Selected value shown as `subtitle` instead of trailing chip.
- **Receipt size** — Moved from PromptPay settings to Shop Info settings.
- `AppSettings.props` — 33 → 34 (accessibilityMode).
- `SettingsValuePreview` — Removed chip background; now plain bold `softAccent` text.

### Fixed

- `app_settings_test.dart` — `props.length` updated 33 → 34.
- `settings_page_test.dart` — Category tile count adjusted for new layout.

### Tests

- Settings root page renders with search and category tiles.
- Settings root page shows ≥7 `SettingsCategoryTile` widgets.
- Shop Info form validation, dirty state, and save flow.
- Existing Cubit/repo/datasource tests unchanged (27 settings tests passing).

`flutter analyze` → **0 issues** · `flutter test` → **258/258 passing**

---

## [0.6.3] - 2026-06-04

InventoryLog Clean Architecture, category autocomplete, history search, cart qty input, bug fixes, platform hardening, and store submission prep.

### Highlights

- **InventoryLog Clean Architecture** — Domain/data/presentation layer split; UI no longer imports Drift directly.
- **Category Autocomplete** — Product form suggests existing categories while preserving free-text entry.
- **History Search Bar** — Filter sale history by receipt number, payment method, or amount.
- **Cart Direct Qty Input** — Tap quantity in cart to open numeric input dialog with stock info.

### Added

- `InventoryLog` domain entity, repository, use case, cubit, and DI wiring (full Clean Architecture stack).
- `_CategoryAutocomplete` widget with case-insensitive filtering.
- `HistorySearchChanged` event + `HistoryState.filteredSales` for history search.
- Cart qty tap dialog with stock clamping in `CartItemRow` and `CartReviewPage`.
- Android permissions (`INTERNET`, `CAMERA`, `READ_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`).
- Android release signing config with `keystore.properties` fallback to debug.
- iOS privacy strings (`NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`).
- iOS App Store compliance (`ITSAppUsesNonExemptEncryption = false`) and ATS (`NSAllowsArbitraryLoads = true`).
- Play Store + App Store metadata in `fastlane/metadata/`.
- `docs/PRIVACY_POLICY.md` and `docs/STORE_SUBMISSION.md`.
- GitHub Actions CI enhancements: `dart format`, `dart pub outdated`, `flutter build apk --debug`.
- Dependabot weekly `pub` updates.
- `android:allowBackup="false"` to prevent Google Cloud DB backups.
- 2 l10n keys: `searchHistoryHint`, `noSearchResults`.

### Changed

- `InventoryLogPage` — Replaced direct Drift queries with `InventoryLogCubit` + `BlocBuilder`.
- `ProductFormPage` — Category field replaced by `_CategoryAutocomplete`.
- `HistoryBloc`/`HistoryPage` — Added search handler + filtered list view.
- App label → `"Promsell"` on Android (`AndroidManifest.xml`) and iOS (`Info.plist`).
- Version bumped `0.6.2+1` → `0.6.3+2`.

### Fixed

- Schema migration `from < 2` gap — safe migration with `_addColumnIfNotExists` guard.
- Receipt number race condition — cached device prefix in `_cachedPrefix`.
- `SettingsCubit.load` silently swallowed errors — now surfaces `errorMessage` in `failure` state.
- Void sale deleted-product log — `logVoidReversal` accepts `reason` for semantic clarity.
- VAT/discount rounding — centralized in `MoneyUtils.round()`.
- Receipt number service — batched 3 queries into single `SELECT ... WHERE key IN (...)`.
- `querySales` read consistency — wrapped in `_db.transaction()` for snapshot isolation.
- `watchSales`/`watchRecentSales` N+1 verification confirmed — already uses `saleId.isIn()` batching.

### Tests

- InventoryLog entity equality, `isPositive`, `props`.
- `WatchInventoryLogs` use case with/without `productId` filter.
- `InventoryLogCubit` initial, success, failure states.
- `HistoryBloc` search query updates and `filteredSales` behavior.

`flutter analyze` → **0 issues** · `flutter test` → **258/258 passing**

---

## [0.6.2] - 2026-06-02

UX accessibility & performance improvements plus 14 systematic bug fixes.

### Highlights

- **Cart drag performance** — `ValueNotifier` refactor eliminates frame jank during panel resize.
- **Checkout VAT efficiency** — Single `calculateVat()` call deduplicated from total + receipt preview.
- **Accessibility batch** — 48dp checkbox touch targets, drag tooltips, focus indicators, colorblind stock badge icons.
- **Delete confirmation** — Cart item removal shows `AlertDialog` confirmation; consistent with product deletion.

### Added

- Drag handle tooltip (`reorderItem` l10n key, EN + TH).
- Semantic labels on key icons for screen readers.
- Focus color on `_QtyButton` for keyboard navigation visibility.
- Colorblind-friendly stock badge icons (`error_outline` / `warning_amber` / `check_circle_outline`).
- Product list `SearchBar` clear button.
- `DiscountDialog` keyboard submit (`TextInputAction.done`).

### Changed

- `SalePage` drag panel uses `ValueNotifier<double>` + `ValueListenableBuilder` instead of `setState`.
- `CheckoutBody` computes `calculateVat()` once per `BlocBuilder` callback and reuses result.
- Toast now dismissible by tap (replaced `IgnorePointer` with `GestureDetector`).
- Cart minus button always shows `remove` icon; delete confirmation on last qty.
- All `showModalBottomSheet` calls use `useRootNavigator: true`.

### Fixed

- Checkbox touch target below 48dp minimum.
- BUG-1 — Cart/Checkout VAT display inconsistent in EXCLUSIVE mode.
- BUG-2/11 — Negative `preTaxTotal` when cart discount exceeds subtotal.
- BUG-3 — Void sale restored stock for non-tracked products.
- BUG-4 — `ReportState.copyWith` couldn't set `from`/`to` to null.
- BUG-5 — `AppSettings.copyWith` couldn't clear `lastBackupAt`.
- BUG-6 — `lastBackupAt` null handling in settings save/load.
- BUG-7 — `SaleCartCleared` preserved cart discount fields.
- BUG-8 — `SaleReset` carried over old items/note/discount.
- BUG-9 — Windows path separator bug in `ProductImageService`.
- BUG-10 — `ReceiptNumberService` used insecure `Random()`.
- BUG-12 — `CheckoutBody` `_effectiveTotal` side-effect in `build()`.
- BUG-13 — `SettingsCubit.load` silently marked error as `loaded`.
- BUG-14 — `_compressAndSave` didn't check source file exists.
- BUG-17 — Cart reorder fallback inserted unknown items at index 0.
- BUG-18 — Per-item `vatAmount` not persisted in `saleItems`.

`flutter analyze` → **0 issues** · `flutter test` → **243/243 passing**

---

## [0.6.1] - 2026-06-02

Sale flow UX redesign, cart panel overhaul, interactive checkout review, and product image system polish.

### Highlights

- **Cart Panel Overhaul** — Search, group-by-category, multi-select, swipe actions, drag-to-reorder, resizable panel with drag handles, compact/ultra-compact modes, landscape support.
- **Interactive Checkout Review** — Full-screen `CheckoutPage` with `CartReviewPage` for cart editing (qty +/-, delete, undo), product image zoom, and detail bottom sheet.
- **Product Image Polish** — Orphaned file cleanup, remove-then-cancel fix, image visibility throughout sale flow, avatar and form improvements.

### Added

- **Cart search & grouping** — `CartPanel` search bar filters by name (appears at >5 items); group-by-category view with section headers; toggle between grouped/flat list.
- **Multi-select & swipe** — Long-press enters selection mode for bulk delete/clear discount; flat list supports swipe-right-to-delete and swipe-left-to-increment.
- **Drag-to-reorder** — Flat list uses `ReorderableListView` with explicit drag handle (`ReorderableDragStartListener`).
- **Compact modes** — `cartCompactMode` / `ultraCompactMode` settings; quick cycle button in `CartHeader` (Normal → Compact → Ultra-Compact).
- **Resizable cart panel** — Drag handle for freeform height/width resizing with hit-area (24/20px), mouse cursor hints, snap-to-preset, and landscape side-by-side layout.
- **Checkout flow** — Full-screen `CheckoutPage` with `CartReviewPage` (interactive cart editing, image zoom, product detail sheet, receipt summary); `CheckoutBody` auto-computes total from live `SaleBloc` state.
- **Receipt preview zoom** — Tap receipt to open full-screen `InteractiveViewer` dialog (pinch zoom 0.8x–3x, close button, background dismiss).
- **Centralized `ImageViewerDialog`** — Reusable `core/widgets/image_viewer_dialog.dart` with pinch zoom, double-tap zoom (2.5x), swipe gallery, page indicators. Used in `CartReviewPage` and `ProductFormAvatar`.
- **Draft system** — Configurable `maxDrafts` (5–100), draft search + sort, count badge in `CartHeader`, auto-archive after 7 days, count caching.
- **Product image polish** — `ProductAvatar` in sale flow, `ProductFormAvatar` edit badge + ripple, long-press zoom preview, loading overlay during pick, Material 3 picker bottom sheet, `renameImages()` API.
- **17 new ARB keys** (EN + TH) — `searchDrafts`, `untitledDraft`, `noMatchingItems`, `noMatchingDrafts`, `groupView`, `cartSizeMini/Half/Full`, `cartCompactNormal/Compact/Ultra`, `atStockLimit`, `justNow`, `timeAgoMinutes/Hours/Days`, `searchResultsCount`.

### Fixed

- **Orphaned product images** — `updateProduct()` deletes old file + thumbnail on replacement/removal; `addProduct()` renames temp files to match product ID.
- **Remove-then-cancel** — Image deletion deferred to repository `updateProduct()` so canceling the form doesn't leave broken references.
- **Draft cart images** — `_productFromData()` now copies `imagePath` and `imageThumbnailPath` so restored drafts preserve images.
- **Cart overflows** — `CartItemRow` overflow (5.6px), `CartPanel` bottom overflow (8.6px), `CartTotalBar` narrow layout all fixed.
- **Layer violation** — `ProductImageService` no longer depends on `SettingsCubit`; accepts `SettingsRepository` instead.
- **Draft count error state** — Badge shows `'—'` instead of `0` on `FutureBuilder` error.
- **Thai uppercase** — Category headers skip `.toUpperCase()` for Thai text.

### Changed

- **Auto-save debounce** — Increased from 500ms to 1.5s.
- **Visual design** — Unified `image_outlined` placeholder; grid avatar 72→96px; `SaleProductCard` switched to vertical layout; catalog grid sizing bumped; category chips use `primaryContainer` + fade gradient.
- **Cart widgets** — `CartItemRow` redesigned with `Card`, pill discount badge, `FittedBox` subtotal, stock tooltip; `CartTotalBar` top shadow, bold label, subtotal breakdown; `CartHeader` `PopupMenuButton` actions.
- **Payment & drafts** — `PaymentMethodCard` replaces `SegmentedButton`; `DraftsBottomSheet` rounded corners + `Card` tiles; checkout via `Navigator.push` instead of bottom sheet.

### Tests

- `ProductImageService` unit tests: `deleteImage`, `deleteImages`, `generateThumbnail`, `pickFromGallery` cancellation.
- Repository tests for orphaned-image cleanup in `updateProduct`.

`flutter analyze` → **0 issues** · `flutter test` → **243/243 passing**

---

## [0.6.0] - 2026-06-02

Merchant Tools — PDF receipt, PromptPay QR, backup/restore, and product image system overhaul.

### Highlights

- **Receipt PDF** — Print and share receipts as PDF with Thai font support (80mm thermal + A4).
- **PromptPay QR** — EMVCo-compliant QR generation for static/dynamic payments; integrated into payment sheet.
- **Backup System** — Full SQLite export/import, CSV export for sales & products, backup reminder banner.
- **Product Image Overhaul** — Pure Dart compression, thumbnail system, image cleanup lifecycle, CachedNetworkImage, compression settings.

### Added

#### Receipt PDF & PromptPay QR

- **`ReceiptPdfService`** — `printReceipt()` / `shareReceipt()` with Thai font; moved to feature-based architecture.
- **`ReceiptLabels`** — Localized label entity extracted to `domain/entities/`.
- **80mm thermal layout** — Shop info, items, VAT breakdown, payment details, footer note.
- **`PromptpayQrService`** — EMVCo TLV payload generation (phone/citizen ID, static/dynamic).
- **Payment sheet QR** — QR display with amount, confirm button.
- **6 `AppSettings` fields** — `promptpayId`, `receiptSize`, `backupReminderDays`, `lastBackupAt`, `imageMaxWidth`, `imageQuality`.
- **24 l10n keys** (EN + TH) — PromptPay (7), receipt size (3), backup/data (14).

#### Backup System

- **`BackupService`** — SQLite export with WAL checkpoint, import with schema validation + confirm dialog.
- **CSV export** — Sales (date-range) and products via `csv` + `share_plus`.
- **Backup reminder** — Configurable days threshold, banner on Settings page.

#### Product Image Overhaul

- **Pure Dart compression** — Replaced `flutter_image_compress` with `image` package; no native dependency.
- **Thumbnail system** — 200px thumbnails alongside 800px full images; `ProductAvatar` uses thumbnails for sizes ≤100px.
- **`imageThumbnailPath`** — Added to `Product` entity, `products` table, all data/domain/presentation layers.
- **Image cleanup on delete** — `ProductRepositoryImpl` deletes images before DB row removal.
- **`CachedNetworkImage`** — Replaced `Image.network` in `ProductAvatar` and `ProductFormAvatar` with caching + placeholders.
- **Async file check** — `File.existsSync()` → `File.exists()` in both avatar widgets (converted to `StatefulWidget`).
- **Image naming fix** — New products no longer get `new.jpg`; UUID-based naming.
- **Compression settings** — `imageMaxWidth` (800) / `imageQuality` (80) in `AppSettings`; `ProductImageServiceImpl` reads from `SettingsCubit`.
- **Schema migration v5→v6** — `image_thumbnail_path` column; `_seedR45Settings()` seeds image defaults.
- **6 dependencies** — `share_plus`, `file_picker`, `csv`, `qr_flutter`, `image`, `cached_network_image`.

### Changed

- **`AppSettings.props`** — Count updated 24 → 30 (6 new fields).
- **`SettingsRepositoryImpl`** — Added load/save keys for 6 new settings fields.
- **`app_database.dart`** — Schema version bumped 4 → 6; `_seedR4Settings()` + `_seedR45Settings()` migration steps.
- **`ProductImageServiceImpl`** — Requires `SettingsCubit` injection; reads `_maxWidth`/`_quality` from settings.
- **`ProductRepositoryImpl`** — Requires `ProductImageService` injection; deletes images on product removal.
- **`ProductAvatar` / `ProductFormAvatar`** — Rewritten as `StatefulWidget` with async file check, thumbnail support, `CachedNetworkImage`.
- **`ProductFormPage`** — Tracks `_imageThumbnailPath`; generates thumbnail on pick; deletes both images on remove.
- **Product data layer** — `ProductAdded`, `AddProduct`, `ProductRepository.addProduct` accept `imageThumbnailPath`.

### Removed

- **`flutter_image_compress`** — Replaced by pure Dart `image` package.

### Tests

- **`app_settings_test.dart`** — `props.length` 24 → 30; default assertions for 6 new fields.
- **`product_test.dart`** — `props.length` → 12; `imageThumbnailPath` in equality test.
- **`product_repository_impl_test.dart`** — `MockProductImageService`; deleteProduct verifies image cleanup.
- **`checkout_flow_test.dart`** — `_NoOpImageService` stub for `ProductRepositoryImpl`.
- **All `Product()` constructors** in tests updated with `imageThumbnailPath: null`.

`flutter analyze` → **0 issues** · `flutter test` → **215/215 passing**

---

## [0.5.4] - 2026-05-29

Discount policy settings with preset manager, and product image management with gallery/camera pick.

### Highlights

- **Discount Policy settings** — Toggles for item/cart discount, max % and max amount limits, and card-based preset manager.
- **Discount Presets** — Named groups with type and values; quick-apply chips in `DiscountDialog`; PERCENT/AMOUNT clamped to configured max.
- **Receipt discount visibility** — Item and cart discounts appear as localized rows on the receipt PDF.
- **Product image management** — Gallery/camera pick, local JPEG compression (800px/80%), `imagePath` takes precedence over `imageUrl`; URL field retained for future sync.

### Added

#### Discount Policy

- **`DiscountPreset` entity** — `id`, `name`, `type` (PERCENT/AMOUNT), `values` (List<double>).
- **`AppSettings` discount fields** — `enableItemDiscount`, `enableCartDiscount`, `maxDiscountPercent`, `maxDiscountAmount`, `defaultDiscountType`, `discountPresets`, `activeDiscountPresetId` + `activeDiscountPreset` getter.
- **`DiscountPresetCard` widget** — Inline name editing, type toggle, value chips with add/remove, active/set/delete.
- **SettingsPage "Discount Policy" section** — Toggles, max fields, preset card list.
- **`DiscountDialog` preset chips** — `ActionChip` buttons from active preset; auto-switches type; AMOUNT clamped to `maxAmount`.
- **Receipt PDF discount rows** — Localized `receiptItemDiscounts` / `receiptCartDiscount`.
- **18 l10n keys** (EN + TH) for discount policy, presets, and receipt labels.

#### Product Images

- **`ProductImageService`** — `pickFromGallery`, `pickFromCamera`, `deleteImage`; compresses to `/images/{productId}.jpg` (800px, 80% JPEG); `@LazySingleton`.
- **`imagePath` column** — `products` table; schema v3→v4 migration.
- **`Product.imagePath` field** — Nullable local path; takes precedence over `imageUrl` in all display widgets.
- **`ProductFormAvatar` tap-to-pick** — Bottom sheet with Gallery / Camera / Remove.
- **`ProductAvatar` local image** — `Image.file` from `imagePath` → `Image.network` from `imageUrl` → placeholder.
- **4 l10n keys** (EN + TH) — `pickImageGallery`, `pickImageCamera`, `removeImage`, `imagePickError`.
- **Dependencies** — `image_picker: ^1.2.2`, `flutter_image_compress: ^2.4.0`.

### Changed

- **`DiscountDialog`** — Accepts `maxAmount` and `presetType`; helper text shows max for AMOUNT mode.
- **`cart_item_row.dart`** — Discount button hidden when `enableItemDiscount` is `false`; passes preset values and limits to dialog.
- **`cart_total_bar.dart`** — Cart discount button hidden when `enableCartDiscount` is `false`; passes preset values and limits.
- **`ReceiptLabels`** — Added required `itemDiscounts` and `cartDiscount` fields.
- **`AppSettings`** — Replaced `presetDiscountValues: List<double>` with `discountPresets: List<DiscountPreset>`.
- **`ProductFormPage`** — Replaced imageUrl text field with `ProductFormAvatar` tap-to-pick; `_imageUrlCtrl` → `_imagePath`/`_imageUrl` state fields.
- **Product data layer** — `ProductAdded`, `AddProduct`, `ProductRepository.addProduct` accept `imagePath`; `ProductRepositoryImpl` and `ProductLocalDatasource` persist/mapped `imagePath`.
- **`product_tile.dart` / `product_grid_card.dart`** — Pass `product.imagePath` to `ProductAvatar`.

### Removed

- **`_presetValuesCtrl` / `_parsePresetValues`** — Replaced by `DiscountPresetCard` chip editor.
- **`_imageUrlCtrl`** — URL text input replaced by image picker.

### Tests

- **`app_settings_test.dart`** — `props.length` updated for new discount fields (24 total).
- **`product_test.dart`** — `props.length` → 11; `imagePath` in equality test.
- **`product_bloc_test.dart` / `product_usecases_test.dart`** — Added `imagePath` to mock `when` clauses.
- **`product_form_page_test.dart`** — TextFormField indices 5→4; mock `ProductImageService` registered in GetIt.
- **Receipt PDF / ReceiptPreview tests** — `ReceiptLabels` updated with new required fields.

`flutter analyze` → **0 issues** · `flutter test` → **215/215 passing**

---

## [0.5.3] - 2026-05-29

VAT calculation and payment fixes, draft cart persistence overhaul, and bill UX improvements.

### Highlights

- **EXCLUSIVE VAT payment fix** — Payment sheet now charges the correct VAT-inclusive total.
- **Receipt double-VAT fix** — Reprinting receipts no longer adds VAT twice for EXCLUSIVE mode.
- **Draft cart discount round-trip** — Cart-level discounts persist across draft switch, app restart, clear, and delete.
- **Bill UX improvements** — Cart header shows bill name, New Bill button on cart, auto-named bills after sale, name dialog on create.

### Added

- **`CartHeader` bill name display** — Shows `activeDraftName` as title with `cartTitle` as subtitle.
- **New Bill button on cart** — `IconButton` in `CartHeader` opens name dialog and dispatches `SaleDraftCreated`.
- **New Draft name dialog** — `DraftsBottomSheet` "New Draft" button now prompts for a name before creating.
- **Auto-named bills** — `_onConfirmed` creates draft with name `Bill #N` based on draft count.

### Fixed

#### VAT & Payment

- **Payment sheet undercharged EXCLUSIVE VAT** — `PaymentSheet` used `SaleState.total` (pre-tax) as the amount to pay; now computes `effectiveTotal` including VAT for EXCLUSIVE mode. Affected: confirm button label, cash validation, change calculation, quick-amount chips.
- **Receipt double-VAT on reprint** — `ReceiptPdfService.calculateVat` received `sale.totalAmount` (already includes VAT for EXCLUSIVE) and added VAT again. Added `isTotalPreTax` parameter; post-sale callers now pass `isTotalPreTax: false`.
- **`calculateVat` floating-point drift** — No `toStringAsFixed(2)` rounding; could produce values like `7.0000000001`. All outputs now rounded.

#### Entity & Data Integrity

- **Sale entity missing discount fields** — `_buildSale()` did not map `discountType`, `discountValue`, `discountAmount` from `SaleData`; fields added to entity and mapped in datasource.
- **SaleItem entity missing discount/vat fields** — `_buildSale()` did not map `discountAmount`, `vatAmount` from `SaleItemData`; fields added to entity and mapped in datasource.

#### Draft Cart Persistence

- **Draft names cleared on every save** — `upsertDraft` always set `name` to `Value(null)` from auto-save; now uses `Value.absent()` to preserve existing names.
- **Cart discount lost on draft switch/restart** — `DraftCarts` table and `DraftCart` entity had no `cartDiscountType`/`cartDiscountValue` fields; added to DB schema, entity, datasource, and bloc state restoration.
- **`SaleReset` dropped cart discount** — `_onReset` emitted `SaleState` without `cartDiscountType`/`cartDiscountValue`; now preserved.
- **`_onCartCleared` dropped cart discount** — Clearing the cart lost `cartDiscountType`/`cartDiscountValue`; now preserved.
- **`_onDraftDeleted` didn't restore cart discount** — After deleting the active draft, the replacement draft's discount fields were not restored in state.
- **Draft total ignored cart discount** — `DraftCart.total` summed item subtotals only; now subtracts `discountAmount` like `SaleState.total`.

#### Bill UX

- **Delete didn't refresh draft list** — `DraftsBottomSheet` called `_reload()` synchronously after delete, but BLoC event hadn't completed yet; draft remained visible until sheet was reopened. Now uses `Future.delayed(300ms)`.
- **Rename didn't refresh draft list** — Same race condition as delete; now uses `Future.delayed(300ms)` to wait for DB write.
- **New draft after sale had no name** — `_onConfirmed` created a draft with `createDraft()` (no name); now uses `createDraft(name: 'Bill #N')` and sets `activeDraftName`.
- **CartHeader overflow** — Adding draft name subtitle + New Bill button caused `RenderFlex` overflow by 14px in compact cart; fixed with smaller text styles (`titleSmall`/`labelSmall`), compact `visualDensity`, and reduced padding.

### Changed

- **`PaymentSheet`** — Constructor changed from `total` to `preTaxTotal` + `vatInfo`; computes `effectiveTotal` internally.
- **`CartTotalBar`** — Now computes `vatInfo` via `ReceiptPdfService.calculateVat` and passes it to `PaymentSheet`.
- **`calculateVat`** — New `isTotalPreTax` parameter (default `true` for backward compatibility with pre-sale usage).
- **`DraftCarts` table** — Schema v2→v3; added `cart_discount_type` and `cart_discount_value` columns via `ALTER TABLE` migration.
- **`DraftCart` entity** — Added `cartDiscountType`, `cartDiscountValue`, `discountAmount`, and corrected `total` getter.
- **`SaleBloc`** — All `saveDraft` calls now pass `activeDraftName`; `_onDraftInitialized`, `_onDraftSwitched`, `_onReset`, `_onCartCleared`, `_onDraftDeleted` restore cart discount fields; `_onConfirmed` auto-names new draft `Bill #N`.
- **`CartHeader`** — Shows `activeDraftName` as title with `cartTitle` as subtitle; added New Bill button with name dialog.
- **`DraftsBottomSheet`** — `_reload()` delayed 300ms after rename/delete to avoid race condition; New Draft button now prompts for name before creating.

`flutter analyze` → **0 issues** · `flutter test` → **216/216 passing**

---

## [0.5.2] - 2026-05-29

Drift build optimization and page structure refactoring across all features.

### Highlights

- **Drift build optimization** — `build.yaml` added with `generate_manager: false` and `skip_verification_code: true`, reducing `app_database.g.dart` from 8,549 lines / 293KB to 4,769 lines / 150KB (-44% lines, -49% size).
- **Page structure refactoring** — Private widgets extracted into public widget files under `widgets/` subfolders across 6 features; helper functions converted to static methods. No behavior changes.

### Changed

- **`build.yaml`** — New file at project root configuring Drift code generation options.
- **`app_database.g.dart`** — Regenerated without Manager/Composer classes (FilterComposer, OrderingComposer, AnnotationComposer, TableManager, ProcessedTableManager typedefs) and without verification metadata code. These APIs were not used by the project.
- **Sale page** — Extracted 9 widgets (`DiscountDialog`, `SaleCatalog`, `SaleProductCard`, `CartHeader`, `CartItemRow`, `CartTotalBar`, `DraftsBottomSheet`, `SaleReceiptDialog`, `CartPanel`) into `lib/features/sale/presentation/widgets/`; helper functions → static methods (`DiscountDialog.showItemDiscount`, `DraftsBottomSheet.show`, `SaleReceiptDialog.show`).
- **Product page** — Extracted 7 widgets (`ProductAvatar`, `StockBadge`, `ProductTile`, `ProductGridCard`, `ProductTextField`, `ProductFormAvatar`, `ProductSectionLabel`) into `lib/features/product/presentation/widgets/`.
- **Settings page** — Extracted 7 widgets (`SettingsSectionHeader`, `SettingsTextField`, `LanguageTile`, `ThemeTile`, `CurrencyTile`, `DateFormatTile`, `ResponsiveSettingsPicker`) into `lib/features/settings/presentation/widgets/`.
- **Payment sheet** — Extracted 2 widgets (`ChangePreview`, `PaymentTotalRow`) into `lib/features/sale/presentation/widgets/payment_widgets.dart`.
- **History page** — Extracted 2 widgets (`SaleExpansionTile`, `VoidSaleDialog`) into `lib/features/history/presentation/widgets/`; `_showVoidDialog` → `VoidSaleDialog.show()`.
- **Report page** — Extracted `SummaryCard` into `lib/features/report/presentation/widgets/`.

`flutter analyze` → **0 issues** · `flutter test` → **208/208 passing**

---

## [0.5.1] - 2026-05-29

Theme accessibility, overlay toast, UX fixes, and DI compile-time safety.

### Highlights

- **Theme accessibility** — Explicit ColorScheme overrides, visible borders on all components, higher contrast for elderly readability.
- **Overlay-based toast** — `AppSnackBar` migrated from `ScaffoldMessenger` to `Overlay` with reliable auto-dismiss.
- **Cart undo** — Clear-cart and item-removal show undo toast via `SaleCartRestored` event.
- **Category filter sync** — `categoryFilter` moved into `ProductState`; shared across Sale and Product pages.
- **History void via BLoC** — Void routes through `HistoryBloc` with loading/success/failure states.
- **Injectable DI** — `get_it` registrations replaced by `injectable` annotations + code generation.
- **Lazy-loaded tabs** — Only active tab is built; visited tabs kept alive.

### Added

- **BLoC events** — `SaleCartRestored`, `ProductCategoryFilterChanged`, `SaleVoidRequested`; `HistoryStatus.voiding`.
- **`AppSnackBar.withAction`** — Overlay-based undo toast with action button.
- **Payment sheet close button** — Visible `✕` for non-technical staff.
- **8 l10n strings** (EN + TH) — Cart, view-mode, payment, discount labels.
- **Theme colors** — All ColorScheme properties explicitly defined for both light and dark themes; borders added to Card, Button, Chip, Input, Cart panel, SearchBar.

### Changed

- **Toast system** — `AppSnackBar` → `Overlay`-based; `OverlayToast` merged and removed.
- **Light theme** — Softer surfaces, darker borders/dividers, all ColorScheme properties overridden.
- **Dark theme** — All ColorScheme properties overridden; no more overly bright greens.
- **Component borders** — Card, ElevatedButton, FilledButton, Chip, Cart panel, Input all have visible outlines.
- **Hardcoded colors removed** — Feature pages now use `colorScheme` instead of `Colors.*`.
- **Cart panel** — Responsive height (120 empty / 200–360 with items); border added.
- **Qty=1** — Minus button becomes delete icon; removal shows undo toast.
- **Discount preview** — Shows `15%` for PERCENT type instead of `฿15.00`.
- **Confirm payment** — Shows amount: "Confirm ฿150.00".
- **Report date range** — `ActionChip` → prominent `Card` with edit icon.
- **VAT rate field** — Persistent `TextEditingController`; saves correctly.
- **DI** — `initDependencies()` → `configureDependencies()` with `@injectable` annotations.
- **Tab navigation** — Eager `IndexedStack` → lazy `_pageBuilders` + `_cachedPages`.

### Fixed

- **SnackBar persistence** — Stayed on screen indefinitely; fixed by Overlay migration.
- **SnackBar not showing** — After `hideCurrentSnackBar()`; fixed by eliminating `ScaffoldMessenger`.
- **Sale search not filtering** — Used `state.products` instead of `state.filtered`.
- **Light theme `onPrimary`** — Icon on green buttons was dark; fixed by explicit `onPrimary`.
- **Dark theme bright greens** — `ColorScheme.fromSeed` auto-gen; fixed by overriding all properties.
- **Invisible component boundaries** — No borders; fixed by adding `side: BorderSide(...)`.

`flutter analyze` → **0 issues** · `flutter test` → **208/208 passing**

---

## [0.5.0] - 2026-05-28

Draft cart persistence, discount system, and stock policy for real-shop workflow.

### Highlights

- **Draft cart persistence** — Cart auto-saves every 500 ms. Up to 10 simultaneous drafts (switch customers/tables, rename, delete). Active draft restores on app launch; cleared on checkout.
- **Discount system** — Per-item discount (% or ฿) and per-cart discount. Payment sheet shows full breakdown: Subtotal → discounts → Total. VAT applied after discounts.
- **Stock policy** — Per-product `trackStock` toggle (service items show ∞, no stock deduction). `allowOversell` setting permits selling beyond available stock.
- **Low stock indicator** — Product card stock label turns red when stock ≤ configurable threshold.

### Added

- **Draft cart** — Bookmarks icon in Sale AppBar opens draft sheet; list, switch, rename, delete drafts; new-draft button; cap enforced at 10.
- **Per-item discount** — Tag icon in cart row → dialog (% / ฿, live preview, apply / clear); discount badge shown on item.
- **Cart-level discount** — "Apply cart discount" button below subtotal; discount line in cart summary.
- **Payment sheet breakdown** — Subtotal / item discounts / cart discount / TOTAL when any discount is active.
- **`trackStock` per-product** — Switch in product form; `∞` stock display and no DB deduction when off.
- **Stock Policy settings section** — Allow oversell toggle + Low stock threshold input.
- **30 new localization keys** (EN + TH) — Stock policy, discount dialog, draft cart labels.

### Changed

- **VAT calculation** — Now calculated on pre-discount total (`preTaxTotal`) in sale datasource.
- **`DailyCloses` `@Deprecated` removed** — Table stays in schema v2 for upcoming R5 Daily Close UI.

### Fixed

- **Non-tracked products removed from cart** — Products with `trackStock=false` (stock = 0) no longer removed from cart on product refresh.
- **Qty clamp for non-tracked products** — Skipped for non-tracked products (no artificial stock ceiling).

`flutter analyze` → **0 issues** · `flutter test` → **208/208 passing**

---

## [0.4.2] - 2026-05-28

Full-system bug fix pass: VAT data integrity, product edit, report stability, localization gaps, and UX polish.

### Highlights

- **VAT data integrity** — sale-time `vatMode`, `vatRate`, `vatAmount`, and `subtotalAmount` now round-trip through the `Sale` entity; reprints always show the VAT that was charged, not current settings.
- **Report stability** — `ReportCubit` registered as `lazySingleton`; `ReportPage` initialises once via `StatefulWidget.initState()` — no more spurious reloads on locale/theme change.
- **Localization gaps closed** — 7 new ARB keys (EN + TH) replace all hardcoded English strings in `InventoryLogPage` and `ProductFormPage`.
- **Dead dependency removed** — `shared_preferences` + 6 platform plugins eliminated; settings fully Drift-backed since v0.4.1.

### Added

- **History VAT breakdown** — expanded sale tile now shows Subtotal + VAT rows (with rate %) when `vatMode != 'NONE'`
- **CI coverage** — `flutter test --coverage`; `lcov.info` uploaded as GitHub Actions artifact on every push/PR

### Fixed

#### Sale & Payments

- **Stale cart qty** — `_onProductsRefreshed` clamps item qty to refreshed stock and removes zero-stock items; prevents `StateError` on a second checkout attempt
- **VAT not persisted** — `insertSaleWithItems` writes `subtotalAmount`, `vatMode`, `vatRate`, `vatAmount` at sale time; previously always stored table defaults
- **`Sale` entity missing VAT fields** — `_buildSale` now maps all four VAT columns; receipt dialogs use `settings.copyWith(vatRate: sale.vatRate, vatMode: sale.vatMode)` for correct reprint values
- **`totalAmount` rounding** — `items.fold` result rounded to 2 dp before DB write
- **PDF receipt payment method** — `ReceiptLabels` gains `paymentMethodLabel`; PDF prints localized name instead of raw key (`"cash"` → `"เงินสด"`)
- **Payment sheet close on success** — `PaymentSheet` closes via its own `BlocListener`; `_CartPanel` no longer calls broad `Navigator.canPop()`
- **Search reset on every tab switch** — `ProductSearchChanged('')` fires only when switching to/from Sale tab (index 0)

#### Products

- **`imageUrl` lost on edit** — `ProductFormPage` passes `imageUrl` from `_imageUrlCtrl` into `copyWith`; previously any field edit silently cleared the URL
- **Top-products splits on rename** — `_topProducts` groups by `productId` instead of `productName`
- **`AdjustStockDialog` accepted qty = 0** — validator now rejects zero
- **`ProductListPage` empty state on filter** — shows `noMatchingProducts` when filter returns empty but products exist; previously showed misleading `noProductsYet`

#### Localization

- **`InventoryLogPage` labels** — `SALE`, `VOID_REVERSAL`, `ADJUSTMENT_IN/OUT` types use `l10n` keys (EN + TH)
- **`ProductFormPage` labels** — `'Image URL'`, `'Basic info'`, `'Details'` replaced with `l10n` keys

### Changed

- **`ReportCubit`** — registration changed from `registerFactory` → `registerLazySingleton`; `ReportPage` converted to `StatefulWidget` with `load()` in `initState()`; date range persists across tab navigation

### Removed

- **`shared_preferences`** — removed from `pubspec.yaml`; eliminates 7 packages (`shared_preferences` + 6 platform plugins)

`flutter analyze` → **0 issues** · `flutter test` → **187/187 passing**

---

## [0.4.1] - 2026-05-28

Receipt system overhaul with VAT-aware rendering, configurable previews, Thai PDF font embedding, and CI hardening.

### Highlights

- **Configurable receipt rendering with VAT support** — `NONE` / `INCLUSIVE` / `EXCLUSIVE` modes with correct subtotal/VAT/total breakdown.
- **On-screen receipt previews** — `thermal` and `card` styles shown before and after checkout.
- **Thai PDF font embedding** — bundled `NotoSansThai` fonts for thermal printing.
- **Automated CI validation** — `flutter analyze` + `flutter test` on every push/PR.

### Fixed

- **Safe migration guard** — `onUpgrade` uses no-op for patch releases; incremental template for v3+
- **SettingsRepository** — migrated from `SharedPreferences` to `SettingsLocalDatasource` (Drift-backed)
- **ProductBloc delete state** — consistent `saving` → `saved` emissions
- **SaleBloc stale state** — `SaleReset` clears `lastSale` without dropping the cart
- **Card overflow in dialogs** — fixed receipt preview overflow in narrow dialogs
- **PDF receipt header overflow** — fixed text collision between receipt number and date on 80mm thermal paper

### Added

#### Receipt system overhaul (PDF)
- `ReceiptPdfService` accepts `AppSettings` + localized `ReceiptLabels`; no more hardcoded strings
- **Receipt number** — uses `sale.receiptNumber` instead of UUID on header and share filename
- **Shop info** — conditional rendering via `showShopInfoOnReceipt`
- **Date format** — respects user's `dateFormat` setting
- **Footer** — uses `receiptNote` setting
- **VAT modes** — `NONE` / `INCLUSIVE` / `EXCLUSIVE` with correct subtotal/VAT/total breakdown
- **Thai font embedding** — loads bundled `NotoSansThai` fonts for Thai character support
- **Post-sale print dialog** — Print / Share / Close buttons, configurable via `autoPrintPrompt`

#### On-screen receipt preview (`ReceiptPreview`)
- `thermal` style — 80mm paper look, monospace layout, dashed dividers, centered shop info
- `card` style — modern `Card` UI with colored total row and structured layout
- **Pre-sale** — inside `PaymentSheet`, controlled by `showPreSalePreview`
- **Post-sale** — in success dialog, controlled by `showPostSalePreview`
- **`"none"` style** — hides preview entirely; falls back to text-only
- **VAT-aware** — shows subtotal/VAT/total breakdown when `vatMode != 'NONE'`

#### Settings UI
- `autoPrintPrompt` toggle — ask to print receipt after sale
- `vatMode` dropdown — None / Inclusive / Exclusive
- `vatRate` input
- `receiptPreviewStyle` dropdown — thermal / card / none
- `showPreSalePreview` toggle
- `showPostSalePreview` toggle

#### Localization
- 22 new ARB keys (EN + TH) for receipt labels, settings, VAT modes, and preview styles

#### Infrastructure
- **Input validation** — `Validators` utility; `AddProduct`, `UpdateProduct`, `CreateSale` validate before DB
- **CI/CD** — `.github/workflows/ci.yml` runs `flutter analyze` + `flutter test` on every push/PR
- **DI graph smoke test** — `test/core/di/di_graph_test.dart` verifies all `GetIt` registrations

### Deprecated

- `DailyCloses` table marked `@Deprecated` — removal in v0.5.0 (schema v3)

`flutter analyze` → **0 issues** · `flutter test` → **187/187 passing**

---

## [0.4.0] - 2026-05-27

### Added

> **BREAKING CHANGE:** This release contains a destructive database migration. Existing app data will be dropped and recreated.

Complete database overhaul: integer auto-increment IDs → UUIDv4 text IDs across all entities, 6 new tables, atomic sale transactions with receipt numbers and inventory audit trail, void/refund flow, and manual stock adjustments.

- **6 new tables**: `categories`, `inventory_logs`, `app_settings`, `draft_carts`, `draft_cart_items`, `daily_closes`
- **`IdGenerator`** — UUIDv4 generation for all entity IDs
- **Sync-ready columns** on all tables: `version`, `deviceId`, `updatedAt`, `deletedAt`
- **Extended product fields**: `sku`, `barcode`, `cost`, `trackStock`
- **Extended sale fields**: `receiptNumber`, `status`, `subtotalAmount`, discount/VAT columns, `voidedAt`, `voidReason`
- **Database indexes** — 9 new indexes for query performance
- **WAL journal mode** with foreign key enforcement
- **Batch seed** for default app settings on first run
- **`ReceiptNumberService`** — auto-generated receipt numbers (`YYMMDD-XX-NNNN`) with daily reset
- **`InventoryLogService`** — audit trail for all stock changes
- **`SettingsLocalDatasource`** — Drift-backed typed key-value store
- **Atomic sale insertion** — receipt number + sale items + stock deduction + inventory log in single DB transaction
- **Void sale flow** — marks sale as VOIDED, restores stock, logs reversal; confirmation dialog with reason
- **Manual stock adjustment** — `AdjustStock` use case + dialog for manual add/remove with audit reason
- **Inventory log viewer** — color-coded log entries, filterable by product
- **History UI** — VOIDED badge, strikethrough amount, receipt number in subtitle, void action button
- **Report UI** — net revenue (excludes voided), voided total summary card
- **Localization** — 18 new keys (EN + TH) for void, adjust, inventory log
- **Architecture documentation** — `ARCHITECTURE.md` (C4 diagrams, data flows, ADRs) + `DATABASE.md` (ERD, schema, migration)

### Changed

- **All entity IDs** migrated from `int` → `String` (UUIDv4)
- **Repository/use-case signatures** updated for String IDs
- **`ProductRepository.addProduct`** return type: `Future<int>` → `Future<String>`
- **`ProductsCompanion`** field: `category` → `categoryId`
- **Schema version**: 1 → 2
- **All 135 tests** migrated to use String UUID fixtures

### Removed

- Auto-increment integer ID generation
- `setup()` override in `AppDatabase`

`flutter analyze` → **0 errors** · `flutter test` → **170/170 passing**

---

## [0.3.0] - 2026-05-26

Product management UI overhaul with offline font bundling, PDF receipt export, centralised feedback system, and database upgrade hardening.

### Highlights

- **Product catalog:** Toggleable list/grid views, category filter chips, traffic-light `_StockBadge`, and `Image.network` avatar with fallback.
- **Product form:** Live image URL preview, `BASIC INFO` / `DETAILS` section grouping, and `imageUrl` wired to `ProductAdded`.
- **Offline fonts:** `NotoSansThai` bundled locally — no network call on first launch; `google_fonts` dependency removed.
- **PDF receipts:** 80 mm thermal receipt PDF with Print and Share actions in history page.
- **Feedback system:** `AppSnackBar` + `OverlayToast` replace all 9 inline `ScaffoldMessenger` calls; cart toast no longer blocks the checkout panel.
- **DB safety:** Step-based `onUpgrade` loop — an incomplete schema bump fails at the exact step, not silently at startup.

### Added

#### Product page redesign
- **List/Grid toggle** — `_ViewMode` enum; AppBar shows `view_list` / `grid_view` icon pair with active colour highlight.
- **Category filter chips** — horizontal scroll row below SearchBar; categories derived live from products; combined with search filter; hidden when no categories exist.
- **`_ProductTile` upgrade** — `_ProductAvatar` (`Image.network` + icon fallback), `_StockBadge` (green > 5 / orange 1–5 / red 0), inactive dim 40 % + strikethrough name.
- **`_ProductGridCard`** — 2-column `GridView.builder`, aspect ratio 0.76; tap = edit, long-press = context menu bottom sheet.
- **Product form: image URL + preview** — `imageUrl` field in header row with live `_FormAvatar` (80 px rounded); wired to `ProductAdded.imageUrl`.
- **Form section grouping** — `BASIC INFO` / `DETAILS` uppercase section labels.

#### Local font bundling (offline-first)
- Removed `google_fonts` dependency; bundled four `NotoSansThai` weights (400/500/600/700) under `assets/fonts/`.
- `AppTheme` rewritten to use `TextStyle(fontFamily: 'NotoSansThai', ...)` throughout.

#### PDF receipt export
- `ReceiptPdfService` — 80 mm thermal PDF with `printReceipt` / `shareReceipt` methods.
- Print / Share buttons added to each sale's `ExpansionTile` in history page.
- `printReceipt` / `shareReceipt` localisation keys added to `app_en.arb` and `app_th.arb`.
- Registered as `lazySingleton` in `injection_container.dart`.

#### AppSnackBar + OverlayToast — centralised feedback
- `AppSnackBar` — static `success` (2 s) / `error` (4 s) / `info` (1.2 s) helpers with `context.mounted` guard.
- Refactored all 9 inline `ScaffoldMessenger` callsites across 5 pages to use `AppSnackBar`.
- `OverlayToast` — fade-in pill toast via Flutter `Overlay`; `IgnorePointer` prevents checkout panel obstruction.

#### ReportCubit — state management consistency
- `ReportPage` migrated from `StatefulWidget` + `StreamSubscription` to `BlocProvider<ReportCubit>`.
- Added `report_cubit_test.dart` covering load success, failure, and `changeDateRange`.
- Registered as `factory` in `injection_container.dart`.

#### DB migration loop framework
- `onUpgrade` replaced with step-based `for` loop; each schema version bump requires an explicit `case N:` block.

### Fixed

- **RenderFlex overflow** in sale product card padding
- **`_StockBadge` dark-theme contrast** — improved visibility in dark mode
- **Add product button visibility** in dark theme — improved contrast and foreground color

### Changed

- Add product AppBar button: `FilledButton.icon` → compact `IconButton.filled` (M3 pattern, tooltip retained).
- `README.md` screenshots section: replaced "Coming soon" placeholder with contributor call-to-action.
- `pubspec.yaml` version bumped to `0.3.0+1`.

`flutter analyze` → **0 issues** · `flutter test` → **135/135 passing**

---

## [0.2.3] - 2026-05-26

Layout hotfix for RenderFlex overflows in the sale page, plus data integrity, cart state, and cashier UX improvements.

### Fixed

#### Sale page

- Fixed RenderFlex overflows in product catalog and product card layouts.
- Improved product card sizing for Thai font rendering.

#### Database

- `onUpgrade` now throws `UnimplementedError` — schema bumps without a migration fail loudly instead of silently.

#### Cart state

- Cart syncs live with product state; hard-deleted products are auto-removed before checkout.

#### Sale checkout

- Selling a deleted product now throws a clear error instead of silently bypassing validation.
- Reduced duplicate database reads during checkout.

#### Payment sheet

- Quick-amount chips always generate three distinct values; round totals no longer collapse to a single "Exact" chip.

### Added

- Regression test for `AppEmptyState` compact layout.

### Changed

- Removed dead `onChanged` handler from payment sheet note field.
- Cleaned up 5 lint warnings in test files.
- Updated documentation (`README.md`, `CODEBASE.md`).

`flutter analyze` → **0 issues** · `flutter test` → **131/131 passing**

---

## [0.2.2] - 2026-05-26

Stability and UX hardening for the offline POS workflow: safer sales writes, clearer cashier feedback, tighter BLoC behavior, leaner dependencies, and better compact-screen usability.

### Fixed

#### Sale and checkout

- Prevented partial sale-item work by validating all item stock before insert/deduct operations.
- Added stock-limit protection to cart quantity controls and kept database validation as the final authority.
- Prevented duplicate payment submissions from rapid double taps.
- Added optional transfer/card payment reference support, stored through the sale note.
- Made payment sheet dismissal safe when the sheet context is already unmounted.
- Reset sale state correctly after a completed sale when starting a new cart.

#### Products and inventory

- Reworked `ProductBloc` stream handling to avoid blocking refresh flows.
- Added reliable product save status handling so forms close only after confirmed saves.
- Reset stale product save status on product stream updates.
- Added product-card cart quantity badges in the sale catalog.
- Reduced noisy add-to-cart SnackBars for repeated taps.
- Made product delete dialogs use a captured BLoC and dialog-local navigation context.
- Improved stock-zero warning and product form feedback.

#### History and reports

- Limited initial history loading to a default 30-day range.
- Made history date picker reopen with the current selected range.
- Replaced fake refresh delays with state-based refresh completion.
- Fixed report date ranges that could go stale overnight.
- Moved report date range display out of the AppBar into a compact filter chip.
- Added pull-to-refresh support to the report dashboard.

#### Settings and localization

- Settings load failures now fall back to usable default settings instead of leaving the app in a failure state.
- Removed duplicate settings save notifications for live locale/theme changes.
- Added dirty-state awareness for manually saved text settings.
- Improved responsive settings dropdown layout on compact screens.
- Added EN/TH strings for retry actions, no-match states, stock limits, and payment references.

#### UI, accessibility, and resilience

- Replaced hardcoded destructive colors with `colorScheme.error`.
- Added retry actions to shared empty/error states.
- Improved dialog context safety for cart clearing and product deletion.
- Clarified intentional `SaleItems.productId` behavior so sale history survives product deletion.
- Documented the intentional singleton lifecycle for `ProductBloc`.

### Removed

- Removed unused direct dependencies: `go_router`, `uuid`, `permission_handler`, `image_picker`, `cached_network_image`, `qr_flutter`, and `path`.
- Removed unused DI registrations for `GetReport` and `GetSaleHistory` while keeping their source/test coverage for future use.
- Deleted the empty `date_formatter.dart` file.

### Changed

- Updated generated localization files after adding new EN/TH keys.
- Updated SettingsCubit tests to match the load-failure fallback behavior.
- Updated documentation and audit notes for the completed stability and UX hardening work.
- Bumped version to `0.2.2+1`.

`flutter analyze` → **0 issues** · `flutter test` → **130/130 passing**

---

## [0.2.1] - 2026-05-26

### Added

- **130 automated tests** covering 7 layers of the application:
  - **Domain** — entity equality, use case delegation for all features
  - **BLoC / Cubit** — event-to-state transitions for `SaleBloc`, `ProductBloc`, `HistoryBloc`, `SettingsCubit`
  - **Repository** — `SaleRepositoryImpl`, `ProductRepositoryImpl`, `HistoryRepositoryImpl`, `SettingsRepositoryImpl`
  - **Datasource** — `ProductLocalDatasourceImpl`, `SaleLocalDatasourceImpl` with in-memory SQLite
  - **Widget** — `ProductListPage`, `ProductFormPage`, `PaymentSheet`, `SettingsPage` with mocked BLoC states
  - **Integration** — end-to-end checkout flow (add → sale → stock deduction → history)
  - **L10n parity** — EN/TH key completeness, parameterized messages, locale-specific values
- **Test helpers** (`test/helpers/`):
  - `mocks.dart` — shared mock classes using `mocktail` + `bloc_test`
  - `pump_app.dart` — `pumpApp` extension with `MultiBlocProvider` and full localization
  - `fake_database.dart` — in-memory Drift database factory
- **4 new localization keys** for both EN and TH:
  - `productAddedToCart` — cart feedback message
  - `productSaved` — form success message
  - `insufficientCash` — payment validation hint
  - `stockZeroWarning` — product form warning
- **4 regression tests** for critical UI bug fixes (UI-BUG-1, UI-BUG-8, UI-BUG-11)

### Fixed

- **Search state bleed across tabs** — `ProductBloc.searchQuery` resets on navigation; `BlocListener` syncs text controllers automatically
- **Cart quantity overflow** — replaced fixed `SizedBox(width: 28)` with `ConstrainedBox(minWidth: 32)` to support 3+ digit quantities
- **Cart subtotal clipping** — replaced fixed `SizedBox(width: 82)` with `ConstrainedBox(minWidth: 82)` for large amounts
- **No feedback on add-to-cart** — floating `SnackBar` now confirms product addition
- **No feedback on product save** — success `SnackBar` shown after form submission
- **Report AppBar overflow** — date range text wrapped in `Flexible` with `TextOverflow.ellipsis`
- **Redundant tap hint** — "Tap product to add" hidden when cart already has items
- **Unclear disabled button** — payment confirm shows "Insufficient cash" explanation when amount is below total
- **Missing transaction reference** — sale ID (`#N`) now displayed in History list subtitle
- **No refresh mechanism** — pull-to-refresh added to History and Product list pages
- **Silent stock=0 state** — product form shows warning when stock is zero ("won't appear in sale")

### Changed

- Added `sqlite3_flutter_libs: ^0.5.28` to `dev_dependencies` for FFI-based in-memory database testing.

---

## [0.2.0] - 2026-05-26

### Added

- **Merchant Command Deck UI refresh** for the main app experience, focused on cashier speed, readability, and safer touch targets.
- **Shared UI primitives** under `lib/core/widgets/`:
  - `AdaptiveBreakpoints` for compact/medium/expanded layout decisions
  - `AppEmptyState` for consistent empty/error states with compact-height handling
  - `MoneyText` for consistent currency display
  - `SectionCard` for grouped settings and dashboard surfaces
- **Sale tab redesign** via `sale_page.dart`:
  - Search-first product catalog
  - Category chips
  - Responsive product grid
  - Compact mobile cart panel and expanded tablet cart pane
  - Touch-friendly quantity controls and checkout action
- **Payment sheet redesign** via `payment_sheet_redesign.dart`:
  - Clear total summary
  - Payment method segmented buttons
  - Quick cash amount chips
  - Change preview for cash payments
- **Products UX refresh**:
  - Stronger product cards with price, stock status, category, and tap-to-edit behavior
  - Responsive product form with compact single-column and wider two-column layouts
- **History, Report, and Settings refresh**:
  - Receipt-like expandable history cards
  - Report dashboard with empty/error states
  - Settings grouped into section cards with a clearer save action
- **Widget tests** for shared UI components.

### Fixed

- Prevented compact empty-state layouts from causing `RenderFlex` bottom overflow in constrained panels.

### Changed

- Updated localization strings for sale search, cart title, category filter, and quick cash actions.
- Updated theme tokens and Material 3 component defaults for the refreshed visual system.

---

## [0.1.0] - 2026-05-25

First public release. Complete offline-first mobile POS with sale, inventory, history, reporting, and settings.

### Added

#### Core architecture

- Flutter 3.x with Material 3 theming
- Clean Architecture per feature (`data` / `domain` / `presentation`)
- BLoC/Cubit state management with `flutter_bloc`
- `get_it` dependency injection
- `go_router` declarative navigation
- Drift SQLite ORM with code generation
- `shared_preferences` for app settings

#### Features

- **Sale** — product grid with search and category filter, live cart, multi-method payment (cash/transfer/card), change calculation
- **Products** — full CRUD with validation, searchable list, delete confirmation
- **History** — date-ranged sale history with item breakdown and notes
- **Report** — revenue summary, sales count, payment breakdown, top 5 products
- **Settings** — language (Thai/English) and theme (Light/Dark/System) with live reload, shop info, currency, date format, receipt settings

#### Localization

- Flutter ARB localization (EN + TH)
- 80+ localized strings
- Payment method normalization with locale-neutral keys

#### App shell

- 5-tab `NavigationBar` (Sale · Products · History · Report · Settings)
- Reactive `MaterialApp` with live locale + theme switching
- Material 3 `ColorScheme`

---

[Unreleased]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.4...HEAD
[0.7.4]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.3...v0.7.4
[0.7.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.2...v0.7.3
[0.7.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.3...v0.7.0
[0.6.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.2...v0.6.3
[0.6.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.1...v0.6.2
[0.6.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.4...v0.6.0
[0.5.4]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.3...v0.5.4
[0.5.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.2...v0.5.3
[0.5.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.1...v0.5.2
[0.5.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.2.3...v0.3.0
[0.2.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/teeprakorn1/promsell-pos-ce/tree/v0.2.0
