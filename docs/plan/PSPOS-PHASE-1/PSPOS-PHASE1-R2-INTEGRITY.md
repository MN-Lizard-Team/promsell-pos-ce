# Round 2 — Sale Integrity 🟡

> Goal: ทุก sale transaction ต้อง audit ได้, reversible, มี receipt number unique — รองรับ void/refund + manual stock adjustment.

**Version target:** `v0.4.0`
**Effort:** ~3 dev-days
**Risk:** 🟡 Medium (atomic transactions, race conditions)
**Depends on:** R1 complete

---

## Why R2

R1 ให้ schema. R2 เติม integrity layer ที่ทำให้ระบบ **trust ได้**:
- ทุก stock change มี audit trail
- ทุก sale มี receipt number unique
- void/refund ไม่ทำลายข้อมูล

ถ้าข้าม R2 → R3 ทำ feature บน sale ที่ยัง void ไม่ได้, ต้อง refactor อีก

---

## Pre-flight

- [ ] R1 merged + `v0.3.0` released
- [ ] Branch `feat/phase1-r2-sale-integrity`
- [ ] อ่าน Drift transaction docs

---

## Tasks

### 1. Settings Repository (Drift-backed)

ก่อน R2 task อื่น ต้องมี settings r/w จริงก่อน เพราะ receipt sequence ต้องเก็บ.

`lib/features/settings/data/datasources/settings_local_datasource.dart`:

```dart
abstract class SettingsLocalDatasource {
  Future<String?> getString(String key);
  Future<int?> getInt(String key);
  Future<bool?> getBool(String key);
  Future<double?> getDouble(String key);
  Future<void> setString(String key, String value);
  Future<void> setInt(String key, int value);
  Future<void> setBool(String key, bool value);
  Future<void> setDouble(String key, double value);
  Future<Map<String, String>> getAll();
}
```

> Note: SharedPreferences ของเดิมยังอยู่สำหรับ locale/theme. Settings table ใช้กับ business config (vat, oversell, receipt seq, ฯลฯ).

### 2. Receipt Number Generator

`lib/features/sale/data/services/receipt_number_service.dart`:

```dart
class ReceiptNumberService {
  ReceiptNumberService(this._db);
  final AppDatabase _db;

  /// Format: {YYMMDD}-{devicePrefix}-{seq:0000}
  /// Example: 260526-A1-0001
  /// MUST be called inside a transaction.
  Future<String> nextReceiptNumber() async {
    final now = DateTime.now();
    final dateKey = DateFormat('yyMMdd').format(now);
    final isoDate = DateFormat('yyyy-MM-dd').format(now);

    // Read sequence + last date from settings (within tx)
    final lastDate = await _readSetting('receiptSequenceDate');
    final lastSeq = int.tryParse(await _readSetting('receiptSequence') ?? '0') ?? 0;
    final devicePrefix = await _readSetting('devicePrefix') ?? 'A1';

    final newSeq = (lastDate == isoDate) ? lastSeq + 1 : 1;

    await _writeSetting('receiptSequence', newSeq.toString());
    await _writeSetting('receiptSequenceDate', isoDate);

    return '$dateKey-$devicePrefix-${newSeq.toString().padLeft(4, '0')}';
  }
}
```

**Rules:**
- ต้องเรียกใน transaction เดียวกับ `insertSaleWithItems`
- Reset sequence ทุกวัน (ตาม `receiptSequenceDate`)
- Format unique เพราะ device prefix ต่างกัน + seq ต่างกัน

### 3. Inventory Log Service

`lib/features/inventory/data/services/inventory_log_service.dart`:

```dart
class InventoryLogService {
  Future<void> logSale({
    required String productId,
    required int qty,
    required String saleId,
    required int balanceAfter,
  });

  Future<void> logVoidReversal({
    required String productId,
    required int qty,
    required String saleId,
    required int balanceAfter,
  });

  Future<void> logAdjustment({
    required String productId,
    required int qtyChange,
    required String reason,
    required int balanceAfter,
  });
}
```

`qtyChange` signed: negative = decrease, positive = increase.

### 4. Update `SaleLocalDatasourceImpl.insertSaleWithItems`

ใน transaction เดียวกัน:

```
1. Generate receipt number (atomic seq)
2. Insert sale (with status='COMPLETED', receiptNumber)
3. Validate ALL stock first (existing behavior)
4. For each item:
   a. Insert sale_item
   b. Deduct stock from products
   c. Insert inventory_log (type='SALE', refSaleId, qtyChange=-qty)
5. Commit
```

> ❗ Important: ทั้งหมดต้องเป็น atomic. ถ้า step ใด fail → rollback ทุกอย่าง.

### 5. Sale Status Filtering

#### History
- Default: show ทุก status, badge "VOIDED" สีแดงสำหรับ voided
- Filter chip: All / Completed / Voided

#### Reports
- Total revenue = sum where `status='COMPLETED'`
- Add `totalVoid` summary card
- Top products = exclude voided sales

### 6. Void Sale Flow

#### UI
- History page → long-press item → bottom sheet with `Void this sale` button (destructive color)
- Confirm dialog with optional `voidReason` text field
- After void → snackbar "Sale voided, stock restored"

#### Implementation
`VoidSale` use case + repository method `voidSale(String saleId, String? reason)`:

```dart
Future<void> voidSale(String saleId, String? reason) async {
  await _db.transaction(() async {
    final sale = await _getSale(saleId);
    if (sale.status == 'VOIDED') {
      throw StateError('Sale already voided');
    }

    // Update sale status
    await _updateSale(saleId,
      status: 'VOIDED',
      voidedAt: DateTime.now(),
      voidReason: reason,
      updatedAt: DateTime.now(),
    );

    // Restore stock + log reversal
    final items = await _getSaleItems(saleId);
    for (final item in items) {
      final product = await _getProduct(item.productId);
      if (product == null) continue; // product deleted, skip stock restore but still log
      final newStock = product.stock + item.qty;
      await _updateProductStock(item.productId, newStock);
      await _logVoidReversal(
        productId: item.productId,
        qty: item.qty,
        saleId: saleId,
        balanceAfter: newStock,
      );
    }
  });
}
```

> Edge case: product ถูกลบไปแล้ว (soft-delete) → log reversal แต่ไม่ restore stock. Document พฤติกรรมนี้.

### 7. Manual Stock Adjustment

#### UI
- Product detail page → "Adjust stock" button
- Dialog: +/- qty input, reason text field (required), confirm

#### Implementation
- Use case `AdjustStock(productId, qtyChange, reason)`
- ใน transaction: update stock + insert inventory_log

### 8. Inventory Log Viewer (basic)

- Product detail → tab "History" → list inventory logs descending
- Show type icon, qty change, balance after, reason, timestamp

### 9. Tests

#### Unit
- `ReceiptNumberService`:
  - Sequence increments same day
  - Resets next day
  - Format correct
  - Concurrent calls inside tx → no duplicates (use sqlite in-memory + 100 parallel sales)
- `InventoryLogService`:
  - Each log type produces correct row
  - Balance after calculated correctly

#### Integration
- Full sale → verify receipt number + inventory log row
- Void sale → verify status update + stock restored + reversal log
- Void already-voided → throws
- Manual adjustment → log created + stock changed
- Reports exclude voided sales

#### Widget
- History page shows VOIDED badge
- Long-press → void dialog appears
- Stock adjustment dialog flow

---

## Success Gate

- ✅ Every successful sale has receipt number + inventory log row
- ✅ Receipt number unique across 100 concurrent sale test
- ✅ Void restores stock + creates reversal log atomically
- ✅ Reports correctly separate gross / void / net
- ✅ Test count grows ~130 → ~155+
- ✅ `flutter test` 100% pass
- ✅ Manual: void a sale, verify history shows VOIDED, stock restored, report excludes
- ✅ CHANGELOG + version `0.4.0`

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Receipt number race condition | Generate inside `_db.transaction()` — Drift serializes writes |
| Forget to log inventory in some path | Audit all stock mutation sites; add lint/test |
| Void on deleted product crashes | Defensive: skip stock restore, still log |
| Reports query slow with status filter | Already has `idx_sales_status` from R1 |

---

## Out of Scope for R2

- ❌ Discount calculation (R3)
- ❌ VAT calculation (R3)
- ❌ Draft cart (R3)
- ❌ Receipt PDF (R4)
- ❌ Daily close (R5)

R2 = **integrity only**. Sale ยังไม่มี discount/VAT — ใช้ subtotal = total.

---

## Definition of Done

```
□ Settings local datasource (Drift) implemented
□ Receipt number generator + tests
□ Inventory log service + tests
□ Sale insert wraps everything atomically
□ Void sale flow (UI + logic + tests)
□ Manual stock adjustment (UI + logic + tests)
□ Inventory log viewer (basic)
□ Reports exclude voided
□ History badge for voided
□ All tests pass
□ CHANGELOG + v0.4.0
□ PR merged
```
