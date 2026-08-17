# Workstream B — QA Hardening

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Backlog IDs:** B0–B6  
**Sources:** elite QA report; `docs/codebase/testing.md`; `docs/testing/*`; `.github/workflows/{ci,release-trust,stress-test}.yml`

---

## Goal

Make quality **honest and fail-closed at money-risk points** — do not overclaim E2E; expand trust; smoke 1.0; establish policy coverage/E2E/security tests

---

## Current baseline (v0.9.1 — do not inflate)

| Layer | Reality |
|-------|---------|
| Unit/widget | ~308 `*_test.dart` files; ~2028 tests pass (`--exclude-tags stress`); CI blocks |
| Host integration | `test/integration/` solid; in release-trust |
| Device E2E | `ci.yml` format/analyze only; `release-trust` **blocks** emulator `--flavor dev`; still scaffold/flake |
| Coverage floor | 60% global (CI gate); sale-logic ~92.4%; receipt low |
| Smoke | `RELEASE_0.9_SMOKE.md` honest device evidence |
| Stress | weekly; not merge-blocking |

---

## B0 — Doc honesty (Wave 0)

Align:

| File | Required message |
|------|------------------|
| `docs/codebase/testing.md` | E2E = not on `ci.yml`; trust blocking `--flavor dev`; host integration = hard money net |
| `docs/testing/E2E_IMPLEMENTATION_STATUS.md` | Update: analyze-clean vs runtime-ready; drop stale compile blockers if fixed |
| `docs/testing/E2E_TEST_GUIDE.md` | Prerequisites: device/emulator; known DI/selector risks |
| CI comments | Point at `docs/testing/CI.md` — do not revive `continue-on-error` |

**Exit:** No doc says “30 tests ready for runtime validation” without emulator evidence.

**Done 2026-07-20:** First honesty pass.  
**Updated 2026-08-13 (DOC-SSOT):** Live E2E docs + `CI.md` match YAML (no main-CI device run; trust blocking).

---

## B1 — Trust suite expand (Wave 1)

### Add fail-closed scenarios (host)

| Scenario | Suggested location |
|----------|-------------------|
| Payable golden matrix (line/cart/promo × SC × VAT) | ✅ `sale_payable_golden_test.dart` (2026-07-20) |
| Tender sum mismatch reject + exact multi-tender | ✅ already in `sale_local_datasource_test` |
| Void blocked on closed day (use case) | ✅ `void_sale_test` (repo mocked; full DB stack still optional) |
| `cart_discount_policy` + `receipt_number` in trust workflow | ✅ release-trust.yml (2026-07-20) |
| Path filter expand (inventory/product/promo/settings/db/pubspec) | ✅ release-trust.yml (2026-07-20) |
| Inactive / missing / expired promotion on create | ✅ `sale_local_datasource_test` (stock unchanged) |
| Multi-tender → daily_close expected cash | ✅ `test/integration/multi_tender_daily_close_test.dart` |
| Backup encrypt→restore money continuity | ✅ `test/integration/backup_money_continuity_test.dart` (satang snapshot + file path) |
| Empty/negative tender lines | ⬜ optional harden |

### Path filter / tags

- Expand PR paths: inventory, product price/stock, promotion, migrations, `pubspec.yaml`, settings backup tree  
- **Or** prefer `@Tags(['trust'])` discovery over hard-coded file list  

**Exit:** `release-trust.yml` green with expanded set; document list in this file when implemented.

**Partial 2026-07-20:**
- Added `sale_payable_golden_test.dart` (matrix + satang identity) — host tests **12/12 Pass**
- Trust workflow now includes golden, `cart_discount_policy_test`, `receipt_number_service_test`
- Path filters expanded: inventory, product, promotion, settings, database, pubspec
- Still open: tender boundary DS cases, void closed-day full stack, multi-tender daily_close cash, restore→money continuity

---

## B2 — RELEASE_1.0_SMOKE (Wave 1–2)

Create `docs/testing/RELEASE_1.0_SMOKE.md` (new file when implementing):

### Must cases
1. Cold start encrypted DB (prod flavor if possible)  
2. Cash sale E2E  
3. Void sale + stock restore  
4. Day lock: closed day rejects sale  
5. Draft park/reopen  
6. Multi-tender or PromptPay freeze (at least one)  
7. Store PIN enable + gate (void or stock)  
8. Backup encrypt export + same-device restore  
9. Trust suite automated Pass  
10. `flutter analyze` clean  

### Matrix
- ≥1 physical Android **or** 2 API levels  
- **Prod** AAB/APK for store cut  
- Locale TH primary  

### Should
- Search product/sale  
- CSV import PIN gate  
- Barcode scan (device camera)  

**Exit:** All Must Pass recorded with date/device.

**Partial 2026-07-20:** Emulator API 37 walk + trust 281 green + analyze clean. Day-lock **Pass** with Settings → block sales after day close ON (banner + checkout blocked). See `docs/testing/RELEASE_1.0_SMOKE.md`. Not production Go (M2, prod keystore, void full path with known PIN, draft re-walk).

---

## B3 — Coverage policy (Should)

| Target | Value |
|--------|------:|
| Global (CI excludes generated) | ≥ **60%** (ladder → 70 → **80** later) |
| **sale-logic** (sale `domain/` + `data/` + `lib/core/domain/`) | ≥ **80%** hard |
| Full `sale/**` + `core/domain` tree (incl. presentation) | report only until ≥80 + buffer |
| Receipt pure domain (not PDF plugin) | raise via goldens |

Implement as CI jobs/tickets — **not** vanity one-shot 80% global.

### Ladder (approved)

| Phase | Gate | Status |
|-------|------|--------|
| 0 | Measure baseline | **done** |
| 1 | `tool/check_path_coverage.dart` soft report on CI | **done** |
| 2 | Global `min_coverage` **60** | **done** (CI enforced 2026-07-22) |
| 3 | Path **sale-logic ≥80** hard (`--fail`) | **done** (2026-07-23; money path without presentation chrome) |
| 3b | Full sale+domain tree ≥80 hard | pending (~58% → 80%; presentation-heavy) |
| 4 | Global **70** | pending |
| 5 | Global **80** | pending (~5k more hits after excludes) |

### Measured snapshot (2026-07-23, after Phase 3 sale-logic gate)

```text
dart run tool/check_path_coverage.dart --fail --min-global=60 --min-sale-logic=80
global           17021/27487  61.92%
sale              4258/ 7422  57.37%
core/domain         29/   29 100.00%
sale+domain       4287/ 7451  57.54%
sale-logic        1042/ 1124  92.70%   ← hard gate
sale/domain        345/  382  90.31%
sale/data          668/  713  93.69%
sale/presentation 3245/ 6327  51.29%
✅ Coverage thresholds met.
```

| Next target | Approx shortfall |
|-------------|-----------------:|
| full sale+domain 80% | ~**1,670** lines (presentation) |
| global 70% | ~**2,220** lines |
| global 80% | ~**4,970** lines |

**CI today:** `tool/check_path_coverage.dart` **hard** `--fail --min-global=60 --min-sale-logic=80` (no `very_good_coverage`).  
**Hard rule:** raise a floor only when measured ≥ new floor + ~2 pp buffer (full-tree path 80 / global 70 still open).

---

## B4 — E2E hard smoke path (Should)

### Known blockers (from audit)
1. Double `configureDependencies` / DB in `integration_test/helpers/test_app.dart`  
2. Asserts via `Money.toString()` vs UI currency  
3. EN-only text finders; missing stable `Key`s  
4. CI ubuntu without emulator  

### Sequence
1. Fix TestApp DI + format asserts + Keys on cart/checkout/pay  
2. Emulator workflow job  
3. Hard-gate **3–5** tests (sale happy, draft, void/stock) after 3 consecutive greens  
4. Do not hard-gate all of `all_tests.dart` until 5 cases are green 3× (trust already blocks the whole file — treat flakes as a release risk)  

---

## B5 — Security test pack (Should)

| Test | Covers |
|------|--------|
| `db_key_store_test` | key create/persist; no prod fixed key |
| opener / plain reject | at-rest contract |
| image sandbox traversal | delete outside `images/` |
| crash_log on-write PII | not only export sanitize |
| PIN gate matrix | void/stock/CSV/PromptPay/backup when lock on |
| optional Gradle check | release without keystore fails |

---

## B6 — Stress / perf (Could)

Move beyond full-table SELECT:

- Catalog watch/page 5k SKUs  
- Barcode lookup  
- Checkout ≤20 lines  
- Report day/year  
- Backup large on-disk SQLCipher DB  

Suggested SLOs: see elite performance notes (p95 mid Android).

**Implemented (2026-08-17, unreleased):**

- **P0 performance regression tests** — `p0_regression_test.dart` (10 tests) covering cursor pagination (`getProductsPage`, `searchProductsPage`, `querySalesPage`), DB-backed product search, SQL report summary aggregate (`queryReportSummary`), and bounded streaming CSV export (`exportCsvStream`). Baseline timing captured in `p0_baseline_timing_test.dart`. Test fixture: `scaling_fixture.dart`.
- **P1 migration benchmarks** — `p1_migration_benchmark_test.dart` (3 tests) measuring migration throughput on large datasets.
- **P1 migration safety** — `p1_migration_safety_test.dart` (10 tests) covering free-space preflight, status tracking, and interrupted-migration detection.
- **P1 WAL/health** — `p1_wal_health_test.dart` (13 tests) covering WAL checkpoint (PASSIVE/TRUNCATE, 10MB/50MB thresholds) and database health report (sizes, schema version, integrity, 512MB guardrail).

**Still pending:** Full stress SLOs on physical devices (p95 mid Android measurement); nightly stress workflow integration.

---

## Exit criteria (WS-B for 1.0 Must)

- B0 done  
- B1 expanded trust green  
- B2 smoke file exists and Must Pass for store cut  
- B3–B5 tracked as Should with owners  

---

<sub>WS-B · COMPLETE (historical record)</sub>
