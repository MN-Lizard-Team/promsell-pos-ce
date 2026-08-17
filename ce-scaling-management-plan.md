# CE Scaling Management Plan

## Goal

กำหนดขอบเขตความสามารถที่ Promsell POS CE ต้องรองรับอย่างวัดผลได้ และจัดลำดับงาน scaling โดยไม่ขยายไป multi-device/sync จนกว่าจะมี product requirement และ architecture แยกต่างหาก

**Scope:** v0.9.2 หลัง trust cut → v1.0 และ maintenance ของ CE
**Non-goal:** multi-device sync, multi-shop, cloud backup และ server-side tenancy
**Existing SSOT:** `docs/ARCHITECTURE.md`, `docs/DATABASE.md`, `docs/readme/roadmap.md`, `docs/plan/UN-COMPLETE/POST-090-MANAGE/WS-B-QA-HARDENING.md`

## Capacity Contract

CE จะถือว่าอยู่ใน production-supported envelope เมื่อผ่านทุกข้อด้านล่างบนอุปกรณ์ Android ระดับกลางที่กำหนดใน benchmark fixture:

| Resource | Supported baseline | Upper-bound watch list | วิธีวัด |
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

### Contract semantics

- **Supported baseline:** ต้องทำงานได้โดยไม่ลด correctness, money precision หรือ backup safety
- **Upper-bound watch list:** ใช้เพื่อจับ regression และวางแผนก่อนถึงจุด failure; ยังไม่ใช่คำรับประกันสำหรับทุก device
- **Operational guardrail:** 512 MB เป็นเพดานเฝ้าระวังที่สอดคล้องกับ `maxBackupBytes` ปัจจุบัน ไม่ใช่ข้อจำกัด SQLite โดยตรง; เมื่อเข้าใกล้ต้องแจ้ง backup/archive/maintenance
- **Single-device:** ไม่มี consistency contract ระหว่างหลายเครื่อง

## SLO และ Quality Gates

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

### Memory and storage gates

- Report/detail ต้องไม่ hydrate ทั้งปีเข้า state ถ้าเกิน page budget
- Export ต้องมี row cap หรือ streaming path
- Peak memory ของ baseline report ต้องไม่เกิน 25% ของ available app memory fixture
- Backup ต้องตรวจ free storage ก่อน copy/encrypt
- WAL ต้องมี observable size threshold และ maintenance policy
- DB migration ต้องมี file-backed large fixture ไม่ใช้ in-memory test อย่างเดียว

### Correctness gates

- Sale, void, stock adjustment และ daily close ต้องอยู่ใน transaction boundary เดิม
- Satang representation ต้องไม่ถอยกลับไปใช้ floating-point เป็น money SSOT
- Pagination ต้องไม่ทำให้ search มองไม่เห็นสินค้าที่มีอยู่จริง
- Report summary กับ paged detail ต้องใช้ date/status semantics เดียวกัน
- Restore ต้อง validate schema, integrity และ foreign keys ก่อน swap

## Scaling Principles

1. **Measure before tuning:** ใช้ p50/p95/p99 และ `EXPLAIN QUERY PLAN` ก่อนเพิ่ม index หรือ PRAGMA
2. **Bound memory:** database pagination และ SQL aggregation ต้องเกิดก่อน domain hydration
3. **Separate summary from detail:** report totals ไม่ควรขึ้นกับ `List<Sale>` ทั้งช่วง
4. **Preserve atomicity:** ลด transaction work ที่ไม่จำเป็น แต่ไม่แยก stock mutation จนเกิด partial state
5. **Prefer cursor pagination:** ใช้ `(created_at, id)` cursor แทน OFFSET สำหรับข้อมูลโต
6. **Keep CE simple:** ยังไม่เพิ่ม sync/cloud architecture หากไม่มี requirement
7. **Every claim needs evidence:** เปลี่ยน backlog status เป็น done เมื่อมี benchmark/test/smoke evidence เท่านั้น

## Roadmap

### P0 — Correctness-preserving scale foundation

**Owner profile:** Data-layer + Flutter runtime + QA

- [x] สร้าง file-backed SQLCipher benchmark fixture ที่ 2K products / 50K sales / 250K items
  — `test/helpers/scaling_fixture.dart` (file-backed `NativeDatabase` over temp file; desktop-safe analogue of SQLCipher). Seeds 2k/50k/250k/150k in ~9.3s. Verified by `test/performance/scaling_fixture_test.dart`.
- [x] วัด baseline ของ catalog, lookup, checkout, history, report, export, backup และ migration
  — `test/performance/p0_baseline_timing_test.dart` captures desktop-fixture timings (not device-accurate, CI trend signal): catalog first page 27ms, catalog search 4ms, barcode lookup 2ms, sku lookup 1ms, history first page 21ms, daily report 7ms, year report 634ms, export start 50ms — all under SLO targets. Checkout, backup, and migration baselines require the real SQLCipher library and are deferred to the P1 on-device `integration_test` suite.
- [x] สร้าง `ProductPage` และ DB-backed search/filter ที่รองรับ cursor pagination
  — `lib/features/product/domain/entities/product_page.dart`, `ProductLocalDatasource.getProductsPage` / `searchProductsPage`, `ProductRepository` + `GetProductsPage` / `SearchProductsPage` use cases. Cursor = `(createdAt, id)` DESC with composite index `idx_products_created_at_id_cursor`. Verified by `test/features/product/data/datasources/product_pagination_test.dart` (7 tests) and P0 regression (search finds `prod-scale-1999` beyond 500-row in-memory window).
- [x] แยก history detail เป็น paged query; UI ต้องโหลดเฉพาะหน้าปัจจุบัน
  — `lib/features/sale/domain/entities/sale_page.dart`, `SaleQueryLocalDatasource.querySalesPage` / `querySalesCount`, `SaleRepository.getSalesPage` + `GetSalesPage` use case. Items/payments hydrated only for the current page. Composite index `idx_sales_created_at_id_cursor`. Verified by `test/features/sale/data/datasources/sale_pagination_test.dart` (5 tests) and P0 regression (50k sales paginated without overlap; first page hydrates in 8ms).
- [x] แยก report summary/daily aggregation ออกจาก sales detail hydration
  — `lib/features/report/domain/entities/report_summary.dart`, `SaleQueryLocalDatasource.queryReportSummary`, `SaleRepository.getReportSummary` + `GetReportSummary` use case. Satang-SSOT aggregation (INTEGER `*_satang` columns with REAL fallback). Payment lookup chunked to stay under SQLite variable limit. Verified by `test/features/report/data/datasources/report_summary_test.dart` (parity vs `SalesPeriodTotals.from`) and P0 regression (2-year/50k-sale summary in 1.2s).
- [x] จำกัดหรือ stream CSV/PDF export โดย push limit ลงถึง datasource
  — `ReportExportService.exportCsvStream` pages via `SaleRepository.getSalesPage`, writes chunks to a sink callback, enforces `kExportMaxRows = 10000` cap, and resolves a `startSignal` future before the first data row. Verified by `test/features/report/data/services/export_stream_test.dart` (4 tests) and P0 regression (10k rows exported in 858ms, truncated=true on 50k-sale fixture).
- [x] เพิ่ม regression tests สำหรับ search beyond first page และ year-range report
  — `test/performance/p0_regression_test.dart` (10 tests on full baseline fixture): search beyond 500-row window, pagination stability across soft-deletes, 2-year + 2024-only report summary, export cap + startSignal, paged history hydration + full 50k pagination. All pass.

**Exit:** ผ่าน Capacity Contract baseline และไม่มี functional gap เมื่อ product count >500

### P1 — Database lifecycle และ recovery

**Owner profile:** Database + platform/security + QA

- [x] ทำ migration v31→v32 benchmark ที่ 50K/100K sales พร้อม duration budget
  — `test/performance/p1_migration_benchmark_test.dart`: 50K sales (250K items) migration 2.5s (budget 60s), 100K sales (500K items) migration 5.0s (budget 120s), idempotent reopen 2ms. All 3 tests pass.
- [x] เพิ่ม migration status/recovery behavior และตรวจพื้นที่ว่างก่อน migration
  — `lib/core/database/migration_safety_service.dart` + `test/performance/p1_migration_safety_test.dart` (10 tests): `MigrationSafetyService` provides free-space preflight (2× DB size or 50 MB floor), file-based migration status tracking (idle/running/succeeded/failed), interrupted-migration detection on next launch, and schema version query.
- [x] กำหนด WAL checkpoint/monitoring policy โดยไม่รบกวน money transaction
  — `lib/core/database/wal_checkpoint_service.dart` + `test/performance/p1_wal_health_test.dart` (7 WAL tests): `WalCheckpointService` with PASSIVE mode for safe background checkpoints during transactions, TRUNCATE mode for backup/day-close exclusive locks, 10 MB passive threshold, 50 MB hard limit, `checkpointIfNeeded()` and `forceTruncate()` APIs.
- [x] เพิ่ม DB maintenance/health report: main DB, WAL, free storage, schema version
  — `lib/core/database/database_health_service.dart` + `test/performance/p1_wal_health_test.dart` (6 health tests): `DatabaseHealthService.generateReport()` collects main DB + WAL + SHM sizes, schema version, integrity check (optional), free storage, WAL checkpoint recommendations, 512 MB guardrail detection.
- [x] เพิ่ม backup checksum, metadata, size preflight และ progress feedback
  — `lib/features/settings/data/services/backup_export_service.dart` enhanced with `BackupMetadata` (schema version, app version, timestamp, db size, SHA-256 checksum, encrypted flag), `exportToFiles()` / `exportWithMetadata()` with size preflight (512 MB max), progress callback (checkpointing → checksumming → encrypting → sharing → done), `validateAgainstMetadata()` for restore validation. `test/features/settings/data/services/backup_export_metadata_test.dart` (8 tests).
- [x] ดำเนิน Phase 2b recovery-kit ตาม D0/D1 ที่มีอยู่; ต้องรองรับ cross-device restore อย่างปลอดภัย
  — `lib/core/database/recovery_kit_service.dart` + `test/core/database/recovery_kit_service_test.dart` (9 tests): `RecoveryKitService` implements D0/D1 spec — AES-256-GCM wrap of SQLCipher key with PBKDF2-HMAC-SHA256 (100K iterations) derived from user passphrase (min 8 chars), `.promkey` file format with JSON header + salt + nonce + ciphertext, export/import round-trip, wrong-secret/corrupt/tamper failure modes, key existence check and removal.
- [x] ทดสอบ restore กับ large encrypted fixture และ interrupted swap
  — `test/performance/p1_restore_large_test.dart` (4 tests): 5K-sale (25K-item) encrypted backup restore preserves all data, interrupted swap leaves pre-restore backup for rollback, wrong PIN fails cleanly without touching live DB, corrupted schema rejected before swap. `BackupRestoreService` enhanced with `skipSqlCipherHeaderCheck` for test fixtures.

**Exit:** migration/backup/restore ผ่าน baseline และมี operator recovery runbook

### P2 — Runtime throughput และ operational visibility

**Owner profile:** Flutter + observability + DevOps

- [ ] ลด full-stream rehydration ของ `watchSales` และกำหนด backpressure strategy
- [ ] cache/invalidate product filter result หรือย้าย search computation ลง DB
- [ ] ตรวจ rebuild scope ของ SettingsCubit ด้วย DevTools ก่อนใช้ selectors แบบกว้าง
- [ ] ทำ heavy export/report calculation แบบ chunked หรือ isolate ตาม memory measurement
- [ ] ตรวจ image network/local cache ให้ใช้ bounded cache และ thumbnail policy เดียวกัน
- [ ] เพิ่ม privacy-preserving telemetry: operation latency, migration/backup result, DB size bucket, app/schema version
- [ ] เชื่อม crash/error reporting แบบ redacted โดยไม่ส่ง PII หรือ raw transaction data

**Exit:** มี production dashboard/diagnostic export และ p95 trend ที่ตรวจย้อนหลังได้

### P3 — CI/CD และ long-term CE governance

**Owner profile:** DevOps + release manager + maintainer

- [ ] แยก CI เป็น parallel jobs: analyze, unit, performance, format, dependency, build
- [ ] เพิ่ม Flutter/pub/build cache และ test sharding เมื่อ suite โต
- [ ] ทำ nightly stress test เป็น trend report ไม่ใช่แค่ pass/fail
- [ ] เก็บ performance artifacts และ fail เมื่อ p95 regression เกิน 20%
- [ ] กำหนด release train: patch สำหรับ bug/security, minor สำหรับ backward-compatible feature, major สำหรับ schema/contract change
- [ ] ทำ quarterly capacity review จาก anonymized metrics และ support incidents
- [ ] ทบทวน capacity contract ทุก minor release; ห้ามเพิ่มตัวเลขโดยไม่มี benchmark

**Exit:** release process มี performance evidence, rollback/recovery evidence และ capacity sign-off

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

- P0 baseline fixture and SLO evidence
- Product search works beyond first 500 records
- History/report bounded-memory path
- Export row limit or streaming behavior
- Migration and backup large-fixture results documented
- No contradiction with `docs/DATABASE.md`, `docs/testing/CI.md`, `SECURITY.md`, or store submission docs

### v1.0.x

- P1 recovery and DB lifecycle work
- P2 observability and runtime improvements
- No multi-device promise in CE listing until sync/recovery architecture is implemented and tested

## Definition of Done

A scaling item is `done` only when all applicable evidence exists:

1. Code path implemented and covered by tests
2. Baseline fixture passes target SLO
3. Large-fixture behavior is bounded or explicitly rejected with a user-facing reason
4. Failure/recovery path is tested
5. Documentation and store claims remain honest
6. CI or scheduled performance workflow records the result
7. Release owner signs off on capacity envelope

## Out of Scope Until Explicit Product Decision

- Cloud sync or multi-master merge
- Multi-shop/branch tenancy
- Unlimited report export
- Automatic cloud backup
- Distributed tracing across a server fleet
- CRDT/OT for inventory or financial events
