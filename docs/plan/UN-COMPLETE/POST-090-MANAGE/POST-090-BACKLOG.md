# Post-v0.9.0 — Backlog Checklist

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Status legend:** `todo` · `in_progress` · `done` · `blocked` · `deferred`  
**Rule:** เปลี่ยน status เมื่อมี evidence (PR / smoke / Console) — ห้าม mark done จากแผนอย่างเดียว

---

## Must (1.0 store / tag readiness)

| ID | Description | Depends | Evidence | Status |
|----|-------------|---------|----------|--------|
| A0 | Freeze Play checklist: human vs in-repo; Must/Should for store cut | — | `docs/STORE_SUBMISSION.md` §A0 (2026-07-20) | **done** |
| A1 | Production keystore + dual custody runbook; never throwaway for Play | A0 | Runbook in STORE_SUBMISSION (2026-07-20); **operator** still must generate JKS + secrets | **in_progress** |
| A2 | Play Data safety + content rating + pricing TH free draft ตรง PRIVACY | A0 | Data safety draft in STORE_SUBMISSION §A2 (2026-07-20); Console submit still operator | **in_progress** |
| A3 | CI: require signed prod AAB on `v*` (`require_signed_aab` or equivalent) | A1 | `release-aab.yml` tags fail-closed without secrets (2026-07-20); dry-run still needs operator secrets | **done** (CI gate) |
| A4 | Upload signed AAB to Play (internal/closed at minimum) | A1–A3 | Console version code | todo |
| A5 | Post-submit smoke on **prod** build per `RELEASE_1.0_SMOKE` Must | A4, B2 | Filled `RELEASE_1.0_SMOKE` or addendum | todo |
| B0 | Reconcile E2E docs vs soft CI vs runtime (no “30 ready” overclaim) | — | `testing.md` + `E2E_IMPLEMENTATION_STATUS.md` + guide + `integration_test/README` (2026-07-20) | **done** |
| B1 | Expand trust: payable golden, tender boundary, void closed-day, multi-tender daily_close, restore→money; expand path filter or `@Tags(['trust'])` | B0 optional | golden + promo gate + multi_tender_daily_close + backup_money_continuity + release-trust paths (2026-07-20 host green) | **done** |
| B2 | Create + run `docs/testing/RELEASE_1.0_SMOKE.md` matrix (≥2 devices or 1 physical+1 emu, prod AAB, TH) | B1 partial OK | Emulator API37: Must 1,2,4,7,9,10 Pass; 3 blocked unknown PIN; 5 not walked; 6/8 host; M2 open; throwaway AAB | **in_progress** |
| E0 | Spec: store PIN default-on + domain-level session/gate (not UI-only) | — | [WS-E](./WS-E-PRODUCT-UX.md) locked 2026-07-20 | **done** |

---

## Should (1.0.x)

| ID | Description | Depends | Evidence | Status |
|----|-------------|---------|----------|--------|
| B3 | Coverage policy: global ≥60%; **sale-logic** ≥80% hard; full sale tree 80 later | B1 | Global **60%** + sale-logic **80%** hard (2026-07-23, measured logic ~93%); full sale+domain tree ~58% still soft | **done** (money-path); 3b full-tree open |
| B4 | E2E blockers fixed in plan order: TestApp DI, CurrencyFormatter asserts, Keys; hard-gate 3–5 smokes | B0 | Emulator job green 3× then drop soft-fail for subset | todo |
| B5 | Security test pack: DbKeyStore, image sandbox, crash on-write PII, PIN UI gates | B1 | db_key_store + sandbox + crash + domain PIN + StorePinSetup tests in trust (2026-07-20) | **done** |
| C0 | Inventory all REAL money columns + dual-write design | B1 | [WS-C](./WS-C-PHASE-M-MONEY.md) full table + Option A locked 2026-07-20 | **done** |
| C1 | Migration v31+ INTEGER satang (or in-place) + non-finite audit | C0 | Migration PR + tests | todo |
| C2 | Drift `TypeConverter<Money,int>` / stop baht `.value` at writers | C1 | Code review | todo |
| C3 | Integration: legacy REAL fixtures → new schema; tender equality satang | C2 | Host tests green | todo |
| C4 | DATABASE / CHANGELOG / SECURITY honesty for Phase M | C3 | Docs PR | todo |
| D0 | Threat model for key export / cross-device restore | — | [WS-D](./WS-D-PHASE-2B-KEY-RESTORE.md) locked decisions 2026-07-20 | **done** |
| D1 | UX design: export envelope / recovery path / PIN | D0 | UX notes + copy TH/EN | todo |
| E1 | Tablet dual-pane sale + orientation policy | E0 optional | Feature PR + smoke | todo |
| E0c | Implement PIN default-on + domain gates (code) | E0 | Domain gates + onboarding default-on PIN finish/skip (2026-07-20); optional legacy first-action force still open | **done** |

---

## Could (later / help wanted)

| ID | Description | Depends | Evidence | Status |
|----|-------------|---------|----------|--------|
| D2 | Cross-device restore implementation + tests | D1 | Integration + device smoke | todo |
| D3 | PRIVACY / SECURITY / store listing update for 2b | D2 | Docs + listing | todo |
| D4 | First-run backup education (interim if 2b delayed) | — | Onboarding/settings UX | todo |
| E2 | Bluetooth thermal printer (CE help-wanted scaffold) | — | Design + optional plugin spike | todo |
| E3 | A11y mode real wiring + Semantics on sale/checkout | E1 optional | Manual a11y pass | todo |
| E4 | Discoverability microcopy (express cash, multi-tender) | — | l10n + UX | todo |
| B6 | Stress: app-path SLOs (catalog 5k, reports, backup large DB) | — | stress-test.yml or nightly | todo |
| A6 | Tablet store screenshots / feature graphic polish | A4 | Play assets | todo |

---

## Wave mapping (quick)

| Wave | IDs |
|------|-----|
| 0 | B0, A0 |
| 1 | B1, B2, A1, A2, E0 |
| 2 | A3, A4, A5, E0c (if scheduled) |
| 3 | C0–C4, D0–D1 |
| 4 | E1–E4, B3–B5, D2–D4, B6, A6 |

---

## Dependency graph (critical path)

```
B0 ──► B1 ──► B2 ──► A5
         │
         └──► C0 → C1 → C2 → C3 → C4

A0 → A1 → A3 → A4 → A5
A0 → A2 ────────┘

E0 → E0c → (optional) B5 PIN gates
D0 → D1 → D2 → D3
```

---

## Definition of Done (item-level)

1. Status `done` เฉพาะเมื่อมี evidence column ไม่ว่าง  
2. Money-path changes: trust suite green  
3. Docs changes: no contradiction with `SECURITY.md` / `CHANGELOG` known limits  
4. Store changes: operator sign-off noted in A5 / STORE_SUBMISSION  

---

<sub>Promsell POS CE · Post-0.9 backlog · PLAN ONLY</sub>
