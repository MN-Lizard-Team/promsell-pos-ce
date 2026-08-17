# CE Scaling Management Plan

## Goal

Define the measurable capability envelope that Promsell POS CE must support, and prioritize scaling work without expanding to multi-device/sync until there is a separate product requirement and architecture.

**Scope:** v0.9.2 post trust cut → v1.0 and CE maintenance
**Non-goal:** multi-device sync, multi-shop, cloud backup, and server-side tenancy
**Existing SSOT:** `docs/ARCHITECTURE.md`, `docs/DATABASE.md`, `docs/readme/roadmap.md`, `docs/plan/UN-COMPLETE/POST-090-MANAGE/WS-B-QA-HARDENING.md`

## Capacity Contract

CE is considered within the production-supported envelope when it meets every item below on a mid-range Android device as defined in the benchmark fixture:

| Resource | Supported baseline | Upper-bound watch list | How to measure |
|---|---:|---:|---|
| Active products | 2,000 | 10,000 | DB-backed catalog search/page |
| Sales | 50,000 | 100,000 | File-backed SQLCipher fixture |
| Sale items | 250,000 | 500,000 | History/report/export benchmark |
| Inventory logs | 150,000 | 300,000 | Product audit/history benchmark |
| Report range | 1 year | 2 years | SQL summary + paged detail |
| Product search result | 50 rows/page | 100 rows/page | Cursor pagination |
| Export | 10,000 rows/request | 50,000 with streaming | Temp-file/chunked writer |
| Database size | 100 MB target | 512 MB operational guardrail* | Main DB + WAL + temp space |
| Sale cart | 20 lines | 50 lines | Money-path transaction benchmark |
| Concurrent UI surfaces | 2 history/report watchers | 3 | Stream/query load test |

`*` The 512 MB value is a proposed operational guardrail aligned with the current restore limit (`BackupRestoreService.maxBackupBytes`); it must be validated against device free-space and backup-duration measurements before becoming a user-facing hard limit.

> **Evidence caveat (2026-08-17):** All P0/P1 benchmark numbers in this plan are measured on **desktop `flutter test` using a plain `NativeDatabase` over a temp file** — not real SQLCipher and not a real Android device. SQLCipher adds per-page AES-CBC overhead on every read/write, so on-device p95 will be slower than desktop numbers by more than just the CPU ratio. Checkout, backup, and migration baselines have **no on-device evidence yet**. The SLO targets below are **contract intent**, not validated Android measurements. On-device validation is a P2 prerequisite before claiming any SLO as met.

> **Unknown ceiling above 100K sales:** The contract defines a supported baseline (50K) and an upper-bound watch list (100K, with migration benchmark evidence only). Behavior at 200K / 500K / 1M sales is **unknown** — there is no stress test that finds the breaking point. The 512 MB guardrail is the only hard ceiling today. A "known degradation curve" test (measuring p95 at 100K / 250K / 500K even if SLO fails) is a P2 follow-up so the contract can state an approximate failure point instead of leaving the upper range blank.

### Contract semantics

- **Supported baseline:** must operate without degrading correctness, money precision, or backup safety
- **Upper-bound watch list:** used to catch regressions and plan before reaching failure point; not yet a guarantee for every device
- **Unknown ceiling:** above 100K sales / 500K items, there is no evidence — the contract does not claim support and does not state a failure point
- **Operational guardrail:** 512 MB is a watch ceiling aligned with the current `maxBackupBytes`; it is not a direct SQLite limit — when approaching, backup/archive/maintenance must be signaled
- **Single-device:** no consistency contract across multiple devices

## SLO and Quality Gates

### Runtime SLO

| Operation | Target p95 | Gate |
|---|---:|---|
| Barcode/product lookup | <150 ms | Blocking |
| Catalog first page | <500 ms | Blocking |
| Catalog search after debounce | <500 ms | Blocking |
| Checkout sale, ≤20 lines | <500 ms | Blocking |
| History first page | <800 ms | Blocking |
| Daily report summary | <1 s | Blocking |
| Year report summary | <3 s | Blocking |
| Export start feedback | <500 ms | User feedback gate |
| Migration v31→v32 at baseline | <60 s | Release gate |
| Backup baseline DB | <30 s | Release gate |
| Crash-free critical money path | 100% in trust suite | Blocking |

> **SLO evidence status:** Checkout, backup, and migration rows have **no on-device evidence** — desktop fixture only. Year report (634ms desktop) is close to the 3s SLO ceiling and may fail on low-end Android with SQLCipher overhead. On-device validation is required before treating any SLO row as "met."

### Memory and storage gates

- Report/detail must not hydrate an entire year into state if it exceeds the page budget
- Export must have a row cap or streaming path
- Peak memory of the baseline report must not exceed 25% of the available app memory fixture
- Backup must check free storage before copy/encrypt
- WAL must have an observable size threshold and maintenance policy
- DB migration must have a file-backed large fixture, not only in-memory tests

### Correctness gates

- Sale, void, stock adjustment, and daily close must remain within the same transaction boundary
- Satang representation must not regress to floating-point as the money SSOT
- Pagination must not cause search to miss products that actually exist
- Report summary and paged detail must use the same date/status semantics
- Restore must validate schema, integrity, and foreign keys before swap

## Scaling Principles

1. **Measure before tuning:** use p50/p95/p99 and `EXPLAIN QUERY PLAN` before adding indexes or PRAGMAs
2. **Bound memory:** database pagination and SQL aggregation must happen before domain hydration
3. **Separate summary from detail:** report totals should not depend on the full-period `List<Sale>`
4. **Preserve atomicity:** reduce unnecessary transaction work, but do not split stock mutations until partial state occurs
5. **Prefer cursor pagination:** use `(created_at, id)` cursor instead of OFFSET for large data
6. **Keep CE simple:** do not add sync/cloud architecture unless there is a requirement
7. **Every claim needs evidence:** change backlog status to done only when there is benchmark/test/smoke evidence

## Roadmap

### P0 — Correctness-preserving scale foundation

**Owner profile:** Data-layer + Flutter runtime + QA

- [x] Create file-backed SQLCipher benchmark fixture at 2K products / 50K sales / 250K items
  — `test/helpers/scaling_fixture.dart` (file-backed `NativeDatabase` over temp file; desktop-safe analogue of SQLCipher). Seeds 2k/50k/250k/150k in ~9.3s. Verified by `test/performance/scaling_fixture_test.dart`.
- [x] Measure baseline of catalog, lookup, checkout, history, report, export, backup, and migration
  — `test/performance/p0_baseline_timing_test.dart` captures desktop-fixture timings (not device-accurate, CI trend signal): catalog first page 27ms, catalog search 4ms, barcode lookup 2ms, sku lookup 1ms, history first page 21ms, daily report 7ms, year report 634ms, export start 50ms — all under SLO targets. Checkout, backup, and migration baselines require the real SQLCipher library and are deferred to the P1 on-device `integration_test` suite.
- [x] Build `ProductPage` and DB-backed search/filter with cursor pagination support
  — `lib/features/product/domain/entities/product_page.dart`, `ProductLocalDatasource.getProductsPage` / `searchProductsPage`, `ProductRepository` + `GetProductsPage` / `SearchProductsPage` use cases. Cursor = `(createdAt, id)` DESC with composite index `idx_products_created_at_id_cursor`. Verified by `test/features/product/data/datasources/product_pagination_test.dart` (7 tests) and P0 regression (search finds `prod-scale-1999` beyond 500-row in-memory window).
- [x] Split history detail into paged query; UI must load only the current page
  — `lib/features/sale/domain/entities/sale_page.dart`, `SaleQueryLocalDatasource.querySalesPage` / `querySalesCount`, `SaleRepository.getSalesPage` + `GetSalesPage` use case. Items/payments hydrated only for the current page. Composite index `idx_sales_created_at_id_cursor`. Verified by `test/features/sale/data/datasources/sale_pagination_test.dart` (5 tests) and P0 regression (50k sales paginated without overlap; first page hydrates in 8ms).
- [x] Separate report summary/daily aggregation from sales detail hydration
  — `lib/features/report/domain/entities/report_summary.dart`, `SaleQueryLocalDatasource.queryReportSummary`, `SaleRepository.getReportSummary` + `GetReportSummary` use case. Satang-SSOT aggregation (INTEGER `*_satang` columns with REAL fallback). Payment lookup chunked to stay under SQLite variable limit. Verified by `test/features/report/data/datasources/report_summary_test.dart` (parity vs `SalesPeriodTotals.from`) and P0 regression (2-year/50k-sale summary in 1.2s).
- [x] Limit or stream CSV/PDF export by pushing the limit down to the datasource
  — `ReportExportService.exportCsvStream` pages via `SaleRepository.getSalesPage`, writes chunks to a sink callback, enforces `kExportMaxRows = 10000` cap, and resolves a `startSignal` future before the first data row. Verified by `test/features/report/data/services/export_stream_test.dart` (4 tests) and P0 regression (10k rows exported in 858ms, truncated=true on 50k-sale fixture).
- [x] Add regression tests for search beyond first page and year-range report
  — `test/performance/p0_regression_test.dart` (10 tests on full baseline fixture): search beyond 500-row window, pagination stability across soft-deletes, 2-year + 2024-only report summary, export cap + startSignal, paged history hydration + full 50k pagination. All pass.

**Exit:** pass Capacity Contract baseline with no functional gap when product count >500

### P1 — Database lifecycle and recovery

**Owner profile:** Database + platform/security + QA

- [x] Run migration v31→v32 benchmark at 50K/100K sales with duration budget
  — `test/performance/p1_migration_benchmark_test.dart`: 50K sales (250K items) migration 2.5s (budget 60s), 100K sales (500K items) migration 5.0s (budget 120s), idempotent reopen 2ms. All 3 tests pass.
- [x] Add migration status/recovery behavior and check free space before migration
  — `lib/core/database/migration_safety_service.dart` + `test/performance/p1_migration_safety_test.dart` (10 tests): `MigrationSafetyService` provides free-space preflight (2× DB size or 50 MB floor), file-based migration status tracking (idle/running/succeeded/failed), interrupted-migration detection on next launch, and schema version query.
- [x] Define WAL checkpoint/monitoring policy without disrupting money transactions
  — `lib/core/database/wal_checkpoint_service.dart` + `test/performance/p1_wal_health_test.dart` (7 WAL tests): `WalCheckpointService` with PASSIVE mode for safe background checkpoints during transactions, TRUNCATE mode for backup/day-close exclusive locks, 10 MB passive threshold, 50 MB hard limit, `checkpointIfNeeded()` and `forceTruncate()` APIs.
- [x] Add DB maintenance/health report: main DB, WAL, free storage, schema version
  — `lib/core/database/database_health_service.dart` + `test/performance/p1_wal_health_test.dart` (6 health tests): `DatabaseHealthService.generateReport()` collects main DB + WAL + SHM sizes, schema version, integrity check (optional), free storage, WAL checkpoint recommendations, 512 MB guardrail detection.
- [x] Add backup checksum, metadata, size preflight, and progress feedback
  — `lib/features/settings/data/services/backup_export_service.dart` enhanced with `BackupMetadata` (schema version, app version, timestamp, db size, SHA-256 checksum, encrypted flag), `exportToFiles()` / `exportWithMetadata()` with size preflight (512 MB max), progress callback (checkpointing → copying → checksumming → encrypting → sharing → done), `BackupMetadata.tryDecode()` for restore validation. `test/features/settings/data/services/backup_export_metadata_test.dart` (8 tests).
- [x] Execute Phase 2b recovery-kit per existing D0/D1; must support safe cross-device restore
  — `lib/core/database/recovery_kit_service.dart` + `test/core/database/recovery_kit_service_test.dart` (9 tests): `RecoveryKitService` implements D0/D1 spec — AES-256-GCM wrap of SQLCipher key with PBKDF2-HMAC-SHA256 (100K iterations) derived from user passphrase (min 8 chars), `.promkey` file format with JSON header + salt + nonce + ciphertext, export/import round-trip, wrong-secret/corrupt/tamper failure modes, key existence check and removal. **Status: code complete, device validation pending** — unit tests cover wrap/unwrap logic only; on-device cross-device restore (export `.promkey` + `.db` on device A → import on device B → open DB) is **not yet tested**. D2 device smoke remains the gate before claiming "supported."
- [x] Test restore with large encrypted fixture and interrupted swap
  — `test/performance/p1_restore_large_test.dart` (4 tests): 5K-sale (25K-item) encrypted backup restore preserves all data, interrupted swap leaves pre-restore backup for rollback, wrong PIN fails cleanly without touching live DB, corrupted schema rejected before swap. `BackupRestoreService` enhanced with `skipSqlCipherHeaderCheck` for test fixtures.

**Exit:** migration/backup/restore pass baseline and have an operator recovery runbook

### P2 — Runtime throughput and operational visibility

**Owner profile:** Flutter + observability + DevOps

- [ ] **On-device SLO validation (prerequisite for all SLO claims):** run the P0/P1 benchmark suite on real Android hardware (low-end, mid-range, tablet) with real SQLCipher — not desktop plain `NativeDatabase`. Checkout, backup, and migration baselines have **no on-device evidence yet**. Year report (634ms desktop) is close to the 3s SLO ceiling and may fail on low-end Android with SQLCipher per-page overhead.
- [ ] **Known degradation curve (capacity evidence above 100K):** measure p95 at 100K / 250K / 500K / 1M sales even if SLO fails, so the Capacity Contract can state an approximate breaking point instead of leaving the upper range blank. Today the contract has evidence only up to 100K (migration benchmark); 200K+ is unknown.
- [ ] Reduce full-stream rehydration of `watchSales` and define a backpressure strategy
- [ ] **Product search — LIKE → FTS5 trigger condition:** current `LIKE '%query%'` uses a leading wildcard, which forces a full table scan regardless of the `sku_lower` / `barcode_lower` indexes. At 2K–10K products this is ~1–10ms (passes SLO). Do **not** migrate to FTS5 now — instead, add a trigger condition: **migrate to SQLite FTS5 when (a) a merchant reports search lag at >10K products, or (b) on-device benchmark shows search p95 >200ms.** FTS5 cost: virtual table + sync trigger + schema complexity for CE — not justified without evidence of need.
- [ ] Cache/invalidate product filter result or move search computation down to DB
- [ ] Audit rebuild scope of SettingsCubit with DevTools before using broad selectors
- [ ] Run heavy export/report calculation in chunked or isolate mode per memory measurement
- [ ] Audit image network/local cache to use bounded cache and a single thumbnail policy
- [ ] Add privacy-preserving telemetry: operation latency, migration/backup result, DB size bucket, app/schema version
- [ ] Connect crash/error reporting in redacted form without sending PII or raw transaction data

**Exit:** on-device SLO evidence exists for at least one Android tier; known degradation curve covers 100K–500K; production dashboard/diagnostic export and a p95 trend that can be retroactively inspected

### P3 — CI/CD and long-term CE governance

**Owner profile:** DevOps + release manager + maintainer

- [ ] Split CI into parallel jobs: analyze, unit, performance, format, dependency, build
- [ ] Add Flutter/pub/build cache and test sharding as the suite grows
- [ ] Run nightly stress test as a trend report, not just pass/fail
- [ ] Store performance artifacts and fail when p95 regression exceeds 20%
- [ ] Define release train: patch for bug/security, minor for backward-compatible feature, major for schema/contract change
- [ ] Conduct quarterly capacity review from anonymized metrics and support incidents
- [ ] Review capacity contract every minor release; do not increase numbers without a benchmark

**Exit:** release process has performance evidence, rollback/recovery evidence, and capacity sign-off

## Dependency Graph

```text
P0 benchmark
 ├──► P0 catalog cursor/search
 ├──► P0 report summary/detail
 └──► P0 bounded export
          │
          ├──► P1 migration/backup large-fixture tests
          └──► P2 runtime tuning/telemetry

P1 recovery-kit ──► future multi-device product decision
P2 metrics ───────► P3 regression gates and quarterly capacity review
```

## Ownership Model

| Area | Primary | Required evidence |
|---|---|---|
| Catalog/search/pagination | Flutter + data | Query tests, page contract, p95 |
| Report/history | Data + Flutter | SQL aggregation tests, memory benchmark |
| Migration/WAL/DB health | Database | File-backed fixture, migration duration, integrity check |
| Backup/recovery | Security + platform | Encrypted restore, checksum, interrupted swap test |
| Stress/performance | QA | Repeatable fixture, trend artifact, p95 gate |
| CI/CD | DevOps | Parallel workflow, cache hit rate, artifact retention |
| Product scope/release | Maintainer/release owner | Capacity sign-off, changelog, operator runbook |

## Release Policy

### v0.9.2 / current release

- Do not claim unlimited catalog/history/report scalability
- Keep current single-device and same-device restore limitations explicit
- Treat `B6 Stress: app-path SLOs` as the first implementation anchor, not a duplicate roadmap
- Complete operator-owned trust/device smoke and Play gates separately from this engineering plan

### v1.0 gate

Must have:

- P0 baseline fixture and SLO evidence (**on-device Android, not desktop-only**)
- Product search works beyond first 500 records
- History/report bounded-memory path
- Export row limit or streaming behavior
- Migration and backup large-fixture results documented
- Recovery-kit D2 device smoke passes (export on device A → restore on device B) before claiming cross-device restore support
- No contradiction with `docs/DATABASE.md`, `docs/testing/CI.md`, `SECURITY.md`, or store submission docs

### v1.0.x

- P1 recovery and DB lifecycle work (recovery-kit D2 device smoke is the gate for "supported")
- P2 observability and runtime improvements (on-device SLO validation is the gate for "SLO met")
- No multi-device promise in CE listing until sync/recovery architecture is implemented and tested

## Definition of Done

A scaling item is `done` only when all applicable evidence exists:

1. Code path implemented and covered by tests
2. Baseline fixture passes target SLO (**on-device Android for SLO claims; desktop-only evidence is "code complete," not "done"**)
3. Large-fixture behavior is bounded or explicitly rejected with a user-facing reason
4. Failure/recovery path is tested
5. Documentation and store claims remain honest (no "implemented" without device evidence for device-dependent features)
6. CI or scheduled performance workflow records the result
7. Release owner signs off on capacity envelope

## Out of Scope Until Explicit Product Decision

- Cloud sync or multi-master merge
- Multi-shop/branch tenancy
- Unlimited report export
- Automatic cloud backup
- Distributed tracing across a server fleet
- CRDT/OT for inventory or financial events
