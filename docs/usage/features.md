# Features & Settings — Promsell POS CE

> **Main reference:** [`docs/USAGE.md`](../USAGE.md) — installation, building, links

---

## Features walkthrough

### Home tab

- **Hero dashboard card** — Shows today's revenue with sparkline trend, flip counter animation, and cost/profit summary
- **Stats row** — Revenue, cost, and profit cards with compact k/M formatting
- **Menu grid** — 6 quick-action buttons for navigation to key features (Sale, Products, Customers, Promotions, Reports, Settings)
- **Promotion banner** — Gradient card with floating animated image for active promotions

### Sale tab

- **AppBar subtitle** — Locale-aware date/time + open bill count (e.g. "27 ก.ค. 2026 • 10:37 • บิลที่ 3"), updates every 30 seconds
1. Use the search bar or category chips to narrow the product catalog
2. Tap any product card to add it to the cart — out-of-stock products appear dimmed and cannot be tapped (unless **Allow oversell** is enabled in Settings → Stock)
3. If a product in your cart goes out of stock (e.g. stock adjusted elsewhere), a snackbar warns you with the product name; the item stays in the cart with qty clamped to available stock
4. Adjust quantity with `+` / `-` controls, or **tap the quantity number** (or long-press qty) to open a numeric keypad with stock clamping; use the line **⋯ menu** or action sheet for discount, note, duplicate, or remove (with undo)
5. **Cart layout** — Open cart from the bottom command bar (or compact FAB / current-bill chip) → full-page `CartReviewPage`. Receipt-style lines (thumb, name, options, discount badge, qty steppers, line total). Payable total is sticky and uses `SalePayableCalculator` (VAT/SC aware). Park + Pay CTAs on the cart footer
6. **Ultra-compact sale** — Settings → ultra-compact mode replaces the bottom bar with a floating cart FAB (long-press to exit compact)
7. **Apply discounts** (optional):
   - Line **⋯** / action sheet → discount, note, duplicate, remove (undo on remove)
   - Tap **Apply cart discount** below the subtotal for a bill-wide discount
   - Payment sheet shows the full breakdown: Subtotal → discounts → Total
8. **Switch drafts** (optional): tap the 🔖 bookmarks icon in the app bar to open the Drafts sheet — create new drafts, rename, search, switch between customers / tables, or delete; cart auto-saves every 1.5 s
9. Tap **Pay** on the cart (or bottom bar) → retail opens payment sheet after leaving cart review; restaurant opens full-screen `CheckoutPage`
10. Select **Cash / Transfer / Card / PromptPay**
11. For cash, use quick cash chips or enter the amount received — change is calculated automatically
12. Optionally add a sale note
13. Tap **Confirm Payment** — sale is saved; if **Auto print prompt** is on, a receipt preview dialog appears with Print / Share / Close options; closing the dialog resets the cart and creates a fresh empty draft

> **Review cart:** Bottom bar / FAB / bill strip / checkout cart icon all open `CartReviewPage` — product image zoom, row detail, +/- qty (or long-press qty keypad), line actions, live payable total. **Add items** / system back returns to the catalog; cart session stays in `CartBloc`.

Sale catalog always uses the full width; cart is never docked beside the grid.

### Products tab

- **Dashboard** — Hero gradient card at top showing total product count and inventory value (stock × cost), with 3 mini stat cards below for active, low stock, and out of stock (tap to filter)
- Toggle between **List** and **Grid** view with the segmented button below the stats
- Use category **filter chips** to narrow the catalog; combined with the search bar
- Each product shows an image avatar via `UnifiedImageWidget` — skeleton shimmer loading while fetching, consistent error placeholder with neutral dark-mode-safe colors, local file with thumbnail for small sizes, or `CachedNetworkImage` for network URLs; traffic-light **stock badge** (green > 5 / orange 1–5 / red 0); inactive products appear dimmed with strikethrough
- Swipe left on any product card (list or grid) to delete with confirmation
- Tap **Add Product** (➕ FAB) to open the product form
- Product form uses a **Hybrid Collapsible layout** (single scroll) with sticky save button:
  - **Basic fields** (always visible) — image (tap to pick from Gallery/Camera, long-press to preview, remove with confirmation), name, price, stock, category picker (bottom sheet with auto-pop selection and "None" clear option)
  - **Advanced fields** (expandable `ExpansionTile`) — barcode (scan with camera or enter manually), generate EAN-13 compliant barcode with Luhn check digit (GS1 prefix `200`, auto-padded to 3 digits, collision-checked against DB), SKU, cost, track stock toggle
  - **Show Product toggle** — dedicated visibility card, always visible in edit mode
  - Image is compressed using pure Dart (configurable max width/quality in Settings, default 800px/80%) and saved locally with a 200px thumbnail; `ImageCacheService` enforces 50MB LRU cache eviction automatically
  - Draft save/restore — unsaved changes prompt to save draft on back press; drafts validate image paths on restore
- Tap a card to **preview** the product, or long-press to **edit** — the preview page shows a hero image, price breakdown (selling price, cost, profit + margin %), stock status with inline edit button, SKU/barcode with visual barcode rendering and copy actions (copy text, view full, save as PDF/PNG/JPEG, print), a **Generate barcode** button when none exists, and system info (product ID, timestamps). Generated barcode images are persisted to `product.barcodeImagePath` and reused for view/save/print
- Tap **Manage Categories** (overflow menu ⋮) to open **Category Management** — drag & drop reordering, color + icon picker (10 colors / 21 icons), product count badges, search, and bulk delete
- Tap **Generate Missing Barcodes** (overflow menu ⋮) to batch-generate EAN-13 barcodes for all products without one — shows confirmation dialog with count, then success snackbar. Each generated barcode also creates a persisted PNG image in the app documents directory
- Search filters by name and category in real time

### History tab

- Lists all sales as receipt-like cards, newest first
- Each card shows receipt number (e.g. `260527-A1-0001`), total, timestamp, and payment method
- Tap any card to expand the per-item breakdown
- **Voided sales** display a red **VOIDED** badge, strikethrough amount, dimmed card, and a block icon
- Expanded card shows:
  - **VAT breakdown** — when `vatMode` is INCLUSIVE or EXCLUSIVE, Subtotal and VAT (with rate %) rows are shown above the total, using the VAT settings that were active at the time of sale
  - **Void Sale** button (red) — confirmation requires a **void reason**; atomically marks sale as voided, restores stock, and logs VOID_REVERSAL
  - **Print Receipt** and **Share Receipt** buttons — generates an 80 mm thermal receipt PDF with sale-time VAT values
- Use the **search bar** (appears below the app bar) to filter by receipt number, payment method, or amount
- Use the date-range picker (calendar icon) to filter history by period

### Report tab (with History sub-tab)

- **TabBar** — Report page now includes a History sub-tab for merged report + history view

- Tap the date icon or date filter chip to pick a custom range (default: last 30 days)
- **Net Revenue** card — shows revenue from completed sales only (voided sales excluded)
- **Voided Total** card — appears when voided sales exist; shows voided amount and count
- Payment method breakdown and top 5 products only count completed (non-voided) sales
- Pull down to refresh the report dashboard
- Empty states are shown when there are no sales in the selected date range

### Settings tab

The Settings root page uses a **2-level hierarchy**: section headers (General, Store & Sales, Discounts, Payments, System & Data, About) → individual pages. A **search bar** at the top filters settings across all sections in real time. A **dashboard card** shows at-a-glance badges (shop name, language, theme, backup status, PromptPay status, barcode scan status). Each tile displays a colored **status chip** showing its current state. See [Settings](#settings) below.

---

## Settings

All settings persist via `SettingsLocalDatasource` (Drift-backed typed key-value store). Locale, theme, currency, and date format apply immediately; shop info and other text fields are saved automatically.

### Root page

- **Dashboard card** — Gradient card at the top showing current shop name, language, theme, backup status (Safe/Warning/Overdue), and PromptPay status (Active/Not set)
- **Section headers** — General, Store & Sales, Discounts, Payments, System & Data, About — each lists individual setting pages directly (1 tap to reach any page)
- **Status chips** — Each tile shows a colored badge: Complete/Incomplete, Active/Not set, Safe/Warning/Overdue, or the current value (language, currency, receipt size)
- **Search** — Cross-section real-time filtering by title or subtitle across all settings pages

### General Settings

- **Summary card** — Gradient card showing current language, theme, and accessibility status as badge chips
- **Language** — Tap to open a visual dialog picker with icon-based option cards for Thai (`th`) and English (`en`) — live reload
- **Theme** — Tap to open a visual dialog picker with icon-based option cards for Light, Dark, or System — live reload
- **Accessibility mode** — Toggle "Large Text & High Contrast" (default off)
- **Reset to Defaults** — Confirmation dialog restoring `locale: th`, `themeMode: system`, `accessibilityMode: false`

### Shop Info

- **Preview card** — Live preview showing shop name, address, and phone as they will appear on receipts
- **Inline form** — All 3 fields visible and editable at once with character counters and phone auto-format (`081-234-5678`)
- **Receipt size** — `80mm` (thermal) or `A4` dropdown

### Sales Settings

| Setting | Description |
|---------|-------------|
| **Currency symbol** | Default `฿` — used in money formatting |
| **Date format** | Default `dd/MM/yyyy` — `intl` format pattern |
| **Allow oversell** | Permit selling beyond available stock (default off) |
| **Low stock threshold** | Stock count at which the product card turns red (default `5`) |
| **Enable item discount** | Show discount button on each cart item (default off) |
| **Enable cart discount** | Show bill-wide discount button below subtotal (default off) |
| **Max discount percent** | Upper limit for percentage discounts (default `0` = unlimited) |
| **Max discount amount** | Upper limit for fixed-amount discounts (default `0` = unlimited) |
| **Discount presets** | Named preset groups with type (%/฿) and quick-apply values |
| **Active discount preset** | Which preset group is active in the sale discount dialog |
| **VAT mode** | `NONE` / `INCLUSIVE` / `EXCLUSIVE` |
| **VAT rate** | Percentage (default `7.0`) |

### Receipt Settings

| Setting | Description |
|---------|-------------|
| **Receipt note** | Optional footer text on receipts |
| **Show shop info on receipt** | Toggle on/off |
| **Auto print prompt** | Ask to print receipt after sale |
| **Receipt preview style** | `thermal` / `card` / `none` |
| **Show pre-sale preview** | Show preview in PaymentPage |
| **Show post-sale preview** | Show preview in success dialog |

### PromptPay Settings

- **Preview card** — Gradient card showing configured/not-configured state with QR icon and current PromptPay ID
- **PromptPay ID** — Tap to open validation dialog: phone number (10 digits, starting with 0) or citizen ID (13 digits)
- **Info card** — Explains how PromptPay ID is used for QR code payments

### Backup Settings

- **Status card** — Gradient card showing backup status (Safe/Warning/Overdue) with last backup date
- **Backup reminder** — Switch to enable/disable; tap to open frequency picker dialog with preset chips (3/7/14/30 days) or custom input
- **Encryption** (v0.7.2+) — Toggle AES-256-GCM encryption with PIN-derived PBKDF2 key (default **on** in v0.9); PIN is never stored — forgotten PIN = unrecoverable export. Turning encryption **off** requires store PIN (if enabled) + confirmation
- **Backup Now** — Manual backup trigger (export `.db` or encrypted package) + sales/products CSV; **store PIN** when lock enabled. **(v0.9.3)** Each export includes a `.meta.json` sidecar with schema/app version, DB size, SHA-256 checksum, and encrypted flag for restore-side validation
- **Restore (same-device, v0.9.0)** — Pick a previous `.enc` or SQLCipher `.db` export and restore into the live DB. Requires this device’s SQLCipher key. **Not** for another phone or after uninstall. App restart recommended after restore; **store PIN** when lock enabled. **(v0.9.3)** Restore validates the candidate (schema tables, integrity, foreign keys) before swapping; a pre-restore backup is kept for rollback if the new DB fails to open
- **Recovery kit** (v0.9.3, **code complete — device validation pending**) — Export the SQLCipher key as a `.promkey` file wrapped with AES-256-GCM + PBKDF2 (100K iterations). Min secret length 8. Must be paired with a DB backup to restore data. Import unwraps and installs the key into platform secure storage. On-device cross-device restore (D2) is not yet tested
- **Key loss** — Uninstall / keystore wipe without an off-device export = permanent data loss

### Store PIN lock (v0.9.0)

- Required on new install (onboarding finish/skip). Settings → Store PIN lock (min **6** digits, PBKDF2); may be turned off later if the code still allows
- When enabled, PIN is required for: **void sale**, **backup export/restore**, **turn backup encryption off**, **AdjustStock**, **CSV product import**, **PromptPay ID/biller changes**. Product-form / quick-edit stock and price are **not** PIN-gated
- Session grace (~2 min); cleared when app goes to background
- Too many wrong attempts → temporary lockout **persists** across app restart

### Image Settings

| Setting | Description |
|---------|-------------|
| **Image max width** | Maximum width for product image compression in pixels (default `800`) |
| **Image quality** | JPEG quality for product images 1–100 (default `80`) |
| **Clear image cache** | Removes orphaned/unused product images to free disk space |

### Barcode Settings

| Setting | Description |
|---------|-------------|
| **Enable barcode scan** | Show/hide camera scan button on Sale page |
| **Vibrate on scan** | Haptic vibration feedback when barcode is detected |
| **Auto-generate prefix** | Numeric prefix for EAN-13 barcodes (default `200`, 1-3 digits, auto-padded to 3 digits) |
| **Generate Missing Barcodes** | Batch-generate EAN-13 barcodes for all products without one — shows count of products missing barcodes, confirmation dialog, and success message. Each product receives a persisted PNG barcode image (`/barcodes/{productId}.png`) |
| **Help section** | Expandable guide for non-technical staff on how to use barcodes |

### Draft Settings

| Setting | Description |
|---------|-------------|
| **Max drafts** | Maximum number of simultaneous draft carts (default `30`, range 5–100) |
| **Compact cart** | Reduce padding and font size in the cart panel |
| **Ultra-compact cart** | Hide unit price line and shrink avatar for maximum density |

### About App

- **App icon + name + version** — Shows app name "Promsell POS CE", version and build number (retrieved via `package_info_plus`)
- **Description** — "Offline-first mobile POS for small businesses"
- **Built with** — Tech stack summary (Flutter, Drift SQLite)
- **Contact** — Support email (mnlizard.official@gmail.com)
- **Privacy Policy** — Opens in-app `PrivacyPolicyPage` with 8 sections: Data Collection, Third-Party Services, Data Storage, Backup Encryption, Customer Data, Crash Logging, Permissions, Contact
- **Open Source License** — Opens in-app `AppLicensePage` showing full AGPL-3.0 license text (loaded from `LICENSE` file, selectable for copy)
- **Footer** — Copyright notice "© 2026 Promsell POS CE · AGPL-3.0"

---

<sub>Promsell POS Community Edition · © 2026 MN Lizard Team · AGPL-3.0</sub>
