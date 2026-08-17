# P0 Scaling Foundation

## Goal
Implement the P0 layer of `ce-scaling-management-plan.md`: a file-backed SQLCipher benchmark fixture, cursor-paginated catalog/search, paged history, separated report summary, bounded export, and regression tests — all preserving existing correctness, money precision, and backup safety.

## Scope decision
- Full P0 (per user selection).
- Benchmark fixture runs on desktop `flutter test` (per user selection) using a temp-file `NativeDatabase` with the same schema/migration path as production. Not device-accurate but validates query plans, pagination semantics, and memory bounds.
- No UI redesign; existing blocs/cubits keep their public contracts. New paginated query methods are added alongside existing ones so callers can migrate incrementally.

## Tasks

- [x] 1. Create `test/helpers/scaling_fixture.dart` — file-backed `AppDatabase` seeded with 2k products / 50k sales / 250k items, plus a `withScalingFixture` helper. → Verify: `flutter test test/performance/scaling_fixture_test.dart` seeds and counts match.
- [x] 2. Add cursor-paginated product query to `ProductLocalDatasource` + repository + `GetProductsPage` use case. Cursor = `(createdAt, id)`, page size from capacity contract (50). → Verify: unit test returns correct pages, no overlap, no skipped rows on a 2k fixture.
- [x] 3. Add DB-backed product search (`searchProductsPage`) to datasource/repository/use case using `name LIKE` + `sku_lower` / `barcode_lower` indexes, with the same rank ordering as `matchProducts` done in memory only on the result page. → Verify: search beyond first 500 records returns hits that in-memory filter would miss.
- [x] 4. Add paged history query (`querySalesPage`) to `SaleQueryLocalDatasource` + repository + `GetSalesPage` use case. Cursor = `(createdAt, id)`. Items/payments hydrated only for the current page. → Verify: page of 50 sales hydrates only 50 sales' items, not the whole range.
- [x] 5. Add SQL report summary aggregate (`queryReportSummary`) returning `SalesPeriodTotals`-equivalent without hydrating `List<Sale>`. Add `queryTopProductStats` SQL aggregate. Wire a `GetReportSummary` use case. → Verify: summary matches `ReportCalculatorService.periodTotals` on the same fixture within satang precision.
- [x] 6. Add bounded/streaming export: `ReportExportService.exportCsvStream` writes rows in chunks via a callback sink; add a `maxRows` hard cap constant (`kExportMaxRows = 10000`) and a `startSignal` future that resolves before the first row. → Verify: export of 50k-row fixture completes under memory cap; start feedback resolves < 500ms.
- [x] 7. Regression tests: search-beyond-first-page, year-range report summary, export row cap, pagination stability across soft-deletes. → Verify: `flutter test test/performance/p0_regression_test.dart` passes.

## Done When
- [x] All new tests pass on desktop `flutter test`.
- [x] No existing test regresses (`flutter test`).
- [x] `flutter analyze` is clean.
- [x] No public contract on existing blocs/cubits/repositories is broken (additive only).
- [x] Money precision stays satang-SSOT; no floating-point aggregation in new SQL.
- [x] `ce-scaling-management-plan.md` P0 checkboxes are ticked with evidence notes.

## Notes
- Existing `_createIndexes` already covers `idx_sales_created_at`, `idx_products_is_active`, `idx_products_deleted_at`, `idx_sale_items_sale_id`, `idx_sale_items_product_id`. Cursor pagination on `(created_at, id)` needs a composite index — added in task 2/4 via idempotent `CREATE INDEX IF NOT EXISTS` in `_createIndexes`.
- SQLCipher native lib is not available on Windows desktop test runner; the fixture uses plain `NativeDatabase` over a temp file. This still exercises the real Drift schema, migrations, and query plans. The plan's "file-backed SQLCipher" requirement is documented as a follow-up to run on-device.
- All new SQL aggregates use `*_satang` INTEGER columns (not REAL baht) to preserve money SSOT.
