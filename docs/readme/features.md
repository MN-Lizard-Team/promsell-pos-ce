# Features & Tech Stack — Promsell POS CE

> **Main reference:** [`README.md`](../../README.md) — project overview, quick start, links
>
> Capability index for README. Cashier walkthrough and settings live in [`docs/usage/features.md`](../usage/features.md). Do not duplicate step-by-step sale/settings here.

---

## Features

| Feature | Description |
|---------|-------------|
| **Sale** | Catalog + full-page cart review (`CartReviewPage`); `paymentLocked` freeze on confirm; multi-tender + PromptPay; payable SSOT (`SalePayableCalculator` / Money satang). Park/saved bills, per-item & cart discount, day-closed banner, and adaptive tablet `SaleDualPane` with docked cart. Checkout failure unlocks cart without clearing lines |
| **Draft Cart** | Auto-save every 1.5s; configurable max drafts (5–100); search + sort; count badge; auto-archive after 7 days; switch/rename/delete drafts; active draft restored on app launch; cleared on checkout |
| **Discount** | Per-item / per-cart discount (% or ฿) with live preview; merchant-configurable preset groups with quick-apply chips; max discount clamping; full payment sheet breakdown; VAT applied after discounts |
| **Products** | List/grid toggle with dashboard (hero gradient card showing total products + inventory value, 3 mini stat cards for active/low-stock/out-of-stock), **category filter chips with color/icon**, image picker (gallery/camera) with pure Dart compression + thumbnail system, `CachedNetworkImage`, configurable image quality, `_StockBadge` (traffic-light), unified add/edit form with Hybrid Collapsible layout (basic fields visible, advanced in `ExpansionTile`), `ProductFormCubit` with typed draft persistence, swipe-to-delete in both list and grid modes, active/inactive toggle, orphaned file cleanup, remove-then-cancel protection. **Barcode** — camera scan (EAN-13/8, UPC-A/E, Code 128/39, ITF, QR Code, DataMatrix, PDF417, Aztec, Codabar), manual number entry fallback with inline validation, EAN-13 compliant auto-generation with Luhn check digit (GS1 prefix `200`), duplicate prevention, case-insensitive lookup, persisted barcode images, generate-from-preview button, copy barcode/SKU, save as PDF/PNG/JPEG. **Category Management** — drag-drop reordering, color + icon picker (10 colors / 21 icons), product count badges, search, bulk delete. Schema v32 |
| **Home** | `HomeHeader` (shop name + greeting + notification badge), `HomeHeroDashboardCard` (today revenue + sparkline + flip counter), `HomeStatsRow` (revenue/cost/profit with compact k/M formatting), `HomeMenuGrid` (6 quick-action buttons), `HomePromotionBanner` (gradient + floating animated image) |
| **History** | Date-ranged receipt-like sale history with expandable item breakdown, receipt numbers, VOIDED badge, VAT breakdown rows (Subtotal + VAT rate %) when VAT is active, void sale action with reason, notes, and search bar (filter by receipt number, payment method, or amount) |
| **Report** | Dashboard cards for net revenue (excludes voided), voided summary, payment method breakdown, top 5 products, date filter chip, pull-to-refresh, and empty states. **History sub-tab** (v0.8.9+): `HistoryTabView` as TabBar sub-tab in `ReportPage` |
| **Inventory** | Audit log (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT); manual stock adjust sheet with reason — **store PIN** on AdjustStock + CSV when lock enabled (product form / quick-edit are not PIN-gated); per-product log viewer |
| **Settings** | Elderly-friendly redesign with larger touch targets (48dp icons, 64dp tiles). Dashboard cards with gradient backgrounds and status badges on every page. Dialog-based visual pickers for language/theme with icon-based option cards. PromptPay ID validation (phone 10 digits / citizen ID 13 digits). Shop Info inline form with live preview and phone auto-format. Backup reminder switch + preset frequency picker (3/7/14/30 days). "Reset to Defaults" confirmation dialog. Root page dashboard with 5 summary badges and grouped sections (`Store & Business`, `Payments`, `System & Data`) with colored status chips on every tile. **v0.7.2**: 3-level hierarchy (Root → SubTopic → Page) with flattened search, backup encryption toggle, theme color tokens (`AppColors`) replacing hardcoded values. **v0.7.1**: Compact Cart Mode toggle, global theme unification (green accent `#00C853`, dark bg `#0D1117`, 16px card / 12px button radius), readability fixes for dark mode badges and icons |
| **Customer Management** (v0.8.9+) | `Customer` entity with `CustomerBloc`, list page with search + stats, form page with validation (name/phone/email) |
| **Promotion Management** (v0.8.9+) | `Promotion` entity (`PromotionType` enum: percent/fixed), `PromotionBloc`, list/form pages with `SegmentedButton` type selector and date pickers |
| **Restaurant Mode** (v0.8.9+) | `BusinessType` toggle (retail/restaurant) in Settings; `OrderTypeSelector` (dine-in/takeaway/delivery) + `OrderChannelSelector` (walk-in/phone/online) in checkout; configurable service charge; `RestaurantTable` entity with `TableBloc`, floor plan UI with zone grouping and status indicators; table selector in checkout when dine-in |
| **Product Modifiers/Options** (v0.8.9+) | `ProductOptionGroup` + `ProductOption` entities with full CRUD; `OptionGroupsEditor` in product form; `ProductOptionSheet` bottom sheet for cart; price delta in subtotal |
| **Navbar Floating Center Button** (v0.8.9+) | Diamond-shaped Sale button rising above bar with bounce animation on tab change; `RepaintBoundary` on regular items; `Positioned` overlay in `Stack` |
| **Void sale** | Same-sale void only: mark VOIDED, restore stock, log `VOID_REVERSAL`, keep original receipt number. No partial refund, no refund-to-tender, no credit note |
| **Receipt Preview** | On-screen preview in `thermal` (80mm paper) and `card` styles, with independent pre/post-sale toggles and `"none"` option; pinch-to-zoom full-screen dialog |
| **Receipt PDF** | Print and share receipts as PDF with Thai font support; **80mm thermal or A4** via settings `receiptSize`; logo / PromptPay-on-receipt / barcode planned; totals from **stored sale fields** (SC, promo, VAT); VOID watermark on voided sales; **sale receipt ≠ tax invoice** disclaimer; centralized `ImageViewerDialog` for product images |
| **PromptPay QR** | EMVCo-compliant QR generation for static/dynamic payments; integrated into payment sheet; configurable PromptPay ID (phone or citizen ID) |
| **Backup export / restore** | WAL checkpoint → DB copy → AES-GCM (PIN ≥ 6, default **on**) + share; CSV export; reminder. **Same-device in-app restore** of `.enc` / SQLCipher `.db`. Cross-device / after uninstall **not** supported. Schema **v32**; recovery-kit export/import remains Phase 2b |
| **Store PIN lock** | Store PIN setup is offered on onboarding (min 6, PBKDF2) with explicit risk confirmation for skip/disable. When enabled, it gates void, backup export/restore, AdjustStock, CSV import, PromptPay, encryption-off, report export, and day-close/settings actions. Lockout persists across cold start; session clears on background |
| **CSV product import** | Full-page import with template; store PIN when lock enabled |
| **VAT** | `NONE` / `INCLUSIVE` / `EXCLUSIVE`; snapshotted at sale time for reprints |
| **Offline-first** | Local Drift/SQLCipher — core POS needs no internet |
| **Material 3** | Shared theme tokens and responsive UI primitives |

---

## Tech stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x · Dart 3.11+ |
| **State management** | flutter_bloc (BLoC + Cubit pattern) |
| **Database** | Drift + **SQLCipher** — **16 tables**, schema **v32** (`sale_payments` multi-tender + 32 satang columns), UUID PKs; satang-first reads with legacy REAL baht compatibility |
| **DI** | injectable + get_it (compile-time safe) |
| **Routing** | Navigator + lazy-loaded tabs |
| **Persistence** | SettingsLocalDatasource (Drift-backed typed key-value store); Drift tables for receipt sequences |
| **Localization** | flutter_localizations + Flutter ARB intl |
| **PDF / Print** | pdf + printing |
| **Barcode / QR** | mobile_scanner (product scan + checkout) + qr_flutter (PromptPay EMVCo) + barcode_widget (EAN-13 visual rendering + off-screen image generation) |
| **Share / Export** | share_plus + file_picker + csv |
| **Image handling** | image_picker + image (pure Dart compression) + cached_network_image (gallery/camera → local JPEG + thumbnails, configurable quality, orphaned cleanup) |
| **Design** | Material 3, NotoSansThai (bundled local fonts), shared UI primitives |

---

<sub>Promsell POS Community Edition · v0.9.2 · AGPL-3.0</sub>
