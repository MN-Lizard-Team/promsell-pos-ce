# Round 3 — Cashier UX ✅ DONE (2026-05-28)

> Goal: รองรับ workflow ร้านจริง — พักบิล/หลายบิล, ส่วนลด per-item + per-cart, VAT inclusive/exclusive, นโยบาย stock ที่ปรับได้.

**Version:** `v0.5.0`
**Completed:** 2026-05-28
**Effort:** ~3 dev-days
**Risk:** 🟡 Medium → DONE
**Depends on:** R1+R2 complete ✅ (v0.4.0)

---

## Why R3

R2 ทำให้ระบบ trust ได้. R3 ทำให้ระบบ **ใช้งานได้จริง** ในร้าน:
- พักบิลรอลูกค้าอื่น
- ลดราคา negotiate ได้
- จัดการ VAT ตามใบกำกับภาษี
- ขายเกิน stock ได้ถ้า merchant อนุญาต

---

## Pre-flight

- [x] R1+R2 merged → `v0.4.0` released (2026-05-27)

---

## Tasks

### 1. Settings UI Expansion

หน้า Settings เพิ่ม section ใหม่:

#### "Tax & Pricing"
- VAT mode dropdown: None / Inclusive / Exclusive
- VAT rate input (default 7%) — disabled when mode = None

#### "Stock Policy"
- Switch: `Allow oversell` (default OFF)
- Number input: `Low stock threshold` (default 5)

#### "Receipt"
- (R4 will add more here)

ทั้งหมด save ผ่าน Settings table.

### 2. Stock Policy Enforcement

#### Per-product `trackStock`
- Product form: switch "Track stock" (default ON)
- ถ้า OFF → ไม่ deduct stock, ไม่ check stock, แสดง "∞" แทน qty
- Useful for service items (e.g. "ค่าบริการ")

#### Cart validation logic

```dart
bool canAddToCart(Product p, int currentCartQty) {
  if (!p.trackStock) return true;
  if (settings.allowOversell) return true;
  return currentCartQty < p.stock;
}
```

#### Database insert
- ถ้า `allowOversell=true` → skip stock check ใน `insertSaleWithItems`
- ยัง insert inventory log + deduct stock (อาจติดลบ — แสดงเตือนใน UI ภายหลัง)

#### Low stock indicator
- Product list: badge สีส้มถ้า `stock <= lowStockThreshold && trackStock`
- Sale catalog: indicator เล็ก ๆ มุมการ์ด

### 3. Discount System

#### Data model (already in R1 schema)
- `SaleItem.discountAmount`
- `Sale.discountType`, `discountValue`, `discountAmount`

#### Calculation rules

```
Per-item discount:
  if PERCENT: itemDiscount = price * qty * (value / 100)
  if AMOUNT:  itemDiscount = value (capped at price * qty)
  itemSubtotal = (price * qty) - itemDiscount

Cart subtotal = sum(itemSubtotal)

Per-cart discount applied to cart subtotal:
  if PERCENT: cartDiscount = cartSubtotal * (value / 100)
  if AMOUNT:  cartDiscount = value (capped at cartSubtotal)

Pre-VAT total = cartSubtotal - cartDiscount
```

> ⚠️ Per-cart discount distributes proportionally across items for accurate per-item VAT. Document formula:
> `item.proportionalDiscount = cartDiscount * (itemSubtotal / cartSubtotal)`

#### UI

##### Per-item
- Cart item row → tap "..." → "Apply discount"
- Dialog: toggle PERCENT/AMOUNT, input value, preview new subtotal
- Show discount badge in cart item

##### Per-cart
- Below cart subtotal → "Apply cart discount" button
- Dialog same as above
- Show in cart summary as separate line

#### State management
Add to `SaleState`:
- `cartDiscountType`, `cartDiscountValue`
- `CartItem` already has `discount` (add)

Add events:
- `SaleItemDiscountChanged(productId, type, value)`
- `SaleCartDiscountChanged(type, value)`

### 4. VAT System

#### Rules

```
NONE:
  vatAmount = 0
  total = subtotal - discount

INCLUSIVE:
  // Price already includes VAT
  preVatTotal = (subtotal - discount) / (1 + vatRate)
  vatAmount   = (subtotal - discount) - preVatTotal
  total       = subtotal - discount  // unchanged

EXCLUSIVE:
  preVatTotal = subtotal - discount
  vatAmount   = preVatTotal * vatRate
  total       = preVatTotal + vatAmount
```

#### Distribute to items (for receipt detail)
Each `saleItem.vatAmount = totalVatAmount * (itemSubtotal / cartSubtotal)`

#### UI in payment sheet

```
Subtotal           ฿1,000.00
Cart discount      -฿100.00
─────────────────────────
                    ฿900.00
VAT 7% (excl.)     +฿63.00
═════════════════════════
TOTAL              ฿963.00
```

หรือถ้า INCLUSIVE:

```
Subtotal           ฿1,000.00
Cart discount      -฿100.00
─────────────────────────
TOTAL              ฿900.00
   (VAT incl. ฿58.88)
```

#### Rounding
- ทุกค่าเก็บ 2 decimal
- ใช้ `(x * 100).round() / 100` หลังทุก calculation
- Test: edge cases — 0, very small, very large, repeating decimals

### 5. Draft Cart Persistence

#### Data flow

```
SaleBloc state change
   ↓ debounce 500ms
DraftCartRepository.upsertActiveDraft(state)
   ↓
draft_carts + draft_cart_items in SQLite
```

#### Auto-save
- ทุกครั้ง `SaleState` เปลี่ยน → debounce 500ms → upsert
- 1 active draft = `id = settings.activeDraftId`

#### Multi-draft

##### UI
- Sale page AppBar → icon `bookmarks_outlined` → drawer/sheet "Drafts"
- List ของ draft (name, item count, total, time)
- Buttons: New draft / Switch to / Rename / Delete
- Current active draft highlighted

##### Logic
- "New draft": save current cart as draft, clear sale state, create new active draft
- "Switch to X": save current → load X into sale state → set X as active
- "Delete": confirm dialog → remove from DB; if active → create empty new

#### Restore on app launch
- `SaleBloc.init` → load active draft from DB → emit state

#### Cleanup on checkout
- After `SaleConfirmed` success → delete active draft → create new empty active draft

### 6. Tests

#### Unit
- Discount calculation: PERCENT, AMOUNT, capped, zero, very large
- VAT calculation: INCLUSIVE/EXCLUSIVE/NONE, rounding edges
- Combined: discount + VAT + multi-item with proportional distribution
- Draft cart upsert/load round-trip

#### BLoC
- Discount events update state correctly
- Cart discount event recalculates total
- Switching draft replaces state

#### Widget
- Discount dialog input + preview
- Payment sheet shows VAT breakdown
- Drafts sheet lists + switches

#### Integration
- Add items → apply discount → apply VAT → checkout → verify DB row has correct values
- Auto-save: change cart → wait 600ms → kill app → relaunch → cart restored
- Multi-draft: create A, switch to B, switch back to A → A's cart intact

---

## Success Gate

- ✅ VAT/discount math passes 50+ test cases including rounding edges
- ✅ Cart survives app kill (verified manually + integration test)
- ✅ Multi-draft switch <100ms perceived
- ✅ Oversell toggle changes behavior end-to-end
- ✅ Low stock indicator visible
- ✅ Receipt math matches DB (subtotal + discount + VAT = total)
- ✅ Test count grows ~170 → ~210+
- ✅ CHANGELOG + v0.5.0

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| VAT rounding causes off-by-1 baht | Pin formula; comprehensive test fixtures with expected values |
| Auto-save thrashing DB | Debounce 500ms; only upsert if state actually changed |
| Draft state lost on crash | Save synchronously inside transaction (not async) |
| Per-cart discount distribution wrong | Document formula; test with 3+ items including odd amounts |
| UX confusion with too many drafts | Cap at 10 active drafts; warn before creating 11th |

---

## Out of Scope for R3

- ❌ Receipt PDF (R4)
- ❌ PromptPay QR (R4)
- ❌ Backup (R4)
- ❌ Daily close (R5)
- ❌ Onboarding (R5)

---

## Definition of Done

```
✅ Settings UI: VAT, oversell, low stock threshold
✅ trackStock per-product working
✅ Oversell toggle working end-to-end
✅ Per-item discount UI + math + DB
✅ Per-cart discount UI + math + DB
✅ VAT inclusive/exclusive UI + math + DB
✅ Payment sheet shows clear breakdown
✅ Draft cart auto-save (500ms debounce)
✅ Multi-draft list/switch/rename/delete
✅ Restore active draft on launch
✅ Cleanup draft on checkout
✅ All tests pass (208/208)
□ Manual: realistic POS flow with discount + VAT + multi-customer
✅ CHANGELOG + v0.5.0
```
