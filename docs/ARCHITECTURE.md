# Architecture — Promsell POS CE (v0.9.3)

Deep technical reference for the system architecture: C4 model, data flow per feature, transaction boundaries, state management patterns, DI graph, error handling, and performance strategy.

> **Quick reference:** See [`CODEBASE.md`](../CODEBASE.md) for file maps and module summaries.
> **Database details:** See [`docs/DATABASE.md`](DATABASE.md) for schema, indexes, query patterns, SQLCipher encryption.

---

## Table of contents

### [C4 Diagrams & Data Flows](architecture/c4-diagrams.md)
System context, container diagram, component diagram, and data flow sequences for all stock-mutating operations (sale, void, stock adjustment). Includes PlantUML source file references.

### [Technical Deep-Dive](architecture/technical-deep-dive.md)
State management patterns (BLoC vs Cubit, singleton vs factory, stream lifecycle), dependency injection graph, transaction boundaries, error handling strategy, and performance & scaling characteristics.

### [Architecture Decision Records (ADRs)](architecture/adr/index.md)
ADRs 001–036 covering ORM, state, DI, transactions, audit trail, settings, widgets, generated code, barcodes, payable pipeline (027), CE sync-metadata non-goals (028), cursor pagination (029), SQL report summary (030), streaming CSV export (031), DB lifecycle services (032), recovery kit key wrapping (033), backup metadata with SHA-256 checksum (034), shared domain entities for cross-feature coupling (035), and migration file split by version (036).

---

## System Overview

Offline-first mobile POS system — Flutter, Drift SQLite, BLoC/Cubit, Material 3.

```
┌──────────────────────────────────────────────────────┐
│   main.dart — App entry point (shared)               │
│   main_dev.dart / main_prod.dart — Flavor entry pts  │
│   MaterialApp wrapped in BlocBuilder<SettingsCubit>  │
│   5-tab NavigationBar shell with lazy-loaded tabs    │
└────────────────────────┬─────────────────────────────┘  
                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│   lib/features/ — 13 feature modules                                            │
│   home/ sale/ product/ customer/ promotion/ report/ settings/                   │
│   history/ inventory/ receipt/ daily_close/ restaurant_table/ onboarding/       │
│   (sale owns cart/checkout/drafts; report shell hosts history tab)              │
└────────────────────────┬────────────────────────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│   lib/core/   — Cross-cutting infrastructure                                    │
│   database/   — Drift schema v32, SQLCipher opener, satang converters,           │
│                 migration safety, WAL checkpoint, health report, recovery kit     │
│   di/         — injectable + get_it DI                                          │
│   extensions/ — context.l10n helper                                             │
│   image/      — Unified image system                                            │
│   services/   — AppLock lifecycle, CrashLogService, secure-screen helpers       │
│   utils/      — Money, IdGenerator, payment_method, EAN-13, DateFormatter       │
│   widgets/    — shared UI primitives                                            │
└───────────────────────┬─────────────────────────────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│   lib/shared/ — Shared domain entities (cross-feature)                          │
│   domain/entities/  — Sale, SaleItem, SalePayment, SelectedProductOption,      │
│                       SalesPeriodTotals (used by sale, report, history,        │
│                       receipt, daily_close, home; re-exported by sale feature   │
│                       for backward compatibility)                               │
└─────────────────────────────────────────────────────────────────────────────────┘
                        ▼
┌──────────────────────────────────────────────────────────┐
│   lib/l10n/ — Localization                               │
│   app_th.arb  — Thai (template)                          │
│   app_en.arb  — English                                  │
│   app_localizations.dart — GENERATED                     │
└──────────────────────────────────────────────────────────┘
```

### Layer structure (per feature)

Each feature under `lib/features/<name>/` follows Clean Architecture:

```
features/<name>/
├── data/
│   ├── datasources/          # Drift DAO wrappers
│   └── repositories/         # Repository implementations
├── domain/
│   ├── entities/             # Pure Dart domain models and value objects
│   ├── repositories/         # Abstract interfaces / ports
│   └── usecases/             # Business logic
└── presentation/
    ├── bloc/ or cubit/       # State management
    ├── pages/                # Page-level UI
    └── widgets/              # Extracted reusable widgets
```

**Dependency rule:** `presentation → domain ← data`. The import fence (`dart run tool/check_domain_fence.dart`) is enforced in CI for `lib/**/domain/**`; the current allowlist is empty. Use domain ports and presentation mappers when crossing boundaries.

### C4 Level 1 — System Context

```
┌─────────────────────────┐
│   👤 Merchant           │
│   Small shop owner      │
│   / cashier             │
└────────────┬────────────┘
             │ Manages sales, products,
             │ inventory, reports
             ▼
┌────────────────────────────────────────────────┐
│   Promsell POS CE                              │
│   Offline-first mobile POS — Flutter + SQLite  │
└────────────┬──────────────────────┬────────────┘
             │                      │
             ▼                      ▼
┌─────────────────┐   ┌───────────────────────────┐
│ OS Share Sheet  │   │ Thermal Printer (future)  │
│ PDF export      │   │ Bluetooth / USB           │
└─────────────────┘   └───────────────────────────┘
```

**Key characteristics:**
- **Offline-first selling** — no developer server; optional `INTERNET` only for product image URLs
- **Single-user per device** — store PIN, not multi-user auth
- **Local-only persistence** — SQLCipher SQLite on device

> Full C4 Level 2-3 diagrams and data flows: [`docs/architecture/c4-diagrams.md`](architecture/c4-diagrams.md)

---

## Database & Reliability Services (v0.9.2)

Schema v32 adds two cursor-pagination indexes for bounded large-list queries
(no schema version bump — indexes are within v32):

- `idx_products_created_at_id_cursor` — `products (created_at DESC, id)`
- `idx_sales_created_at_id_cursor` — `sales (created_at DESC, id)`

These back the cursor-paginated product (`getProductsPage` /
`searchProductsPage`) and sale history (`getSalesPage`) queries so memory is
bounded by page size, not by total row count.

### Core database services (`lib/core/database/`)

| Service | File | Responsibility |
|---------|------|----------------|
| `MigrationSafetyService` | `migration_safety_service.dart` | Free-space preflight (2× DB size / 50 MB floor), migration status tracking via `migration_status.json`, interrupted-migration detection on next launch |
| `WalCheckpointService` | `wal_checkpoint_service.dart` | WAL monitoring and checkpointing; `PASSIVE` mode for periodic background (10 MB threshold), `TRUNCATE` mode for backup/export/day-close (50 MB hard limit) |
| `DatabaseHealthService` | `database_health_service.dart` | `DatabaseHealthReport` with main/WAL/SHM sizes, schema version, integrity check, free storage, WAL recommendations; 512 MB operational guardrail (400 MB approaching) |
| `RecoveryKitService` | `recovery_kit_service.dart` | AES-256-GCM + PBKDF2 (100K iterations) wrapping of the SQLCipher key; `.promkey` file format; `exportKit()` / `importKit()` for key recovery |

### Settings data services (`lib/features/settings/data/services/`)

| Service | File | Responsibility |
|---------|------|----------------|
| `BackupExportService` | `backup_export_service.dart` | `BackupMetadata` with SHA-256 checksum; `exportToFiles()` / `exportWithMetadata()`; progress callback (`BackupProgress`); 512 MB size preflight |
| `BackupRestoreService` | `backup_restore_service.dart` | Same-device SQLCipher restore with staged swap + rollback; `skipSqlCipherHeaderCheck` test param; `@ignoreParam` on `candidateValidator` and `skipSqlCipherHeaderCheck` for injectable |

> Full API signatures: [`docs/api/CORE_MODULES.md`](api/CORE_MODULES.md)

---

<sub>Promsell POS CE · v0.9.3 · Architecture Document · Deep Technical Reference</sub>
