# WS-DOC-DATA — Database handbook honesty

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** DOC-M.1 … DOC-M.4  
**Status:** todo (wave DOC-4)  
**Code SSOT:** `lib/core/database/app_database.dart` (`schemaVersion` 30)

**Link only:** V092-C.2 (SKU dedupe), V092-C.4 (unique vs `deleted_at`), V092-A.4 (sync marketing), POST-090 C (Phase M).

---

## Goal

A reader who follows the handbook must **not** brick an upgrade or invent a unique SKU index in `_createIndexes()`.

---

## DOC-M.1 — `docs/database/migration-and-ops.md`

Cut the fake `from < 2` `createAll` + image/discount snippet.

Fix the historical table to match `onUpgrade`:

| Doc says today | Code is |
|----------------|---------|
| v2: `createAll` + column adds | `createTable` for draft/daily_closes/categories/inventory_logs/app_settings + `_createIndexes` + seed |
| v7: `sales.vat*` | `draft_carts.is_archived` |
| v8: (wrong/omitted) | `_seedR5Settings` (deviceId, prefix, onboarding, dailyCloseLock, lastClosedDate) |
| v10: device settings | rebuild `daily_closes` so `closed_at` is nullable |
| v16: warn + skip unique | `_deduplicateBarcodes()` then unique; leftover dupes **`throw StateError`** |
| v23: drop barcode UNIQUE | **no-op** (runtime only) |
| v24: `idx_products_barcode_deletedAt` | re-dedupe + partial unique on `barcode` WHERE non-null/non-empty + sale indexes |
| v30: unique `sku_lower` (safe) | add column, backfill `LOWER(sku)`, `CREATE UNIQUE` — **no SKU dedupe** |
| (omitted) | `from < 27` (receipt unique) runs **after** `from < 30` in source |

Rewrite “How to add an index”: unique indexes belong in `onUpgrade` **after a dedupe pass**. `_createIndexes()` is `onCreate` + `from < 2` only and does **not** create `idx_products_sku_lower_unique`.

Do not write a v31 unique-SKU recipe.

---

## DOC-M.2 — `docs/database/schema-reference.md`

- `products.categoryId`: `KeyAction.setNull`. Cut RESTRICT/NO ACTION.
- Receipt KV: `receiptSequence`, `receiptSequenceDate`, `devicePrefix`. Cut `receipt_seq` / `receipt_date` / `device_prefix`.
- Unique barcode / barcode_lower / sku_lower: WHERE non-null/non-empty only. They do **not** add `AND deleted_at IS NULL`. Runtime “excludes deleted” is app-only. Policy = V092-C.4.
- Fresh install: non-unique `idx_products_sku` only. `sku_lower` unique exists on the **v30 upgrade path**.

---

## DOC-M.3 — `docs/database/query-patterns.md`

Cut the N+1 “fetch items for each sale” sketch.

Point at `SaleQueryLocalDatasource.hydrateSales`: one items query + one payments query via `saleId.isIn`.  
File: `lib/features/sale/data/datasources/sale_query_local_datasource.dart`.

Do not invent stock/`version++` behavior (V092-C.1).

---

## DOC-M.4 — `docs/DATABASE.md`

Cut “16 tables, all sync-ready / version++ on every write.”

Say: metadata columns exist on most tables; `ProductAudits` has no `deletedAt`; sale/void stock updates do not `version++`; there is no sync engine.

Timeline labels for v7/v10/v16/v23/v24/v30 must match DOC-M.1 **or** say “see `app_database.dart`.”

`categoryId` SET NULL in the relationship table is already correct — leave it. No Phase M text.

---

## Verify

A reader of the revised docs will **not**:

1. `CREATE UNIQUE` on `sku_lower` without a prior SKU dedupe
2. add that unique inside `_createIndexes()`
3. assume unique barcode/SKU ignore `deleted_at` rows
4. copy v16 as “skip on dupes”, v23 as “drop UNIQUE”, or v24 as `(barcode, deleted_at)`

---

<sub>Promsell POS CE · DOC-SSOT · WS-DATA · 2026-08-13</sub>
