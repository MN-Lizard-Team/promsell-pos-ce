# WS-V092-C — Stock integrity + migrate hygiene

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** V092-C.1 … V092-C.6  
**Status:** todo (wave V092-1)

---

## Goal

Make `products.stock` a count that **a stale product form cannot overwrite after a sale**, and make small schema repairs in this slice fail closed on upgrade.

Not a goal: event-sourced inventory, INTEGER money (Phase M), or multi-device sync.

---

## V092-C.1 — CAS + version on every stock path

### Problem

Sale/void use:

```sql
UPDATE products SET stock = stock - ?, updated_at = ?
WHERE id = ? AND track_stock = 1 AND stock >= ?
```

They do **not** `version = version + 1`.

The product form uses optimistic locking on `version`, then writes `stock` from the value that was on screen when the page opened.

Failure sequence: open form (v=5, stock=10) → sell down to 7 (v still 5) → save form → stock is 10 again.

Evidence: `sale_insert_writer.dart`, `sale_void_writer.dart`, `product_local_datasource.dart`

### Target rules

1. Operational paths (sale / void / `adjustStock`) use `stock = stock ± ?` in the existing TX + `version = version + 1` + `updated_at`.
2. The product form must **not** send `stock` from a stale draft if someone else moved the count.
   - Preferred: the form never writes stock (use the adjust sheet) **or**
   - It may write only when `version` still matches **and** the payload is a delta, not an absolute from cache.
3. Quick-edit stock uses a delta or re-reads before write.
4. Keep `stock >= ?` on decrement and the existing oversell policy.

Product recommendation: **the product form does not touch stock** — stock has one home: Adjust + sale/void.  
Setting an initial count on **insert** of a new product is allowed.

### Implementation sketch

1. Add `version = version + 1` to the `customUpdate`s in insert/void/adjust.
2. Remove `stock` writes from generic `updateProduct` (other columns stay).
3. If the stock field must remain on the form: a separate `setStockAbsolute` that re-reads the row in a TX and rejects on version mismatch (never overwrite silently).
4. Keep `product_audits` / inventory logs consistent — do not log a manual adjust when the value was a stale overwrite.

### Tests (Must in trust)

- Snapshot form stock=10 version=5 → sell 3 → save form with stock=10 → **result stock = 7** (or the form is rejected). Must not become 10.
- Existing parallel-sale cases in `sale_local_datasource_test` still never go negative.
- Void restock still `version++`.
- Adjust below zero still throws.

### Done when

- A test fails if someone puts draft `stock:` back into a blind `UPDATE`.
- SECURITY/DATABASE has a short note that operational stock is CAS.

---

## V092-C.2 — Dedupe SKU before unique (Should / almost Must if v31 ships)

v30 created `idx_products_sku_lower_unique` without clearing duplicates the way barcode did.  
`ABC` vs `abc` can stall the upgrade.

### Target

- If no wild DB is known to collide: add an idempotent repair in `onUpgrade` (from < 31, or in-place if unique never applied — check reality first).
- Clear dupes like barcode (keep newest / not-deleted).
- Test a migrate fixture with mixed-case SKUs.

Do not rebuild tables the v10 way.

---

## V092-C.3 — index/trigger at the end of every upgrade (Should)

`_createIndexes()` runs on `onCreate` and `from < 2`.  
DBs upgraded from v2+ may lack price > 0 / cost >= 0 triggers.

Make that set **idempotent** (`CREATE INDEX IF NOT EXISTS` / `CREATE TRIGGER IF NOT EXISTS`) and call it at the end of every `onUpgrade`.

Do not fold Phase M into this set.

---

## V092-C.4 — Barcode/SKU policy after soft-delete (Could → decide in 0.9.2)

Uniques currently cover the whole table, including rows with `deleted_at` set.  
v23 docs implied runtime skipped deleted rows.

Pick one and write it in `docs/DATABASE.md`:

- **Reusable after delete:** partial unique `WHERE deleted_at IS NULL` (careful migrate).
- **Not reusable:** fix the docs to match the current indexes.

Do not leave two truths.

---

## C.5 / C.6 — later

DB CHECKs for qty/status and report indexes do not block the tag.  
They stay on the map so the audit does not lose them.

---

## Schema policy for 0.9.2

| Allowed | Not allowed |
|---------|-------------|
| v31 SKU repair / small nullable column | Move money to INTEGER |
| `version++` on existing UPDATEs | Table rebuild |
| Idempotent index/trigger | Down migration |

If C.1 needs no schema change (it is mostly SQL UPDATE) — **do not** bump schema version without a reason.

---

## Ordering

```
C.1 (stock behavior)  ★ before tag, pair with B.1
C.2 + C.3 (migrate) if wave 1 still has time
C.4 document the decision
```

C.1 and B.1 should be separate PRs if they collide on files — both must land before GATE.

---

<sub>Promsell POS CE · V092-INTEGRITY · WS-C stock · 2026-08-13</sub>
