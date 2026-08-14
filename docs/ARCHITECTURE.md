# Architecture — Promsell POS CE (v0.9.2)

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
ADRs 001–028 covering ORM, state, DI, transactions, audit trail, settings, widgets, generated code, barcodes, payable pipeline (027), and CE sync-metadata non-goals (028).

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
│   database/   — Drift schema v32, SQLCipher opener, satang converters           │
│   di/         — injectable + get_it DI                                          │
│   extensions/ — context.l10n helper                                             │
│   image/      — Unified image system                                            │
│   services/   — AppLock lifecycle, CrashLogService, secure-screen helpers       │
│   utils/      — Money, IdGenerator, payment_method, EAN-13, DateFormatter       │
│   widgets/    — shared UI primitives                                            │
└───────────────────────┬─────────────────────────────────────────────────────────┘
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

<sub>Promsell POS CE · v0.9.2 · Architecture Document · Deep Technical Reference</sub>
