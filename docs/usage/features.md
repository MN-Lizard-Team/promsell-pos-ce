# Features & Settings — Promsell POS CE

> **Main reference:** [`docs/USAGE.md`](../USAGE.md) — installation, building, links

---

## Features walkthrough

### Sale tab

1. Use the search bar or category chips to narrow the product catalog
2. Tap any product card to add it to the cart — out-of-stock products appear dimmed and cannot be tapped (unless **Allow oversell** is enabled in Settings → Stock)
3. If a product in your cart goes out of stock (e.g. stock adjusted elsewhere), a snackbar warns you with the product name; the item stays in the cart with qty clamped to available stock
4. Adjust quantity with `+` / `-` controls, or **tap the quantity number** to open a numeric input dialog with stock info and clamping; long-press a cart item to enter **multi-select mode** for bulk delete or clear discount
5. **Cart layout** — Items display in a single-row 3-zone layout (product info | stepper | price). Swipe right to delete (with undo), swipe left to increment quantity, and long-press to drag-and-reorder items. Discount chips appear inline with the price
6. **Compact modes** — Tap the density toggle button in the cart header to switch between Normal ↔ Ultra-Compact layouts
7. **Resizable panel** — Drag the handle between the catalog and cart to resize the panel, or use the size slider in the cart header for Small/Large presets
8. **Apply discounts** (optional):
   - Tap the 🏷️ tag icon on any cart item → choose **%** or **฿**, enter value, tap Apply
   - Tap **Apply cart discount** below the subtotal for a bill-wide discount
   - Payment sheet shows the full breakdown: Subtotal → discounts → Total
9. **Switch drafts** (optional): tap the 🔖 bookmarks icon in the app bar to open the Drafts sheet — create new drafts, rename, search, switch between customers / tables, or delete; cart auto-saves every 1.5 s
10. Tap **Checkout** → full-screen `CheckoutPage` opens
11. Select **Cash / Transfer / Card / PromptPay**
12. For cash, use quick cash chips or enter the amount received — change is calculated automatically
13. Optionally add a sale note
14. Tap **Confirm Payment** — sale is saved; if **Auto print prompt** is on, a receipt preview dialog appears with Print / Share / Close options; closing the dialog resets the cart and creates a fresh empty draft

> **Review cart before checkout:** Tap the 🛒 cart icon with the item-count badge in the app bar to open `CartReviewPage` — tap a product image for zoom (with share and info buttons in the viewer toolbar), tap a row for product detail, use +/- to adjust quantities, or delete items with undo. The total updates live on every change.

On compact phones, the cart appears as a bottom command panel. On tablet or expanded width layouts, the cart remains visible beside the product grid.

### Products tab

- Toggle between **List** and **Grid** view with the icon pair in the app bar
- Use category **filter chips** to narrow the catalog; combined with the search bar
- Each product shows an image avatar via `UnifiedImageWidget` — skeleton shimmer loading while fetching, consistent error placeholder with neutral dark-mode-safe colors, local file with thumbnail for small sizes, or `CachedNetworkImage` for network URLs; traffic-light **stock badge** (green > 5 / orange 1–5 / red 0); inactive products appear dimmed with strikethrough
- Tap **Add Product** (➕ icon, app bar) to open the product form
- Product form uses a **2-tab layout** (Basic + Advanced) with sticky save button:
  - **Basic tab** — image (tap to pick from Gallery/Camera, long-press to preview, remove with confirmation), name, price, stock, category picker (bottom sheet with auto-pop selection and "None" clear option)
  - **Advanced tab** — barcode (scan with camera or enter manually), generate EAN-13 compliant barcode with Luhn check digit (GS1 prefix `200`, auto-padded to 3 digits, collision-checked against DB), SKU, cost, track stock toggle
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
  - **Void Sale** button (red) — opens confirmation dialog with optional reason; atomically marks sale as voided, restores stock, and logs VOID_REVERSAL
  - **Print Receipt** and **Share Receipt** buttons — generates an 80 mm thermal receipt PDF with sale-time VAT values
- Use the **search bar** (appears below the app bar) to filter by receipt number, payment method, or amount
- Use the date-range picker (calendar icon) to filter history by period

### Report tab

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
| **Show pre-sale preview** | Show preview in PaymentSheet |
| **Show post-sale preview** | Show preview in success dialog |

### PromptPay Settings

- **Preview card** — Gradient card showing configured/not-configured state with QR icon and current PromptPay ID
- **PromptPay ID** — Tap to open validation dialog: phone number (10 digits, starting with 0) or citizen ID (13 digits)
- **Info card** — Explains how PromptPay ID is used for QR code payments

### Backup Settings

- **Status card** — Gradient card showing backup status (Safe/Warning/Overdue) with last backup date
- **Backup reminder** — Switch to enable/disable; tap to open frequency picker dialog with preset chips (3/7/14/30 days) or custom input
- **Encryption** (v0.7.2+) — Toggle to enable AES-256-GCM encryption with PIN-derived PBKDF2 key; PIN is never stored — forgotten PIN = unrecoverable backup
- **Backup Now** — Manual backup trigger action tile
- **Export/Restore** — Export database (`.db` or `.db.enc` if encrypted), sales CSV, products CSV; restore from backup file

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
- **Privacy Policy** — Opens in-app `PrivacyPolicyPage` with 6 sections: Data Collection, Third-Party Services, Data Storage, Backup Encryption, Permissions, Contact
- **Open Source License** — Opens in-app `AppLicensePage` showing full AGPL-3.0 license text (loaded from `LICENSE` file, selectable for copy)
- **Footer** — Copyright notice "© 2026 Promsell POS CE · AGPL-3.0"

---

<sub>Promsell POS Community Edition · © 2026 MN Lizard Team · AGPL-3.0</sub>
