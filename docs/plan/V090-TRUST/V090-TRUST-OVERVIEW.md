# v0.9.0 — Trust Package Plan Overview

**Version target:** `0.9.0+1`  
**Branch base:** `fix/v0.9.0-critical-fixes`  
**Schema:** **v28** (`lib/core/database/app_database.dart`)  
**Theme:** Honesty SSOT · Security harden · Test gates · God-file extract · Release path  
**Status:** **NEAR COMPLETE** — A–E automation + **G1 product_form_page** + **G2 barcode session**; store console upload remains human
---

## Goal

ปิดช่องว่าง trust-cut ของ CE offline POS ให้ GitHub tag พร้อม “Go” และเตรียม store path โดยไม่ทำลาย money-path semantics:

1. เอกสาร = โค้ด (restore / schema / claims)
2. App lock + backup discipline แข็งขึ้น
3. Characterization + smoke gates ก่อน tag
4. แยก god files บน sale → product แบบ behavior-preserving
5. Signing docs + dry-run release (store assets เป็นเฟสถัดไป)

---

## Go / No-Go (หลังปิดแพ็กเกจ)

| ช่องทาง | เป้า |
|---------|------|
| GitHub trust-cut tag | Conditional Go → **Go** |
| Play / App Store | **No-Go** จนกว่า E5 store packaging ปิด |

---

## Principles (Locked)

| Topic | Decision |
|-------|----------|
| Money path | **Behavior-preserving** — ไม่เปลี่ยน payable / stock / freeze โดยไม่ตั้งใจ |
| Docs | **SSOT = code** ก่อน public claim |
| Tests | Characterization **เขียวก่อน** แล้วค่อย extract god files |
| Delivery | PR เล็ก ทีละ concern (เมื่อลงมือ) |
| God files | หั่นเฉพาะ multi-responsibility — **ไม่** vanity-split theme/migrations/l10n |
| This document | Plan/checklist only until implement order |

---

## Workstream Overview

| WS | Theme | Blocks | Risk |
|----|-------|--------|------|
| **A** | Honesty SSOT (docs/privacy/security) | Trust messaging | 🟢 Low (docs) / 🔴 if skipped |
| **B** | Security harden (PIN / backup UX) | Trust + fraud | 🟡 Medium |
| **C** | Test & smoke gates | Tag | 🟡 Medium |
| **D** | God-file extract (sale P0 → product P1) | Maintainability | 🟡–🔴 if untested |
| **E** | Release path (signing, AAB, store later) | Tag partial / Store | 🟢–🟡 |

**Recommended execution order when implementing:**

```
A ∥ B  →  C (nets)  →  D (extract)  →  E (release/store)
```

**Do not start W-D god splits before W-C has a usable money-path net.**

---

## Why This Order

```
A + B (trust surface)
  → เอกสารผิด + PIN อ่อน = บล็อก reputational/security ทันที
  → ทำคู่ขนานได้ (docs vs code)

C (gates)
  → ตาข่ายก่อนแตะ sale_local_datasource / cart_bloc
  → trust suite + smoke cashier paths

D (god extract)
  → ลดความเสี่ยง maintain บนเส้นทางเงิน
  → PR เล็ก: helpers → query → void → insert → presentation

E (release)
  → signing SSOT + dry-run ก่อน store
  → assets/listing หลัง binary นิ่ง
```

---

## God-file inventory (post extract)

| Label | Count | Notes |
|-------|------:|-------|
| True GOD (money + product form) | **0** | sale DS / cart / product form page extracted |
| Borderline | **~1** | `checkout_body` ~538 (optional further extract) |
| Soft-god | **~2** | `product_bloc`, `sale_page` — only if hot-path pain |
| Barcode scanner | ✅ | G2 session extract — not god |
| Large cohesive ≥500 | **~10+** | theme, migrations, draft_bloc, filter UI — **do not vanity-split** |

Detail: see `V090-TRUST-D-GOD-FILES.md` (D1–D3 + **G1**).

---

## Sprint map (priority order — no hard calendar)

| Sprint | Focus | Items |
|--------|--------|-------|
| **0** | Docs + sec start | A1–A6, B1–B5 design, C1–C3 |
| **1** | Gates | C4–C6, smoke fill, baseline suite green |
| **2** | Sale extract | D0, D1.1–D1.4 |
| **3** | UI extract | D2.1–D2.2 |
| **4** | Product + release | D3.*, E1–E3, tag readiness |
| **5** | Store optional | E4–E5, B6 |

---

## Quality gates per milestone

| Milestone | Gate |
|-----------|------|
| After **A** | No restore/schema doc contradictions |
| After **B** | New PIN/backup policy + unit tests |
| After **C** | Trust suite green + cashier smoke paths Pass |
| Each **D** PR | `flutter analyze` + touched tests; no payable/stock semantic drift |
| Before **GitHub tag** | A+B+C done; D1 done or deferred with reason; E1–E3 |
| Before **Store** | + E2, E5, privacy/Data safety, 0 open critical security |

---

## Trust suite (minimum green before tag)

```
sale_local_datasource_test
sale_integrity_test
create_sale_test / void_sale_test
sale_payable_calculator_test / money tests
cart_bloc_test (+ option/state)
checkout_bloc_test
app_lock_service_test
backup_encryption_service_test
backup_restore_service_test
flutter analyze
```

Smoke source of truth: `docs/testing/RELEASE_0.9_SMOKE.md`

---

## Risk register

| Risk | L | I | Mitigation |
|------|---|---|------------|
| Extract breaks money | M | C | Tests before/after; never split insert/void transaction |
| PIN migration UX pain | M | H | Re-enroll flow; grace; clear copy |
| Doc SSOT drifts again | M | H | One master paragraph + pre-tag checklist |
| Unreleased UI ships as 0.9.0 | M | M | Freeze tag commits; 0.9.1 separate |
| E2E still soft-fail in CI | H | H | Separate trust suite; later blocking release job |
| God-split before tests | M | C | Enforce D0 after C |

---

## Explicit non-goals

- Implement in the plan-only phase
- Cloud sync / multi-device key export (Phase 2b = separate epic)
- Raising global coverage floor to 80% in one shot
- SOC2 / multi-region
- Vanity LOC cuts on `app_theme`, `app_database` migrations, l10n, `*.g.dart`

---

## Child documents

| Doc | Content |
|-----|---------|
| [V090-TRUST-A-HONESTY.md](./V090-TRUST-A-HONESTY.md) | Workstream A checklist |
| [V090-TRUST-B-SECURITY.md](./V090-TRUST-B-SECURITY.md) | Workstream B checklist |
| [V090-TRUST-C-GATES.md](./V090-TRUST-C-GATES.md) | Workstream C + trust suite |
| [V090-TRUST-D-GOD-FILES.md](./V090-TRUST-D-GOD-FILES.md) | Workstream D extract map |
| [V090-TRUST-E-RELEASE.md](./V090-TRUST-E-RELEASE.md) | Workstream E release/store |

---

## Next step when implementation is ordered

1. Start **W-A + W-B + W-C** (not W-D first).  
2. Land D0 baseline suite green, then D1 sale data extracts.  
3. Tag only after A+B+C gates (and D1 unless explicitly deferred).

**Current status:** plan captured — **no code/docs implementation performed in this step beyond this epic folder.**
