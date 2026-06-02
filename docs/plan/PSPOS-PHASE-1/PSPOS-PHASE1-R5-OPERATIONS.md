# Round 5 — Operations 🟢

> Goal: ปิดรอบวันได้ + Onboarding ครั้งแรกเรียบร้อย + ระบบพร้อม Phase 4 sync — Phase 1 ปิดงาน release `v1.0.0-rc1`.

**Version target:** `v1.0.0-rc1` → after RC stabilization → `v1.0.0`
**Effort:** ~2 dev-days
**Risk:** 🟢 Low
**Depends on:** R1+R2 ✅ (v0.4.0), R3, R4 complete

---

## Why R5

R1–R4 ทำให้ POS ใช้งานได้ครบ. R5 = **ปิด loop ปลายวัน + เปิดประสบการณ์ครั้งแรก** + verify ระบบพร้อม sync ในอนาคต.

> **Note:** R1+R2 merged เข้า v0.4.0 เดียวกัน (Schema Foundation + Sale Integrity).

---

## Pre-flight

- [x] R1+R2 merged → `v0.4.0` released (2026-05-27)
- [x] R3 merged + `v0.5.0` released
- [x] R4 merged + `v0.6.0` released (2026-06-02)
- [x] R4.5 (Cart UX Redesign) merged + `v0.6.1` released (2026-06-02)

---

## Tasks

### 1. Daily Close (End of Day)

#### Concept
ปลายวัน cashier ปิดรอบ:
1. ระบบคำนวณยอดที่ควรมี (sales - void, แยกตาม payment method)
2. Cashier นับเงินสดจริง → ใส่ตัวเลข
3. ระบบคำนวณ over/short
4. Save snapshot → optional lock การขายของวันนั้น

#### Page: `lib/features/daily_close/presentation/pages/daily_close_page.dart`

##### Section 1: Date selector
- Default: today
- Date picker: select past date (read-only mode if already closed)

##### Section 2: Auto summary (read-only)
```
Date: 26/05/2026
Sales count:        15
Voided count:       1
─────────────────────
Gross revenue:    ฿8,500.00
Voided amount:      -฿200.00
─────────────────────
Net revenue:      ฿8,300.00

By payment:
  Cash:           ฿5,200.00
  PromptPay:      ฿2,800.00
  Card:             ฿300.00

VAT collected:      ฿543.00
Discounts given:    -฿150.00
```

##### Section 3: Cash reconciliation (input)
```
Opening cash:     [฿1,000.00]  (input, default = previous close's countedCash)
Expected cash:     ฿6,200.00   (auto = opening + cash sales)
Counted cash:     [฿_______]   (cashier input)

Over/Short:        ─           (live calc)
Note:             [optional]
```

##### Section 4: Actions
- Button "Close day" → confirm dialog → save to `daily_closes` + update `lastClosedDate` setting
- After close: show summary read-only + "Reopen day" button (with confirmation)

#### Optional sales lock
- Setting: `dailyCloseLock` (default OFF)
- When ON + day closed → block new sales for that date with snackbar "Day closed. Reopen to continue."

#### Daily Close List
- Page: list of closed days, descending
- Each shows: date, net revenue, over/short
- Tap → view detail (read-only)

#### Tests
- Calculate expected cash = opening + sum(cash sales) - sum(cash voids)
- Over/short = counted - expected
- Reopen restores lock state
- Edge: 0 sales day, all-void day, multi-payment-method day

### 2. First Launch / Onboarding

#### Detection
- On app start: check `settings.onboardingCompleted`
- If false → show `OnboardingPage` instead of `_MainShell`

#### Wizard (6 steps)

```
1. Welcome
   - App logo + tagline
   - "Get started" button

2. Shop Info
   - Shop name (required)
   - Address (optional)
   - Phone (optional)

3. Locale & Currency
   - Language: TH / EN (default TH)
   - Currency symbol (default ฿)
   - Date format (default dd/MM/yyyy)

4. Tax Setup (optional)
   - VAT mode: None / Inclusive / Exclusive
   - VAT rate (if not None)

5. PromptPay (optional)
   - Phone or Citizen ID
   - "Skip for now"

6. Done
   - "Add your first product" CTA → ProductFormPage
   - "Skip" → SalePage with empty state
```

#### Behavior
- Each step: Back / Next, validation per field
- On finish: save all settings + set `onboardingCompleted=true` + generate `deviceId` (UUID) + `devicePrefix` (random 2-char A-Z 0-9)
- Skip on step 4–5 OK; step 2 required (at least shop name)

### 3. Empty State Polish

ทุก tab ตอนเปิดครั้งแรก (no data):

#### Sale (no products)
- Icon + message + "Add product" CTA → navigate to Products tab + open form

#### Products (none)
- Icon + message + "Add first product" button

#### History (no sales)
- Icon + message: "No sales yet. Make your first sale!"

#### Reports (no sales)
- Icon + message + "View sales" CTA

(Most already exist via `AppEmptyState` from R1 codebase — verify all paths covered)

### 4. Database Health UI

Settings → "About" or "Database":
- Show DB file size (`File.statSync().size`)
- Show row counts: products, sales, sale_items, inventory_logs
- Warning banner if DB > 500MB
- "Vacuum database" button (manual `VACUUM` command, with progress)

### 5. Phase 4 Readiness Audit

Internal checklist (no UI, just verify):

- [ ] All tables have `updatedAt`
- [ ] All tables have `deletedAt` (soft delete)
- [ ] All tables have `version` (for sync conflict resolution)
- [ ] All tables have `deviceId` for origin tracking
- [ ] All IDs are UUID
- [ ] All timestamps stored as UTC (verify `DateTime.now().toUtc()`)
- [ ] Receipt number unique across devices (device prefix prevents collision)
- [ ] No reliance on auto-increment IDs anywhere
- [ ] Document sync-ready schema in `CODEBASE.md`

If any miss → create issue tagged `phase-4-prep`.

### 6. Performance Verification

Run `EXPLAIN QUERY PLAN` on hot paths:
- Sale list (history)
- Product list
- Report aggregations
- Inventory log lookup

Verify all use indexes from R1. Add missing indexes if found.

Test with seeded large data:
- Script: insert 10,000 products + 50,000 sales + 200,000 sale_items + 200,000 inventory logs
- Measure: home page load, history load, report load
- Target: < 1s for all common operations
- If slow → add index or optimize query

### 7. Documentation Update

#### `README.md`
- Update feature list (Phase 1 complete)
- Screenshots/GIFs of: sale flow, draft cart, discount, PromptPay, receipt PDF, daily close
- Build instructions current

#### `CODEBASE.md`
- Update tables list (9 tables)
- Update feature module list (add `inventory`, `cart`, `daily_close`, `onboarding`, `backup`, `receipt`, `payment`)
- Update folder structure
- Sync-readiness section

#### `docs/USAGE.md`
- New flows: void sale, draft cart, PromptPay, daily close, backup/restore

#### `CHANGELOG.md`
- Comprehensive `v1.0.0-rc1` entry summarizing R1–R5

#### Mark plan files
- `PSPOS-PHASE-1.md` → add header "✅ FULLY IMPLEMENTED in v1.0.0"

### 8. Final Polish

- [ ] All strings TH + EN (l10n parity test must pass)
- [ ] All icons consistent (Material Symbols)
- [ ] All money displays use `MoneyText`
- [ ] All empty states use `AppEmptyState`
- [ ] All destructive actions confirm
- [ ] Loading states for all async operations
- [ ] Error states with retry where applicable
- [ ] App icon + splash screen branded
- [ ] Settings sections logically grouped

### 9. RC Testing

After all tasks:
- 1-week internal RC test on real device
- Test all flows end-to-end with real data volumes
- Fix any issues found → `v1.0.0-rc2`, etc.
- When stable: tag `v1.0.0`

---

## Success Gate

- ✅ Daily close: open day, sales happen, close day, over/short correct
- ✅ Reopen day works
- ✅ Onboarding completes once, never reappears
- ✅ Fresh install → onboarding → first sale → all settings populated
- ✅ All tabs have proper empty states
- ✅ DB size visible in settings
- ✅ Phase 4 readiness checklist 100% green
- ✅ 10k product / 50k sale stress test < 1s home load
- ✅ Test count grows ~243 → ~280+ (R5 target)
- ✅ Documentation updated
- ✅ CHANGELOG `v1.0.0-rc1` published
- ✅ All 5 rounds checklist green

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Daily close math wrong on edge cases | Comprehensive test fixtures: 0/all-void/multi-method/partial day |
| Reopen day creates double-counting | Track open/close events as state machine; `dailyCloseLock` ensures consistency |
| Onboarding skipped settings cause crashes | Provide safe defaults for every setting; null-safe reads |
| 10k products UI freezes | Verify lazy loading + paginated lists; profile with DevTools |
| Phase 4 readiness gaps found late | Audit during R1 review, not just R5 |

---

## Definition of Done — Phase 1 Complete

```
□ Daily close page (input + summary + save)
□ Daily close list page
□ Optional sales lock toggle
□ Onboarding 6-step wizard
□ deviceId + devicePrefix auto-generated on first launch
□ All empty states polished
□ DB health UI in settings
□ Phase 4 readiness audit passed
□ Performance verified at scale (10k products, 50k sales)
□ All docs updated (README, CODEBASE, USAGE, CHANGELOG)
□ PSPOS-PHASE-1.md marked implemented
□ Test count ~250+, all passing
□ flutter analyze 0 errors
□ Tagged v1.0.0-rc1
□ 1-week RC tested on device
□ Final v1.0.0 released
```

---

## After Phase 1

Ready for **Phase 2** consideration:
- Multi-device sync (foundation done)
- Cloud backup
- Customer/loyalty
- Hardware integrations
- Advanced reports
- Multi-shop

All Phase 4 sync prerequisites already in schema thanks to R1 forward-compat decisions.
