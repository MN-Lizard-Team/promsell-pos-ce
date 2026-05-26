# Round 1 — Schema Foundation 🔴

> Goal: Migrate database ให้ตรง Phase 1 spec ทั้งหมด ก่อนเพิ่ม feature ใด ๆ — UUID ทุก table, สร้าง table ใหม่ครบ, indexes, migration safety.

**Version target:** `v0.3.0`
**Effort:** ~3 dev-days
**Risk:** 🔴 High (touches every datasource + repository + test)

---

## Why R1 First

ถ้าทำ feature R2–R5 บน schema ปัจจุบัน จะ refactor 2 ครั้ง — เสียเวลามากกว่าทำ schema ให้ถูกตั้งแต่ต้น. R1 เปลี่ยน foundation อย่างเดียว ไม่เพิ่ม feature ใหม่ — เพื่อแยก migration risk ออกจาก feature risk.

---

## Pre-flight Checklist

- [ ] Branch ใหม่ `feat/phase1-r1-schema`
- [ ] Backup current `app_database.g.dart` (reference)
- [ ] อ่าน Drift migration docs: https://drift.simonbinder.eu/docs/migrations/
- [ ] CHANGELOG เตรียม note breaking change

---

## Tasks

### 1. Add Dependencies

`pubspec.yaml`:

```yaml
dependencies:
  uuid: ^4.5.1
```

### 2. ID Generator Utility

`lib/core/utils/id_generator.dart`:

```dart
import 'package:uuid/uuid.dart';

class IdGenerator {
  static const _uuid = Uuid();
  static String newId() => _uuid.v4();
}
```

### 3. Update All Tables → UUID + sync-ready fields

#### `lib/core/database/tables/products_table.dart`

| Column | Type | Note |
|---|---|---|
| `id` | TextColumn | UUIDv4, PK |
| `name` | TextColumn | |
| `sku` | TextColumn nullable | NEW |
| `barcode` | TextColumn nullable | NEW |
| `price` | RealColumn | |
| `cost` | RealColumn nullable | NEW |
| `stock` | IntColumn | |
| `categoryId` | TextColumn nullable | NEW (FK to categories) |
| `imageUrl` | TextColumn nullable | |
| `trackStock` | BoolColumn default true | NEW |
| `isActive` | BoolColumn | |
| `createdAt` | DateTimeColumn | |
| `updatedAt` | DateTimeColumn | |
| `deletedAt` | DateTimeColumn nullable | NEW (soft delete) |
| `version` | IntColumn default 1 | NEW (sync) |
| `deviceId` | TextColumn nullable | NEW (sync) |

#### `lib/core/database/tables/sales_table.dart`

เพิ่ม:
- `id TEXT` (UUID)
- `receiptNumber TEXT` (unique)
- `status TEXT` default `'COMPLETED'` (`COMPLETED` | `VOIDED`)
- `subtotalAmount REAL`
- `discountType TEXT nullable` (`PERCENT` | `AMOUNT`)
- `discountValue REAL nullable`
- `discountAmount REAL default 0`
- `vatMode TEXT default 'NONE'` (`NONE` | `INCLUSIVE` | `EXCLUSIVE`)
- `vatRate REAL default 0`
- `vatAmount REAL default 0`
- `voidedAt DateTime nullable`
- `voidReason TEXT nullable`
- `updatedAt`, `deletedAt`, `version`, `deviceId`

#### `lib/core/database/tables/sale_items_table.dart`

- `id TEXT`, `saleId TEXT`, `productId TEXT`
- เพิ่ม `discountAmount REAL default 0`, `vatAmount REAL default 0`

### 4. New Tables

#### `categories_table.dart`

```
id TEXT PK, name TEXT, sortOrder INT, createdAt, updatedAt, deletedAt, version, deviceId
```

#### `inventory_logs_table.dart`

```
id TEXT PK
productId TEXT (FK products)
type TEXT  -- SALE | VOID_REVERSAL | ADJUSTMENT_IN | ADJUSTMENT_OUT | INITIAL
qtyChange INT  -- signed: -3 for sale, +3 for void
balanceAfter INT
reason TEXT nullable
refSaleId TEXT nullable (FK sales)
createdAt DateTime
deviceId TEXT nullable
```

#### `settings_table.dart`

```
key TEXT PK
value TEXT  -- JSON-encoded
updatedAt DateTime
```

Default keys (seed on first run):
- `vatMode = "NONE"`
- `vatRate = 7.0`
- `allowOversell = false`
- `lowStockThreshold = 5`
- `devicePrefix = "A1"` (random 2-char on first launch)
- `receiptSequence = 0`
- `receiptSequenceDate = "2026-01-01"`
- `onboardingCompleted = false`
- `dailyCloseLock = false`
- `promptpayId = ""`
- `deviceId = "<UUID>"` (generated on first launch)

> ⚠️ Note: Settings table จะค่อย ๆ replace `SharedPreferences` ใน R3. R1 แค่สร้าง table.

#### `draft_carts_table.dart`

```
id TEXT PK
name TEXT nullable  -- "Customer A", "Table 3"
note TEXT nullable
createdAt, updatedAt
deviceId
```

#### `draft_cart_items_table.dart`

```
id TEXT PK
cartId TEXT (FK draft_carts)
productId TEXT (FK products)
productName TEXT  -- snapshot
price REAL
qty INT
discountType TEXT nullable
discountValue REAL nullable
```

#### `daily_closes_table.dart`

```
id TEXT PK
closeDate TEXT  -- YYYY-MM-DD
openingCash REAL
expectedCash REAL  -- calculated from sales
countedCash REAL  -- cashier input
overShortAmount REAL
totalRevenue REAL
totalVoid REAL
salesCount INT
voidCount INT
note TEXT nullable
closedAt DateTime
deviceId TEXT
```

### 5. Indexes (Drift `customStatement` in migration)

```sql
CREATE INDEX idx_sales_created_at ON sales(created_at);
CREATE INDEX idx_sales_status ON sales(status);
CREATE INDEX idx_sale_items_sale_id ON sale_items(sale_id);
CREATE INDEX idx_inventory_logs_product_id ON inventory_logs(product_id);
CREATE INDEX idx_inventory_logs_ref_sale_id ON inventory_logs(ref_sale_id);
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_draft_cart_items_cart_id ON draft_cart_items(cart_id);
CREATE UNIQUE INDEX idx_sales_receipt_number ON sales(receipt_number);
```

### 6. Migration Strategy

`app_database.dart`:

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) async {
    await m.createAll();
    await _createIndexes();
    await _seedDefaultSettings();
  },
  onUpgrade: (m, from, to) async {
    if (from < 2) {
      // Pre-release: drop & recreate (documented breaking change)
      await m.deleteTable('products');
      await m.deleteTable('sales');
      await m.deleteTable('sale_items');
      await m.createAll();
      await _createIndexes();
      await _seedDefaultSettings();
    }
  },
  beforeOpen: (details) async {
    await customStatement('PRAGMA foreign_keys = ON');
    await customStatement('PRAGMA journal_mode = WAL');
    await customStatement('PRAGMA busy_timeout = 5000');
  },
);
```

### 7. Update DI + Repositories

ทุก signature `int id` → `String id`:
- `ProductLocalDatasource` + `Impl`
- `ProductRepository` + `Impl`
- `SaleLocalDatasource` + `Impl`
- `SaleRepository` + `Impl`
- `HistoryRepository` + `Impl`
- All use cases
- All BLoCs/states/events

### 8. Update Test Helpers

- `test/helpers/fake_database.dart` → no change to factory, but seeded data uses UUID
- `test/helpers/fixtures.dart` → `tProduct.id` from `1` → `'00000000-0000-0000-0000-000000000001'`
- `test/helpers/mocks.dart` → update mock signatures
- ทุก test file ที่ใช้ `int id` → fix

### 9. Codegen + Verify

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

---

## Success Gate

- ✅ `flutter analyze` → 0 errors
- ✅ `flutter test` → 130/130 still passing (after fixture migration)
- ✅ App launches → sale → checkout works end-to-end (manual smoke)
- ✅ Database file inspect: tables ครบ 9 (`products`, `categories`, `sales`, `sale_items`, `inventory_logs`, `settings`, `draft_carts`, `draft_cart_items`, `daily_closes`)
- ✅ Indexes created (verify via `sqlite3` CLI)
- ✅ WAL mode active
- ✅ `CHANGELOG.md` documents breaking change + migration note
- ✅ Version bumped to `0.3.0`

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Drift codegen fails on FK ref | Test on minimal table first, then expand |
| Test fixture cascade | Run `flutter test` after each table migration, fix incrementally |
| Forgotten `int → String` somewhere | Use `flutter analyze` aggressively; type system catches most |
| Existing user data lost | Document clearly in CHANGELOG; pre-release acceptable |

---

## Out of Scope for R1

- ❌ Receipt number generation (R2)
- ❌ Inventory log inserts on sale (R2)
- ❌ Discount calculation (R3)
- ❌ Settings table read/write logic (R3)
- ❌ Draft cart persistence logic (R3)

R1 = **schema only**. ไม่มี business logic เพิ่ม.

---

## Definition of Done

```
□ All 9 tables defined with UUID + sync-ready fields
□ All indexes created
□ Migration safe (pre-release: drop+recreate documented)
□ WAL + busy_timeout configured
□ DI signatures updated (int → String)
□ Test fixtures migrated
□ flutter test 100% pass
□ flutter analyze 0 errors
□ Manual smoke test: install → sale → restart → history persists
□ CHANGELOG updated
□ Version 0.3.0 tagged
□ PR merged to main
```
