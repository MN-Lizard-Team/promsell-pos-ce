# C4 Diagrams & Data Flows — Promsell POS CE (v0.9.3)

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
┌─────────────────┐   ┌──────────────────────────┐
│ OS Share Sheet  │   │ Thermal Printer (future) │
│ PDF export      │   │ Bluetooth / USB          │
└─────────────────┘   └──────────────────────────┘
```

**Key characteristics:**
- **Offline-first selling** — no developer server; optional `INTERNET` only for product image URLs
- **Single-user per device** — store PIN, not multi-user auth
- **Local-only persistence** — SQLCipher SQLite on device
- **Adaptive sale shell** — narrow layouts use `CartBottomBar`/`CompactCartFab`; tablet-width layouts use `SaleDualPane` with `DockedCartPanel`

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
│  Entities + UseCases + Repo interfaces             │
│  Pure Dart domain; import fence enforced in CI     │
└────────────────────────┬───────────────────────────┘
                injected │ implementations
                         ▼
┌──────────────────────────────────────────────────────────────┐
│  Data Layer                                                  │
│  Repo impls + Datasources + Services                         │
│  ReceiptPdfService (80mm thermal PDF)                        │
│  PromptPayQrCode (EMVCo QR widget)                           │
│  slip_verifier (bank slip Mini-QR decoding)                  │
│  SlipScannerDialog (QR camera scanner)                       │
│  Ean13Generator (@injectable, EAN-13 + Luhn check digit)     │
│  BackupExportService +                                       │
│  BackupRestoreService (export/share; same-device restore)    │
│  MoneySatangConverter (v32 dual-write/read boundary)         │
│  ProductImageService (compression + format validation)       │
│  BarcodeImageService (barcode PNG via RenderRepaintBoundary) │
│  ImageCacheService (LRU cache eviction)                      │
└────────────────────────┬─────────────────────────────────────┘
                   Drift │ queries + transactions
                         ▼
┌─────────────────────────────────────────────────────┐
│  SQLite (Drift ORM)                                 │
│  16 tables • schema v32 • WAL • FK ON • UUIDv4 PKs  │
└─────────────────────────────────────────────────────┘
```

### Layer rules

| Layer | Can depend on | Cannot depend on |
|-------|---------------|------------------|
| **Presentation** | Domain | Data (directly) |
| **Domain** | Nothing | Flutter, Drift, data, presentation; enforced by `tool/check_domain_fence.dart` |
| **Data** | Domain (implements interfaces) | Presentation |

---

## Component Diagram (C4 Level 3)

> PlantUML source: [`docs/architecture/puml/c4-component.puml`](puml/c4-component.puml)

```
┌──────────────────── Presentation ───────────────────────┐
│                                                         │
│     SalePage ──┐  HistoryPage ──┐   ReportPage─┐        │
│  CheckoutPage  │   VoidSaleDialog│             │        │
│  PaymentPage   │                │              │        │
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
│  WatchReport → ReportRepository (not HistoryRepository) │
│  VoidSale is owned by HistoryBloc, not CheckoutBloc     │
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
│  16 tables • schema v32 • WAL • FK ON • UUIDv4 PKs      │
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
                │         REAL compatibility amounts + INTEGER satang columns,
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
SaleLocalDatasource → CreateSale →   CheckoutBloc →   SalePage → Merchant
                     (Sale entity) (emit SaleSuccess)  (toast)
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
                │       └── if status == VOIDED → throw BusinessRuleError
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
| Already voided | Throws `BusinessRuleError` — UI shows error snackbar |
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
                    ├──→ AppLockService.requireSensitiveSession()
                    │       └── if store PIN on + session locked → throw
                    │
                    └──→ InventoryRepository.adjustStock()
                             │
                ┌────────────┘
                │  TRANSACTION BEGIN
                │
                ├──→ SELECT product WHERE id = productId
                │       └── if not found → throw StateError
                │
                ├── newStock = currentStock + qtyChange
                │       └── if newStock < 0 → throw (insufficient stock)
                │
                ├──→ UPDATE products SET stock = newStock
                │
                ├──→ INSERT inventory_logs
                │       (type=ADJUSTMENT_IN or ADJUSTMENT_OUT)
                │
                │  TRANSACTION COMMIT
                └───────────┬────────────────────┘
                            │
AdjustStockDialog ← success → close dialog + refresh product
```

---

## Data Flow — Cursor Pagination ([Unreleased])

> PlantUML source: [`docs/architecture/puml/sequence-cursor-pagination.puml`](puml/sequence-cursor-pagination.puml)

```
UI (ProductPage / HistoryPage)
  │  call(cursor: null, pageSize: 50)        ← first page
  └─→ UseCase → Repository → Datasource
         │
         └─→ SELECT * FROM products
              WHERE deleted_at IS NULL
                [AND active = 1]
              ORDER BY created_at DESC, id DESC
              LIMIT 51  -- +1 to detect hasMore
                    │
         ┌────────────┘
         │  rows.length > pageSize?
         │    yes → hasMore=true, nextCursor=Cursor(rows[49])
         │    no  → hasMore=false, nextCursor=null
         │
         ├──→ SELECT COUNT(*) → totalCount
         │
         └──→ ProductPage(products, nextCursor, totalCount)

UI scrolls to bottom → call(cursor: nextCursor, pageSize: 50)
  └─→ SELECT ... WHERE (created_at, id) < (cursor.createdAt, cursor.id)
       ORDER BY created_at DESC, id DESC LIMIT 51
```

Sale history uses the same pattern via `SaleQueryLocalDatasource.querySalesPage()`, with optional `from`/`to` date range applied before the cursor predicate. Items and payments are hydrated only for the current page (batched, not N+1).

---

## Data Flow — SQL Report Summary ([Unreleased])

> PlantUML source: [`docs/architecture/puml/sequence-report-summary.puml`](puml/sequence-report-summary.puml)

```
ReportPage → GetReportSummary.call(from, to)
  └─→ SaleRepository.getReportSummary(from, to)
       └─→ SaleQueryLocalDatasource.queryReportSummary(from, to)
              │
              ├──→ SELECT COUNT(*), SUM(*_satang), ...
              │     FROM sales WHERE deleted_at IS NULL
              │       AND created_at BETWEEN from AND to
              │     → aggregated totals (INTEGER satang)
              │
              ├──→ SELECT payment_method, SUM(amount_satang), COUNT(*)
              │     FROM sale_payments (chunked 500-row batches)
              │     GROUP BY payment_method
              │     → payment breakdown + counts
              │
              ├──→ SELECT order_type, SUM(net_amount_satang) ... GROUP BY order_type
              ├──→ SELECT order_channel, SUM(net_amount_satang) ... GROUP BY order_channel
              └──→ SELECT void_reason, COUNT(*) ... WHERE status='VOIDED' GROUP BY void_reason
                    │
              satang → Money via Money.fromSatang
              REAL baht fallback for pre-v32 rows
                    │
              ReportSummary → UI renders summary card
```

No `List<Sale>` hydration — all metrics computed in SQL. Item-derived metrics (top products, profit/margin) still require the existing hydration path.

---

## Data Flow — Streaming CSV Export ([Unreleased])

> PlantUML source: [`docs/architecture/puml/sequence-streaming-csv-export.puml`](puml/sequence-streaming-csv-export.puml)

```
ReportPage → ReportExportService.exportCsvStream(
  saleRepository, sink, from, to, maxRows=10000, pageSize=500, startSignal)
  │
  ├──→ sink(csv.encode([header row]))
  ├──→ startSignal() — dismiss "Preparing..."
  │
  └──→ LOOP while rowsWritten < maxRows:
         │
         ├──→ SaleRepository.getSalesPage(from, to, cursor, 500)
         │     → SalePage (500 sales hydrated)
         │
         ├──→ FOR each sale in page.sales:
         │     if rowsWritten >= maxRows → truncated=true, break
         │     buffer.add(saleRow(sale)); rowsWritten++
         │
         ├──→ sink(csv.encode(buffer)); buffer.clear()
         ├──→ cursor = page.nextCursor
         └──→ if !page.hasMore → break
       │
       if !truncated && rowsWritten >= maxRows:
         probe = getSalesPage(from, to, cursor, 1)
         if probe.sales.isNotEmpty → truncated=true
       │
       CsvExportResult(rowsWritten, truncated) → UI
```

Memory is O(pageSize) — only 500 sales hydrated at any time. Hard cap `kExportMaxRows = 10000` prevents unbounded exports.

---

## Data Flow — Backup Export ([Unreleased])

> PlantUML source: [`docs/architecture/puml/sequence-backup-export.puml`](puml/sequence-backup-export.puml)

```
SettingsPage → BackupExportService.exportWithMetadata(encrypt, pin, ...)
  │
  ├──→ AppLockService.requireSensitiveSession()
  ├──→ PIN validation (PIN_REQUIRED / PIN_TOO_SHORT if encrypt)
  ├──→ Size preflight (BACKUP_TOO_LARGE if > 512 MB)
  │
  ├──→ onProgress(checkpointing)
  ├──→ WalCheckpointService.forceTruncate()  ← exclusive lock
  │
  ├──→ onProgress(copying)
  ├──→ copy dbFile → temp snapshot
  │
  ├──→ onProgress(checksumming)
  ├──→ SHA-256(snapshotFile) → checksum
  ├──→ PRAGMA user_version → schemaVersion
  ├──→ BackupMetadata(schemaVersion, appVersion, createdAt, dbSize, checksum, encrypted)
  ├──→ write .meta.json sidecar
  │
  ├──→ onProgress(encrypting) [if encrypt]
  ├──→ BackupEncryptionService.encryptFile(snapshot, pin) → .enc file
  │
  ├──→ onProgress(sharing)
  ├──→ SharePlus.share([.db/.enc, .meta.json])
  │
  └──→ onProgress(done) → BackupExportResult → UI
```

---

## Data Flow — Backup Restore ([Unreleased])

> PlantUML source: [`docs/architecture/puml/sequence-backup-restore.puml`](puml/sequence-backup-restore.puml)

```
SettingsPage → BackupRestoreService.restoreFromPath(sourcePath, pin)
  │
  ├──→ AppLockService.requireSensitiveSession()
  ├──→ SOURCE_MISSING / BACKUP_TOO_LARGE checks
  │
  ├──→ if .enc: decryptFile(sourcePath, pin) → temp .db
  │       PIN_REQUIRED / PIN_TOO_SHORT checks
  ├──→ if .db: assert not plain SQLite (PLAIN_SQLITE_UNSUPPORTED)
  │
  ├──→ Candidate Validation:
  │     open with PRAGMA key → check 4 tables (INVALID_BACKUP_SCHEMA)
  │     PRAGMA integrity_check (INVALID_BACKUP_INTEGRITY)
  │     PRAGMA foreign_key_check (INVALID_BACKUP_INTEGRITY)
  │     close candidate
  │
  ├──→ Stage + Swap (atomic):
  │     copy workingPath → staged
  │     copy live db → pre_restore backup
  │     ┌─ TRY:
  │     │  _db.close()
  │     │  rename live → old
  │     │  rename staged → live
  │     │  delete WAL + SHM
  │     │  delete old
  │     └─ CATCH: rename old → live (rollback), rethrow
  │     FINALLY: safeDelete(staged), safeDelete(old)
  │
  └──→ preRestorePath → UI ("Restart app")
       cleanupPreRestoreBackups() on next launch after successful DB open
```

---

## Data Flow — Recovery Kit Export/Import ([Unreleased])

> PlantUML source: [`docs/architecture/puml/sequence-recovery-kit.puml`](puml/sequence-recovery-kit.puml)

```
EXPORT:
SettingsPage → RecoveryKitService.exportKit(secret, outputPath?)
  ├──→ SECRET_TOO_SHORT if secret.trim().length < 8
  ├──→ DbKeyStore.getOrCreateKey() → hexKey (SQLCipher key)
  ├──→ salt = SecureRandom(16), nonce = SecureRandom(12)
  ├──→ Isolate.run(PBKDF2-HMAC-SHA256(secret, salt, 100K, 32)) → wrapKey
  ├──→ AES-256-GCM encrypt(utf8.encode(hexKey), wrapKey, nonce)
  ├──→ build file: [uint32 headerLen][JSON header][salt][nonce][ciphertext+tag]
  └──→ writeAsBytes(.promkey) → RecoveryKitExportResult

IMPORT:
SettingsPage → RecoveryKitService.importKit(filePath, secret, replaceExisting?)
  ├──→ SECRET_TOO_SHORT check
  ├──→ KIT_FILE_NOT_FOUND / KIT_CORRUPT checks
  ├──→ parse header → RecoveryKitMetadata
  ├──→ KIT_VERSION_UNSUPPORTED if version > kRecoveryKitVersion
  ├──→ extract salt + nonce + ciphertext
  ├──→ Isolate.run(PBKDF2(...)) → wrapKey
  ├──→ AES-256-GCM decrypt(ciphertext, wrapKey, nonce)
  │     WRONG_SECRET if GCM auth tag fails
  ├──→ KEY_ALREADY_EXISTS if key exists && !replaceExisting
  └──→ SecureStorage.write("promsell_db_key_v1", hexKey) → installed
```

File format: `[uint32 headerLength][JSON header][salt(16)][nonce(12)][ciphertext+GCM tag]`. PBKDF2 runs in a background isolate — 100K iterations do not block the UI thread.

---

## Data Flow — Migration Safety + WAL Checkpoint ([Unreleased])

> PlantUML source: [`docs/architecture/puml/sequence-migration-safety.puml`](puml/sequence-migration-safety.puml)

```
APP LAUNCH:
  MigrationSafetyService.readMigrationStatus()
    → if "running" → alert operator / trigger recovery
    → if "idle" → proceed

PRE-MIGRATION:
  MigrationSafetyService.checkFreeSpace()
    requiredBytes = max(dbSize * 2, 50 MB)
    if freeBytes < requiredBytes → INSUFFICIENT_FREE_SPACE (abort)
    if freeBytes unknown → FREE_SPACE_UNKNOWN (proceed with warning)

  markMigrationStart(from, to) → write migration_status.json

  Drift migration (ALTER TABLE + backfill UPDATE)
    → markMigrationSuccess() or markMigrationFailure(error)
    → clearMigrationStatus()

WAL CHECKPOINT (periodic / on-demand):
  WalCheckpointService.checkpointIfNeeded()
    if walSize >= 10 MB → PRAGMA wal_checkpoint(PASSIVE)
    → safe during money transactions (never blocks)

  WalCheckpointService.forceTruncate()
    exclusively(() → PRAGMA wal_checkpoint(TRUNCATE))
    → backup / day-close only (exclusive lock)

DATABASE HEALTH (day-close / diagnostics):
  DatabaseHealthService.generateReport(checkIntegrity: false)
    → mainDbSize + walSize + shmSize + totalSize
    → schemaVersion (PRAGMA user_version)
    → walNeedsCheckpoint / walNeedsTruncate
    → approachingGuardrail (> 400 MB) / exceedsGuardrail (> 512 MB)
```

---

## PlantUML Source Files

Detailed diagrams are available as `.puml` files for rendering with PlantUML tools:

| File | Diagram |
|------|---------|
| [`docs/architecture/puml/c4-context.puml`](puml/c4-context.puml) | System Context (C4 Level 1) |
| [`docs/architecture/puml/c4-container.puml`](puml/c4-container.puml) | Container Diagram (C4 Level 2) |
| [`docs/architecture/puml/c4-component.puml`](puml/c4-component.puml) | Component Diagram — Sale Feature (C4 Level 3) |
| [`docs/architecture/puml/c4-component-lifecycle.puml`](puml/c4-component-lifecycle.puml) | Component Diagram — DB Lifecycle Services (C4 Level 3) |
| [`docs/architecture/puml/sequence-sale.puml`](puml/sequence-sale.puml) | Sale Transaction Sequence |
| [`docs/architecture/puml/sequence-void.puml`](puml/sequence-void.puml) | Void Sale Sequence |
| [`docs/architecture/puml/sequence-adjust-stock.puml`](puml/sequence-adjust-stock.puml) | Stock Adjustment Sequence |
| [`docs/architecture/puml/sequence-cursor-pagination.puml`](puml/sequence-cursor-pagination.puml) | Cursor Pagination Sequence |
| [`docs/architecture/puml/sequence-report-summary.puml`](puml/sequence-report-summary.puml) | SQL Report Summary Sequence |
| [`docs/architecture/puml/sequence-streaming-csv-export.puml`](puml/sequence-streaming-csv-export.puml) | Streaming CSV Export Sequence |
| [`docs/architecture/puml/sequence-backup-export.puml`](puml/sequence-backup-export.puml) | Backup Export Sequence |
| [`docs/architecture/puml/sequence-backup-restore.puml`](puml/sequence-backup-restore.puml) | Backup Restore Sequence |
| [`docs/architecture/puml/sequence-recovery-kit.puml`](puml/sequence-recovery-kit.puml) | Recovery Kit Export/Import Sequence |
| [`docs/architecture/puml/sequence-migration-safety.puml`](puml/sequence-migration-safety.puml) | Migration Safety + WAL Checkpoint Sequence |

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

<sub>Promsell POS CE · v0.9.3 · schema v32 · 16 tables · C4 Diagrams & Data Flows</sub>
