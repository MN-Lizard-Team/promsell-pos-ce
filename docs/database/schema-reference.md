# Schema Reference — Promsell POS CE (schema v27)

Detailed column reference for all 14 database tables, indexes, seed data, and enum values.

> **Main reference:** [`docs/DATABASE.md`](../DATABASE.md) — overview, ERD, sync columns, SQLCipher encryption

---

## Schema Reference

### Products

Source: `lib/core/database/tables/products_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `name` | TEXT | No | — | length 1–200 |
| `sku` | TEXT | Yes | — | |
| `barcode` | TEXT | Yes | — | Partial unique index (v24) when non-null/non-empty; uppercase on save/lookup; runtime uniqueness for active products |
| `price` | REAL | No | — | Baht on disk; domain maps via `Money` |
| `cost` | REAL | Yes | — | |
| `stock` | INTEGER | No | `0` | |
| `categoryId` | TEXT | Yes | — | Logical ref → categories |
| `imageUrl` | TEXT | Yes | — | Network URL for future online sync |
| `imagePath` | TEXT | Yes | — | Local file path from gallery/camera pick |
| `imageThumbnailPath` | TEXT | Yes | — | Local thumbnail path (200px) for small avatar display |
| `barcodeImagePath` | TEXT | Yes | — | Local barcode image (PNG/JPEG) via `BarcodeImageService` |
| `description` | TEXT | Yes | — | Optional long-form description (v22) |
| `brand` | TEXT | Yes | — | Product brand (schema **v25**) |
| `unit` | TEXT | Yes | — | Sell unit label (schema **v25**) |
| `supplier` | TEXT | Yes | — | Supplier name (schema **v25**) |
| `isRecommended` | BOOLEAN | No | `false` | Catalog “recommended” flag (schema **v25**) |
| `trackStock` | BOOLEAN | No | `true` | `false` = service item: skip stock check, no deduction, show ∞ in UI |
| `isActive` | BOOLEAN | No | `true` | |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

### Sales

Source: `lib/core/database/tables/sales_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `receiptNumber` | TEXT | Yes | — | |
| `status` | TEXT | No | `'COMPLETED'` | `COMPLETED` \| `VOIDED` |
| `subtotalAmount` | REAL | No | `0` | |
| `discountType` | TEXT | Yes | — | `PERCENT` \| `AMOUNT` |
| `discountValue` | REAL | Yes | — | |
| `discountAmount` | REAL | No | `0` | |
| `totalAmount` | REAL | No | — | |
| `vatMode` | TEXT | No | `'NONE'` | `NONE` \| `INCLUSIVE` \| `EXCLUSIVE` |
| `vatRate` | REAL | No | `0` | |
| `vatAmount` | REAL | No | `0` | |
| `orderType` | TEXT | No | `'dinein'` | `dinein` \| `takeaway` \| `delivery` (added v20) |
| `orderChannel` | TEXT | No | `'walkin'` | `walkin` \| `online` \| `phone` (added v20) |
| `externalOrderRef` | TEXT | Yes | — | External order ID / delivery reference (added v20) |
| `tableId` | TEXT | Yes | — | Logical ref → restaurant_tables (added v20) |
| `serviceChargeRate` | REAL | No | `0` | Service charge % (added v20) |
| `serviceChargeAmount` | REAL | No | `0` | Computed service charge amount (added v20) |
| `customerId` | TEXT | Yes | — | Logical ref → customers (added v21) |
| `promotionId` | TEXT | Yes | — | Logical ref → promotions (added v21) |
| `promotionDiscountAmount` | REAL | No | `0` | Promotion discount applied (added v21) |
| `paymentMethod` | TEXT | No | — | `cash` \| `transfer` \| `card` \| `promptpay` |
| `amountReceived` | REAL | Yes | — | |
| `changeAmount` | REAL | Yes | — | |
| `paymentReference` | TEXT | Yes | — | PromptPay transaction ID |
| `sendingBankCode` | TEXT | Yes | — | Bank code from slip verification |
| `note` | TEXT | Yes | — | |
| `voidedAt` | DATETIME | Yes | — | |
| `voidReason` | TEXT | Yes | — | |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

### SaleItems

Source: `lib/core/database/tables/sale_items_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `saleId` | TEXT | No | — | **FK → sales.id** (CASCADE) |
| `productId` | TEXT | No | — | Logical ref → products (no FK) |
| `productName` | TEXT | No | — | Snapshot at time of sale |
| `price` | REAL | No | — | Snapshot at time of sale |
| `qty` | INTEGER | No | — | |
| `discountAmount` | REAL | No | `0` | |
| `vatAmount` | REAL | No | `0` | |
| `subtotal` | REAL | No | — | `price × qty − discount` |
| `note` | TEXT | Yes | — | Per-item note (added v19) |
| `productOptionsJson` | TEXT | Yes | — | JSON snapshot of selected product options at time of sale (added v20) |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

> **Design decision:** `productId` has no FK constraint to `products` — sale history must survive product deletion. `productName` and `price` are snapshots.

### Categories

Source: `lib/core/database/tables/categories_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `name` | TEXT | No | — | length 1–100 |
| `sortOrder` | INTEGER | No | `0` | |
| `color` | TEXT | Yes | — | Hex color (e.g. "E53935") |
| `iconName` | TEXT | Yes | — | Material icon identifier |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

### InventoryLogs

Source: `lib/core/database/tables/inventory_logs_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `productId` | TEXT | No | — | Logical ref → products |
| `type` | TEXT | No | — | See [Enum Values](#enum--constant-values) |
| `qtyChange` | INTEGER | No | — | Signed: negative for sale, positive for void/adjustment |
| `balanceAfter` | INTEGER | No | — | Stock balance after this change |
| `reason` | TEXT | Yes | — | Free-text reason for adjustments |
| `refSaleId` | TEXT | Yes | — | Logical ref → sales (for SALE/VOID_REVERSAL) |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `deviceId` | TEXT | Yes | — | Sync |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |

### AppSettings

Source: `lib/core/database/tables/app_settings_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `key` | TEXT | No | — | **PK** |
| `value` | TEXT | No | — | JSON-encoded string |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

> Table name override: `app_settings` (Drift `tableName` getter).

### DraftCarts

Source: `lib/core/database/tables/draft_carts_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `name` | TEXT | Yes | — | e.g. "Customer A", "Table 3" |
| `note` | TEXT | Yes | — | |
| `cartDiscountType` | TEXT | Yes | — | `PERCENT` \| `AMOUNT` |
| `cartDiscountValue` | REAL | Yes | — | |
| `orderType` | TEXT | No | `'dinein'` | `dinein` \| `takeaway` \| `delivery` (added v20) |
| `orderChannel` | TEXT | No | `'walkin'` | `walkin` \| `online` \| `phone` (added v20) |
| `externalOrderRef` | TEXT | Yes | — | External order ID / delivery reference (added v20) |
| `tableId` | TEXT | Yes | — | Logical ref → restaurant_tables (added v20) |
| `serviceChargeRate` | REAL | Yes | — | Carries through to sale creation (added v20) |
| `customerId` | TEXT | Yes | — | Logical ref → customers (added v21) |
| `promotionId` | TEXT | Yes | — | Logical ref → promotions (added v21) |
| `promotionDiscountAmount` | REAL | No | `0` | Carries through to sale creation (added v21) |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `isArchived` | BOOLEAN | No | `false` | Auto-archive after 7 days |
| `deviceId` | TEXT | Yes | — | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |

### DraftCartItems

Source: `lib/core/database/tables/draft_cart_items_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `cartId` | TEXT | No | — | **FK → draft_carts.id** (CASCADE) |
| `productId` | TEXT | No | — | Logical ref → products |
| `productName` | TEXT | No | — | Snapshot |
| `price` | REAL | No | — | Snapshot |
| `qty` | INTEGER | No | — | |
| `discountType` | TEXT | Yes | — | `PERCENT` \| `AMOUNT` |
| `discountValue` | REAL | Yes | — | |
| `note` | TEXT | Yes | — | Per-item note (added v19) |
| `productOptionsJson` | TEXT | Yes | — | JSON snapshot of selected product options (added v20) |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

### DailyCloses

Source: `lib/core/database/tables/daily_closes_table.dart`

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `closeDate` | TEXT | No | — | Format: `YYYY-MM-DD` |
| `openingCash` | REAL | No | `0` | |
| `expectedCash` | REAL | No | `0` | Calculated from sales |
| `countedCash` | REAL | No | `0` | Cashier input |
| `overShortAmount` | REAL | No | `0` | `countedCash − expectedCash` |
| `totalRevenue` | REAL | No | `0` | |
| `totalVoid` | REAL | No | `0` | |
| `salesCount` | INTEGER | No | `0` | |
| `voidCount` | INTEGER | No | `0` | |
| `paymentBreakdown` | TEXT | No | `'{}'` | JSON map of payment method → amount |
| `vatAmount` | REAL | No | `0` | Total VAT for the day |
| `discountAmount` | REAL | No | `0` | Total discounts for the day |
| `note` | TEXT | Yes | — | |
| `closedAt` | DATETIME | Yes | — | Nullable since schema v10 |
| `deviceId` | TEXT | Yes | — | Sync |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |

### RestaurantTables

Source: `lib/core/database/tables/restaurant_tables_table.dart` — added schema v20

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `name` | TEXT | No | — | length 1–100 |
| `zone` | TEXT | Yes | — | Section/zone label (e.g. "Main Hall") |
| `seats` | INTEGER | Yes | — | Seat capacity |
| `status` | TEXT | No | `'available'` | `available` \| `occupied` \| `reserved` |
| `sortOrder` | INTEGER | No | `0` | Display order |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

### ProductOptionGroups

Source: `lib/core/database/tables/product_option_groups_table.dart` — added schema v20

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `productId` | TEXT | No | — | **FK → products.id** (CASCADE) |
| `name` | TEXT | No | — | length 1–100 (e.g. "Size", "Topping") |
| `selectionType` | TEXT | No | `'single'` | `single` \| `multiple` |
| `isRequired` | BOOLEAN | No | `false` | Forces selection before checkout |
| `sortOrder` | INTEGER | No | `0` | |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

### ProductOptions

Source: `lib/core/database/tables/product_options_table.dart` — added schema v20

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `groupId` | TEXT | No | — | **FK → product_option_groups.id** (CASCADE) |
| `name` | TEXT | No | — | length 1–100 (e.g. "Large", "Extra Cheese") |
| `priceDelta` | REAL | No | `0` | Price adjustment added to item price |
| `sortOrder` | INTEGER | No | `0` | |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

### Customers

Source: `lib/core/database/tables/customers_table.dart` — added schema v21

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `name` | TEXT | No | — | length 1–200 |
| `phone` | TEXT | Yes | — | |
| `email` | TEXT | Yes | — | |
| `note` | TEXT | Yes | — | |
| `totalSpent` | REAL | No | `0` | Lifetime spend — updated automatically on each sale/void |
| `visitCount` | INTEGER | No | `0` | Number of completed sales — updated automatically |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

> `totalSpent` and `visitCount` are maintained atomically inside the sale/void transaction by `SaleLocalDatasource`. They are **read-only** from the customer form — do not overwrite them manually.

### Promotions

Source: `lib/core/database/tables/promotions_table.dart` — added schema v21

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| `id` | TEXT | No | — | **PK**, UUIDv4 |
| `name` | TEXT | No | — | length 1–200 |
| `type` | TEXT | No | `'PERCENT'` | `PERCENT` \| `AMOUNT` |
| `value` | REAL | No | `0` | Discount value (percent or fixed amount) |
| `minPurchaseAmount` | REAL | No | `0` | Minimum cart total to activate |
| `startDate` | DATETIME | No | `currentDateAndTime` | |
| `endDate` | DATETIME | Yes | — | `null` = no expiry |
| `isActive` | BOOLEAN | No | `true` | |
| `createdAt` | DATETIME | No | `currentDateAndTime` | |
| `updatedAt` | DATETIME | No | `currentDateAndTime` | Sync |
| `deletedAt` | DATETIME | Yes | — | Soft delete |
| `version` | INTEGER | No | `1` | Sync |
| `deviceId` | TEXT | Yes | — | Sync |

---

## Indexes

Created in `_createIndexes()` during `onCreate` and `onUpgrade`.

| Index | Table | Column(s) | Purpose |
|-------|-------|-----------|---------|
| `idx_products_category_id` | products | `category_id` | Filter products by category |
| `idx_products_is_active` | products | `is_active` | Filter active products for sale catalog |
| `idx_products_barcode_unique` | products | `barcode` (partial) | **UNIQUE** where `barcode IS NOT NULL AND barcode != ''` (schema **v24**) |
| `idx_sales_created_at` | sales | `created_at` | Date-range queries in history/reports |
| `idx_sales_status` | sales | `status` | Filter completed vs voided sales |
| `idx_sale_items_sale_id` | sale_items | `sale_id` | Fetch items for a specific sale |
| `idx_inventory_logs_product_id` | inventory_logs | `product_id` | Product stock audit trail |
| `idx_draft_cart_items_cart_id` | draft_cart_items | `cart_id` | Fetch items for a draft cart |
| `idx_daily_closes_close_date_unique` | daily_closes | `close_date` | **UNIQUE** one close row per business day (schema **v28**) |
| `idx_sales_receipt_number_unique` | sales | `receipt_number` | **UNIQUE** where non-null/non-empty (schema **v27**) |
| `idx_product_option_groups_product_id` | product_option_groups | `product_id` | Fetch option groups for a product (v20) |
| `idx_product_options_group_id` | product_options | `group_id` | Fetch options for a group (v20) |
| `idx_restaurant_tables_status` | restaurant_tables | `status` | Filter tables by availability (v20) |
| `idx_customers_name` | customers | `name` | Customer search by name (v21) |
| `idx_customers_phone` | customers | `phone` | Customer lookup by phone (v21) |
| `idx_promotions_active` | promotions | `is_active` | Filter active promotions (v21) |
| `idx_sales_customer_id` | sales | `customer_id` | Customer purchase history (v21) |

### Barcode uniqueness (current · v0.9.0)

- **DB:** partial unique index `idx_products_barcode_unique` on `products(barcode)` where barcode is non-null and non-empty (schema **v24**).
- **Runtime:** `ProductLocalDatasource` validates uniqueness for active products (case-insensitive), excludes soft-deleted rows, length 1–50 when set.
- Empty/null barcodes are allowed on multiple products.

---

## Seed Data

Inserted on `onCreate` via `_seedDefaultSettings()` using `InsertMode.insertOrIgnore` (won't overwrite existing keys).

| Key | Default value | Description |
|-----|---------------|-------------|
| `shop_name` | `""` | Shop display name for receipts |
| `receipt_footer` | `""` | Optional receipt footer text |
| `vat_rate` | `"7"` | VAT percentage |
| `vat_mode` | `"NONE"` | `NONE` \| `INCLUSIVE` \| `EXCLUSIVE` |
| `currency_symbol` | `"฿"` | Currency display symbol |

Keys added by **Sale Integrity** (written at runtime by `ReceiptNumberService` and `SettingsLocalDatasource`):

| Key | Example value | Description |
|-----|---------------|-------------|
| `receipt_seq` | `"42"` | Current daily receipt sequence counter (resets each day) |
| `receipt_date` | `"260527"` | Date of last receipt (YYMMDD); triggers reset when day changes |
| `device_prefix` | `"A1"` | 2-char device prefix for receipt numbers |

Keys managed by **SettingsRepositoryImpl** (read/written at runtime):

| Key | Default | Added in |
|-----|---------|----------|
| `allowOversell` | `false` | v0.5.0 |
| `lowStockThreshold` | `5` | v0.5.0 |
| `promptpayId` | `""` | v0.6.0 |
| `receiptSize` | `"80mm"` | v0.6.0 |
| `backupReminderDays` | `"7"` | v0.6.0 |
| `lastBackupAt` | `null` | v0.6.0 |
| `imageMaxWidth` | `"800"` | v0.6.0 |
| `imageQuality` | `"80"` | v0.6.0 |
| `deviceId` | generated UUID | R5; backfilled on all existing rows in v13 |
| `onboardingCompleted` | `false` | R5 |
| `dailyCloseLock` | `false` | R5 |

---

## Enum & Constant Values

### `sales.status`

| Value | Meaning |
|-------|---------|
| `COMPLETED` | Normal completed sale (default) |
| `VOIDED` | Sale voided — stock reversed, excluded from revenue |

### `sales.vatMode`

| Value | Meaning |
|-------|---------|
| `NONE` | No VAT applied (default) |
| `INCLUSIVE` | Price includes VAT |
| `EXCLUSIVE` | VAT added on top of price |

### `sales.discountType` / `draft_cart_items.discountType`

| Value | Meaning |
|-------|---------|
| `PERCENT` | Discount as percentage (e.g. 10%) |
| `AMOUNT` | Discount as fixed amount (e.g. ฿50) |
| `null` | No discount |

### `inventory_logs.type`

| Value | Meaning | `qtyChange` sign |
|-------|---------|-----------------|
| `SALE` | Stock deducted from sale | Negative (e.g. −3) |
| `VOID_REVERSAL` | Stock restored from void | Positive (e.g. +3) |
| `ADJUSTMENT_IN` | Manual stock addition | Positive |
| `ADJUSTMENT_OUT` | Manual stock removal | Negative |
| `INITIAL` | Initial stock set | Positive |

### `sales.paymentMethod`

| Value | Display (TH) | Display (EN) |
|-------|-------------|-------------|
| `cash` | เงินสด | Cash |
| `transfer` | โอนเงิน | Transfer |
| `card` | บัตร | Card |
| `promptpay` | พร้อมเพย์ | PromptPay |

> Payment method values are normalized by `payment_method_helper.dart` and localized at display time.

---

<sub>Promsell POS CE · v0.9.0 · schema v28 · 14 tables · SQLCipher AES-256</sub>
