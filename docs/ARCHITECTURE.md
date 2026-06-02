# Architecture — Promsell POS CE v0.6.0

Deep technical reference for the system architecture: C4 model, data flow per feature, transaction boundaries, state management patterns, DI graph, error handling, and performance strategy.

> **Quick reference:** See [`CODEBASE.md`](../CODEBASE.md) for file maps and module summaries.
> **Database details:** See [`docs/DATABASE.md`](DATABASE.md) for schema, indexes, and query patterns.

---

## Table of contents

- [System Context (C4 Level 1)](#system-context-c4-level-1)
- [Container Diagram (C4 Level 2)](#container-diagram-c4-level-2)
- [Component Diagram (C4 Level 3)](#component-diagram-c4-level-3)
- [Data Flow — Sale Transaction](#data-flow--sale-transaction)
- [Data Flow — Void Sale](#data-flow--void-sale)
- [Data Flow — Manual Stock Adjustment](#data-flow--manual-stock-adjustment)
- [State Management Deep-Dive](#state-management-deep-dive)
- [Dependency Injection Graph](#dependency-injection-graph)
- [Transaction Boundaries](#transaction-boundaries)
- [Error Handling Strategy](#error-handling-strategy)
- [Performance & Scaling](#performance--scaling)
- [Architecture Decision Records (ADRs)](#architecture-decision-records-adrs)
- [PlantUML Source Files](#plantuml-source-files)

---

## System Context (C4 Level 1)

> PlantUML source: [`docs/architecture/c4-context.puml`](architecture/c4-context.puml)

```
┌─────────────────────────┐
│   👤 Merchant          │
│   Small shop owner    │
│   / cashier            │
└────────────┬────────────┘
             │ Manages sales, products,
             │ inventory, reports
             ▼
┌────────────────────────────────────────────────┐
│   Promsell POS CE                                │
│   Offline-first mobile POS — Flutter + SQLite     │
└────────────┬──────────────────────┬────────────┘
             │                      │
             ▼                      ▼
┌─────────────────┐   ┌───────────────────────┐
│ OS Share Sheet  │   │ Thermal Printer (future)│
│ PDF export      │   │ Bluetooth / USB         │
└─────────────────┘   └───────────────────────┘
```

**Key characteristics:**
- **Zero network dependencies** — fully offline by design
- **Single-user per device** — no authentication layer
- **Local-only persistence** — all data in SQLite on device

---

## Container Diagram (C4 Level 2)

> PlantUML source: [`docs/architecture/c4-container.puml`](architecture/c4-container.puml)

```
┌────────────────────────────────────────────────────┐
│   👤 Merchant → Touch interactions              │
└────────────────────────┬───────────────────────────┘
                         ▼
┌────────────────────────────────────────────────────┐
│  Presentation Layer                                │
│  Flutter Widgets + BLoC/Cubit  (5-tab shell UI)    │
└────────────────────────┬───────────────────────────┘
                   events │ method calls
                         ▼
┌────────────────────────────────────────────────────┐
│  Domain Layer                                      │
│  Pure Dart: Entities + UseCases + Repo interfaces   │
└────────────────────────┬───────────────────────────┘
              injected │ implementations
                         ▼
┌────────────────────────────────────────────────────┐
│  Data Layer                                        │
│  Repo impls + Datasources + Services               │
│  ReceiptPdfService (80mm thermal PDF)               │
│  PromptpayQrService (EMVCo QR)                      │
│  BackupService (export/import/CSV)                   │
│  ProductImageService (pure Dart compression)         │
└────────────────────────┬───────────────────────────┘
                Drift │ queries + transactions
                         ▼
┌────────────────────────────────────────────────────┐
│  SQLite (Drift ORM)                                │
│  9 tables • WAL • FK ON • UUIDv4 PKs                │
└────────────────────────────────────────────────────┘
```

### Layer rules

| Layer | Can depend on | Cannot depend on |
|-------|---------------|------------------|
| **Presentation** | Domain | Data (directly) |
| **Domain** | Nothing (pure Dart) | Flutter, Drift, packages |
| **Data** | Domain (implements interfaces) | Presentation |

---

## Component Diagram (C4 Level 3)

> PlantUML source: [`docs/architecture/c4-component.puml`](architecture/c4-component.puml)

```
┌──────────────────── Presentation ───────────────────────┐
│                                                       │
│  SalePage ──┐   HistoryPage ──┐   ReportPage          │
│  PaymentSheet ┤   VoidDialog   │                       │
│              ▼                ▼              │        │
│         SaleBloc        HistoryBloc   ReportCubit    │
│         ProductBloc                                   │
└─────────┬─────────────┬─────────────┬─────────────┘
          │             │             │
          ▼             ▼             ▼
┌────────────────────── Domain ────────────────────┐
│                                                       │
│  CreateSale   VoidSale   AdjustStock                  │
│  GetProducts  WatchSaleHistory  WatchReport            │
│                                                       │
└─────────┬─────────────┬─────────────┬─────────────┘
          │             │             │
          ▼             ▼             ▼
┌─────────────────────── Data ─────────────────────┐
│                                                       │
│  SaleRepositoryImpl   ProductRepositoryImpl           │
│  HistoryRepositoryImpl                                │
│       │                      │                        │
│       ▼                      ▼                        │
│  SaleLocalDatasource   ProductLocalDatasource          │
│       │                                               │
│       ├───→ ReceiptNumberService                       │
│       ├───→ InventoryLogService                        │
│       │                                               │
│  ProductImageService ──→ SettingsCubit (image settings)│
│  SettingsLocalDatasource (app_settings)                │
└───────────────────────┬─────────────────────────────┘
                        │
                        ▼
┌───────────────────── Storage ────────────────────┐
│                                                       │
│  SQLite (Drift)                                       │
│  9 tables • WAL • FK ON • UUIDv4 PKs                  │
└─────────────────────────────────────────────────────┘
```

---

## Data Flow — Sale Transaction

> PlantUML source: [`docs/architecture/sequence-sale.puml`](architecture/sequence-sale.puml)

```
Merchant → SalePage → SaleBloc → CreateSale → SaleLocalDatasource
                                                    │
                ┌───────────────────────────────────────────┘
                │  TRANSACTION BEGIN
                │
                ├──→ ReceiptNumberService.next()
                │       read/write app_settings (seq, date)
                │       ──→ returns "260527-A1-0042"
                │
                ├──→ INSERT sale (id, receiptNumber, status=COMPLETED,
                │         subtotalAmount, vatMode, vatRate, vatAmount)
                │
                ├── FOR EACH cart item:
                │   ├──→ INSERT sale_item
                │   ├──→ UPDATE products SET stock = stock - qty
                │   └──→ InventoryLogService.logSale()
                │            INSERT inventory_logs (type=SALE, qty=-N)
                │
                │  TRANSACTION COMMIT
                └───────────────────────────────────────────┘
                                                    │
SaleLocalDatasource → CreateSale → SaleBloc → SalePage → Merchant
                      (Sale entity)   (emit SaleSuccess)  (toast)
```

### Guarantees

- **Atomicity** — all-or-nothing: if any step fails, entire transaction rolls back
- **Receipt uniqueness** — sequence counter incremented inside same transaction
- **Audit completeness** — every stock deduction has a matching `inventory_logs` row
- **Stock integrity** — pre-validates ALL items have sufficient stock before any write

---

## Data Flow — Void Sale

> PlantUML source: [`docs/architecture/sequence-void.puml`](architecture/sequence-void.puml)

```
Merchant → HistoryPage [Tap "Void Sale"]
             │
             ├── Show confirm dialog (optional reason)
             │
             └─→ VoidSale.call(saleId, reason)
                    │
                    └─→ SaleLocalDatasource.voidSale()
                            │
                ┌────────────┘
                │  TRANSACTION BEGIN
                │
                ├──→ SELECT sale WHERE id = saleId
                │       └── if status == VOIDED → throw StateError
                │
                ├──→ UPDATE sales SET status=VOIDED, voidedAt, voidReason
                │
                ├──→ SELECT sale_items WHERE saleId
                │
                ├── FOR EACH item:
                │   ├──→ UPDATE products SET stock = stock + qty
                │   └──→ InventoryLogService.logVoidReversal()
                │            INSERT inventory_logs (type=VOID_REVERSAL, qty=+N)
                │
                │  TRANSACTION COMMIT
                └────────────────────────────────┘
                            │
            HistoryPage ← success
            Merchant ← "Sale voided" snackbar + VOIDED badge
```

### Edge cases

| Scenario | Behavior |
|----------|----------|
| Already voided | Throws `StateError` — UI shows error snackbar |
| Product deleted since sale | Skip stock restore, still log reversal with `balanceAfter = -1` |
| Network interruption | N/A — fully local operation |

---

## Data Flow — Manual Stock Adjustment

> PlantUML source: [`docs/architecture/sequence-adjust-stock.puml`](architecture/sequence-adjust-stock.puml)

```
Merchant → AdjustStockDialog [Enter qty ±, reason, confirm]
             │
             └─→ AdjustStock.call(productId, qtyChange, reason)
                    │
                ┌───┘
                │  TRANSACTION BEGIN
                │
                ├──→ ProductRepository.getProductById()
                │       └── returns Product(stock = currentStock)
                │
                ├── newStock = currentStock + qtyChange
                │       └── if newStock < 0 → throw (insufficient stock)
                │
                ├──→ ProductRepository.updateProduct(stock: newStock)
                │       UPDATE products SET stock = newStock
                │
                ├──→ InventoryLogService.logAdjustment()
                │       INSERT inventory_logs
                │       (type=ADJUSTMENT_IN or ADJUSTMENT_OUT)
                │
                │  TRANSACTION COMMIT
                └──────────────────────────────┘
                    │
AdjustStockDialog ← success → close dialog + refresh product
```

---

## State Management Deep-Dive

### Pattern selection rationale

| Pattern | Used by | Why chosen |
|---------|---------|------------|
| **BLoC** (event-driven) | `SaleBloc`, `ProductBloc`, `HistoryBloc` | Multiple event types, complex async flows, stream subscriptions |
| **Cubit** (method-driven) | `SettingsCubit`, `ReportCubit` | Simple state, no event classes needed, direct method calls |

### BlocListener ordering caution

Multiple `BlocListener`s subscribed to the same BLoC receive emissions in **subscription order**. When a modal (via `showModalBottomSheet`) and its parent page both listen to the same BLoC, the parent listener fires first because it was registered earlier. If the parent listener pushes a new route while the modal listener tries to pop, the pop removes the newly pushed route instead of the modal, leaving the modal open. The fix is to defer any push from the parent listener using `WidgetsBinding.instance.addPostFrameCallback`, giving the modal's pop time to execute in the current frame first.

### Singleton vs Factory BLoCs

| Registration | Instance | Reason |
|-------------|----------|--------|
| `@LazySingleton` | `ProductBloc` | Shared across Sale + Product tabs — same product list everywhere |
| `@LazySingleton` | `SettingsCubit` | Global app state (locale, theme) — must persist across navigation |
| `@LazySingleton` | `ReportCubit` | Persistent singleton — date range preserved across tab navigation; `load()` called once in `ReportPage.initState()` |

### State immutability

All state classes extend `Equatable` for:
- **Efficient rebuilds** — `BlocBuilder` only rebuilds when state actually changes
- **Predictable testing** — state comparison via value equality
- **Debug logging** — meaningful `toString()` output

### Stream lifecycle

```
HistoryBloc subscribes → WatchSaleHistory → Drift watchQuery (SQLite trigger)
                                               ↓
                         Auto-emits new state when DB row changes
                                               ↓
                         UI rebuilds (e.g. VOIDED badge appears after void)
```

Drift's `watch()` queries use SQLite update hooks — no polling, no manual refresh needed.

---

## Dependency Injection Graph

Registered in `lib/core/di/injection_container.dart` via `injectable` + `get_it` (generated config in `injection_container.config.dart`).

```
┌─────────────────── BLoCs / Cubits ───────────────────────┐
│                                                           │
│  ProductBloc ──→ GetProducts, AddProduct,                 │
│                  UpdateProduct, DeleteProduct              │
│  SettingsCubit ──→ SettingsRepository                     │
│  ReportCubit (lazySingleton) ──→ WatchReport               │
│                                                           │
└──────────┬────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Use Cases ────────────────────────────┐
│                                                           │
│  CreateSale ──→ SaleRepository                            │
│  VoidSale ──→ SaleRepository                              │
│  AdjustStock ──→ ProductRepository + InventoryLogService  │
│  GetProducts / Add / Update / Delete ──→ ProductRepository│
│  WatchSaleHistory ──→ HistoryRepository                   │
│  WatchReport ──→ HistoryRepository                        │
│                                                           │
└──────────┬────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Repositories ─────────────────────────┐
│                                                           │
│  SaleRepository ──→ SaleLocalDatasource                   │
│  ProductRepository ──→ ProductLocalDatasource             │
│                       ──→ ProductImageService              │
│  HistoryRepository ──→ SaleLocalDatasource                │
│  SettingsRepository ──→ SettingsLocalDatasource         │
│                                                           │
└──────────┬────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Datasources & Services ───────────────┐
│                                                           │
│  SaleLocalDatasource ──→ AppDatabase                      │
│       ├──→ ReceiptNumberService ──→ AppDatabase           │
│       └──→ InventoryLogService ──→ AppDatabase            │
│  ProductLocalDatasource ──→ AppDatabase                   │
│  ProductImageService ──→ SettingsCubit (imageMaxWidth/Quality)│
│  SettingsLocalDatasource ──→ AppDatabase                  │
│  ReceiptPdfService (stateless)                            │
│  PromptpayQrService (stateless)                           │
│  BackupService (stateless)                                │
│                                                           │
└──────────┬────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Database ─────────────────────────────┐
│                                                           │
│  AppDatabase (singleton)                                  │
│  SQLite • Drift ORM • 9 tables • WAL • FK ON             │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Registration order

1. **Database** (singleton — created once, shared)
2. **Datasources** (lazy — depends on DB)
3. **Services** (lazy — depends on DB)
4. **Repositories** (lazy — depends on datasources)
5. **Use Cases** (lazy — depends on repositories)
6. **BLoCs/Cubits** (singleton or factory)

---

## Transaction Boundaries

Every stock-mutating operation runs inside a **single Drift transaction** to guarantee atomicity.

| Operation | Transaction scope | Tables touched |
|-----------|------------------|----------------|
| **Create Sale** | 1 sale + N items + N stock updates + N logs + 1 receipt seq | `sales`, `sale_items`, `products`, `inventory_logs`, `app_settings` |
| **Void Sale** | 1 sale update + N stock restores + N reversal logs | `sales`, `products`, `inventory_logs` |
| **Adjust Stock** | 1 product update + 1 log | `products`, `inventory_logs` |

### Design rules

1. **Services never open their own transactions** — they participate in the caller's ambient transaction
2. **Stock pre-validation happens before any writes** — prevents partial deductions
3. **Every stock change has a matching log** — enforced by service API design (no raw UPDATE allowed)
4. **Idempotency guard for void** — check `status != VOIDED` before proceeding

---

## Error Handling Strategy

### Layer-specific patterns

| Layer | Strategy |
|-------|----------|
| **Datasource** | Throw Dart exceptions (`StateError`, `ArgumentError`) on constraint violations |
| **Repository** | Catches DB exceptions, wraps in domain-specific failures (when needed) |
| **Use Case** | Propagates exceptions — no silent swallowing |
| **BLoC/Cubit** | Catches in event handler, emits error state |
| **UI** | Reacts to error state → shows `AppSnackBar.error()` |

### Transaction failure recovery

```dart
try {
  await _db.transaction(() async { ... });
} catch (e) {
  // Transaction auto-rolled back by Drift
  // No partial state possible
  rethrow; // Let BLoC handle error state
}
```

### Specific error scenarios

| Error | Source | Handling |
|-------|--------|----------|
| Insufficient stock | `SaleLocalDatasource` | Throw before writes; BLoC shows "Stock insufficient" snackbar |
| Double void | `SaleLocalDatasource` | `StateError("Already voided")` → UI error snackbar |
| Product not found | Repository | Returns `null` → use case throws `ArgumentError` |
| DB corruption | SQLite | Drift WAL recovery; worst case: app reinstall |

---

## Performance & Scaling

### Write performance

| Operation | Expected latency | Bottleneck |
|-----------|-----------------|------------|
| Create sale (5 items) | ~5–10 ms | N inserts + N updates in single tx |
| Void sale (5 items) | ~3–8 ms | N updates + N inserts |
| Stock adjustment | ~1–2 ms | 1 update + 1 insert |
| Receipt number generation | ~0.5 ms | 1 read + 1 write (app_settings) |

### Read performance

| Query | Index used | Expected latency |
|-------|-----------|-----------------|
| Active products list | `idx_products_is_active` | ~1–3 ms |
| Sale history (30 days) | `idx_sales_created_at` | ~2–5 ms |
| Sale items for 1 sale | `idx_sale_items_sale_id` | <1 ms |
| Inventory logs for product | `idx_inventory_logs_product_id` | ~1–2 ms |
| Filter by status | `idx_sales_status` | ~1–2 ms |

### Scaling characteristics

- **WAL mode** — concurrent reads during writes (no reader blocking)
- **Lazy-loaded tabs** — only active tab is built; visited tabs kept alive via `_cachedPages` map
- **Stream-based queries** — Drift watch() uses SQLite update hooks, zero polling
- **Lazy DI registration** — services only instantiated on first access
- **UUID generation** — pure Dart, ~1μs per call, no I/O

### Memory considerations

- `ProductBloc` singleton — shared product list, single subscription
- `ReportCubit` lazySingleton — date range persists across tab navigation; `load()` guarded to `initState()` only
- Drift query streams — auto-disposed when BLoC is closed

---

## Architecture Decision Records (ADRs)

### ADR-001: Drift over raw SQLite

**Context:** Need type-safe database access with code generation.

**Decision:** Use Drift (formerly Moor) as SQLite ORM.

**Consequences:**
- ✅ Type-safe queries, compile-time schema validation
- ✅ Built-in migration support
- ✅ Reactive streams via `watch()` with SQLite update hooks
- ✅ In-memory DB for testing (real SQL execution)
- ⚠️ Requires code generation step (`build_runner`)
- ⚠️ Generated file is large (~290KB)

---

### ADR-002: BLoC + Cubit hybrid

**Context:** Need state management that scales from simple settings to complex sale flows.

**Decision:** Use `flutter_bloc` with BLoC for complex event-driven flows and Cubit for simple state.

**Consequences:**
- ✅ Testable (event→state is deterministic)
- ✅ Separation: UI dispatches events, never calls business logic directly
- ✅ Cubit reduces boilerplate for simple cases
- ⚠️ Learning curve for event/state pattern

---

### ADR-003: injectable + get_it for DI

**Context:** Need dependency injection with compile-time safety.

**Decision:** Use `injectable` annotations + `get_it` service locator with code generation.

**Consequences:**
- ✅ Compile-time dependency graph verification
- ✅ Annotations (`@injectable`, `@LazySingleton`, `@lazySingleton`, `@module`) are self-documenting
- ✅ Generated config in `injection_container.config.dart`
- ✅ Singleton + factory + lazy patterns supported
- ⚠️ Requires `build_runner` code generation step

---

### ADR-004: Services run inside caller's transaction

**Context:** `ReceiptNumberService` and `InventoryLogService` need to participate in atomic transactions.

**Decision:** Services accept the ambient transaction context — they never open their own `_db.transaction()`.

**Consequences:**
- ✅ Atomic: receipt + sale + items + logs all commit or all rollback together
- ✅ No nested transaction issues (SQLite doesn't support savepoints well in all scenarios)
- ✅ Testable: service can be tested with its own transaction in isolation
- ⚠️ Caller must ensure transaction is open before calling service

---

### ADR-005: Receipt number generated inside transaction

**Context:** Need unique receipt numbers without collisions under concurrent access.

**Decision:** Generate receipt number inside the sale transaction by reading/incrementing `app_settings` counter.

**Consequences:**
- ✅ Serialized by transaction lock — impossible to get duplicate numbers
- ✅ Daily reset via date comparison inside same atomic operation
- ✅ Format (`YYMMDD-XX-NNNN`) is human-readable and sortable
- ⚠️ Slight serialization overhead (transactions queue)

---

### ADR-006: Inventory logs are immutable append-only

**Context:** Need audit trail for all stock mutations.

**Decision:** `inventory_logs` table is append-only — no UPDATE or DELETE ever.

**Consequences:**
- ✅ Complete audit history — can reconstruct stock balance at any point in time
- ✅ Tamper-evident — any gap in logs indicates data corruption
- ✅ `balanceAfter` provides running total without aggregation query
- ⚠️ Table grows indefinitely (acceptable for POS scale — see DB size estimates)

---

### ADR-007: Soft-voided sales, not hard-deleted

**Context:** Voided sales must remain in history for audit purposes.

**Decision:** Void sets `status=VOIDED` + `voidedAt` timestamp — never DELETE the sale row.

**Consequences:**
- ✅ Full audit trail preserved
- ✅ Report filtering by status is trivial (`WHERE status = 'COMPLETED'`)
- ✅ UI can show voided sales with visual indicator
- ⚠️ History list grows (mitigated by date-range filtering)

---

### ADR-009: Deferred route push after modal pop (addPostFrameCallback)

**Context:** Both a modal bottom sheet (`PaymentSheet`) and its parent page (`_CartPanel`) listen to `SaleBloc`. On `SaleStatus.success`, the parent listener (subscribed first) pushes a receipt dialog before the modal listener can pop the sheet. `Navigator.pop()` then removes the dialog, not the modal — leaving it open and `_submitted = true` permanently.

**Decision:** Wrap any `showDialog` call in the parent `BlocListener` with `WidgetsBinding.instance.addPostFrameCallback`. The dialog push is deferred to the next frame, after the modal's `Navigator.pop()` has already run.

**Consequences:**
- ✅ Modal always closes correctly before the receipt dialog appears
- ✅ No change to the BLoC or event model
- ✅ Single-line fix — zero architectural overhead
- ⚠️ Slight one-frame delay before the dialog is visible (imperceptible at 60+ fps)

---

### ADR-008: Feature-first folder structure

**Context:** Need clear module boundaries as app grows through R1–R5 phases.

**Decision:** `lib/features/<name>/` with Clean Architecture layers inside each feature.

**Consequences:**
- ✅ Each feature is self-contained (can be understood in isolation)
- ✅ No cross-feature imports enforced by convention
- ✅ Easy to add new features without touching existing ones
- ⚠️ Some code duplication across features (acceptable trade-off for isolation)

---

### ADR-012: Pure Dart image compression over native plugin

**Context:** Product image compression previously used `flutter_image_compress` (native platform channels). This added a native dependency, complicated the build, and couldn't be configured at runtime.

**Decision:** Replace with the `image` package (pure Dart). Compression settings (`imageMaxWidth`, `imageQuality`) are stored in `AppSettings` and read via `SettingsCubit`, allowing merchant configuration without app rebuild.

**Consequences:**
- ✅ No native dependency — simpler build, no platform channel issues
- ✅ Runtime-configurable quality/size via settings
- ✅ Thumbnail generation in same pass (200px + full size)
- ✅ `CachedNetworkImage` replaces `Image.network` for better UX (placeholder, error widget, disk cache)
- ✅ Async file existence check replaces sync `existsSync()` — no frame jank
- ⚠️ Pure Dart decoding is slower than native libyuv for very large images (acceptable for POS photo scale)
- ⚠️ `image` package increases APK size by ~2MB (wasm/JS decoder)

---

### ADR-010: Draft cart auto-save via Timer debounce in BLoC

**Context:** Cart state changes rapidly on every tap (add item, change qty, apply discount). Saving to SQLite synchronously on every event would cause write thrashing.

**Decision:** Use a `Timer?` field in `SaleBloc`. Every cart-mutating handler cancels the previous timer and schedules a new 500 ms save. The save captures `state.activeDraftId` at schedule time and validates it's still the same draft at fire time.

**Consequences:**
- ✅ Batches rapid edits into a single write
- ✅ No lost state — even a crash within the 500 ms window only loses the last 500 ms of changes
- ✅ `Timer` is cancelled in `close()` to prevent post-dispose writes
- ⚠️ `SaleBloc` must be registered as `factory` (not singleton) so each `SalePage` instance gets its own timer lifecycle

---

### ADR-011: Discount applied before VAT (preTaxTotal)

**Context:** Merchants expect discounts to reduce the taxable amount, not the final total.

**Decision:** VAT is calculated on `preTaxTotal = itemsSubtotal - cartDiscountAmount`, not on the raw sum of item prices.

```
preTaxTotal = sum(item.subtotal) - cartDiscountAmount
INCLUSIVE: subtotal = preTaxTotal / (1 + vatRate)
EXCLUSIVE: finalTotal = preTaxTotal + (preTaxTotal * vatRate)
```

**Consequences:**
- ✅ Correct tax semantics (discount reduces taxable base)
- ✅ Receipt math is consistent: subtotal + VAT = total
- ✅ Per-item `discountAmount` stored at sale time for accurate historical reprints
- ⚠️ Payment sheet must read `SaleState.total` (preTaxTotal) not the raw `itemsSubtotal`

---

## PlantUML Source Files

Detailed diagrams are available as `.puml` files for rendering with PlantUML tools:

| File | Diagram |
|------|---------|
| [`docs/architecture/c4-context.puml`](architecture/c4-context.puml) | System Context (C4 Level 1) |
| [`docs/architecture/c4-container.puml`](architecture/c4-container.puml) | Container Diagram (C4 Level 2) |
| [`docs/architecture/c4-component.puml`](architecture/c4-component.puml) | Component Diagram — Sale Feature (C4 Level 3) |
| [`docs/architecture/sequence-sale.puml`](architecture/sequence-sale.puml) | Sale Transaction Sequence |
| [`docs/architecture/sequence-void.puml`](architecture/sequence-void.puml) | Void Sale Sequence |
| [`docs/architecture/sequence-adjust-stock.puml`](architecture/sequence-adjust-stock.puml) | Stock Adjustment Sequence |

### Rendering PlantUML locally

```bash
# Install PlantUML (requires Java)
brew install plantuml   # macOS
choco install plantuml  # Windows

# Generate PNG from all .puml files
plantuml docs/architecture/*.puml

# Generate SVG
plantuml -tsvg docs/architecture/*.puml
```

Or use the [PlantUML VS Code extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) for live preview.

---

<sub>Promsell POS CE · v0.6.0 · Architecture Document · Deep Technical Reference</sub>
