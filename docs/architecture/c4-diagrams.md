# C4 Diagrams & Data Flows — Promsell POS CE v0.8.5

System context, container diagram, component diagram, and data flow sequences for all stock-mutating operations.

> **Main reference:** [`docs/ARCHITECTURE.md`](../ARCHITECTURE.md) — index + TOC
> **Technical deep-dive:** [`docs/architecture/technical-deep-dive.md`](technical-deep-dive.md) — state management, DI, transactions, error handling, performance
> **ADRs:** [`docs/architecture/adr/index.md`](adr/index.md) — all architecture decision records

---

## System Context (C4 Level 1)

> PlantUML source: [`docs/architecture/puml/c4-context.puml`](puml/c4-context.puml)

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
┌─────────────────┐   ┌─────────────────────────┐
│ OS Share Sheet  │   │ Thermal Printer (future)│
│ PDF export      │   │ Bluetooth / USB         │
└─────────────────┘   └─────────────────────────┘
```

**Key characteristics:**
- **Zero network dependencies** — fully offline by design
- **Single-user per device** — no authentication layer
- **Local-only persistence** — all data in SQLite on device

---

## Container Diagram (C4 Level 2)

> PlantUML source: [`docs/architecture/puml/c4-container.puml`](puml/c4-container.puml)

```
┌────────────────────────────────────────────────────┐
│   👤 Merchant → Touch interactions                 │
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
│  Pure Dart: Entities + UseCases + Repo interfaces  │
└────────────────────────┬───────────────────────────┘
                injected │ implementations
                         ▼
┌────────────────────────────────────────────────────────┐
│  Data Layer                                            │
│  Repo impls + Datasources + Services                   │
│  ReceiptPdfService (80mm thermal PDF)                  │
│  PromptPayQrCode (EMVCo QR widget)                     │
│  SlipVerifier (bank slip Mini-QR decoding)             │
│  SlipScannerDialog (QR camera scanner)                 │
│  BarcodeScannerDialog (product barcode scanner)        │
│  BackupService (export/import/CSV)                     │
│  ProductImageService (compression + format validation) │
│  ImageCacheService (LRU cache eviction)                │
└────────────────────────┬───────────────────────────────┘
                   Drift │ queries + transactions
                         ▼
┌─────────────────────────────────────────────────────┐
│  SQLite (Drift ORM)                                 │
│  9 tables • schema v17 • WAL • FK ON • UUIDv4 PKs   │
└─────────────────────────────────────────────────────┘
```

### Layer rules

| Layer | Can depend on | Cannot depend on |
|-------|---------------|------------------|
| **Presentation** | Domain | Data (directly) |
| **Domain** | Nothing (pure Dart) | Flutter, Drift, packages |
| **Data** | Domain (implements interfaces) | Presentation |

---

## Component Diagram (C4 Level 3)

> PlantUML source: [`docs/architecture/puml/c4-component.puml`](puml/c4-component.puml)

```
┌──────────────────── Presentation ───────────────────────┐
│                                                         │
│     SalePage ──┐  HistoryPage ──┐   ReportPage─┐        │
│  CheckoutPage  │   VoidDialog   │              │        │
│  PaymentSheet  │                │              │        │
│  CheckoutBody  │                │              │        │
│                ▼                ▼              ▼        │
│    CartBloc/DraftBloc/  HistoryBloc   ReportCubit       │
│    CheckoutBloc         ProductBloc   CategoryBloc      │
└─────────┬─────────────┬─────────────┬───────────────────┘
          │             │             │
          ▼             ▼             ▼
┌────────────────────── Domain ───────────────────────────┐
│                                                         │
│  CreateSale   VoidSale   AdjustStock  GetSales          │
│  GetProducts  WatchSaleHistory  WatchReport             │
│  GetSaleById  WatchSales  WatchRecentSales              │
│                                                         │
└─────────┬─────────────┬─────────────┬───────────────────┘
          │             │             │
          ▼             ▼             ▼
┌─────────────────────── Data ────────────────────────────┐
│                                                         │
│  SaleRepositoryImpl       ProductRepositoryImpl         │
│  HistoryRepositoryImpl       │                          │
│       │                      │                          │
│       ▼                      ▼                          │
│  SaleLocalDatasource   ProductLocalDatasource           │
│       │                                                 │
│       ├───→ ReceiptNumberService                        │
│       ├───→ InventoryLogService                         │
│       │                                                 │
│  ProductImageService ──→ SettingsRepository (image)     │
│  ImageCacheService ──→ image directory (LRU eviction)   │
│  SettingsLocalDatasource (app_settings)                 │
│  SettingsMapper (Settings ↔ Map<String,String>)         │
│  SettingsPersistenceService (debounce + save)           │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌───────────────────── Storage ───────────────────────────┐
│                                                         │
│  SQLite (Drift)                                         │
│  9 tables • WAL • FK ON • UUIDv4 PKs                    │
└─────────────────────────────────────────────────────────┘
```

---

## Data Flow — Sale Transaction

> PlantUML source: [`docs/architecture/puml/sequence-sale.puml`](puml/sequence-sale.puml)

```
Merchant → SalePage → CheckoutBloc → CreateSale → SaleLocalDatasource
                                                    │
                ┌───────────────────────────────────┘
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
                └───────────────────────────────────┬───────┘
                                                    │
SaleLocalDatasource → CreateSale → CheckoutBloc → SalePage → Merchant
                      (Sale entity)   (emit SaleSuccess)  (toast)
```

### Guarantees

- **Atomicity** — all-or-nothing: if any step fails, entire transaction rolls back
- **Receipt uniqueness** — sequence counter incremented inside same transaction
- **Audit completeness** — every stock deduction has a matching `inventory_logs` row
- **Stock integrity** — pre-validates ALL items have sufficient stock before any write

---

## Data Flow — Void Sale

> PlantUML source: [`docs/architecture/puml/sequence-void.puml`](puml/sequence-void.puml)

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
                └───────────┬────────────────────────────┘
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

> PlantUML source: [`docs/architecture/puml/sequence-adjust-stock.puml`](puml/sequence-adjust-stock.puml)

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
                └───┬──────────────────────────┘
                    │
AdjustStockDialog ← success → close dialog + refresh product
```

---

## PlantUML Source Files

Detailed diagrams are available as `.puml` files for rendering with PlantUML tools:

| File | Diagram |
|------|---------|
| [`docs/architecture/puml/c4-context.puml`](puml/c4-context.puml) | System Context (C4 Level 1) |
| [`docs/architecture/puml/c4-container.puml`](puml/c4-container.puml) | Container Diagram (C4 Level 2) |
| [`docs/architecture/puml/c4-component.puml`](puml/c4-component.puml) | Component Diagram — Sale Feature (C4 Level 3) |
| [`docs/architecture/puml/sequence-sale.puml`](puml/sequence-sale.puml) | Sale Transaction Sequence |
| [`docs/architecture/puml/sequence-void.puml`](puml/sequence-void.puml) | Void Sale Sequence |
| [`docs/architecture/puml/sequence-adjust-stock.puml`](puml/sequence-adjust-stock.puml) | Stock Adjustment Sequence |

### Rendering PlantUML locally

```bash
# Install PlantUML (requires Java)
brew install plantuml   # macOS
choco install plantuml  # Windows

# Generate PNG from all .puml files
plantuml docs/architecture/puml/*.puml

# Generate SVG
plantuml -tsvg docs/architecture/puml/*.puml
```

Or use the [PlantUML VS Code extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) for live preview.

---

<sub>Promsell POS CE · v0.8.5 · C4 Diagrams & Data Flows</sub>
