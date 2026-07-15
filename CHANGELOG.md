# Changelog

All notable changes to **Promsell POS Community Edition** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.9.0] - 2026-07-15

### Highlights

- **Money-path freeze (hard)** — Confirm freezes cart lines onto CheckoutState.frozenItems; CartPaymentLockChanged blocks live cart mutations during waitingPayment/processing; PromptPay UI prefers freeze over live cart; complete sale no longer falls back to live cart when snapshot is missing.
- **Atomic stock SQL** — Sale deduct / void restore / inventory adjust use stock = stock +/- ? (with floor checks) and re-read balanceAfter for inventory logs (schema **v28** runtime).
- **Same-device backup restore** — BackupRestoreService decrypts optional AES-GCM .enc, rejects plain SQLite, closes DB, keeps .pre_restore_*, replaces promsell_pos.db; Settings Backup UI restore CTA; export fails closed on wal_checkpoint failure.
- **Store PIN lock** — AppLockService (hashed PIN in secure storage, session grace); re-auth for void, backup export/restore, PromptPay ID/biller changes; Settings to Backup and data to Store PIN lock.
- **Release hygiene** — CI coverage floor **50%**; Android release build fails without keystore.properties (no debug-signed release); store/docs honesty for same-device restore; smoke checklist updated.

### Fixed

- PromptPay / payment wait could diverge from sale lines when cart mutated mid-wait (UI + bloc soft lock only).
- Stock RMW absolute writes on sale/void/adjust (lost-update risk under concurrent TX).
- Backup export continued after failed WAL checkpoint (inconsistent file risk).
- Release signing silently fell back to debug when keystore missing.

### Added

- CartPaymentLockChanged / CartState.paymentLocked / CheckoutState.frozenItems.
- BackupRestoreService, Settings restore flow, EN/TH backup restore + app lock l10n.
- AppLockService, ensureAppUnlocked, AppLockSettingsPage.
- Unit tests: payment lock, app lock session, backup restore validation; backup encryption suite retained.

### Changed

- docs/testing/RELEASE_0.9_SMOKE.md — restore + PIN cases; automated analyze/critical suite sign-off notes.
- Schema docs / SECURITY / Fastlane copy aligned toward **v28** and same-device restore.

### Known limitations

- Cross-device restore and SQLCipher key recovery still not available.
- Device/emulator manual smoke (cold start, full cashier path, restore round-trip) still required before store submit.
- Full-tree Unreleased UX waves may still sit in the working tree alongside this trust cut — see Unreleased until fully folded.

---

## [Unreleased]

### Highlights

- **Cart as full page** — Counter path uses `openCartReviewPage` / `CartReviewPage` (named `sale_cart_review`); bottom bar, compact FAB, bill strip, and checkout cart icon all push the page; docked dual-pane cart removed from `SalePage`; retail Pay pops cart review before payment sheet.
- **Cart Phase B/C** — Line action bottom sheet; qty long-press keypad; payment freeze banner; bulk/reorder by lineId; draft payableTotal SSOT; docs no longer claim swipe/reorder multi-select; park long-press names bill.
- **Cart Phase A visual shell** — Payable-first footer hero; receipt-style line rows with discount badge; Park outline / Pay accent; denser list separators; bottom bar payable hierarchy.
- **Settings root PromSell Index (visual redesign)** — Sentence-case section titles; card radius 20; denser icon wells (40); sectionGap 16; attention left bar; always-visible search under AppBar; tileMinHeight 64 kept.
- **Settings UI align (S3)** — Shop info form uses `FormSectionCard` + `AppTextField` + `StickyActionBar` save (Customer-form family); dialog ListTile editors removed.
- **Settings UI align (S2)** — Remaining leaves on `SettingsLeafChrome` (image/barcode/discount/about/backup); root search `AppEmptyState`; preview hardcodes l10n; remove dead `SettingsTextField`.
- **Settings UI align (S1)** — Flat summary/preview cards (no SaaS gradients); `SettingsLeafChrome` maxWidth 720 on key leaves; settings snackbars via `AppSnackBar`; Backup Now uses accent orange.
- **Settings Clean Index (root redesign PR1–PR3)** — Remove gradient dashboard hero and always-on setup checklist; risk-only status chips; single attention banner (backup › shop › PromptPay); dark cards use `AppColors.darkCard`; **Day close** section split from backup/DB; tablet root `maxWidth: 720`; locale/theme under **General** only.
- **Settings Setup Readiness Wave (Sprint 4)** — (superseded on root by Clean Index) checklist replaced by attention banner + risk chips; biller ID masked like PromptPay; shared `maskSensitiveId` helper.
- **Settings Receipt Size + Hardening Wave (Sprint 3)** — `receiptSize` (`80mm`/`A4`) drives PDF page format; paper size UI under **Receipt** settings; PromptPay IDs masked in lists (last 4); confirm dialog when turning **off** backup encryption.
- **Settings UX + Policy Wave (Sprint 2)** — VAT/tax under **Sales** (not Receipt) + search keywords; backup PIN confirm + min length enforced in export/encrypt services; primary Backup CTA; cart/CreateSale clamp discount %/amount and VAT/SC rates against settings. (Root dashboard badges removed in Clean Index.)
- **Settings Integrity Wave (Sprint 1 / Phases 0–2)** — Canonical settings keys + legacy dual-read; safe `businessType`/bool parse; barcode counter **patch** write (no full-document clobber); persistence save failures rethrow / surface to cubit; remove dead `autoPrintPrompt`; hide non-working `receiptSize` and `accessibilityMode` UI until wired.
- **Receipt SSOT Wave (Sprint 1 / Phase 0–2)** — `ReceiptDocument` + `BuildReceiptDocument.fromSale` as printable money SSOT from **stored sale fields** (cart disc, promo amount, service charge, `vatAmount`/`subtotalAmount`/`totalAmount`); PDF + thermal/card previews share breakdown; net line items (no double-count item-discount row); VOID watermark + reason/time; history REPRINT + block share of voided sales; post-sale print/share error handling + loading + Done; thumbnail images + size cap; “sale receipt ≠ tax invoice” disclaimer + docs honesty.

### Fixed

- **Dialog TextEditingController / IME dispose races** — Shared `safe_text_controller` helpers (unfocus before pop; dispose after two frames). Applied to `AppTextDialog`, Settings text tile, backup PIN, PromptPay / biller / barcode prefix, cart qty, draft create, park name, discount dialogs, **bill rename** (`DraftTile` — was `ctrl.dispose()` right after `showDialog`), cart/line note dialogs (was `.whenComplete(dispose)`). Removes common `used after being disposed` + `_dependents.isEmpty` crashes when closing dialogs with keyboard open.
- **Saved Bills → Pay lost CartBloc** — After popping bills, `navigateToCheckout` ran on root navigator context (above Sale providers). Capture blocs before pop and pass them into checkout helper; unfocus search before dispose.
- **Settings root triple chrome** — Gradient dashboard hero + always-on readiness checklist + decorative chips stacked the same status three ways; Clean Index keeps list + risk chips + single attention banner.
- **Shop complete rule mismatch** — Root shop chip + attention use `ShopInfo.isComplete` (name **and** phone), not name-only.
- **Settings dark cards looked GitHub-like** — `SettingsThemeExtension.dark` surfaces now `AppColors.darkCard` / `darkOutline` (`#242424` / `#3D3D3D`).
- **Backup overdue was chip-only** — Settings root shows tappable attention when `BackupConfig.isOverdue` (and shop/PP gaps).
- **Biller ID shown in full on PromptPay settings** — Masked like PromptPay ID (`••••` + last 4).
- **Receipt paper size was cosmetic** — PDF always used roll80; now maps settings `receiptSize` to `PdfPageFormat.roll80` / `a4` via `ReceiptDocument`.
- **PromptPay full ID on settings lists** — Root tile subtitle and PromptPay ID tile show masked form (`••••1234`); full value still editable in dialog.
- **VAT findability** — Tax section moved from Receipt settings to Sales; root search matches `vat` / `tax` / `ภาษี`.
- **Backup PIN UI-only enforcement** — Min length ≥6 enforced in `BackupExportService` and `BackupEncryptionService.encryptFile`; PIN confirm field + mismatch snack.
- **Discount policy UI-only gap** — `CartBloc` clamps item/cart discount to settings max %/amount; `CreateSale` clamps VAT rate, cart discount, and service charge rate.
- **Settings seed/mapper key mismatch** — `_seedDefaultSettings` used snake_case (`shop_name`, `vat_rate`, …) while `SettingsMapper` read camelCase; seeds were ignored. Seeds now camelCase; `fromMap` dual-reads legacy keys for upgrades.
- **Settings load crash on bad `businessType`** — invalid values fall back to `retail` instead of throwing.
- **Settings bool defaults** — empty/garbage values use fallback (not force-false); case-insensitive `true`/`false`/`0`/`1`.
- **Barcode generation clobber race** — `GenerateBarcode` / `BatchGenerateBarcodes` call `saveBarcodeLastCounter` only (no full `Settings.save`).
- **Silent settings save failure** — `SettingsPersistenceService` rethrows on immediate save; debounced failures notify cubit via `onDebouncedSaveError`.
- **Receipt totals vs cart** — PDF no longer reverse-engineers VAT from payable alone; SC and promotion amount lines were missing so restaurant/promo bills could not reconcile. Uses persisted sale money.
- **Receipt item discount double-count** — Net line subtotals no longer paired with a full aggregate item-discount row that made lines not sum to totals.
- **Voided sale clean PDF/share** — Voided sales print with VOIDED banner; share is blocked with l10n warning (history + post-sale).
- **Post-sale print/share silent failure** — Dialog keeps open, shows progress, try/catch + snackbar (parity with history); primary close is **Done** (not Cancel).
- **Sale/Product full search back** — With `PopScope(canPop: false)`, exit used `maybePop()` which never left the route; cleanup now force-`pop()`s when a previous route exists (history save is best-effort).
- **Search AppBar field overflow** — Reduced dense `TextField` vertical padding to stop ~9px bottom `RenderFlex` overflow under keyboard/IME.
- **Sale dashboard cart total** — Uses `payableTotals` (VAT/SC-aware) instead of raw `CartState.total`.

### Added

- **`SettingsAttentionBanner`** — Single root attention for backup overdue, incomplete shop, empty PromptPay; multi-issue summary + deep-link to highest priority page.
- **Settings attention l10n (EN/TH)** — `settingsAttentionItemsCount`, shop/PromptPay titles & bodies, `settingsAttentionReview`.
- **Settings IA section labels (EN/TH)** — `settingsDayClose`, `settingsBackupData` (split from `settingsSystemData` on root).
- **`SettingsTileBuilders.maskSensitiveId`** — Shared mask for PromptPay + biller list subtitles.
- **Receipt paper size control** — Receipt content section: choose 80mm thermal or A4; root Receipt tile subtitle shows size.
- **Backup encryption off confirm** — EN/TH `backupEncryptionOffTitle`, `backupEncryptionOffConfirm`.
- **Settings search keywords** — Sales tile indexes VAT/tax/ภาษี and related terms.
- **Backup PIN confirm** — EN/TH `backupPinConfirmHint`, `backupPinMismatch`.
- **`SettingsRepository.saveBarcodeLastCounter`** — Partial write for EAN sequence without rewriting the full settings document.
- **`SettingsMapper` unit tests** — Legacy snake_case dual-read, bool/businessType edge cases, no `autoPrintPrompt` on write.
- **`ReceiptDocument` / `BuildReceiptDocument`** — Domain model + builder under `lib/features/receipt/domain/` mapping `Sale` + `Settings` + `ReceiptLabels` (void/reprint/disclaimer flags).
- **Receipt preview breakdown** — Thermal/card support cart discount, promotion discount, service charge, void/reprint chrome, optional not-tax-invoice disclaimer.
- **Receipt l10n (EN/TH)** — `receiptThankYouDefault`, `receiptNotTaxInvoice`, `receiptReprint`, `receiptShareVoidBlocked`.
- **Receipt document unit tests** — `build_receipt_document_test` asserts SC/promo/VAT/void SSOT; PDF suite covers void + stored-field builds; removed duplicate `test/core/services/receipt_pdf_service_test.dart`.

### Changed

- **Sale cart host** — Default cart is full-page `CartReviewPage` via `openCartReviewPage` (replaces modal `showCartSheet`); expanded-width docked cart panel removed — catalog + bottom bar/FAB on all widths.
- **Backup Now CTA accent** — Primary backup action uses `AppColors.accent` (orange work CTA).
- **Settings root Clean Index** — No dashboard hero; no permanent readiness checklist; root chips only for incomplete shop, unset PromptPay, backup risk, oversell, disabled barcode; list stagger animation removed; `sectionGap` 32→24; root list capped at 720dp width.
- **Settings root IA** — Order: General → Store & Sales → Restaurant? → Discounts → Payments → **Day close** → **Backup & data** → About (Daily Close no longer under System & Data).
- **`SettingsThemeExtension.dark`** — Card/border/text tokens aligned with app `AppColors` dark stack.
- **`ReceiptPdfService` page format** — Uses document `receiptSize` (default 80mm).
- **Backup Now** — Full-width primary CTA on backup page (not only a list row).
- **Sales settings form** — Includes tax/VAT section; receipt form is content + preview + paper size.
- **Settings honesty** — Removed `autoPrintPrompt` from domain/mapper; General `accessibilityMode` UI still deferred; paper size lives under Receipt (not Shop).
- **`SettingsPersistenceService`** — Immediate save failures propagate; dispose flush is fail-safe; optional `onDebouncedSaveError` for UI.
- **`ReceiptPdfService`** — Builds via `ReceiptDocument`; money formatting uses `CurrencyFormatter.formatGroupedWithSymbol`; `calculateVat` retained for legacy/pre-sale mocks only (completed sales use stored fields).
- **History reprint** — Print marks `isReprint`; share of voided sales refused; product images prefer thumbnail + ~400KB cap.
- **SearchSurfaceConfig (Phase A)** — Policy factories for catalog vs sale search surfaces (`resultCap`, `includeInactive`, pause-filters, barcode gate); pages stay separate (no unified multi-mode search).
- **Sale catalog item hierarchy (P0)** — List/grid cards show one meta line (SKU if present, else `CategoryCue` label/dot); list row 92 / grid extent 200 to fit meta without bottom overflow; OOS/cart/add gestures unchanged.
- **Sale search tile chrome (P1)** — When `showAddAffordance`, tile uses list-like shell, 56 rounded avatar, cart qty on avatar, filled add disc; product search defaults unchanged.
- **Full-screen search AppBar field** — Shared compact `SearchAppBarField` (white fill, radius 12, bodyMedium, dense icons) on Sale + Product search pages so chrome matches the Sale shell search strip.
- **Bill hardening Wave A–C (partial)** — Schema **v27** unique `sales.receipt_number` (dedupe migration) + receipt reseed from disk; insert retries unique races; non-cash tender normalized to payable; line VAT allocated to match header; void filters soft-deleted sale/items; checkout freezes cart on **all** payment methods; draft park/newBill capacity check before save; named create waits for success before clear cart; draft autosave flush on bloc close. Money INTEGER Phase M still deferred (REAL baht on disk).

### Security

- **Backup encryption off friction** — Turning off encryption requires explicit confirm.
- **PromptPay shoulder-surf reduction** — Masked IDs on settings root and PromptPay tile.
- **Backup PIN service gate** — Short/empty PIN rejected outside UI (`PIN_TOO_SHORT` / `PIN_REQUIRED`).
- **Void share integrity** — Cannot share a voided sale as a normal paid receipt; print path always watermarks VOIDED.
- **Receipt disclaimer** — On-paper / preview copy states sale receipt is not a Thai tax invoice (full tax-invoice fields still deferred).

### Documentation

- **`docs/readme/features.md`** — Receipt PDF: 80mm thermal as current; A4/logo/PromptPay-on-receipt/barcode planned; stored-field totals; VOID watermark; not-tax-invoice disclaimer.

### Highlights (continued)

- **Bill UX P1** — Park CTAs catalog + cart footer only; open-bills list hides empty drafts; badge/chip = `openBillCount` (bills with items); Pay from list (switch + checkout); max-drafts snack opens Saved Bills; unify `parkAndNext` copy.
- **Saved Bills full page** — Replaces drafts bottom sheet with `SavedBillsPage` (AppBar list + search + park + named create); open from Sale AppBar, mode chip, cart menu; root-nav push after cart modal pop; empty-state copy; smoke widget tests.
- **Sale Bill UX B-UX0** — Catalog shows current bill name + count; one-tap park from catalog (optional name on **parked** draft); drafts sheet park-only (no duplicate New bill row); cart footer park + pay (drafts via header/chip); unify `parkBill` copy.
- **Bill/Sale Test Wave T0–T1** — Checkout: mixed PromptPay stamps ref on PP tender, cart freeze after `waitingPayment`, DayClosed/PaymentMismatch keys, ignore confirm while processing. Draft: park max/save fail atomic, named newBill, empty blackout vs non-empty autosave. CreateSale payments forward + VAT/discount/SC clamps; `computeWithServiceChargeAmount`; CloseDay expected cash from cash tender lines; datasource multi-tender edges.
- **Bill R1 multi-tender** — `sale_payments` table (schema v28); create/load tender lines; checkout split cash+other; mixed+PromptPay opens QR for PP share only; History/receipt payment breakdown; daily close/report sums tender amounts.
- **Bill R0 + one-tap park** — Cart footer Park; named create uses park+name (no data loss); empty new-bill no-op; autosave blackout only when cart empty; draft error snack dedupe; post-sale draft name `B-#####`.
- **Sale Residual Wave** — Park bill = save + new empty draft + clear (awaitable); atomic New bill (no clear on fail); draft list payable totals; day-closed banner on Sale.
- **Sale Integrity P0** — Shared `SalesDayLock`; CreateSale/VoidSale block when day closed (void needs reopen); checkout helper uses same rule; history maps `DayClosed`; reopen clears `lastClosedDate` only when it matches reopened date.
- **Sale UX Wave 1** — Cart chrome SSOT (docked header clear/drafts); drafts sheet Hold this bill / New bill speed actions; checkout customer/promo dense when attached; docs use `payment_sheet.dart`.
- **Sale UX Wave 0.5** — Named checkout routes + safer shell pop; processing timeout no longer unlocks double-submit; catalog add hit target 48dp + semantics; retail payment file `payment_sheet.dart` (compat export from redesign name).
- **Sale UX Wave 0** — Bottom bar / ultra FAB open cart (not pay); mode switcher is current bill + drafts (no dead checkout chip); hold CTA = saved bills; cart totals use `SalePayableCalculator` (VAT-aware); promo/SC/VAT in breakdown + checkout total card; draft errors snack + l10n; cash exact prefill; restaurant order/table seed from cart; remove dead `SaleStatusStrip` / `CategoryFilterSheet`.

- **Payable SSOT (Wave A)** — `SalePayableCalculator` (Money satang): cart bottom bar / review / FAB / status strip and checkout confirm share the same SC default + VAT (EXCLUSIVE/INCLUSIVE/NONE) as `insertSaleWithItems`.
- **Stock integrity (Wave B)** — Commit honors `allowOversell`; conditional stock update when oversell off; cart aggregates qty by product for options; barcode merges empty-options lines only; `ProductNotAvailable` → productInactive.
- **PromptPay cart freeze (Wave C)** — Snapshot cart at `waitingPayment`; complete uses freeze not live cart; processing timeout no longer unlocks double-submit.
- **Search / add races (Wave D)** — Pop re-entry guard on Sale/Product search; option sheet captures `CartBloc` before close.
- **Security/DB hygiene (Wave F/G partial)** — Crash logs sanitized on write; backup PIN verify deletes temp plaintext; default backup encryption on; sale_items/draft load filter soft-delete.
- **Payment sticky CTA** — Confirm bar outside scroll; sheet single keyboard inset; cash autofocus off.
- **Stock commit tests** — `allowOversell` / `InsufficientStock` / multi-line aggregate at datasource.
- **Backup PIN min length 6** + image delete path sandbox under app `images/`.
- **Cart concurrency** — `bloc_concurrency` sequential on barcode / promo set / recompute.
- **Schema v26** — unique `daily_closes(close_date)` with dedupe migration; draft delete in one transaction.
- **Sale full-screen POS search** — Tappable Sale search opens `SaleProductSearchPage` (ranked name/SKU/barcode, `sale_search_history`, cart-first tap stay-on-add, wedge + camera scan); shared `saleAddToCart`; clears query on exit (not sticky catalog search).
- **Sale search polish** — Enter exact unique barcode adds to cart; OOS feedback via `SaleAddResult`; in-cart qty badge + add affordance on results; history only after commit (add/submit with hits); stock-limit increment emits `outOfStock`; widget tests for search page + open-from-Sale.
- **Product search polish** — Enter exact unique barcode opens preview; history only after commit; includes inactive with label/opacity; scan icon gated by `barcodeScanEnabled`; sticky query still preserved on exit; Sale-matching primary AppBar + filled search field chrome.
- **Product Preview hardening** — Post-create opens preview (list/search/barcode create); form create returns `Product`; header radius 24 + subtitle; summary card elevation/avatar cache + unit (no hard-coded pcs); history virtualized list; currency `select` rebuild scope.
- **Sale category/filter chrome** — Unified filter card (categories + recommended + filter pill + list/grid toggle); mock-style category pills (filled primary, icon/dot accents); polished filter sheet header + summary chips + apply CTA.
- **Sale mockup alignment (rounds 1–3)** — Product `+` button; barcode in search field; dual sale|drafts switcher with `draftCount`; cart header clear-all; cart line thumbs; bill discount/note tiles; filled teal category chips; AppBar subtitle; Pay footer arrow + hold outline.
- **Sale visual redesign (Home/Product tone)** — `PosThemeExtension`; branded primary AppBar + embedded search; cart status strip; product cards radius 16 + in-cart badge/border; orange Pay CTA on bar/footer/FAB/checkout; cart sheet polish; checkout `FormSectionCard` groups; tablet split catalog|cart at ≥840 (phone sheet path unchanged).
- **Report Wave 0.5** — ReportCubit period SSOT under Report shell (History sync); Close CTA uses filter end date; clear sales on range change; empty period CTA; PromptPay currency/locale bank/newest-first; top products ฿ secondary.
- **Payment PAY1–PAY3** — Checkout stores `paymentReference` as its own column (not stuffed into note); post-sale receipt when preview is on; PromptPay cancel pops one route; double-confirm blocked while processing/waiting; transfer uses bank icon.
- **Sale History SH1–SH2 + Wave 0** — Factory `HistoryBloc`; thin `HistoryPage` → tab view (today + presets); void keeps list visible (`voidingSaleId`) + AppDialogShell; required void reason + voided reason/time; Close Day uses History filter end date; Report AppBar follows tab; empty CTAs.
- **Create-missing product CM1–CM3** — Sale not-found → create → auto-add cart with correct snack; product list/search scan offers create CTA + barcode prefill; scan-create skips draft restore and opens Info with name focus.
- **Product inventory History PH1–PH3** — Factory `InventoryLogCubit`; soft-delete filter + 200-row cap; localized stock-edit reason; shared log row (sale ref); Stock → full History jump.
- **Batch barcode BG1–BG3** — Success/none/error snacks; count matches full catalog (active+inactive without barcode); `isBatchGenerating` + double-tap guard; stream refresh after batch.
- **History Wave 0** — Close Day uses History filter end date; void requires reason and shows reason/voidedAt; Report AppBar follows Report/History tab; empty CTAs (clear search / go to sale).
- **Manage Category Wave 1** — Soft-delete categories (`deletedAt`); CSV import creates categories via `AddCategory` (unique + max+1, returns id); Sale catalog selects categories only (no saveStatus fanout).
- **Manage Category Wave 0** — New categories append (`sortOrder` max+1); search empty ≠ true empty; success snacks; clearer delete product impact; reorder POS hint; name max 100; bulk cancel keeps selection.
- **Report / ปอดยอด Wave 0** — Shared `SalesPeriodTotals` for Report, Daily Close, Home, Sale header; default range **today** + date presets; payment count/%; History range visible; Daily Close + PromptPay l10n.
- **CSV product import Wave 0** — Isolated `importStatus` (no race with catalog stream); UTF-8/BOM decode; 2MB / 2000-row caps; correct error l10n keys; template share; empty-state + bottom-bar import CTA.
- **Unified product search** — Shared ranked matcher (barcode/SKU/name); catalog sticky search matches full search page (list filters paused while querying); sale ranks matches inside filters; result cap 80; inactive excluded from catalog search.
- **Promotion on the POS path** — Attach/clear active promo on cart + checkout (`CartPromotionSet` + `PromotionSelector`); amount from `Promotion.discountFor` with recompute on cart changes; sale fails closed if promo missing/inactive; receipt shows promo name; home banner shows real active promo.
- **Customer on the POS path** — Attach/clear customer on cart + checkout (`CartCustomerSet` + `CustomerSelector`); draft keeps `customerId`; receipt PDF shows customer name; sale fails closed if customer missing/soft-deleted; CRM list/form i18n + `MoneyText`.
- **System P0 money & ops** — Real **Backup Now** (WAL checkpoint → DB copy → optional AES-GCM encrypt + PIN → share); promotion discount in cart/sale totals; checkout maps business errors to l10n keys.
- **POS counter path (Sale + Cart)** — Counter-first sale catalog; cart sheet/review redesign; money trust: sale `totalAmount` includes service charge.
- **Product form, dialogs & catalog trust** — Hero + 4 tabs; visibility/recommended; price insights (Money); shared confirm shell (D1/EP); filter isolation Sale↔Products; stock inventory logs; list pagination window 20+20; filter chips show selected category/stock.
- **Codes tab Extra** — Supplier card split from options; preview supplier + options summary.
- **Catalog & barcode ops (v0.9 track)** — Form tabs Info→Price→Stock→Codes; sale scan not-found → create; HID wedge; brand/unit/supplier/recommended (schema v25).
- **Platform** — SQLCipher; Money VO; E2E; typed `AppError`; InventoryRepository.

### Added

- **Sale POS theme** — `PosThemeExtension` (light/dark) + `context.posTheme`; `SaleStatusStrip` cart summary card; optional `ProductCardShell.borderColor` / `elevation`.
- **Report Wave 0.5** — `TopProductStat` + revenue secondary; HistoryTabView `syncWithReport` / initial range; EN/TH `closeDayForDate`, `reportNoSalesInPeriod`; cubit clears sales on range change.
- **Payment / History / create-from-scan l10n** — `productCreatedAddedToCart`; inventory history keys (`invLogReasonProductStockEdited`, `invLogSaleRef`, `productHistoryShowingLatest`, `productHistoryViewAll`); History void/empty CTA keys as in Wave 0.
- **Product inventory log row** — Shared `InventoryLogRow` for preview History + full inventory log page; sale ref short display; quantity compact.
- **Batch barcode eligibility** — `productNeedsBarcode` / `countProductsNeedingBarcode`; `ProductRepository.getAllProducts` for full-catalog batch.
- **History Wave 0** — Required void reason UI; voided bill shows reason + time; EN/TH keys (`voidReason`, `voidReasonRequired`, `voidedAtLabel`, `goToSale`); HistoryBloc tests for not-found/generic void, concurrent guard, reason passthrough, date-range args.
- **Manage Category Wave 1** — Soft-delete on category remove/bulk disposition; `CategoryRepository.addCategory` returns id; `ImportProducts` depends on `AddCategory`; import unit tests for create/reuse category.
- **Manage Category Wave 0** — `AddCategory` auto `sortOrder = max+1`; reorder hint banner; EN/TH keys (`noCategoriesFound`, `categorySaved`/`Deleted`, `categoryReorderHint`, `deleteCategoryProductsImpact`, `categoryNameTooLong`); unit tests for uniqueness, bulk delete bloc path, delete disposition.
- **Report Wave 0** — `SalesPeriodTotals` (sale domain); date preset chips (today / yesterday / 7d / month); payment method count + share %; Report “Close today” CTA; History presets + visible range label; EN/TH keys for presets, PromptPay average/recent, daily-close summary/recon strings.
- **CSV import Wave 0** — `ProductImportStatus` on product state; file size/row caps; template download + column legend; EN/TH keys for file size, too many rows, partial success, categories created, parse/post-import error titles; empty catalog import CTA; bottom bar import button.
- **Product search core** — `matchProducts` / `resolveExactBarcodeMatches` / `sortProductsBySearchRank` under `product/domain/utils`; catalog list banner when filters paused; search page loading state, result cap + “showing N of M”, history on open result; shared barcode exact resolve (0/1/N).
- **Promotion attach on sale** — `CartPromotionSet` / `CartPromotionRecompute`; `PromotionSelector` on cart + checkout; receipt promotion labels; home banner binds active promo.
- **Customer attach on sale** — `CartCustomerSet`; `CustomerSelector` on cart + checkout; receipt customer name; draft `customerId`.
- **Backup export service** — Real DB export/encrypt/share (no stub success).
- **Dialog system** — `AppDialogShell` + `showAppConfirm` / `showAppUnsaved`; product/customer/table/daily-close/settings binary confirms; cart line remove title/detail/qty keys.
- **Product form / preview** — Hero metrics + tab jumps; sellability chips; Visibility section; price insights + markup chips; Codes supplier + options subtitle; form tab icons.
- **Product list** — Recommended star; pinned clear-filters control; compact stock qty (K/M); `ProductListPaging` constants.
- **Price tab P1** — `ProductPricingInsights`; empty-cost honesty; edit price/cost delta strip.
- **Text field clear confirm** — Confirm when trimmed length ≥ 8.
- **l10n (EN/TH)** — Promo/customer/sale/backup keys; visibility/recommended; price form keys; `removeCartLine*`; `deleteProductConfirmTitle`; clear-field keys.

### Changed

- **Sale chrome** — Primary AppBar (bottom radius 24) + surface search field; catalog tool strip card; denser-but-polished list/grid cards with `ProductAvatar` and in-cart qty badge; floating cart bar elevation + accent Pay; unified CTA colors; checkout sections in `FormSectionCard`; expanded width docks cart beside catalog.
- **Checkout payment reference** — Transfer/card/cash optional ref persists on `sales.paymentReference`; note field stays free-form only.
- **Checkout post-sale UX** — When post-sale preview is enabled, success shows `SaleReceiptDialog` after closing payment routes; PromptPay cancel/timeout pops only the PromptPay route.
- **Payment method chrome** — Transfer uses bank icon (not QR); PromptPay remains wallet/QR.
- **History surface** — Single UX via `HistoryTabView` (today + presets); legacy `HistoryPage` is a thin shell.
- **History void UX** — AppDialogShell confirm; row-level void spinner (`voidingSaleId`) instead of full-list loader; errors map to l10n keys.
- **Product form scan-create** — Opens Info tab with name focus (barcode still prefilled); does not offer draft restore over scan prefill.
- **Batch barcode generate** — Targets all products without barcode (active + inactive); UI count matches use case.
- **Inventory log watch** — Soft-deleted rows excluded; per-product watch capped at 200 latest movements.
- **Product CSV import** — Full-page flow (review list, sticky confirm, block back while importing) instead of `AlertDialog`; same parser/limits/`ProductsImported` contract; partial errors stay on page.
- **Product list pagination** — First paint **20** rows, load-more **+20**, throttled scroll, clamp to filtered length, spinner footer (not fake product skeletons).
- **Product list filters F1** — Toolbar category chip shows selected name + icon with per-chip clear; stock chip labels Low/Out; sort icon badges when non-default; full clear X still full reset; category/stock sheets remain for pick/clear.
- **Product list filters** — Clear filters always visible (pinned right); chips reflect real category/stock filters; category/stock sheets no longer clear sibling filters on open.
- **Confirmation dialog chrome** — Centered circular icon, twin pills radius 12 (soft cancel + accent confirm), optional detail/footnote.
- **Text field clear** — Short fields (price/qty) clear immediately; long text still confirms.
- **Product form tab bar** — Icon + label (Info/Price/Stock/Codes).
- **Price insights** — Shared Money math; empty cost shows `—` + hint.
- **Sale catalog R1** — List default, denser tiles, search via sale cards.
- **Cart review R1+R2** — Dense lines; expandable bill; SC + grandTotal; clear confirm; qty−@1 removes with undo.
- **Product Info / Codes UX** — Visibility section; supplier separated from options.
- **Recommended hint copy** — Describes real sale/list behavior.
- **CartItem equality** — `lineId` in `props`.

### Fixed

- **Report / History dual date ranges** — Under Report shell, History seeds from ReportCubit and chips sync both ways (`syncWithReport`).
- **Report Close Day always today** — CTA closes filter end day (`state.to`); label uses `closeDayForDate` when not today.
- **Report stale totals while loading** — `changeDateRange` clears sales so previous period cannot render as success.
- **Report empty period** — Page-level empty + go to Sale CTA.
- **PromptPay report metrics** — Real currency on tiles; bank name follows locale; recent list newest-first.
- **Top products money secondary** — Qty rank kept; line shows revenue from item subtotals.
- **Payment PAY1–PAY3** — Checkout sends `paymentReference` as its own column (not merged into note); post-sale receipt when preview enabled; PromptPay cancel pops one route only; bloc ignores double confirm while processing/waitingPayment; transfer icon is bank (not QR).
- **Sale catalog `context.select` assert** — Category list / settings watched from `State.build`, not parent context inside `BlocBuilder` (fixes Provider “outside build” crash on Sale).
- **History Close Day always today** — FAB opens Daily Close for the end day of the active History date filter (`state.to`).
- **History void reason optional / invisible** — Confirm requires non-empty reason; expanded voided tiles show reason and voided time.
- **Report AppBar always “Report” on History tab** — Title switches to sale history when History tab is active.
- **History empty states had no CTA** — Clear search when querying; go to Sale when no bills.
- **Create-missing product CM1–CM3** — Sale post-create snack says product created and added to cart (auto-scan, not “scan again”); product list/search scan offers create CTA with barcode prefill; scan-create skips draft restore and opens Info with name focus.
- **Sale History SH1–SH2** — `HistoryBloc` factory-scoped; `HistoryPage` thin-wraps tab view (today + presets); void uses `voidingSaleId` (list stays visible) + AppDialogShell confirm; errors map to l10n (`saleAlreadyVoided` / `saleNotFound`).
- **Product preview History PH1–PH3** — `InventoryLogCubit` factory-scoped (not app singleton); inventory watch filters soft-deleted rows and caps at 200; stock-edit reason is l10n key; shared log row shows sale ref + localized reason; Stock tab “view full history” jumps to History.
- **Sale catalog rebuild on category saveStatus** — Chips/filters use `context.select` on categories list only.
- **CSV import bypassed category uniqueness** — Creates categories through `AddCategory` instead of raw repository insert + stream poll.
- **Category hard delete** — Soft-delete via `deletedAt`; watch hides deleted rows.
- **Category create always sortOrder 0** — New categories append after max order (aligned with CSV import).
- **Category search empty mislabeled** — Search miss uses “no match” + clear search, not “no categories yet”.
- **Category silent save** — Success snackbars for create/edit/delete (reorder stays quiet).
- **Bulk delete cancel cleared selection** — Selection preserved unless delete confirmed.
- **Category name length** — Form enforces max 100 characters.
- **Batch barcode generate BG1–BG3** — Success/none/error snacks on product list + barcode settings; confirm count matches full catalog (active+inactive without barcode); `isBatchGenerating` progress + double-tap guard; ensure product stream subscribed after batch so list refreshes.
- **Home H0 safety & money trust** — Home Sell/Products/Settings/Report use shell tabs (no silent `CartCleared` / duplicate Sale push); long-press new draft confirms when cart non-empty; dead notification icon removed; dashboard load error is fail-closed with Retry (not fake ฿0 day); cost/profit show `—` until product catalog is ready; day-close lock syncs `SettingsCubit` after close/reopen; `DailyCloseConfig.copyWith` can clear `lastClosedDate`.
- **Report vs Daily Close payment/revenue drift** — Single `SalesPeriodTotals` + shared `normalizePaymentMethod`; CloseDay no longer uses private payment normalizer or `status == COMPLETED` only.
- **Report default 30-day range** — Opens on **today**; presets for common ranges.
- **History date range invisible** — Shows formatted from–to + presets (default today).
- **Daily Close / PromptPay English hardcodes** — Localized summary, cash recon, open/closed badges, PromptPay Average/Recent; currency from settings.
- **CSV import race with product stream** — Dialog listens to `importStatus` only; catalog `ProductStatus` updates no longer close/mis-handle import UI.
- **CSV import UTF-8 / BOM** — Uses `utf8.decode` + BOM strip; Thai headers and track_stock aliases work.
- **CSV import error mapping** — Maps `csvNoData` / `csvInvalidFormat` / size/row caps instead of generic `csvImportError`.
- **Product search dual semantics** — Sticky list search no longer re-applies category/stock/price on top of ranked query (same set as full search page).
- **Search result SKU hardcode** — Uses `skuLabel` l10n instead of English `SKU:`.
- **Product UX U1** — Filter sheets keep sibling filters; clear includes price range; recommended blocked while product hidden; info tab Visible/Hidden + Recommended/Not; delete shows loading while waiting for bloc.
- **Product bugs B1** — `ProductSurfaceEntered` filter snapshots (Sale↔Products); swipe/preview delete awaits success; stock changes always inventory-log (incl. quick-edit); form blocks back while save/delete in flight; delete snackbar uses `productDeleted`; search trims.
- **Product preview after edit** — Bloc merges updated product into `products` on save; preview reloads when edit returns `true`.
- **Stock on-hand display** — List/grid stock values use compact K/M (`formatQuantityCompact`).
- **Backup Now was a stub** — Now exports a real file.
- **Promotion discount ignored in totals** — Cart/sale totals subtract promo amount before SC/VAT.
- **Promotion / customer attach on sale** — Selectors + fail-closed create when missing/inactive.
- **Home promotion banner** — Shows active promo when present.
- **Checkout swallowed errors** — Maps errors to stable l10n keys.
- **Customer `copyWith` contact clear** — Sentinel pattern for phone/email/note.
- **Customer CRM hardcodes** — List/form use l10n + `MoneyText`.
- **Product / customer / promotion delete** — Shared destructive dialogs; side-effects after confirm.
- **Preview price loss display** — Unclamped profit when cost > price.
- **Service charge in sale ledger** — SC included in pre-tax base before VAT.
- **Create product ignored `isActive`** — Persisted on insert.
- **New draft kept previous cart** — Draft create clears cart session.
- **Draft line identity** — Persist/restore `CartItem.lineId`.
- **Cart duplicate menu label** — Uses `duplicateItemAction`.

### Added (earlier unreleased)

- **Product metadata fields (schema v25)** — Added nullable Brand, Unit, and Supplier fields plus an `isRecommended` flag to products, with an additive migration from v24 for existing databases.
- **AppTextField** — Core filled-dense text field (`lib/core/widgets/primitives/app_text_field.dart`) with optional clear, suffix actions, and theme-driven decoration for POS forms.
- **Unit picker bottom sheet** — `showUnitPicker` with preset retail units + custom unit; `UnitField` opens sheet instead of dropdown.
- **Adjust stock bottom sheet** — `showAdjustStockSheet` (qty delta + required reason) replaces AlertDialog; `showAdjustStockDialog` delegates to the sheet for stable call sites.
- **Option edit bottom sheets** — `showOptionGroupEditSheet` / `showOptionEditSheet` with AppTextField; option deletes use `showConfirmationDialog`.
- **Product form price insights** — Full-width selling price & cost fields; live profit, margin %, markup %; soft warning when cost ≥ price (`costExceedsPriceWarning`); stock sell-out estimate (`priceStockEstimate*`) when tracking stock.
- **Product form stock tab insights** — Status banner (in / low / out) using `Settings.lowStockThreshold`; qty with thousand separators + unit; edit-mode adjust hint; inventory value card (cost · sale · potential profit) when stock > 0; shared `stock_status_resolver`.
- **Adjust stock sheet redesign** — Add/Remove high-contrast mode buttons, amount field (no signed typing), solid current-stock + preview cards, reason chips with primary selected state, **orange accent Save**, returns new balance so product form stock field updates after save.
- **Editable low-stock threshold on product form** — Stock status banner opens a sheet to change app-wide `lowStockThreshold` (presets 3/5/10/20 + custom); persists via `SettingsCubit` like Stock settings.
- **Grouped money formatting** — `CurrencyFormatter.formatGrouped` / `formatGroupedWithSymbol` / `formatGroupedInt` (thousand separators); `MoneyText` and product price insights use readable grouped amounts (e.g. `฿1,500.00`).
- **Product form hero card** — Slim `ProductFormHeroCard` under `DetailHeader`: image picker, live name, sellability + category chips (no SKU/barcode mirror lines); low-stock uses settings threshold (not hardcode 5).
- **Product form top tabs** — Pill `TabBar` + `IndexedStack`: **Info → Price → Stock → Codes** (`tabCodes`); fields stay mounted for full-form validate; save jumps to first invalid tab (price→1, barcode→3).
- **StickyActionBar side-by-side mode** — Optional `sideBySide`, `primaryColor`, and `primaryKey` for cancel + primary action row (product form uses accent orange save).
- **Product form l10n** — EN/TH: section keys, `tabCodes`, `profitMargin`, `notSpecified`, `saveProduct`, `discardChanges`, unsaved messages, `costExceedsPriceWarning`, `priceStockEstimateTitle` / `Revenue` / `Profit`, `editStockAdjustHint`, `lowStockThresholdHint`, `stockInventoryValueTitle`.
- **Category clear on product form** — Clear (X) on category field; empty-id “none” normalized to null on submit; lookup does not restore category after user clear.
- **Text field clear** — `AppTextField` / product fields show clear when non-empty (`product-text-field-clear`).
- **Audited stock adjustment from Product Edit** — Edit mode shows stock read-only and opens adjust-stock bottom sheet (signed qty + required reason) instead of overwriting stock on product save.
- **SQLCipher encryption** — `sqlcipher_flutter_libs` (0.6.0) for AES-256-CBC full-database encryption; `flutter_secure_storage` (10.3.1) for secure key storage; `EncryptedDatabaseOpener` with transparent migration from plain SQLite.
- **Money value object** — `Money` class with `fromDouble`, `zero`, arithmetic operators (+, -, *, /), comparison operators, and `MoneyConverter` for Drift type safety across 81 money fields in 14 entity files (Product, Sale, CartState, DraftCart, Customer, Promotion, DailyClose).
- **Runtime data integrity validations** — barcode uniqueness check before product insert/update; product delete guard checks sale_items and draft_cart_items references to prevent orphaned foreign keys.
- **Database indexes (schema v24)** — conditional unique index on products.barcode (allows NULL/empty), performance index on sale_items.product_id for reports, sales.created_at index (redundant but ensured).
- **InventoryRepository** — Clean Architecture compliance: domain interface + data implementation, replaces direct database access in `AdjustStock` usecase.
- **Product description field (schema v22)** — nullable `description` column in `products` table, `Product` entity, `ProductDraft` entity, `ProductAdded` event, `AddProduct` usecase, `ProductRepository`, and `ProductFormCubit`.
- **Typed error system** — `AppError` sealed class hierarchy (ValidationError, NotFoundError, BusinessRuleError, DatabaseError, NetworkError, FileSystemError, PermissionDeniedError, UnknownError); `ErrorDisplay` widget with consistent icon/message/retry UI; `AppErrorDisplay` extension for localized messages; migrated `ProductState` and `ProductBloc` from `String? errorMessage` to `AppError? error`.
- **E2E Test Suite** — 30 integration tests covering 5 critical user journeys using Robot pattern; in-memory test database with realistic fixtures (20 products, 5 categories, 3 tables, 2 promotions); CI integration ready; `flutter_driver` dependency added.
- **API Documentation** — Comprehensive API reference (1,544 lines): `docs/api/CORE_MODULES.md` (Money, AppError, ID generators), `docs/api/FEATURE_MODULES.md` (Product, Sale, Customer, Promotion APIs), `docs/api/DATABASE_API.md` (Drift query patterns, transaction strategies, repository pattern).
- **Performance Analysis** — Identified 3 critical bottlenecks: N+1 query pattern in product loading (~150ms overhead), cart state recomputation (~10ms overhead), widget rebuild inefficiencies (~10-30ms overhead). Optimization roadmap documented with 2-5x expected performance gains.
- **Security Audit** — Completed dependency vulnerability scan (169 packages); zero critical CVEs found; SQLCipher encryption validated; phased dependency update strategy documented (Phase A: 11 safe patches ready, Phase B: Drift upgrade path).
- **CONTRIBUTING.md enhancements** — Added Performance Guidelines (checklist, benchmarks, query patterns), E2E Test Requirements (when to add, Robot pattern examples, coverage checklist), target metrics (product list <100ms, cart update <5ms, scroll 60fps).
- **Product search bar** — `ProductSearchBar` widget with persistent search input and integrated barcode scanner button.
- **Product stats dashboard** — `ProductStatsRow` with 4 colored stat cards (blue/orange/red/green backgrounds, white text) for total, low stock, out of stock, and inventory value; tap-to-filter with selected border highlight.
- **Tab-based category filters** — `ProductFilterTabs` with underline indicator tab bar (All / Category / Stock) and sort `PopupMenuButton` with check mark on active sort option.
- **Rich product tiles** — `RichProductListTile` with shadow card, 60px rounded-square avatar, name + price on same row, SKU/barcode subtitle, category pill + stock indicator + ⋮ menu at bottom; `RichProductGridCard` grid variant.
- **Bottom action bar** — `ProductBottomBar` with CSV import and add product buttons, replacing the old FAB.
- **CSV import** — `CsvProductParser` (supports EN + TH column headers), `CsvProductRow`/`CsvImportResult` domain models, `ImportProducts` usecase with duplicate barcode skipping, `ProductsImported` bloc event with loading/success states, `CsvImportDialog` with file picker → preview → confirm flow.
- **Product preview tabs** — `InfoTab` (product info card with category, unit, description, dates + `CodesCard`), `StockTab` (stock status, stock value, stock summary, recent movements, adjust button), `PriceTab` (selling price, cost, profit, margin %, markup %, ROI bar, total stock revenue/profit), `HistoryTab` (inventory log list via `InventoryLogCubit`).
- **InfoListItem widget** — shared `InfoListItem` in `shared_widgets.dart` with icon, label, value, optional `valueColor`, `onTap`, and `trailingIcon` (defaults to chevron, supports copy icon).
- **Stock tab enhancements** — stock summary section with total sold, total restocked, total adjusted out (from `InventoryLog` stream), last stock update date, and 3 most recent stock movements.
- **Price tab enhancements** — Markup % (profit/cost × 100), ROI bar (`LinearProgressIndicator`), total stock revenue (stock × price), total stock profit (stock × profit).
- **L10n** — 16 new keys (EN + TH) for product redesign UI texts; 15 new keys for product detail page; 12 new keys for stock/price tab enhancements (stock value, sale value, potential profit, total sold/in/out, last update, recent moves, status, markup, ROI, total revenue/profit).
- **Tests** — 10 CSV parser unit tests, 2 new bloc tests (tab change + import); 3 new Product description entity tests, 7 new ProductDraft description tests; updated preview page tests for tab-based layout.
- **Preview page widget tests** — 7 InfoTab tests (category, dates, description, CodesCard, removed fields); 9 StockTab tests (stock status, stock value, adjust button, recent moves); 8 PriceTab tests (selling price, cost, profit, margin, markup, ROI, total revenue); 4 HistoryTab tests (loading, empty, log list, error retry); 4 ProductPreviewPage interaction tests (delete via menu dialog, delete via menu dispatch, toggle active, bottom bar 2 actions).
- **ProductTextField** — added `maxLines` parameter for multiline support; added `suffixText` parameter for unit labels.
- **ProductAvatar** — added `shape` parameter for rounded square image support.
- **Product search page** — Dedicated full-screen `ProductSearchPage` with auto-focus search field, search history (persisted via `SearchHistoryCubit` with key `'product_search_history'`), recent searches overlay with `ActionChip` UI, `SearchResultTile` with query highlight and match type chip (Name/SKU/Barcode), `SearchEmptyState` for no-results; tap result opens `ProductPreviewPage`; search icon added to `ProductListPage` AppBar actions (inline search bar retained for quick filter).
- **Product search page tests** — 7 widget tests covering empty state, filtered results, no matches, recent searches display, recent search tap, back button, and search field hint.

### Added

- **Sale cart bottom sheet** — `showCartSheet` / `CartReviewBody` shared with page fallback; bar + compact FAB open sheet instead of full-page cart by default.
- **Retail payment sheet** — `showPaymentSheet` wires providers into payment shell; `navigateToCheckout` forks retail → sheet, restaurant → `CheckoutPage` + `TableBloc`.
- **Sale category chips** — Horizontal `CategoryFilterChips` on catalog; advanced filters open as bottom sheet (stock/sort/price only).
- **Sale barcode not-found recovery** — Snack **Create product** + in-scanner CTA (`onCreateProductFromBarcode`) opens form with prefilled barcode (`lastFailedBarcode` / `ProductFormPage.initialBarcode`); optional re-scan into cart after save.
- **HID keyboard-wedge listener on Sale** — `BarcodeWedgeListener` buffers rapid alnum + Enter/Tab into `CartBarcodeScanned` when barcode scan is enabled and no text field is focused.
- **Barcode scan debounce** — Identical code within 1s ignored (camera continuous + HID double-fire); not-found path allows immediate re-scan after create.
- **Product form barcode live strip** — Codes tab: compact glyph preview + type chip + copy; empty-state hint; confirm before generate/scan replaces an existing code; shared `resolveBarcodeSymbology`.
- **Product preview barcode polish** — Symbology type chip on Codes row + label card; action buttons show icon **and** label (copy / view / save / print) with higher contrast.
- **Barcode scanner UX redesign** — Aiming cutout is visual-only; status/result/manual/error in bottom scrim panel (IME-safe); slim app bar with continuous/single mode chip + torch + overflow (focus/gallery); slower laser; create-product CTA uses accent orange; high-contrast white header chrome.
- **Scanner result price** — Found-product price uses grouped currency symbol (e.g. `฿1,500.00`).
- **Product list trust & findability** — Low-stock uses `settings.lowStockThreshold` across list stats/filter/tiles/preview (`stock_level` helper, `filteredProducts`); sticky search after leaving search page; list scan opens preview on exact barcode match; ⋮ menu adds batch barcode generate; CSV import shows parse/import row errors; create product uses `showProductCreatePage`.
- **Product search page upgrade** — Hydrates sticky query on open; query-only results via `productsMatchingQuery` (ignores list category/stock filters) with banner when filters active; in-page barcode scan; ranked matches (exact barcode/SKU first); result count; l10n match chips; SKU/barcode subtitle highlight; history saved on all back paths.
- **StableListenableBuilder** — Stable `Listenable.merge` identity for multi-controller form insights (avoids dispose races).

### Fixed

- **Draft cart restore incomplete** — `CartRestored` + sale load path now restore note, order type/channel, table, service charge, customer, promo (not only items + cart discount); clear-cart undo uses full session snapshot.
- **Draft auto-save missed meta-only edits** — Sale autosave listens for discount/note/table/order/customer/promo changes, not only line items.
- **Sale low-stock hardcode** — Filter preview, product cards, cart detail sheet use `settings.lowStockThreshold`.
- **Product form controller dispose race** — Live price/stock insights no longer recreate `Listenable.merge` every rebuild (`StableListenableBuilder`); form unfocuses before disposing controllers to avoid `TextEditingController was used after being disposed` cascades on IME/route exit.
- **Adjust stock from product form** — After a successful inventory adjustment the form stock field refreshes to the new balance (without marking the product draft dirty).
- **Product list barcode scan button** — Scan icon is no longer under `AbsorbPointer`; opens camera scanner (with settings) and filters the list.
- **Sale barcode outOfStock snack** — Maps `outOfStock` to l10n instead of raw key.
- **Product form barcode scan** — Single-shot scanner result is applied to the field (was dropped because `onScanned` only runs in continuous mode).
- **Product list / preview low-stock hardcode** — Replaced magic `stock <= 5` with settings threshold (default 5 when SettingsCubit absent in tests).
- **Product list search bar contrast** — White filled field + dark text on primary app bar; clear/scan as light icon buttons (not primary-on-primary).
- **Barcode scanner header contrast** — Forced white title/icons/foreground on dark scanner AppBar.

### Changed

- **Sale catalog density** — Denser grid (`mainAxisExtent` ~200, image ~96); quieter add (haptic + qty badge, no snack spam); dashboard header hidden in ultra-compact mode.
- **Database opener** — Replaced `drift_flutter.driftDatabase()` with `LazyDatabase` + `EncryptedDatabaseOpener.open()` for async key fetch from secure storage; schema bumped v21 → v24.
- **Product form Preview-aligned layout** — Shell: `extendBodyBehindAppBar` + `DetailHeader` + slim hero + pill tabs; footer **Cancel | Save product** (accent); delete via header ⋮ (edit only); single image action on hero.
- **Product form IA regroup (4 tabs kept)** — **Info → Price → Stock → Codes**; supplier + option groups on Codes; **isActive only on Product/Settings** (no header eye on form); validation jump price→1, barcode→3.
- **Product form label cleanup** — Tab labels text-only; section titles text-only via optional `FormSectionCard.icon`.
- **FormSectionCard** — `icon` optional; title uses primary color without icon.
- **Input decoration (filled denser)** — Light/dark theme: fill `surfaceContainerLow` / `darkInputFill`, denser padding (14×12), error borders, **teal focus** (not accent orange).
- **ProductTextField** — wrapper over `AppTextField` (`showIcon` default false); customer form uses `AppTextField`.
- **Stock quantity entry** — Create-flow `showStockDialog` is a bottom sheet + AppTextField (inline stepper unchanged).
- **Option groups editor** — Bottom sheets for add/edit; FormSectionCard; `showConfirmationDialog` for delete.
- **DetailHeader** — `onToggleActive` optional (hidden when null); `onMenu` optional.
- **Product form tests** — Tab order/labels, price insights, stock status/value, barcode live strip, menu delete, invalid-tab reveal (**45+** form page tests).
- **ProductSearchBar (list)** — White search surface on teal app bar; sticky query display + clear; scan uses settings + single-shot; exact barcode opens preview.
- **ProductState filtering** — `filteredProducts(lowStockThreshold:)` and `productsMatchingQuery` for list trust vs search isolation.
- **PreviewCard & DetailHeader extensions** — optional `trailing` on PreviewCard/SectionHeader for expand/collapse support.
- **Test fixes** — `CategoryField` test updated to expect `keyboard_arrow_down_outlined` icon (matching actual code); `GeneralAppearanceTiles` test updated to expect 2 ListTiles + 1 Switch (compact cart tile removed in earlier refactor); stock/preview tests tolerate missing SettingsCubit (threshold default 5).
- **Dependencies Updated (Phase A)** — Updated 8 safe dependencies with no breaking changes: audioplayers 6.2.0→6.8.1, equatable 2.0.7→2.1.0, image 4.0.0→4.9.1, image_picker 1.2.2→1.2.3, path_provider 2.1.5→2.1.6, pdf 3.11.3→3.13.0, printing 5.14.1→5.15.0, build_runner 2.4.15→2.15.1. All 1,404 tests passing.
- **Removed `drift_flutter`** — Replaced with manual `LazyDatabase` setup for SQLCipher compatibility.
- **Removed `sqlite3_flutter_libs` from dependencies** — Moved to `dev_dependencies` for test-only usage; production builds use `sqlcipher_flutter_libs` exclusively.
- **CartState refactor** — migrated from `double` to `Money` value object for all monetary calculations (itemsSubtotal, cartDiscountAmount, total, serviceChargeAmount, grandTotal); updated all presentation widgets (CartDottedLineRow, cart_review_page, cart_bottom_bar, cart_summary_footer, cart_total_bar, compact_cart_fab).
- **Money migration across 14 entities** — `Product` (price, cost, profit), `Sale` (subtotal, discount, tax, serviceCharge, grandTotal, paidAmount, changeAmount), `CartState` (all monetary fields), `DraftCart` (subtotal, discount, serviceCharge, grandTotal), `CartItem` (price, itemDiscount, subtotal), `Customer` (totalSpent), `Promotion` (discountValue, maxDiscount, minPurchase), `DailyClose` (totalSales, totalCash, totalPromptpay, totalOther, expenses, finalCash).
- **AdjustStock usecase** — refactored from direct database access to repository pattern, removes Drift dependency from domain layer.
- **InventoryLogLocalDatasource** — added `insertLog`, `watchLogsByProduct`, `getLogsByDateRange` methods for repository support; kept legacy `watchLogs` for backward compatibility.
- **CI Pipeline** — Added integration test step for E2E test execution; analyzer artifacts captured for debugging.
- **ProductListPage** — full refactor: removed old search toggle, integrated `ProductSearchBar`, `ProductStatsRow`, `ProductFilterTabs`, and `ProductBottomBar`; view mode toggle (list/grid) now always visible on all tabs; `CustomScrollView` uses new widgets.
- **ProductStatsRow** — changed from subtle tinted backgrounds to solid colored card backgrounds matching design.
- **ProductFilterTabs** — changed from `SegmentedButton` to underline tab bar with sort dropdown.
- **RichProductListTile** — changed from bordered outline card to shadow card with cleaner layout (name + price same row, consolidated subtitle); removed `IgnorePointer` on inactive products so they can be tapped to open preview; `Opacity(0.55)` visual dimming retained.
- **ProductSearchBar** — changed fill color from `surfaceContainerHigh` to `surfaceContainerLow` for lighter appearance.
- **ProductSliverContent** — uses `RichProductListTile` and `RichProductGridCard` instead of `ModernProductTile`.
- **ProductNavigation** — added `showProductOptionsMenu` modal bottom sheet with Edit and Preview actions.
- **ProductPreviewPage** — refactored from `CustomScrollView` with inline cards to `NestedScrollView` with `TabBar` + `TabBarView` (4 tabs); bottom action bar secondary button label changed from "Stock" to "Adjust Stock"; tab labels enlarged with `FittedBox` and icons; passes `sl<WatchInventoryLogs>()` to `StockTab` constructor.
- **ProductPreviewPage refactor (ADR-024)** — extracted 4 subcomponent files from 955-line God File to `widgets/product_preview/`: `DetailHeader`, `SummaryCard` (+ `StatItem`, `SummaryChip`, `SellabilityStatus` in `summary_widgets.dart`), `BottomActionBar`; page reduced to ~391 lines; replaced `context.watch<SettingsCubit>()` and `context.watch<CategoryBloc>()` with `BlocSelector` for targeted rebuilds; `GenerateBarcode` and `WatchInventoryLogs` now injected via constructor params instead of `sl<>()` calls inside build methods; `showProductPreviewPage` passes `sl<>()` from the call site.
- **ImageSkeleton** — added optional `color` parameter for custom shimmer base color (defaults to `surfaceContainerHighest`).
- **ProductFormPage** — added `_descriptionCtrl` controller with listener, dispose, restore, and sync; passes `description` in both `ProductAdded` and `ProductUpdated` events.
- **ProductFormView** — added `descriptionCtrl` parameter; `_AdvancedSection` now includes multiline description field and auto-expands when description has content.
- **ProductFormCubit.syncDraftFromControllers** — added `description` parameter.
- **InfoTab** — refactored to use shared `InfoListItem` from `shared_widgets.dart`; dividers changed to faded `outlineVariant` with 0.3 alpha; category item tappable only when category exists; description right-aligned; removed empty `onTap` on category `InfoListItem`; removed fields with no data (Brand, Tax, Weight, Size) since `Product` entity has no corresponding fields.
- **StockTab** — refactored from old icon container + badge header to `InfoListItem` structure; uses `StreamBuilder` with `WatchInventoryLogs` for stock summary; `WatchInventoryLogs` now injected via constructor instead of calling `sl<>()` directly in build method (dependency inversion); `_labelForType` parameter changed from `dynamic` to `AppLocalizations` for type safety.
- **PriceTab** — refactored from `MiniStat` cards to `InfoListItem` structure with multiple `PreviewCard`s.
- **CodesCard** — refactored from `_CopyableRow` to `InfoListItem` with `trailingIcon: Icons.copy`; barcode image separated into its own `PreviewCard`; replaced raw `SnackBar` with `AppSnackBar.info()` for consistent toast styling.
- **shared_widgets.dart** — `PreviewCard` and `SectionHeader` icons made optional; title color changed to `#034554`; added `InfoListItem` widget.
- **_PreviewError** — localized hardcoded `'Retry'` text to `context.l10n.retry`.
- **_SummaryCard** — replaced `CircularProgressIndicator` loading spinner with shared `ImageSkeleton` from `core/image/` (was `_ImageShimmer`, now removed).
- **_BottomActionBar** — removed duplicate `onMove` action (was identical to `onEdit`); removed Delete button from bottom bar (Delete still accessible via ⋮ menu); bottom bar now has 2 actions (Adjust Stock, Edit); refactored to use `_buildAction` helper with `InkWell` for larger tap targets.
- **DI** — `ImportProducts` usecase registered in `BlocModule`; `MockImportProducts` added to test mocks.

### Documentation

- **New:** `docs/api/CORE_MODULES.md` — Money class, AppError system, ID generators.
- **New:** `docs/api/FEATURE_MODULES.md` — Product, Sale, Customer, Promotion module APIs.
- **New:** `docs/api/DATABASE_API.md` — Drift query patterns, transaction strategies, repository pattern.
- **New:** `docs/testing/E2E_TEST_GUIDE.md` — Comprehensive E2E test guide with Robot pattern.
- **Updated:** `docs/codebase/testing.md` — Added integration test section.
- **Updated:** `docs/DATABASE.md` — SQLCipher encryption section, schema v22-v24 migrations.
- **Updated:** `docs/database/schema-reference.md` — Product description field, conditional barcode index, performance indexes.
- **Updated:** `docs/database/migration-and-ops.md` — v22-v24 migration details, barcode deduplication strategy.
- **Updated:** `CONTRIBUTING.md` — Performance guidelines (checklist, benchmarks, query patterns), E2E test requirements (Robot pattern, coverage checklist), target metrics.
- **Updated:** `.gitignore` — Added `lib/core/database/database_opener.dart` to exclude generated encryption setup.

### Removed

- **Product form wizard widgets** — `product_form_stepper.dart`, `product_form_basic_step.dart`, `product_form_inventory_step.dart`, `product_form_advanced_step.dart`, `product_form_preview_card.dart` (replaced by flattened `ProductFormView` + `ProductFormHeroCard`).
- `drift_flutter` dependency (0.2.4) — replaced with manual `LazyDatabase` setup for SQLCipher compatibility.
- `sqlite3_flutter_libs` from main dependencies — moved to `dev_dependencies` for test-only usage (production uses `sqlcipher_flutter_libs`).
- `system_info_card.dart` — dead code (was not imported anywhere).
- `price_card.dart` and `stock_card.dart` — replaced by tab-based `InfoListItem` structure in `InfoTab`, `StockTab`, and `PriceTab`.
- `system_info_card_test.dart`, `price_card_test.dart`, `stock_card_test.dart` — stale test files referencing deleted widgets.
- iOS camera usage description keys — removed obsolete `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription` from `ios/Runner/Info.plist` (now handled by permission_handler).
- `_ImageShimmer` — private widget in `product_preview_page.dart`; replaced by shared `ImageSkeleton` from `core/image/`.
- `_formatCompact` — private method in `product_preview_page.dart`; replaced by `CurrencyFormatter.formatCompactWithSymbol`.
- Inline subcomponents from `product_preview_page.dart` — `_DetailHeader`, `_SummaryCard`, `_StatItem`, `_Chip`, `_SellabilityStatus`, `_BottomActionBar` extracted to public files in `widgets/product_preview/`.

### Fixed

- **Product form unsaved dialog** — Exit uses "Don't save" / "ไม่บันทึก" (not "Discard Draft"); edit vs create messages; discard on create clears draft; clearer restore-draft dialog.
- **Product form save validation with tabs** — Failed validate jumps to first invalid tab (name → Info, price/cost → Price, barcode → Codes) and re-validates so errors are visible.
- **Category clear on product form** — User clear is not overwritten by category lookup; empty-id “none” → null on submit.
- **SQLCipher class collision (critical)** — `sqlite3_flutter_libs` and `sqlcipher_flutter_libs` both provide `sqlite3.dart` classes; moved `sqlite3_flutter_libs` to `dev_dependencies` and use `sqlcipher_flutter_libs` in production builds only.
- **Inactive product tiles not tappable** — removed `IgnorePointer` wrapper; inactive products now tappable to open preview with visual dimming retained.
- **Delete button duplicate** — removed Delete button from preview bottom bar (still accessible via ⋮ menu to prevent accidental deletion).
- **StockTab DI violation** — `WatchInventoryLogs` now injected via constructor instead of direct `sl<>()` call in build method.
- **confirmDeleteProduct bug (critical)** — `Navigator.pop(context, false)` on confirm changed to `true`; added `popOnConfirm` parameter so callers can control post-delete navigation (preview page pops itself after delete).
- **ProductPreviewPage DI violation** — `sl<GenerateBarcode>()` and `sl<WatchInventoryLogs>()` removed from build method; now passed via constructor from `showProductPreviewPage` call site.
- **ProductPreviewPage rebuild scope** — `context.watch` caused full page rebuild on any Settings or Category state change; replaced with `BlocSelector` to rebuild only when `currency` or matching `Category` changes.
- **_formatCompact duplication** — removed local `_formatCompact` method; replaced with shared `CurrencyFormatter.formatCompactWithSymbol`.
- **Type safety** — `_labelForType` parameter changed from `dynamic` to `AppLocalizations`.
- **Localization** — Hardcoded `'Retry'` text replaced with `context.l10n.retry`.
- **Loading UX** — Preview page shimmer animation matches `ProductPreviewImage` style; no more inconsistent `CircularProgressIndicator`.
- **Empty state fields** — Hidden fields (Brand, Tax, Weight, Size) that have no corresponding `Product` entity properties.
- **Money precision** — Floating-point errors eliminated with `Money` value object (e.g., 0.1 + 0.2 now correctly equals 0.3).
- **Sale delivery cart flow** — Cart review now receives the shared checkout and draft providers; successful checkout clears the cart and resets checkout state; cart review supports stock-aware quantity changes, line discounts, notes, duplication, and clear/undo actions, with a constrained responsive layout and labeled controls.

### Security

- **Full-database encryption (Phase 2a)** — SQLCipher AES-256-CBC encryption protects all data at rest with transparent migration from plain SQLite; encryption key stored in iOS Keychain / Android Keystore (hardware-backed on supported devices); never written to disk in plain text.
- **Runtime data integrity** — Barcode uniqueness validation prevents duplicate barcodes across active products; product delete guard checks foreign key references before deletion.
- **Zero critical CVEs** — All 169 dependencies scanned; no critical vulnerabilities found; Phase B (major version upgrades) documented for Drift and sqlite3_flutter_libs.
- **Backup encryption default on** — Missing `backupEncryptionEnabled` key now defaults to **on** (aligned with `BackupConfig`); PIN min length 6 for new encrypted exports.
- **Crash log PII** — Sanitized on write (not only export).
- **Image path sandbox** — Delete only under app `images/` directory.

### Breaking / migration

- **Schema auto-upgrade to v26** — v25 product brand/unit/supplier/`is_recommended`; v26 unique `daily_closes(close_date)` with dedupe.
- **SQLCipher key loss** — Losing the device secure-storage key (or uninstall without backup) makes the local DB unrecoverable. There is **no** key recovery in 0.9.0.
- **Backup encryption default** — New installs / missing settings key enable encryption; existing stored false remains false.

### Known limitations

- **In-app backup restore** is deferred (export + share works; restore = manual file replace / offline decrypt). Target 0.9.1+.
- **No SQLCipher key recovery / multi-device key export** (Phase 2b).
- **Money storage** remains SQLite `REAL` baht on disk; domain math uses integer satang via `Money` VO (Phase M INTEGER columns deferred).
- **CI** integration tests may be non-blocking (`continue-on-error`); unit + analyze are the gate.

---

## [0.8.9] — 2026-07-06

Restaurant operations, customer & promotion management, home dashboard redesign, navbar floating center button, product modifiers/options, report/history merge.

### Added

- **Restaurant mode** — `BusinessType` toggle (retail/restaurant) in Settings; `OrderTypeSelector` (dine-in/takeaway/delivery) + `OrderChannelSelector` (walk-in/phone/online) in checkout; configurable service charge.
- **Table management** — `RestaurantTable` entity with `TableBloc`, floor plan UI with zone grouping and status indicators; table selector in checkout when dine-in.
- **Product modifiers/options** — `ProductOptionGroup` + `ProductOption` entities with full CRUD; `OptionGroupsEditor` in product form; `ProductOptionSheet` bottom sheet for cart; price delta in subtotal.
- **Customer management** — `Customer` entity, `CustomerBloc`, list/form pages with search, stats, and validation.
- **Promotion management** — `Promotion` entity (`PromotionType` enum), `PromotionBloc`, list/form pages with `SegmentedButton` type selector and date pickers.
- **Home dashboard** — `HomeHeader`, `HomeHeroDashboardCard` (revenue + sparkline), `HomeStatsRow`, `HomeMenuGrid` (6 buttons), `HomePromotionBanner` (gradient + floating animated image).
- **Navbar floating center button** — diamond-shaped Sale button rising above bar with bounce animation; `RepaintBoundary` on regular items.
- **Report/History merge** — `HistoryTabView` as sub-tab in `ReportPage` with `TabBar`.
- **Schema v20→v21** — `customers`, `promotions`, `RestaurantTables`, `ProductOptionGroups`, `ProductOptions` tables; `customerId`, `promotionId`, `promotionDiscountAmount`, `order_type`, `order_channel`, `external_order_ref`, `table_id`, `service_charge_rate`, `service_charge_amount` columns on `sales`/`draft_carts`.
- **Sale integration** — customer, promotion, restaurant, and option fields threaded through `CartState`, `CheckoutBloc`, `CreateSale`, repositories, and datasources.
- **L10n** — 90+ new keys (EN + TH) for restaurant, home, customer, promotion, and navbar.
- **Tests** — unit tests for `Customer`, `Promotion`, product options, table bloc, cart options, and restaurant cart state.

### Changed

- Navbar tab order: Home(0), Product(1), Sale(2), Report(3), Setting(4).
- `HomePromotionBanner` → `StatefulWidget` with `Stack` layout, `LinearGradient` (`#157E83`→`#085F65`), `headlineSmall` title, faded subtitle.
- `HomeStatsRow` — compact k/M formatting for values ≥ 1,000.
- `HomeHeader` — greeting fallback to "ร้านค้าของฉัน" when shop name empty.
- `HomePage` — merged duplicate `FutureBuilder`s, cached bloc refs, added error handling, removed unused `yesterdayRevenue` query.
- `AppBottomNavigationBar` — solid surface + shadow replaces `BackdropFilter` blur; center button moved to `Positioned` in `Stack` to prevent overflow.
- `CheckoutBody` — restaurant-specific fields conditionally rendered when `isRestaurantMode`.
- `CartItem` — added `lineId` for targeting specific cart lines; `CartProductRemoved`/`CartItemQtyChanged` use `lineId` when available.
- `ProductLocalDatasourceImpl.watchAllProducts` — loads option groups via `asyncMap` for all products on sale page.

### Removed

- `HistoryPage` from navbar (merged into `ReportPage`).
- `BackdropFilter` blur, `yesterdayRevenue` field/query, `dart:ui` import.

---

## [0.8.8] - 2026-06-29

Sale page redesign + cart UI overhaul + barcode scanner upgrade + product form hardening + filter/payment/cart fixes + product preview enrichment.

### Highlights

- **Sale Page Redesign** — `SaleDashboardHeader` (compact `FittedBox` row); `SaleFilterBar` with 3 dropdown filters (Category/Sort/Stock); `SaleProductCard` delivery-style with `ProductCardShell` (grid: full-width images, list: 72×72 rounded-rect); `StockIndicator` + price pills; search moved to AppBar toggle; list/grid `SegmentedButton`.
- **Cart UI Overhaul** — `CartContent` unified widget (expanded + sheet modes); delivery-style `CartBottomBar` (badge bounce, pull-up gesture, velocity snap); compact `CartItemTile` (~48px, 3-column); item note/SKU/stock in tiles; clear cart buttons; cart state persistence via `DraftBloc`.
- **Barcode Scanner Upgrade** — Continuous scan (default ON); product name + price overlay; responsive cutout; camera focus button; scan count indicator; portrait lock; alphanumeric validation; `SoundPlayer` confirmation.
- **Product Form Hardening** — Barcode → Basic section; `_AdvancedSection` auto-expand; `TextEditingController` disposal fix (11 dialogs → `StatefulWidget`); image/barcode orphan prevention (Bugs A–D); stale stock + double-submit fixes.
- **Filter/Payment/Cart Fixes** — `_CategorySelector` + reactive count + price validation; removed duplicate note/PromptPay reference; cash input `onChanged` fix; localized `cartEmpty`/`saleTimeout`; cart review empty state + `Material` bottom card; `CartProductDetailSheet` with qty/subtotal/discount/note/stock status.

### Added

- `CartContent`, `CartBottomBar`, `cart_checkout_helper.dart`, `_CategorySelector`, `_StockStatusRow`, `MoneyDetailRow`, `_DashedBorder` widgets.
- `CartItem.note` + `CartItemNoteChanged` event (schema v19); SKU/barcode + stock remaining + duplicate item in `CartItemTile`.
- Continuous scan mode, product name overlay, camera focus, scan count, `continuousScan` setting.
- `barcodeExistsAnyStatus` + `bulkUpdateBarcodesWithImages` in `ProductLocalDatasource`.
- Badge animations, haptic feedback, velocity snap, clear cart buttons, cart state persistence.
- L10n: `cartEmpty`, `saleTimeout`, `totalDiscountLabel`, `trackStockDisableConfirm`, `costHelper`, `barcodeMustBeAlphanumeric` (EN + TH).

### Changed

- `SaleProductCard` — `ProductCardShell` flat design; grid `FixedCrossAxisCount(3)`; avatar 52→40px; quantity as `จำนวน N` text.
- `PillButton` expands to fill space; `SaleCatalog` list height 76→88; `SegmentedButton` height matched.
- `CartReviewPage` — `Card` → `Material` + `boxShadow`; `CartItemCard` price `Expanded(flex: 0)`; localized strings.
- `CartProductDetailSheet` — localized + currency from `SettingsCubit`; shows qty, subtotal, discount, note, stock status.
- `CheckoutBody` — removed duplicate note; `PaymentInputSection` — removed duplicate PromptPay reference; timeout uses `saleTimeout`.
- `CartItemTile` compacted ~48px; `CartSummaryFooter` simplified; `cartCompactMode` default `true`.
- Barcode scanner: responsive cutout, portrait lock, auto-focus, laser pause on error, success 600→1000ms.
- Product form: barcode → Basic; `_AdvancedSection` auto-expand; `saveStatus` single source of truth; `_resolveStock` from bloc state.

### Fixed

- Stock filter toggle reset-to-`all` on reselect in `ProductBloc`.
- Cash input `onChanged` not updating change preview.
- `'Cart is empty'` → `cartEmpty` l10n key; `'Remove item'` → `removeItem` l10n.
- `TextEditingController` used after disposed (11 dialogs).
- Scanner orientation, invalid barcodes, `GenerateBarcode` counter init, `beepOnScan` sound, barcode case mismatch.
- Image/barcode orphan on fail (Bugs A–D); stale stock; double submit; no confirm on disable stock tracking.
- `CartBottomBar` RenderFlex overflow; `CartBottomSheet` checkout context; AppBar `endDrawer` → `CartBottomSheet`; 3 cart modes merged; `SaleCatalog` padding; `Dismissible`+`ReorderableListView` conflict; dead `onCheckout` param.

### Removed

- `sale_catalog_search_bar.dart`, `sale_catalog_category_filter.dart`, `sale_category_bar.dart`.

`flutter analyze` → **0 issues** · `flutter test` → **1302 passing**

---

## [0.8.7] - 2026-06-26

Product form unification + draft system hardening + product list dashboard redesign + tile performance optimization.

### Highlights

- **Product Form Unification** — Merged `AddProductPage` + `ProductFormPage` into single Hybrid Collapsible form; `ProductFormCubit` with typed `ProductDraft` persistence replaces raw `Map` drafts; `ExpansionTile` for advanced fields; `_VisibilitySection` card for show/hide toggle.
- **Draft System Hardening** — `Completer<void>` sync for load-before-check race; `clearDraft` resets both state + storage; restore cancels debounce (no empty re-save); empty drafts skipped on auto-save.
- **Product List Dashboard** — `StatsDashboard` redesigned with hero gradient card (total products + inventory value) and 3 mini stat cards; view toggle moved to separate row with filtered count label.
- **Tile Performance** — `BlocBuilder<CategoryBloc>` → `BlocSelector` in tiles (only changed-category tiles rebuild); `product_navigation.dart` shared helpers eliminate duplicate `_showEdit`/`_showPreview`/`_confirmDelete` across 3 files.
- **Grid Mode Parity** — `Dismissible` swipe-to-delete added to `ModernProductGridCard`; `ProductCardShell` refactored from `Card(elevation: 2)` to flat `Container` + `BoxDecoration`; `childAspectRatio` 0.75 → 0.80.

### Added

- `ProductFormCubit`, `ProductDraft`, `ProductFormState`, `ProductFormView` — typed draft system with `toJson`/`fromJson`, Equatable state, single-scroll form.
- `product_navigation.dart` — shared `showProductEditPage`, `showProductPreviewPage`, `confirmDeleteProduct`, `DeleteBackground`.
- `UnsavedDialogAction` enum; `_VisibilitySection` widget.
- L10n: `productVisibility`, `tapToAddImage`, `inventoryValue`, `totalProducts` (en + th).
- Tests: `ProductFormCubit` (8), `CategoryField` (5), `Product.copyWith` cost sentinel (3), `ProductFormPage` (5), `ProductCardShell` updated, `ProductHeroImage` updated.

### Changed

- Pinned Flutter to `3.41.4` in CI workflows.
- All add-product entry points navigate to `ProductFormPage()` instead of deleted `AddProductPage`.
- Draft key bumped `product_add_draft_v2` → `product_form_draft_v3`.
- `ProductPreviewPage._showEdit` uses shared `showProductEditPage` helper.
- `ScaffoldMessenger.showSnackBar` → `AppSnackBar.info/success/error` in `ProductPreviewPage` (5 calls).
- `_currentProduct` updates via `BlocListener` only (removed `build()` mutation).
- `StatsDashboard` receives pre-computed counts from parent (no per-build recalculation).
- `ProductCardShell` — `Card` → `Container` + `Material` + `InkWell`; `isActive` opacity handled internally.

### Fixed

- Draft data loss (`syncDraftFromControllers` sends actual form state, not `null`).
- `isClosed` guard prevents `emit` after cubit disposal.
- Cost field clearing via `Product.copyWith` sentinel pattern.
- Image URL cleared when picking new local image.
- Category race condition fallback to `widget.product!.categoryId`.
- Stale product data in `_submit` (reads latest from `ProductBloc.state`).
- Unsaved changes dialog now includes Save option.
- Stock sync on trackStock toggle restores original stock.
- Expansion state persists across rebuilds (`_AdvancedSection` as `StatefulWidget`).
- FAB moves to top-right when image present.

### Removed

- `AddProductPage`, `BasicTabView`, `AdvancedTabView`, `AddProductDraftHandler`, `ImageSourceHandler`, `AddProductDraftCubit`.
- `ProductEditTabView`, `ProductInfoTab`, `ProductPricingTab`, `ProductStockTab`, `ProductSettingsTab`.
- `category_field.dart` moved from `product_edit_tab_view/` to `product_form/`.

`flutter analyze` → **0 issues** · `flutter test` → **1294 product tests passing**

---

## [0.8.6] - 2026-06-25

NavBar overhaul + Product Preview redesign + persistent barcode images + theme polish across light/dark modes.

### Highlights

- **NavBar Overhaul** — Renamed `AnimatedNavBar` → `AppBottomNavigationBar`; long-press actions (Sale → New Draft, Product → Add Product); swipe logic extracted to `NavSwipeHelper`; `AnimatedBuilder` scoped to bouncing tab only (~96 fewer rebuilds/cycle); Semantics for VoiceOver/TalkBack; 34 new tests.
- **Product Preview Redesign** — `SliverAppBar` with collapsing hero, `ProductPreviewImage` widget (shimmer skeleton, retry, tap-to-zoom hint), `PreviewOverlay` with gradient + `StatusChip`, `StickyActionBar` with Delete + Quick Edit, per-product barcode image persistence.
- **Barcode Images** — `BarcodeImageService` renders via `RenderRepaintBoundary` (600×200, pixelRatio 3.0); persistent `barcodeImagePath` column; save as PNG/JPEG/PDF; copy SKU/barcode; generate from preview.
- **QuickEdit Upgrade** — Real-time validation, Save disabled when invalid/unchanged, stock Set/Adjust dual-mode with live preview, SnackBar feedback for all actions, 9 new l10n keys.
- **Theme Polish** — Light theme: secondary → slate gray `#475569`, fixed token collisions, WCAG AA contrast; dark mode: surfaceContainer tokens, theme-aware scrim/alpha; system-wide `colorScheme.secondary` replaces `onSurface.withValues(alpha:)` (33 widgets).
- **Category Management** — `category_icon_data.dart` single source of truth; app bars moved to `widgets/category/`; real-time search; Semantics; 13 new tests.

### Added

- `AppBottomNavigationBar`: long-press → New Draft / Add Product; `Semantics(button, label, selected)` per tab.
- `NavSwipeHelper.handleSwipe()` — shared swipe logic for shell + nav bar.
- `ProductPreviewImage` widget: shimmer skeleton (200ms delay), error + retry, tap-to-zoom hint (once per session), `hasImage(Product)` static method, full-resolution (no `ResizeImage`).
- `PreviewOverlay`: gradient + `StatusChip`; no-image mode uses `black 0.45` gradient.
- `StickyActionBar`: Delete (confirm dialog) + Quick Edit Price actions.
- `BarcodeImageService.generate()`: `BarcodeWidget` off-screen render, PNG/JPEG/PDF export via share sheet.
- `Product.barcodeImagePath` + `barcodeImagePath` DB column; auto-generated on add/update.
- `CodesCard`: copy icon for SKU + barcode; "Generate barcode" button when no barcode exists.
- `ProductInfoTab`: `isGeneratingBarcode` loading state on Generate Barcode button (prevents double-tap).
- `category_icon_data.dart`: single source of truth for `categoryIconMap` + `parseCategoryIcon()`.
- `CategorySearchAppBar` / `CategoryBulkAppBar` (renamed from `CategoryManagement*`).
- L10n: `inStock`, `codesCardTitle`, `barcodeGenerationError`, `productNameTooLong`, `quickEditStock*`, `quickEditName/Price Saved/Cancelled/Invalid` (EN/TH).
- **Tests**: 23 NavBar + 11 regression + 28 `ProductPreviewImage` + 18 Preview UX + 13 Category + 8 Preview regression = **101 new tests**.

### Changed

- `Ean13Generator` → `@injectable` instance (was static); counter per-instance, eliminating cross-test contamination.
- `BarcodeImageService`: size 400×160 → 600×200, `pixelRatio: 3.0`; `BarcodeImageWidget` height 80 → 120px.
- `ProductBloc` error events emit l10n keys instead of raw `e.toString()`.
- `ModernProductTile`: `ProductDeleted` dispatched in `confirmDismiss` (returns `false` to prevent actual dismiss) — fixes "Dismissible still in tree" error.
- `ProductPreviewPage`: `StatelessWidget` → `StatefulWidget` with `BlocListener`; stale product reads via `_latestProduct()`.
- `SliverAppBar`: title/icons use `Color.lerp(onSurface, white, _expandRatio)` for smooth scroll transition.
- `QuickEditSheet`: validation + Save disable; stock Set/Adjust modes; `easeOutCubic` 300ms; haptic on Save.
- Dropdowns: `DropdownButton` for ≤3 options, `SettingsDropdownTile` for ≥4; haptic on all `onChanged`.
- `CategoryPickerBottomSheet` + `SettingsDropdownTile`: `elevation: 0`, `borderRadius: 28`, `enableDrag: true`.
- Light theme: `primary` `#0E7C8A` → `#0D5D6B` (WCAG AA), `secondary` → slate gray `#475569`, token collisions fixed, `inputFillColor` → `surface`.
- Dark theme: `secondary` → `#94A3B8`, `surfaceContainerLow/Medium/High` tokens added, scrim alpha 0.6 (was uncapped).
- `PreviewCard` bg → `surface`; `PriceCard` selling price box → `surface` with border; profit % → `AppColors.success`.
- 33 widgets: `onSurfaceVariant`/`onSurface.withValues(alpha:)` → `colorScheme.secondary`.

### Removed

- `hero_section.dart` + test file — replaced by `ProductPreviewImage`.
- `product_image_container.dart` — dead code, removed with its test group.
- `ProductPreviewImage.heroTag` — Hero animation was one-sided; parameter removed.
- `imageThumbnailPath` usage in preview — full image loaded directly.

### Fixed

- `_animatingIndex` not reset after bounce animation; missing `setState` in `didUpdateWidget`.
- Category Management: unnecessary `ProductBloc` rebuilds; bulk delete concurrent modification; dialog `context` use-after-dispose.
- `ProductPreviewImage`: `FlexibleSpaceBar` uses `CollapseMode.pin`; `SizedBox.expand` + `ClipRect` fills background; no-image gradient `black 0.45`.
- `Navigator.of(context, rootNavigator: true).push()` — prevents double bottom bar on preview.
- `extendBodyBehindAppBar: true` — fixes status bar bleed on preview page.
- `GenerateBarcode`: counter persisted after every retry exit (including failure).
- `BatchGenerateBarcodes`: `initCounter()` called at start to prevent drift.
- `ProductFormPage._generateBarcode()`: passes `excludeId` to prevent self-collision.
- Light theme: divider `#CBD5E1`, text contrast (`textSecondary` `#475569`, `onSurfaceVariant` `#334155`), SnackBar bg → `inverseSurface`.

`flutter analyze` → **0 issues** · `flutter test` → **1259 passing** · coverage **54.5%** (21,562 lines)

---

## [0.8.5] - 2026-06-24
 
Project quality improvements: CHANGELOG archive, generated code gitignore, dependency vulnerability scanning, and god file decomposition round 2.
 
### Highlights
 
- **CHANGELOG archive** — Versions 0.1.0–0.7.x moved to `docs/changelog/` archive files. Main `CHANGELOG.md` reduced from 1,618 → ~300 lines.
- **Generated code untracked** — `*.g.dart` and `*.config.dart` removed from git and added to `.gitignore`; `.gitattributes` marks them `linguist-generated`.
- **Dependency vulnerability scan** — CI runs `tool/check_outdated.dart` to flag direct deps behind by ≥ 1 major version. Dependabot updated; security alerts documented in `docs/DEPLOY.md`.
- **God file decomposition (Round 2)** — 20+ large widget/page files split into modular subfolders across sale, product, settings, and core widgets (Batches E–I). ADR-024 domain subfolder convention applied to all 8 feature `widgets/` directories and `lib/core/widgets/`; 71 feature files + 27 core files moved, ~134 import paths updated.
- **Documentation split** — `ARCHITECTURE.md`, `CODEBASE.md`, `DATABASE.md`, `USAGE.md`, and `README.md` each split into slim index + `docs/` sub-files.
### Added
 
- `docs/changelog/` — 7 archive files (`CHANGELOG-01x.md` through `CHANGELOG-07x.md`).
- `tool/check_outdated.dart` — exits with error if any direct dependency is behind by ≥ 1 major version.
- `.gitattributes` — `linguist-generated=true` for `*.g.dart` and `*.config.dart`.
- `.github/dependabot.yml` — `allow: dependency-type: "all"` for security + version updates.
### Changed
 
- **God file decomposition (Round 2, Batches E–I)** — `barcode_scanner_dialog`, `image_viewer_dialog`, `receipt_preview`, `cart_item_row`, `cart_header`, `sale_catalog`, `sale_expansion_tile`, `backup_settings_page`, `animated_nav_bar`, and others split into subfolder patterns. All verified `flutter analyze` 0 issues + 436 tests.
- **Earlier god files** — `cart_bottom_sheet` (667→~120), `promptpay_payment_page` (793→~410), `product_preview_page` (1,051→106), `barcode_settings_page` (748→~110), `checkout_body` (767→~391), `sale_page` (432→~230), and 10+ settings/product pages decomposed into domain subfolders.
- **ADR-024 widget folder standardization** — All feature and core `widgets/` directories reorganized into domain subfolders (`cart/`, `checkout/`, `catalog/`, `forms/`, `tiles/`, etc.). 71 feature files + 27 core files moved, test subfolder structure aligned.
- **Documentation** — `ARCHITECTURE.md`, `CODEBASE.md`, `DATABASE.md`, `USAGE.md`, `README.md` each split into slim index + sub-files under `docs/`.
- `.gitignore` / CI — `*.g.dart` and `*.config.dart` patterns added; "Dependency audit" step added to CI.
### Removed
 
- `lib/core/database/app_database.g.dart` and `lib/core/di/injection_container.config.dart` — removed from git tracking (now gitignored).
### Fixed
 
- **P0: CategoryBloc race condition** — `_startWatching()` moved after all `on<>` handler registrations to prevent dropped events.
- **P0: ReportCubit / InventoryLogCubit emit after close** — `isClosed` guard added before `emit()` in stream callbacks.
- **P1: TextEditingController leaks** — `ctrl.dispose()` added after `showDialog()` in 12 dialog methods across settings, sale, and product widgets.
- **P1: InventoryLogCubit DI scope** — Changed `@injectable` → `@lazySingleton`.
- **P2: Hardcoded English strings** — `'Save'`, `'Cancel'`, `'OK'`, `'Close'`, etc. replaced with `context.l10n.*`; 5 new l10n keys added (TH/EN).
- **P2: HistoryBloc missing DI annotation** — Added `@lazySingleton`.
- **P2: SettingsPersistenceService uncaught exception** — `_repository.save()` wrapped in try-catch with `AppLogger.error()`.
- **P2: ImagePermissionException** — Typed `ImagePermissionException` replaces fragile `e.toString().contains('PERMISSION_DENIED_*')` matching.
- **P3: Silent catch blocks + raw errors to UI** — `catch (_) {}` replaced with `AppLogger.warning()`; raw `e.toString()` errors replaced with l10n keys in `CartBloc`/`CheckoutBloc`.

`flutter analyze` → **0 issues** · `flutter test` → **1121 passing**
 
---

## [0.8.4] - 2026-06-23

Brand theme migration (Teal + Orange) + Product Preview Page — Promsell Teal (#0E7C8A) and Orange (#FF6B00) replacing green/amber across FAB, FilledButton, Chip, Progress, Switch, and SnackBar action.

### Highlights

- **Product Preview Page** — New read-only `ProductPreviewPage` with hero image + gradient overlay, price/cost/profit card, stock card with inline edit, SKU/barcode card with visual rendering (EAN13/EAN8/UPCA/Code128) and actions (view full, save PDF, print), and system info card.
- **Barcode Widget** — Added `barcode_widget` package dependency for barcode rendering on the preview page.
- **Navigation Update** — `ModernProductTile` + `ModernProductGridCard`: tap → Preview, long-press → Edit Form.
- **AppBadge + SnackBar Variants** — New `AppBadge` widget with 4 types (success/info/warning/error); `AppSnackBar` 4 variants with icons and brand colors.
- **7 New Theme Definitions** — dialog, bottomSheet, floatingActionButton, tabBar, progressIndicator, listTile, popupMenu; TextTheme now has explicit color, line-height, and letter-spacing across all 13 styles.
- **Brand Identity** — Primary changed from Green (#2E7D32) → Promsell Teal (#0E7C8A); accent from Amber → Promsell Orange (#FF6B00); `tertiary` = Orange in ColorScheme, auto-propagates to stock indicators, badges, and report cards.

### Changed

- `AppColors` — 25 color values updated (light/dark/semantic); added onTertiary, onTertiaryContainer, accentShadow, overlay constants, and skeleton colors.
- `app_theme.dart` — ColorScheme tertiary=Orange; AppBar white + Teal border 1.5px; FilledButton → Orange CTA; NavBar active pill → Teal tint; Chip selected → Orange; 11 new theme definitions for dark mode.
- `SettingsThemeExtension` — Added `activeAccent` + `activeAccentContainer` (Orange); 10 color values updated (light/dark).
- 9 settings widgets — `softAccent`/`softAccentContainer` → `activeAccent`/`activeAccentContainer` in selected/active states.
- `GreenChoiceChip` → `BrandChoiceChip`; `accentGreen` → `accentBrand` (16 references in onboarding).
- `animated_nav_bar.dart` — Active tab changed from Orange dot to `primaryContainer` (Teal tint) pill.
- `product_list_page.dart` — Search moved into AppBar; category filter → `ChoiceChip` + ShaderMask fade; body → `CustomScrollView` with slivers.
- `modern_product_tile.dart` + `modern_product_grid_card.dart` — Full redesign with avatar-first layout and category dot/label widgets.
- Replaced ~34 hardcoded `Colors.green/amber/orange/black/white` references with `AppColors` equivalents.

### Fixed

- Dark mode text invisible — root cause: shared `_textTheme` (light colors) used in dark `ThemeData`; fixed by creating separate `_darkTextTheme` with white/Slate-400 colors.
- Switch thumb inconsistency — 5 widgets had `activeThumbColor` overrides conflicting with theme track color; fixed by removing overrides and using SwitchThemeData defaults.

`flutter analyze` → **0 issues** · `flutter test` → **438 passing**

---

## [0.8.3] - 2026-06-23

CI/CD coverage gates, schema v17 barcode dedup migration, persistent crash logging, dev/prod flavor separation, barcode scanner hardening, and product/category UX fixes.

### Highlights

- **CI/CD** — Coverage threshold gate (≥30%), Codecov upload, weekly stress test workflow.
- **Database** — Schema v17 with automatic barcode deduplication migration.
- **Crash Logging** — Persistent local crash log with PII sanitization and export/clear UI.
- **Flavors** — `dev`/`prod` environment separation with Android product flavors.
- **Product UX** — AddProductPage, ProductFormPage, and CategoryManagement fixes (validators, cost field, nested Scaffold, delete confirmations, bulk delete, reorder bug).
- **Barcode Scanner** — Camera freeze fix, torch toggle, scan from gallery, manual entry improvements.

### Added

- GitHub Actions CI badge, Codecov badge, coverage threshold (≥30%), weekly stress test workflow.
- `CrashLogService` — persistent local crash logging with PII sanitization, export, and clear UI.
- `dev`/`prod` product flavors with separate entry points (`main_dev.dart`, `main_prod.dart`).
- Integration test screenshot capture + optional screenshots CI workflow.
- Barcode deduplication migration (schema v17).
- `ProductFormPage` cost field, barcode validator, generate barcode button, `PopScope` back guard.
- `AddProductPage` cost/barcode validators, `TextInputAction.done`, stock hidden when `trackStock=false`, 2-column advanced tab.
- `CategoryManagementPage` bulk delete confirmation, `CategoryFormDialog` sortOrder removed.
- `QuickEditMixin` — shared quick-edit logic for `ModernProductTile` and `ModernProductGridCard`.
- `BarcodeScannerDialog` torch toggle, scan from gallery, scan success animation, error repositioning.
- L10n: `invalidBarcode`, `stockTrackingDisabled`, `unsavedChangesTitle`, `deleteCategory`, `confirmDeleteCategory`, `bulkDeleteConfirm`, `activate`, `deactivate`.

### Changed

- `_addColumnIfNotExists` refactored to use `PRAGMA table_info` for cross-platform reliability.
- Schema version bumped v16 → v17.
- `BackupEncryptionService` moved to `lib/features/settings/data/services/`.
- `main.dart` extracted to `runPromsellApp()` for flavor entry points.
- CI/DEPLOY/README updated with flavor commands.
- `CartBloc`, `DraftBloc`, `CheckoutBloc` changed from `@injectable` to `@lazySingleton`.
- `SalePage` simplified to flat `BlocProvider.value` (removed nested `Builder`).
- `CartHeader` ultraCompact toggle merged into PopupMenu.
- `PromptPayPaymentPage` auto-confirm snackbar localized, `resizeToAvoidBottomInset: true`.
- `CheckoutBody` `listenWhen` checks `prev.status != curr.status`, `context.read` instead of `watch`, BlocListener moved to parent of BlocBuilder.
- `ProductEditTabView` inner Scaffold removed; AppBar+TabBar moved to outer `ProductFormPage`.
- `CategoryListTile` always shows product count (including 0).

### Fixed

- **CheckoutBloc shared instances (critical)** — `@injectable` factory created separate BLoC instances, causing silent checkout failure; now `@lazySingleton`.
- **SettingsPersistenceService.dispose()** — Final save was blocked by `_isDisposed` guard.
- **CrashLogService** — StackTrace now written to log entries; PromptPay PII pattern requires context prefix.
- **ShopInfoForm / CartHeader / CartItemRow / SaleProductCard** — `TextEditingController` leak in dialogs fixed.
- **DraftBloc._onRotated** — Unhandled exceptions now caught.
- **CartBottomSheet** — Checkout from compact mode no longer crashes.
- **SaleReceiptDialog** — `barrierDismissible: false` + `CartPanel` resets CheckoutBloc via `.then()`.
- **SaleCatalog** — Search result tap now adds product to cart (was no-op).
- **CompactCartFab** — Watches `SettingsCubit` for currency, long-press confirmation before exiting compact mode.
- **SaleProductCard** — Low-stock indicator uses `tertiary` color, snackbar dedup on rapid taps.
- **PromptPayPaymentPage** — No longer pops itself; CheckoutBody is single source of truth for navigation.
- **CartPanel** — `_isShowingReceipt` flag prevents duplicate receipt dialog.
- **CheckoutBody** — Processing timeout (30s), confirm button disables on tap + empty cart, receipt preview uses VAT-inclusive total, reference field clears on payment method switch, removed duplicate insufficient-cash text.
- **FAB Hero tag collision** — All FABs now have unique `heroTag` values.
- **ProductLocalDatasource** — `getProductByBarcode` no longer throws on duplicates, filters `isActive=true`.
- **CartState** — `errorNonce` field ensures repeated identical errors still fire snackbar.
- **CartBloc** — `errorMessage` cleared on `CartProductRemoved`/`CartItemQtyChanged`.
- **BarcodeScannerDialog** — Camera freeze on second scan fixed, manual entry keyboard `visiblePassword`, torch toggle, scan from gallery, scan success animation, error text repositioned, bottom panel opacity 1.0.
- **ProductImageService** — Permission requests before `ImagePicker.pickImage` with specific error messages.
- **ProductListPage** — Search result tap opens `ProductFormPage`, respects grid view mode.
- **ProductActionSheet** — Activate/deactivate labels localized.
- **ProductFormPage** — Delete dialog uses `confirmDeleteProduct(name)`, waits for BLoC before popping, `PopScope` back guard, `resizeToAvoidBottomInset` fixed, nested Scaffold removed, cost field added, barcode validator, price validator `<= 0` → `< 0`, stock hidden when `trackStock=false`, `_markDirty` moved to image success path, generate barcode button, unsaved dialog title fixed.
- **AddProductPage** — Draft restore price type cast crash fixed, draft restore price display fixed, cost/barcode validators, `TextInputAction.done`, stock hidden when `trackStock=false`, 2-column advanced tab, `CategoryBloc` crash fixed.
- **CategoryManagementPage** — Delete dialog shows category name, bulk delete confirmation, reorder merges filtered subset into full list, search hint fixed.
- **CategoryFormDialog** — sortOrder field removed (drag-to-reorder manages order).
- **QuickEditMixin** — Extracted shared quick-edit logic, eliminates ~60 lines duplication.

`flutter analyze` → **0 issues** · `flutter test` → **438 passing**

---

## [0.8.2] - 2026-06-22

SaleBloc decomposition into focused BLoCs (CartBloc, DraftBloc, CheckoutBloc), critical checkout/draft bug-hunt fixes, and barcode/receipt image fixes.

### Highlights

- **SaleBloc Decomposition** — Split into `CartBloc`, `DraftBloc`, and `CheckoutBloc`; 17 widgets/pages, DI, and test infrastructure migrated.
- **Checkout Stuck After Receipt (critical)** — `CheckoutReset` now dispatches correctly after print/share/close; cart no longer stuck in `success` state.
- **Draft Auto-Save Data Loss (high)** — Pending cart state is now actually flushed on switch/create/delete instead of being discarded.
- **Scanner Black Screen on Android 6+ (critical)** — Runtime camera permission now requested before scanning.
- **Receipt Images Missing** — Product images now embedded in receipt preview, PDF, print, and share.
- 37 new BLoC tests + 8 barcode/receipt tests added.

### Added

- `MockCartBloc`, `MockCheckoutBloc`, `MockDraftBloc`, and `pumpApp` test helper.
- `permission_handler` package for camera permission requests.
- L10n strings: `cameraPermissionDenied`, `openSettings` (TH/EN).

### Changed

- `SaleBloc` split into `CartBloc` (cart), `DraftBloc` (draft persistence), and `CheckoutBloc` (checkout/payment).
- Obsolete `sale_bloc_test.dart`, `sale_bloc_discount_test.dart`, `sale_bloc_barcode_test.dart` removed.
- `ReceiptPdfService.printReceipt`/`shareReceipt` now accept an optional `productImages` map.
- `SaleReceiptDialog.show()` is now async and fetches product images before rendering.

### Fixed

- **Receipt dialog leaves checkout stuck (critical)** — `CheckoutBloc` reference was captured after `Navigator.pop`, so `CheckoutReset` never fired; now captured before pop in all 3 receipt actions.
- **Draft auto-save discarded on switch/delete (high)** — `_flushPendingSave` now saves the pending state instead of just cancelling the timer.
- **Cart stock=0 guard missing (high)** — Added `stock <= 0` check in `CartBloc._onProductAdded`, matching the barcode-scan path.
- **DraftBloc unhandled repository errors (medium)** — Added try-catch to switch/create/delete/rename handlers.
- **Deleted products silently dropped from cart (medium)** — Now surfaced in the `stockWarning` message instead of disappearing silently.
- **Scanner double-pop (critical)** — Dialog popped twice (via callback + directly), closing the page behind it; now pops once.
- **Batch barcode counter not persisted (high)** — Counter now persisted via `SettingsRepository` after batch generation.
- **Scanner black screen on Android 6+ (critical)** — Camera permission was never requested; added permission flow + denied-state UI.
- **Receipt preview/PDF/print/share missing product images (high)** — Image fields now passed through and embedded as 28×28 thumbnails.
- **CheckoutBody test crash** — `BlocBuilder` replaces `context.select` inside `Builder` to fix a Flutter framework assertion during tests.
- Multi-barcode frame could select a `null` barcode value; EAN-13 prefix accepted invalid input without validation.

`flutter analyze` → **0 issues** · `flutter test` → **425 passing**

---

## [0.8.1] - 2026-06-22

PromptPay static QR support, AppSettings facade removal, full barcode system overhaul, and category/settings UX fixes.

### Highlights

- **Barcode System Overhaul** — Reliable scan (first-detect lock pattern), all 12 formats supported, EAN-13 generator with collision check + persistent counter, format selector, auto-open manual entry, prefix validation.
- **Category System Fixes** — Removed double filtering, fixed reactive category lookup race, added "no category" option/filter, unified picker, consistent styling, batch reorder.
- **Settings UX Overhaul** — Flattened 3-level → 2-level hierarchy, merged discount pages, rebalanced groups (Barcode moved to General).
- **AppSettings Facade Removed** — ~30 files migrated to typed `Settings` aggregate ahead of Phase 4 multi-device sync.
- **Critical Sale/Product Fixes** — Cart items no longer silently dropped on stock=0 refresh; SaleCatalog no longer disappears on empty category/loading state; draft name race fixed.
- **About App Page** — Version info, in-app Privacy Policy, and License pages.
- Static PromptPay QR support (no amount embedded) for tip/top-up use cases.

### Added

- PromptPay QR unit tests (22 tests) — EMVCo payload, formatting, CRC16, static/dynamic modes.
- Stress test seeder tooling (`tool/seed_db.dart`) for production-scale data volumes.
- EAN-13 compliant barcode generator (Luhn check digit, GS1 prefix `"200"`).
- Barcode format selector, length validation, case normalization, auto-open manual entry timer, prefix input validation with live preview.
- Batch barcode generation for products missing barcodes.
- "No category" filter chip in Sale Catalog and Product List.
- About App, Privacy Policy, and License in-app pages.

### Changed

- `buildPromptPayQrPayload` — `amount` now nullable; `null` generates a static QR.
- `AppSettings` facade removed in favor of typed `Settings` aggregate (~30 files updated).
- "Play sound on scan" relabeled to "Vibrate on scan" to match actual behavior.
- `BarcodeConfig` expanded with `enabledFormats` and `autoOpenManualDelay`.
- `Product.category` named parameter removed; `categoryId` is now the sole source of truth.
- `CategoryFilterBar` now prefers DB-stored color/icon over name-based guessing.
- `CategoryRepository.reorderCategories` batched into a single transaction.

### Fixed

- **Scan never confirms (critical)** — Debounce restart bug replaced with first-detect lock pattern.
- **Error overlay stuck (critical)** — Error text now auto-clears after 3 seconds.
- **Barcode settings not persisting (critical)** — Mapper was missing barcode keys; settings reset every restart.
- **Cart items silently removed on stock refresh (critical)** — Items now kept with clamped qty + stock warning instead of being dropped.
- **Category lookup race (critical)** — Reactive `BlocListener` replaces one-shot lookup that could fall back to a fake "Uncategorized".
- **Prefix padding bug (critical)** — EAN-13 prefixes now zero-padded to 3 digits.
- **No barcode collision check** — Generation now checks the database and retries up to 10 times.
- **Barcode counter resets on restart** — Now persisted in Settings.
- **`add()` after `close()` crash (critical)** — Inlined cart update to avoid late event dispatch on bloc close.
- **SaleCatalog disappears on empty category / during batch loading (critical)** — Early-return and loading-state bugs removed.
- **Out-of-stock products hidden** — Now shown dimmed instead of filtered out.
- **Draft name race condition** — Switched to timestamp-based unique naming.
- **Double category filtering** — Removed redundant UI-level filter.
- **Cannot remove category from product** — `showNoneOption` now enabled.
- Camera lifecycle, manual entry validation, and `SliverFillRemaining` crash fixes for the barcode scanner UI.

`flutter analyze` → **0 issues** · `flutter test` → **405 passing**

## [0.8.0] - 2026-06-12

Full barcode system (scan, manual entry, generation, settings) + image UX cleanup and orphaned file fixes.

### Highlights

- **Barcode Scanning** — `BarcodeScannerDialog` supports EAN-13/8, UPC-A/E, Code 128/39, ITF. Sale page scan auto-adds to cart; product form scan auto-fills barcode field. Manual entry fallback for slow cameras.
- **Barcode Settings** — `BarcodeSettingsPage` with scan toggle, haptic feedback toggle, auto-generate prefix, and expandable help section for non-technical staff.
- **Duplicate Barcode Prevention** — Schema v16 `UNIQUE INDEX`; app-level `DuplicateBarcodeException` with localized error; case-insensitive lookup via `lower()`.
- **AddProductPage Redesign** — 2-tab layout (Basic + Advanced) with category bottom sheet, barcode scan/generate, SKU, cost, and draft save/restore.
- **Image System Fixes** — shared `showImageSourceSheet()`, temp file lifecycle tracking, draft path validation, error handling with feedback, remove confirmation, orphaned image cleanup in Settings.
- **Category Picker UX** — bottom sheet with auto-pop selection, "None" clear option, and no more separate Save tap.

### Added

- `BarcodeScannerDialog`, `ScanOverlayPainter`, `showProductBarcodeScanner()` helper.
- `DuplicateBarcodeException`, schema v16 migration (duplicate-safe index).
- `SaleBarcodeScanned` event + `SaleBloc._onBarcodeScanned` handler.
- `BarcodeConfig` entity + `BarcodeSettingsPage` (scan toggle, beep toggle, prefix input, help section).
- `showImageSourceSheet()` shared bottom-sheet helper + `ImageSourceAction` enum.
- `ClearOrphanedImages` usecase + cache clear button in `ImageSettingsPage`.
- `ProductLocalDatasource.getProductByBarcode()`, `ProductRepository.barcodeExists()`.
- `ProductTextField.suffix` parameter.
- `AddProductPage` 2-tab layout + `AddProductDraftCubit` (save/restore/discard).
- `CategoryPickerBottomSheet` with auto-pop and `showNoneOption`.
- L10n: barcode scan/generate/settings/help keys + image pick/remove/cache keys (TH/EN).

### Changed

- `AddProductPage` — single form → 2-tab (Basic/Advanced); category picker → bottom sheet.
- `SlipScannerDialog` — uses shared `ScanOverlayPainter`.
- `SaleBloc` — added `ProductRepository` dependency; `BlocListener` for error toasts.
- `AddProduct` / `UpdateProduct` — async with `barcodeExists()` pre-check + `Validators.barcode()`.
- `ProductFormPage` / `AddProductPage` — image source sheet uses shared helper with try/catch + feedback.
- `getProductByBarcode` — case-insensitive via `p.barcode.lower().equals(lowerBarcode)`.

### Fixed

- `BarcodeScannerDialog` unused `_showError` removed.
- `CategoryPickerPage` `ProviderNotFoundException` — wrapped with `Builder` for descendant context.
- `_lookupCategory` missing `setState` — category field showed wrong initial value.
- Quick Edit rejected price `0` — clamp changed to `price >= 0`.
- `_lookupCategory` swallowed errors — narrowed catch to `ProviderNotFoundException` + logging.
- `CategoryPickerPage` required double Save tap — auto-pop on selection.
- `CategoryPickerBottomSheet` layout crash — removed conflicting `mainAxisSize: min`.
- `Validators.barcode()` dead code — now called before duplicate check.
- Barcode lookup case-sensitive — explicit `lower()` match.
- Duplicate barcode scanner code — extracted `showProductBarcodeScanner()`.
- Image temp files orphaned — `_tempImagePaths` tracked and cleaned on dispose/discard.
- Image draft paths stale — `File.existsSync()` validation on restore.
- Image pick silent failures — try/catch + `AppSnackBar.error()`.
- Image remove no confirmation — added AlertDialog before clearing.

`flutter analyze` → **0 issues** · `flutter test` → **351 passing**

## Archive

Older versions are archived by minor version:

- [v0.7.x](docs/changelog/CHANGELOG-07x.md)
- [v0.6.x](docs/changelog/CHANGELOG-06x.md)
- [v0.5.x](docs/changelog/CHANGELOG-05x.md)
- [v0.4.x](docs/changelog/CHANGELOG-04x.md)
- [v0.3.x](docs/changelog/CHANGELOG-03x.md)
- [v0.2.x](docs/changelog/CHANGELOG-02x.md)
- [v0.1.x](docs/changelog/CHANGELOG-01x.md)

---

[0.8.9]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.8...v0.8.9
[0.8.8]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.7...v0.8.8
[0.8.7]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.6...v0.8.7
[0.8.6]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.5...v0.8.6
[0.8.5]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.4...v0.8.5
[0.8.4]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.3...v0.8.4
[0.8.3]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.2...v0.8.3
[0.8.2]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.1...v0.8.2
[0.8.1]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.8.0...v0.8.1
[0.8.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.7.6...v0.8.0