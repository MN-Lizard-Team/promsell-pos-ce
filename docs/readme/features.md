# Features & Tech Stack — Promsell POS CE

> **Main reference:** [`README.md`](../../README.md) — project overview, quick start, links

---

## Features

| Feature | Description |
|---------|-------------|
| **Sale** | `SaleDashboardHeader` (shop name + revenue/sales/cart total), `SaleFilterBar` (Category/Sort/Stock dropdown filters), `SaleProductCard` delivery-style with `ProductCardShell` (grid: full-width images, list: 72×72 rounded-rect), `StockIndicator` + price pills, search in AppBar toggle, list/grid `SegmentedButton`. Adaptive cart: `CartBottomBar` (badge bounce, pull-up gesture, velocity snap) in compact mode; `CartContent` (expanded mode with `ReorderableListView` + `Dismissible`) in expanded mode; `CartReviewPage` with `CartProductDetailSheet` (qty/subtotal/discount/note/stock status). Multi-method checkout, quick cash chips, per-item/cart discount with preset chips, drag-to-reorder, resizable panel, compact/ultra-compact modes |
| **Draft Cart** | Auto-save every 1.5s; configurable max drafts (5–100); search + sort; count badge; auto-archive after 7 days; switch/rename/delete drafts; active draft restored on app launch; cleared on checkout |
| **Discount** | Per-item / per-cart discount (% or ฿) with live preview; merchant-configurable preset groups with quick-apply chips; max discount clamping; full payment sheet breakdown; VAT applied after discounts |
| **Products** | List/grid toggle with dashboard (hero gradient card showing total products + inventory value, 3 mini stat cards for active/low-stock/out-of-stock), **category filter chips with color/icon**, image picker (gallery/camera) with pure Dart compression + thumbnail system, `CachedNetworkImage`, configurable image quality, `_StockBadge` (traffic-light), unified add/edit form with Hybrid Collapsible layout (basic fields visible, advanced in `ExpansionTile`), `ProductFormCubit` with typed draft persistence, swipe-to-delete in both list and grid modes, active/inactive toggle, orphaned file cleanup, remove-then-cancel protection. **Barcode** — camera scan (EAN-13/8, UPC-A/E, Code 128/39, ITF, QR Code, DataMatrix, PDF417, Aztec, Codabar), manual number entry fallback with inline validation, EAN-13 compliant auto-generation with Luhn check digit (GS1 prefix `200`), duplicate prevention (schema v16 unique index), case-insensitive lookup with uppercase normalization, persisted PNG barcode images generated on add/update (schema v18), generate-from-preview button, copy barcode/SKU, save as PDF/PNG/JPEG. **Category Management** — drag-drop reordering, color + icon picker (10 colors / 21 icons), product count badges, search, bulk delete. Schema v19 |
| **Home** | `HomeHeader` (shop name + greeting + notification badge), `HomeHeroDashboardCard` (today revenue + sparkline + flip counter), `HomeStatsRow` (revenue/cost/profit with compact k/M formatting), `HomeMenuGrid` (6 quick-action buttons), `HomePromotionBanner` (gradient + floating animated image) |
| **History** | Date-ranged receipt-like sale history with expandable item breakdown, receipt numbers, VOIDED badge, VAT breakdown rows (Subtotal + VAT rate %) when VAT is active, void sale action with reason, notes, and search bar (filter by receipt number, payment method, or amount) |
| **Report** | Dashboard cards for net revenue (excludes voided), voided summary, payment method breakdown, top 5 products, date filter chip, pull-to-refresh, and empty states. **History sub-tab** (v0.8.9+): `HistoryTabView` as TabBar sub-tab in `ReportPage` |
| **Inventory** | Inventory audit log (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT), manual stock adjustment dialog with reason, and per-product log viewer |
| **Settings** | Elderly-friendly redesign with larger touch targets (48dp icons, 64dp tiles). Dashboard cards with gradient backgrounds and status badges on every page. Dialog-based visual pickers for language/theme with icon-based option cards. PromptPay ID validation (phone 10 digits / citizen ID 13 digits). Shop Info inline form with live preview and phone auto-format. Backup reminder switch + preset frequency picker (3/7/14/30 days). "Reset to Defaults" confirmation dialog. Root page dashboard with 5 summary badges and grouped sections (`Store & Business`, `Payments`, `System & Data`) with colored status chips on every tile. **v0.7.2**: 3-level hierarchy (Root → SubTopic → Page) with flattened search, backup encryption toggle, theme color tokens (`AppColors`) replacing hardcoded values. **v0.7.1**: Compact Cart Mode toggle, global theme unification (green accent `#00C853`, dark bg `#0D1117`, 16px card / 12px button radius), readability fixes for dark mode badges and icons |
| **Customer Management** (v0.8.9+) | `Customer` entity with `CustomerBloc`, list page with search + stats, form page with validation (name/phone/email) |
| **Promotion Management** (v0.8.9+) | `Promotion` entity (`PromotionType` enum: percent/fixed), `PromotionBloc`, list/form pages with `SegmentedButton` type selector and date pickers |
| **Restaurant Mode** (v0.8.9+) | `BusinessType` toggle (retail/restaurant) in Settings; `OrderTypeSelector` (dine-in/takeaway/delivery) + `OrderChannelSelector` (walk-in/phone/online) in checkout; configurable service charge; `RestaurantTable` entity with `TableBloc`, floor plan UI with zone grouping and status indicators; table selector in checkout when dine-in |
| **Product Modifiers/Options** (v0.8.9+) | `ProductOptionGroup` + `ProductOption` entities with full CRUD; `OptionGroupsEditor` in product form; `ProductOptionSheet` bottom sheet for cart; price delta in subtotal |
| **Navbar Floating Center Button** (v0.8.9+) | Diamond-shaped Sale button rising above bar with bounce animation on tab change; `RepaintBoundary` on regular items; `Positioned` overlay in `Stack` |
| **Void / Refund** | Atomic void sale flow: marks VOIDED, restores stock, logs VOID_REVERSAL; receipt number generation |
| **Receipt Preview** | On-screen preview in `thermal` (80mm paper) and `card` styles, with independent pre/post-sale toggles and `"none"` option; pinch-to-zoom full-screen dialog |
| **Receipt PDF** | Print and share receipts as PDF with Thai font support; 80mm thermal + A4 layouts; PromptPay QR on receipt; centralized `ImageViewerDialog` for product/receipt images |
| **PromptPay QR** | EMVCo-compliant QR generation for static/dynamic payments; integrated into payment sheet; configurable PromptPay ID (phone or citizen ID) |
| **Backup & Restore** | Full SQLite export/import with WAL checkpoint and schema validation; CSV export for sales & products; configurable backup reminder banner |
| **VAT** | `NONE` / `INCLUSIVE` / `EXCLUSIVE` modes with correct subtotal/VAT/total breakdown on receipts and PDFs; VAT mode and rate are snapshotted at sale time and used for accurate historical reprints |
| **Offline-first** | All data stored locally in SQLite via Drift — no internet required |
| **Material 3** | Merchant Command Deck refresh with shared theme tokens and responsive UI primitives |

---

## Tech stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.x · Dart 3.11+ |
| **State management** | flutter_bloc (BLoC + Cubit pattern) |
| **Database** | Drift (SQLite ORM) with code generation — 12 tables, UUID PKs |
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

<sub>Promsell POS Community Edition · v0.8.9 · AGPL-3.0</sub>
