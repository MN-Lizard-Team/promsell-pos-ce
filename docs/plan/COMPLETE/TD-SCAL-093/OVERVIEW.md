# Technical Debt and Scalability Refactor

## Goal
Reduce verified scalability and dependency-boundary debt without changing sales, inventory, or backup behavior unexpectedly.

## Phase 1 — Baseline & Hardening (completed)

### Tasks
- [x] Baseline repository state and analyzer result → `flutter analyze` passes with no issues.
- [x] Map architecture, dependencies, data access, and test coverage → use `CODEBASE.md`, architecture docs, and targeted source review.
- [x] Replace database health page full-table row counting with bounded `COUNT(*)` queries behind `DatabaseHealthService` → verify with unit tests and analyzer.
- [x] Harden product subscription initialization so count/query failures emit a failure state instead of leaving the BLoC loading → verify with BLoC regression tests.
- [x] Review resulting diff for behavior changes and run formatter, analyzer, targeted tests, and full test suite where practical.

### Done When
- Database diagnostics use O(1) row-count queries and presentation does not access `AppDatabase` directly.
- Product loading failure is represented in `ProductState` and covered by a regression test.
- Existing analyzer/tests pass, or any unrelated baseline failures are reported explicitly.

---

## Phase 2 — Indexing, Caching, Testing, Organization, Coupling (completed)

### Tasks
- [x] Add composite index `idx_inventory_logs_product_id_created_at` on `(product_id, created_at DESC) WHERE deleted_at IS NULL` → covers `watchLogsByProduct` so the planner avoids full scan + sort on high-volume SKUs. Migration test verifies index existence and `EXPLAIN QUERY PLAN` usage.
- [x] Implement memory-based limit for `ReportCubit` cache → 50 MB ceiling (`_maxCacheMemoryBytes`) alongside the existing count limit (10 entries). `_evictCache()` removes oldest entries by `storedAt`. `_CacheEntry.estimatedBytes` approximates memory per entry (~1 KB per Sale). Cache eviction tests verify both count and memory limits.
- [x] Add tests for critical use cases → 43 new tests:
  - `submit_product` (11 tests) — add/edit, stock preservation, category clearing, trimming, image paths, option groups.
  - `sale_payable_calculator` (16 tests) — VAT NONE/EXCLUSIVE/INCLUSIVE, service charge, edge cases.
  - `adjust_stock` (5 tests) — app lock gate, delegation, error propagation, negative qty, ordering.
  - `update_settings` (11 tests) — sensitive field detection, lock enforcement, failure handling.
- [x] Split `app_database_migrations.dart` into version-based files → three `part of` extension files:
  - `app_database_migrations.dart` (~640 lines) — strategy, `createIndexes()`, seeds.
  - `app_database_migration_helpers.dart` (~215 lines) — dedup, backfill, `addColumnIfNotExists`.
  - `app_database_migration_v32_satang.dart` (~132 lines) — Phase M satang migration.
- [x] Reduce cross-feature domain coupling → moved `Sale`, `SaleItem`, `SalePayment`, `SelectedProductOption`, `SalesPeriodTotals` to `lib/shared/domain/entities/`. Original files are re-export shims. 23 files outside the sale feature updated to import from `shared/domain/`. Fixes reverse dependency in `core/utils/payment_method_helper.dart`.

### Done When
- `inventory_logs` per-product queries use the composite index (verified by `EXPLAIN QUERY PLAN` test).
- `ReportCubit` cache cannot grow unbounded in memory (verified by eviction tests).
- Four critical use cases have regression test coverage (43 tests).
- `app_database_migrations.dart` is under 700 lines with helpers and satang migration extracted.
- No file outside `lib/features/sale/` imports `features/sale/domain/entities/` for sale entities.
- `flutter analyze` → 0 errors. `flutter test` → 91 tests passing.

### Verification
- `flutter analyze` → **0 errors** (4 info lints in tests only — `prefer_const_constructors`).
- `flutter test` → **91 tests passing** across 8 test files:
  - `v092_c2_c3_migration_test.dart` (8 tests, including 2 new composite index tests)
  - `report_cubit_test.dart` (9 tests, including 2 new cache eviction tests)
  - `submit_product_test.dart` (11 tests, new)
  - `sale_payable_calculator_test.dart` (16 tests, new)
  - `adjust_stock_test.dart` (5 tests, new)
  - `update_settings_test.dart` (11 tests, new)
  - `product_bloc_test.dart` (regression, from Phase 1)
  - `p1_wal_health_test.dart` (regression, from Phase 1)
