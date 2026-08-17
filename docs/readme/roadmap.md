# Roadmap — Promsell POS CE

> **Main reference:** [`README.md`](../../README.md) — project overview, quick start, links

---

## Historical phases (completed)

- [x] **Schema + Sale Integrity Overhaul** (v0.4.0): UUID migration, 9 tables, indexes, sync-ready columns, atomic receipt numbers, inventory logs, void/refund, stock adjustments
- [x] **R3 — Cashier UX** (v0.5.0): Draft carts (multi-draft, auto-save), per-item + per-cart discounts, VAT post-discount, `trackStock` per-product, `allowOversell` + low-stock threshold
- [x] **R4 — UX Polish & Accessibility** (v0.5.1): Theme accessibility (borders, contrast, ColorScheme overrides), overlay toast, cart undo, DI compile-time safety, lazy tabs
- [x] **R4 — Code Quality** (v0.5.2): Drift build optimization, page structure refactoring (private widgets → public `widgets/` subfolders across 6 features)
- [x] **R4 — VAT & Draft Cart Fixes** (v0.5.3): EXCLUSIVE VAT payment fix, receipt double-VAT fix, draft cart discount persistence, bill UX (name display, New Bill button, auto-naming)
- [x] **R4 — Discount Policy & Product Images** (v0.5.4): Merchant-configurable discount presets with clamping, receipt discount rows, product image picker with local compression
- [x] **R4 — Merchant Tools** (v0.6.0): PDF receipt print/share, PromptPay QR, backup/restore, receipt settings expansion, product image system overhaul (pure Dart compression, thumbnails, CachedNetworkImage, image cleanup, compression settings)
- [x] **R5 — Cart UX Redesign** (v0.6.1): Cart panel overhaul (search, group-by-category, multi-select, swipe, drag-to-reorder, resizable panel, compact modes), interactive checkout review (`CheckoutPage` + `CartReviewPage`), receipt preview zoom, centralized `ImageViewerDialog`, product image polish
- [x] **R5 — UX Polish & Performance** (v0.6.2): Accessibility touch targets, tooltips, focus indicators, colorblind stock badges, search clear button, delete confirmation dialogs, keyboard submit, toast tap-dismiss, `ValueNotifier` drag refactor (jank fix), VAT calculation deduplication, `useRootNavigator` fixes
- [x] **R5 — Clean Architecture & Store Prep** (v0.6.3): InventoryLog full Clean Architecture refactor, category picker, history search bar, cart direct qty input, 8 bug fixes, platform hardening (Android permissions, iOS privacy strings, release signing), store submission metadata and docs
- [x] **R5 — Settings Refactor** (v0.6.4): Sub-page navigation, auto-save, god page elimination, orphan field surfacing
- [x] **R6 — Settings UX Overhaul** (v0.7.0): Elderly-friendly redesign, gradient dashboard cards, visual dialog pickers, validation, grouped sections with status chips, accessibility mode toggle
- [x] **R7 — Operations** (v0.7.1): Daily close, onboarding wizard, DB health, compact cart mode, global theme unification
- [x] **R8 — Data Resilience & Cart Polish** (v0.7.2): Sync columns (schema v12), backup encryption, 3-level settings hierarchy, cart button animations, single-row item redesign, theme color migration
- [x] **R9 — Clean Architecture & Widget Decomposition** (v0.7.3): Settings aggregate root with 12 typed groups, `SettingsMapper`, `SettingsPersistenceService`, failure types for all features, missing Sale Use Cases, 9-page widget decomposition (16 widgets + `ReportCalculator` domain extension), 339 tests
- [x] **R10 — PromptPay System Overhaul** (v0.7.4): EMVCo QR generation, slip verification with `SlipScannerDialog`, `SlipVerifier`, `SlipErrorType`, auto-confirm after slip, configurable timeout/sound/QR-type/overlay-icon, fullscreen `PromptPayPaymentPage` with responsive layout, timer progress bar, cart summary, customizable QR overlay icon (8 choices, default none)
- [x] **R11 — Image System & Dark Mode** (v0.7.5): `UnifiedImageWidget` with skeleton loading and `ImageErrorPlaceholder`; `ImageCacheService` with LRU eviction; `ImageViewerDialog` share/info overlays; receipt preview product images; dark-mode fixes across payment, cart, cart review, and receipt preview; forest green theme migration; `AnimatedNavBar` iOS-style with swipe/keyboard shortcuts; `NotoSansThai` everywhere
- [x] **R12 — Category System Overhaul** (v0.7.6): Category color/icon picker (schema v15), drag-drop reordering, product count badges, search, bulk delete; product page category support (sale cards, catalog chips, editor); 22 system-wide bug fixes; new app icon
- [x] **R13 — Barcode System** (v0.8.0): Camera barcode scanning (EAN/UPC/Code128/Code39/ITF), manual entry fallback, auto-generation with custom prefix, duplicate prevention (schema v16), BarcodeSettingsPage with scan/beep/prefix toggles + help section for non-technical staff. Image system UX fixes: shared `showImageSourceSheet()`, temp file lifecycle, draft path validation, error handling, remove confirmation, orphaned image cleanup
- [x] **R14 — SaleBloc Decomposition & Bug Hunt** (v0.8.2): Split monolithic `SaleBloc` into `CartBloc`, `DraftBloc`, `CheckoutBloc`; receipt dialog `CheckoutReset` fix, draft auto-save flush, stock=0 guard, deleted product warning, barcode scanner double-pop fix, batch counter persistence, EAN-13 prefix validation, runtime camera permission for barcode scanner, receipt preview & PDF product images
- [x] **R15 — CI/CD, Crash Logging & UX Hardening** (v0.8.3): CI/CD coverage gates (≥30%), Codecov upload, weekly stress test workflow; `CrashLogService` with PII sanitization and export/clear UI; `dev`/`prod` product flavors with separate entry points; schema v17 barcode deduplication migration; barcode scanner hardening (torch, gallery, freeze fix); product/category UX fixes (validators, cost field, bulk delete, reorder bug, `QuickEditMixin`); 13 bug fixes across checkout/cart/settings
- [x] **R16 — Brand Theme & Product Preview** (v0.8.4): Promsell Teal (#0E7C8A) + Orange (#FF6B00) brand migration across entire app; `ProductPreviewPage` with hero image, price card (selling price, cost, profit + margin %), stock card with inline edit, visual barcode rendering (EAN13/EAN8/UPCA/Code128) with view/save PDF/print actions; navigation update (tap → preview, long-press → edit)
- [x] **R17 — Project Quality Hardening** (v0.8.5): CHANGELOG archived by minor version (`docs/changelog/`); generated code (`*.g.dart`, `*.config.dart`) removed from git tracking with `linguist-generated` attributes; dependency vulnerability scanning via `tool/check_outdated.dart` in CI + Dependabot security alerts
- [x] **R18 — NavBar + Preview + Barcode Overhaul** (v0.8.6): NavBar overhaul (`AppBottomNavigationBar` with long-press actions, `NavSwipeHelper`); Product Preview redesign (`SliverAppBar` collapsing hero, `ProductPreviewImage`, `StickyActionBar`); persistent barcode images (`BarcodeImageService` via `RenderRepaintBoundary` 600×200 @ 3x, `barcodeImagePath` column); `Ean13Generator` refactored to `@injectable` instance; theme polish (WCAG AA light theme, dark mode surfaceContainer tokens); QuickEdit upgrade (validation, Set/Adjust dual-mode); category management overhaul (`category_icon_data.dart`, search, Semantics)
- [x] **R19 — Product Form Redesign** (v0.8.7): Merged `AddProductPage` + `ProductFormPage` into unified `ProductFormPage` with Hybrid Collapsible layout (basic fields visible, advanced in `ExpansionTile`); `ProductFormCubit` with typed `ProductDraft` entity replacing raw `Map<String, dynamic>` draft; draft persistence fixes (data loss, `isClosed` guard); `TextEditingController` disposal fix (unfocus before pop, remove listeners before dispose); 31 widget + unit tests
- [x] **R20 — Sale Page Redesign + Cart UI Overhaul + Barcode Scanner Upgrade** (v0.8.8): `SaleDashboardHeader` + `SaleFilterBar` (Category/Sort/Stock dropdowns) + `SaleProductCard` delivery-style; `CartContent` unified widget + `CartBottomBar` with badge bounce/pull-up/velocity snap; continuous scan mode + product overlay; product form hardening (Bugs A–D, 11 dialog disposal fixes); filter/payment/cart page fixes + `CartProductDetailSheet` enrichment; 1302 tests passing
- [x] **R21 — Restaurant Operations + CRM + Home Dashboard + Navbar Redesign** (v0.8.9): Restaurant mode; customer & promotion CRUD; home dashboard; floating Sale nav; product options; report/history merge; schema v20–v21
- [x] **R22 — v0.9.0 trust cut**: SQLCipher; Money satang VO + payable SSOT; hard cart freeze + atomic stock; multi-tender `sale_payments` (schema **v28**); same-device backup restore; store PIN (PBKDF2, persisted lockout, stock/CSV gates); release-trust CI; privacy/store honesty; checkout failure unlocks cart

### v0.9.2 status (2026-08-17)

v0.9.2 is tagged (`v0.9.2`, `pubspec` 0.9.2). The remaining work is operator work: run release-trust/device smoke, configure production signing, and complete the Play Console submission.

Current SSOT documents:

- [POST-090 backlog](../plan/UN-COMPLETE/POST-090-MANAGE/POST-090-BACKLOG.md) — recovery-kit, QA, store, and product UX follow-up
- [ARCH-HARDEN overview](../plan/UN-COMPLETE/ARCH-HARDEN-1.0/OVERVIEW.md) — architecture gate before Play production
- [DOC-SSOT overview](../plan/UN-COMPLETE/DOC-SSOT/OVERVIEW.md) — documentation navigation and honesty work
- [V090 trust package](../plan/COMPLETE/V090-TRUST/V090-TRUST-OVERVIEW.md) — completed trust-cut evidence

| Track | Status | Next action |
|-------|--------|-------------|
| **v0.9.2 integrity** | Tagged `v0.9.2` | Operator: release-trust/device smoke + Play Console submission |
| **ARCH-HARDEN** | Core domain fence and purity work implemented | Complete AH-GATE-1 operator/CI evidence before Play |
| **Phase M** | v32 migration, satang converter, dual-write/read fallback implemented | Keep legacy REAL columns until deprecation release |
| **Phase 2b recovery** | Threat model and UX spec complete; code deferred | Implement recovery-kit export/import |
| **Tablet UX** | Dual-pane and orientation policy implemented | Capture optional tablet store screenshots |
| **Play production** | Operator-gated | Production keystore, Data safety, signed AAB, Console submit, post-smoke |

- [x] v0.9.2 — tagged `v0.9.2`; host suite green; release-trust/device smoke and Play submission remain operator gates
- [x] DOC-SSOT — current docs align with v0.9.2 behavior and limitations
- [x] ARCH-HARDEN core work — domain fence, ports, money boundary, and purity updates are in-tree
- [x] Phase M — schema v32, 32 satang columns, converter, dual-write/read fallback, migration tests
- [x] Tablet dual-pane sale and orientation policy
- [ ] Phase 2b recovery-kit export/import — D1 UX spec complete, implementation deferred
- [ ] Play Console production cut — keystore, Data safety, signed AAB, Console submit, and post-smoke

### Release timeline

```
v0.4.x → … → v0.9.0 trust cut → v0.9.1 UX → v0.9.2 integrity/hardening → POST-090 Play → 1.0
  schema …   SQLCipher+PIN     v32 satang + fence       A1–A5+B2 smoke
```

---

## Future

- [ ] **[CE]** Receipt printing via Bluetooth thermal printer — *Help wanted* (scaffold: WS-E E2)
- [x] PDF receipt export and share (v0.3.0)
- [ ] **[Pro]** Multi-shop support
- [ ] **[Pro]** Cloud backup and restore
- [x] CSV export for products and sales (v0.6.0)
- [x] Customer management (CRM CRUD) (v0.8.9) — not a full loyalty program
- [ ] **[CE]** More languages (Lao, Khmer, Burmese, Vietnamese) — *Help wanted*

---

<sub>Promsell POS Community Edition · v0.9.2 · Roadmap · AGPL-3.0</sub>
