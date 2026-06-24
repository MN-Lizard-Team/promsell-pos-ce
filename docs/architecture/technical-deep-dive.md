# Technical Deep-Dive — Promsell POS CE v0.8.5

State management patterns, dependency injection graph, transaction boundaries, error handling strategy, and performance characteristics.

> **Main reference:** [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) — index + TOC
> **C4 diagrams:** [`docs/architecture/c4-diagrams.md`](c4-diagrams.md) — system context, container, component, data flows
> **ADRs:** [`docs/architecture/adr/index.md`](adr/index.md) — all architecture decision records

---

## State Management Deep-Dive

### Pattern selection rationale

| Pattern | Used by | Why chosen |
|---------|---------|------------|
| **BLoC** (event-driven) | `CartBloc`, `DraftBloc`, `CheckoutBloc`, `ProductBloc`, `CategoryBloc`, `HistoryBloc` | Multiple event types, complex async flows, stream subscriptions |
| **Cubit** (method-driven) | `SettingsCubit`, `ReportCubit`, `InventoryLogCubit` | Simple state or stream-based data, no event classes needed, direct method calls |

### BlocListener ordering caution

Multiple `BlocListener`s subscribed to the same BLoC receive emissions in **subscription order**. When a modal (via `showModalBottomSheet`) and its parent page both listen to the same BLoC, the parent listener fires first because it was registered earlier. If the parent listener pushes a new route while the modal listener tries to pop, the pop removes the newly pushed route instead of the modal, leaving the modal open. The fix is to defer any push from the parent listener using `WidgetsBinding.instance.addPostFrameCallback`, giving the modal's pop time to execute in the current frame first.

### Singleton vs Factory BLoCs

| Registration | Instance | Reason |
|-------------|----------|--------|
| `@LazySingleton` | `ProductBloc` | Shared across Sale + Product tabs — same product list everywhere |
| `@LazySingleton` | `CategoryBloc` | Shared across Product + Category Management — same category list everywhere |
| `@LazySingleton` | `CartBloc`, `DraftBloc`, `CheckoutBloc` | Shared single instances across SalePage, CartPanel, CheckoutPage — prevents split-brain state (v0.8.3 fix from `@injectable` factory) |
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
┌─────────────────── BLoCs / Cubits ────────────────────────┐
│                                                           │
│  ProductBloc ──→ GetProducts, AddProduct,                 │
│                  UpdateProduct, DeleteProduct             │
│  CategoryBloc ──→ WatchCategories, AddCategory,           │
│                  UpdateCategory, DeleteCategory,          │
│                  ReorderCategories                        │
│  CartBloc ──→ (cart state, product add/remove/qty)        │
│  DraftBloc ──→ DraftCartRepository (persist/load drafts)  │
│  CheckoutBloc ──→ CreateSale, VoidSale                    │
│  SettingsCubit ──→ SettingsRepository                     │
│  ReportCubit (lazySingleton) ──→ WatchReport              │
│  InventoryLogCubit ──→ WatchInventoryLogs                 │
│                                                           │
└──────────┬────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Use Cases ───────────────────────────────────────────────┐
│                                                                             │
│  CreateSale ──→ SaleRepository                                              │
│  VoidSale ──→ SaleRepository                                                │
│  AdjustStock ──→ ProductRepository + InventoryLogService                    │
│  GetProducts / Add / Update / Delete ──→ ProductRepository                  │
│  WatchCategories / Add / Update / Delete / Reorder ──→ CategoryRepository   │
│  GetSales / GetSaleById ──→ SaleRepository                                  │
│  WatchSaleHistory ──→ HistoryRepository                                     │
│  WatchSales / WatchRecentSales ──→ SaleRepository                           │
│  WatchReport ──→ HistoryRepository                                          │
│  WatchInventoryLogs ──→ InventoryLogRepository                              │
│                                                                             │
└──────────┬──────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Repositories ────────────────────────────┐
│                                                             │
│  SaleRepository ──→ SaleLocalDatasource                     │
│  ProductRepository ──→ ProductLocalDatasource               │
│                       ──→ ProductImageService               │
│  CategoryRepository ──→ CategoryLocalDatasource             │
│  HistoryRepository ──→ SaleLocalDatasource                  │
│  InventoryLogRepository ──→ InventoryLogLocalDatasource     │
│  SettingsRepository ──→ SettingsMapper                      │
│                        ──→ SettingsLocalDatasource          │
│                                                             │
└──────────┬──────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Datasources & Services ──────────────────┐
│                                                             │
│  SaleLocalDatasource ──→ AppDatabase                        │
│       ├──→ ReceiptNumberService ──→ AppDatabase             │
│       └──→ InventoryLogService ──→ AppDatabase              │
│  ProductLocalDatasource ──→ AppDatabase                     │
│  InventoryLogLocalDatasource ──→ AppDatabase                │
│  ProductImageService ──→ SettingsRepository (image config)  │
│  ImageCacheService ──→ image directory (size tracking)      │
│  SettingsLocalDatasource ──→ AppDatabase                    │
│  ReceiptPdfService (stateless)                              │
│  PromptPayQrCode (stateless)                                │
│  SlipVerifier (stateless)                                   │
│  BackupService (stateless)                                  │
│                                                             │
└──────────┬──────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────── Database ────────────────────────────────┐
│                                                             │
│  AppDatabase (singleton)                                    │
│  SQLite • Drift ORM • 9 tables • WAL • FK ON                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
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

<sub>Promsell POS CE · v0.8.5 · Technical Deep-Dive</sub>
