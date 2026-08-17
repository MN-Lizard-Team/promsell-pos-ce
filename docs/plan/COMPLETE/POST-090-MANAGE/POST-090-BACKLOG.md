# Post-v0.9.0 — Backlog Checklist

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Status legend:** `todo` · `in_progress` · `done` · `blocked` · `deferred`  
**Rule:** Change status only when evidence exists (PR / smoke / Console) — do not mark done from plan alone

---

## Must (1.0 store / tag readiness)

| ID | Description | Depends | Evidence | Status |
|----|-------------|---------|----------|--------|
| A0 | Freeze Play checklist: human vs in-repo; Must/Should for store cut | — | `docs/STORE_SUBMISSION.md` §A0 (2026-07-20) | **done** |
| A1 | Production keystore + dual custody runbook; never throwaway for Play | A0 | Runbook in STORE_SUBMISSION (2026-07-20); **operator** still must generate JKS + secrets | **in_progress** |
| A2 | Play Data safety + content rating + pricing TH free draft aligned with PRIVACY | A0 | Data safety draft in STORE_SUBMISSION §A2 (2026-07-20); Console submit still operator | **in_progress** |
| A3 | CI: require signed prod AAB on `v*` (`require_signed_aab` or equivalent) | A1 | `release-aab.yml` tags fail-closed without secrets (2026-07-20); dry-run still needs operator secrets | **done** (CI gate) |
| A4 | Upload signed AAB to Play (internal/closed at minimum) | A1–A3 | Console version code | todo |
| A5 | Post-submit smoke on **prod** build per `RELEASE_1.0_SMOKE` Must | A4, B2 | Filled `RELEASE_1.0_SMOKE` or addendum | todo |
| B0 | Reconcile E2E docs vs soft CI vs runtime (no "30 ready" overclaim) | — | `testing.md` + `E2E_IMPLEMENTATION_STATUS.md` + guide + `integration_test/README` (2026-07-20) | **done** |
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
| C1 | Migration v31+ INTEGER satang (or in-place) + non-finite audit | C0 | v32 migration + 32 `*_satang` columns + NaN/Inf-safe backfill + file-backed v31→v32 fixture green (2026-08-14); encrypted pre-M backup restore remains pending | **done** (schema; backup fixture pending) |
| C2 | Drift `TypeConverter<Money,int>` / stop baht `.value` at writers | C1 | Nullable satang converter wired; sale/product/option/draft/customer/promotion/daily-close dual-writes; satang-first readers; exact tender equality; integer report aggregation (2026-08-14) | **done** |
| C3 | Integration: legacy REAL fixtures → new schema; tender equality satang | C2 | File-backed migration, dual-write/read fallback, one-satang rejection, void customer reversal, payable goldens, and fractional report aggregation green (2026-08-14) | **done** |
| C4 | DATABASE / CHANGELOG / SECURITY honesty for Phase M | C3 | Updated all three docs for active satang path, REAL compatibility boundary, deferred encrypted pre-M fixture, and current test status (2026-08-14) | **done** |
| D0 | Threat model for key export / cross-device restore | — | [WS-D](./WS-D-PHASE-2B-KEY-RESTORE.md) locked decisions 2026-07-20 | **done** |
| D1 | UX design: export envelope / recovery path / PIN | D0 | [WS-D](./WS-D-PHASE-2B-KEY-RESTORE.md) §D1 locked 2026-08-14 (TH/EN copy, flows, failure modes) | **done** |
| E1 | Tablet dual-pane sale + orientation policy | E0 optional | `SaleDualPane` (catalog|docked cart ≥840dp) + `_applyOrientationForDevice` (landscape on tablet ≥600dp shortest) + `DockedCartPanel` + widget tests (2026-08-14); tablet smoke + screenshots still operator | **done** (code); smoke pending operator |
| E0c | Implement PIN default-on + domain gates (code) | E0 | Domain gates + onboarding default-on PIN finish/skip (2026-07-20); optional legacy first-action force still open | **done** |

---

## Could (later / help wanted)

| ID | Description | Depends | Evidence | Status |
|----|-------------|---------|----------|--------|
| D2 | Cross-device restore implementation + tests | D1 | RecoveryKitService D0/D1 code complete (AES-256-GCM + PBKDF2 100K, `.promkey`, exportKit/importKit, 9 tests in `recovery_kit_service_test.dart`); **unreleased** — D2 device smoke (export A → restore B) still pending | **in_progress** |
| D3 | PRIVACY / SECURITY / store listing update for 2b | D2 | Docs + listing | todo |
| D4 | First-run backup education (interim if 2b delayed) | — | Onboarding/settings UX | todo |
| E2 | Bluetooth thermal printer (CE help-wanted scaffold) | — | Design + optional plugin spike | todo |
| E3 | A11y mode real wiring + Semantics on sale/checkout | E1 optional | Manual a11y pass | todo |
| E4 | Discoverability microcopy (express cash, multi-tender) | — | l10n + UX | todo |
| B6 | Stress: app-path SLOs (catalog 5k, reports, backup large DB) | — | P0 performance regression tests (10 tests in `p0_regression_test.dart`) + P0 baseline timing (`p0_baseline_timing_test.dart`) + P1 migration benchmark (3 tests in `p1_migration_benchmark_test.dart`) implemented — **unreleased**; full stress SLOs on device still pending | **in_progress** |
| A6 | Tablet store screenshots / feature graphic polish | A4 | Play assets | todo |

---

## Unreleased work (P0 scaling + P1 database lifecycle)

> These changes are in the `[Unreleased]` section of `CHANGELOG.md`, not yet tagged. Latest tag is still `v0.9.2`.

### P0 — Scaling foundation

| Item | Evidence | Status |
|------|----------|--------|
| Cursor-paginated queries (`getProductsPage`, `searchProductsPage`, `querySalesPage`) | Implemented; replaces full-table SELECT | **done** (unreleased) |
| DB-backed product search | Implemented; SQL `LIKE` with cursor pagination | **done** (unreleased) |
| SQL report summary aggregate (`queryReportSummary`) | Implemented; single-query aggregate replaces in-memory scan | **done** (unreleased) |
| Bounded streaming CSV export (`exportCsvStream`) | Implemented; chunked stream replaces unbounded load | **done** (unreleased) |
| New indexes: `idx_products_created_at_id_cursor`, `idx_sales_created_at_id_cursor` | Added within schema v32 | **done** (unreleased) |
| Performance tests | `p0_regression_test.dart` (10 tests), `p0_baseline_timing_test.dart`, `scaling_fixture.dart` | **done** (unreleased) |
| Planning docs | [ce-scaling-management-plan.md](./ce-scaling-management-plan.md), [p0-scaling-foundation.md](./p0-scaling-foundation.md) | **done** |

### P1 — Database lifecycle

| Item | Evidence | Status |
|------|----------|--------|
| `MigrationSafetyService` — free-space preflight, status tracking, interrupted-migration detection | Implemented; `p1_migration_safety_test.dart` (10 tests) | **done** (unreleased) |
| `WalCheckpointService` — PASSIVE/TRUNCATE modes, 10MB/50MB thresholds | Implemented; `p1_wal_health_test.dart` (13 tests) | **done** (unreleased) |
| `DatabaseHealthService` — health report (sizes, schema version, integrity), 512MB guardrail | Implemented; covered in `p1_wal_health_test.dart` | **done** (unreleased) |
| `BackupExportService` — `BackupMetadata` with SHA-256 checksum, size preflight, progress callback | Implemented; `backup_export_metadata_test.dart` (8 tests) | **done** (unreleased) |
| `RecoveryKitService` — AES-256-GCM + PBKDF2 (100K iterations), `.promkey` format, `exportKit`/`importKit` | Implemented; `recovery_kit_service_test.dart` (9 tests) — **code complete, device validation pending** | **done** (unreleased) |
| `BackupRestoreService` — `skipSqlCipherHeaderCheck`, `@ignoreParam` on `candidateValidator` | Implemented; `p1_restore_large_test.dart` (4 tests) | **done** (unreleased) |
| P1 migration benchmark | `p1_migration_benchmark_test.dart` (3 tests) | **done** (unreleased) |
| Total P1 tests | 47 new tests (3 + 10 + 13 + 8 + 9 + 4) | **done** (unreleased) |

### CI/DI fixes

| Item | Evidence | Status |
|------|----------|--------|
| `release-trust.yml` / `screenshots.yml` — removed incorrect `-t lib/main_dev.dart` from `flutter test` | `-t` in `flutter test` is `--tags` (test tag filter), not `--target`; was causing Android smoke suite to fail since v0.9.0 | **done** (unreleased) |
| `BackupRestoreService` — `@ignoreParam` on `candidateValidator` and `skipSqlCipherHeaderCheck` | Injectable code generation fix | **done** (unreleased) |

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

1. Status `done` only when evidence column is not empty  
2. Money-path changes: trust suite green  
3. Docs changes: no contradiction with `SECURITY.md` / `CHANGELOG` known limits  
4. Store changes: operator sign-off noted in A5 / STORE_SUBMISSION  

---

<sub>Promsell POS CE · Post-0.9 backlog · COMPLETE (historical record)</sub>
