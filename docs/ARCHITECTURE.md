# Architecture — Promsell POS CE (v0.9.1)

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
│   database/   — Drift schema, tables, DAOs                                      │
│   di/         — injectable + get_it DI                                          │
│   extensions/ — context.l10n helper                                             │
│   image/      — Unified image system                                            │
│   services/   — CrashLogService (PII sanitization, export/clear)                │
│   utils/      — IdGenerator, payment_method, Ean13Generator,                    │
│                 DateFormatter (@injectable)                                     │
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
│   ├── entities/             # Domain models (should be Flutter-free; settings still import Flutter)
│   ├── repositories/         # Abstract interfaces
│   └── usecases/             # Business logic
└── presentation/
    ├── bloc/ or cubit/       # State management
    ├── pages/                # Page-level UI
    └── widgets/              # Extracted reusable widgets
```

**Dependency rule:** `presentation → domain ← data`. **Target, not a CI fact.** Domain is not fence-enforced (AH-1.1). Known leaks: settings `Locale`/`ThemeMode`; CloseDay → sale data; some product image/submit use cases.

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

<sub>Promsell POS CE · v0.9.1 · Architecture Document · Deep Technical Reference</sub>
