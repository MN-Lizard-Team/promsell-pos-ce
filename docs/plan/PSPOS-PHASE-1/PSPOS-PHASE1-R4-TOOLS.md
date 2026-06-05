# Round 4 — Merchant Tools ✅ DONE

> Goal: ร้านใช้งานเต็มรูปแบบได้ — พิมพ์/แชร์ใบเสร็จ PDF, รับเงินผ่าน PromptPay QR, สำรอง/กู้คืนข้อมูลด้วยตัวเอง.

**Version:** `v0.6.0` (core), `v0.6.3` (E1–E4 backlog cleared)
**Effort:** ~2 dev-days (core) + ~1 day (E1–E4 backlog)
**Risk:** 🟢 Low (existing pkg `pdf` + `printing` already in deps)
**Depends on:** R1+R2 ✅ (v0.4.0), R3 ✅ (v0.5.0)

---

## Why R4

R3 จบ business logic. R4 = **interface กับโลกภายนอก**:
- ส่งใบเสร็จให้ลูกค้า (PDF/print)
- รับเงินยุคใหม่ (PromptPay)
- ปกป้องข้อมูล (backup/restore)

---

## Pre-flight

- [x] R1+R2 merged → `v0.4.0` released (2026-05-27)
- [x] R3 merged + `v0.5.0` released
- [ ] Test PromptPay ID พร้อมใช้ (สำหรับ manual scan test ด้วย banking app จริง)
- [x] Add deps:
  ```yaml
  share_plus: ^10.0.2
  file_picker: ^8.1.2
  csv: ^6.0.0
  qr_flutter: ^4.1.0
  ```
- [x] Move `ReceiptPdfService` → `lib/features/receipt/data/services/`
- [x] Extract `ReceiptLabels` → `lib/features/receipt/domain/entities/receipt_labels.dart`
- [x] Add 4 `AppSettings` fields: `promptpayId`, `receiptSize`, `backupReminderDays`, `lastBackupAt`
- [x] Schema migration v4→v5 (`_seedR4Settings`)
- [x] Version bump `0.5.4+1`

---

## Tasks

### 1. Receipt PDF Generator

#### Files
- `lib/features/receipt/data/services/receipt_pdf_service.dart` (service)
- `lib/features/receipt/domain/entities/receipt_labels.dart` (labels entity, extracted from service)

#### Layout (80mm thermal — primary)

```
        [Shop Logo / Name]
        [Address line 1]
        [Address line 2]
        [Phone]
─────────────────────────
Receipt: 260526-A1-0001
Date: 26/05/2026 14:30
Cashier: -

Item              Qty   Total
Water 600ml        3   30.00
Coke 325ml         2   50.00
  Discount -10%        -8.00
─────────────────────────
Subtotal             80.00
Cart discount       -10.00
                     70.00
VAT 7% (excl)        +4.90
═════════════════════════
TOTAL                74.90

Payment: Cash       100.00
Change               25.10

[Receipt note from settings]
       Thank you!
```

#### Layout (A4 — fallback)
- 2-column with shop info top, items table, totals right-aligned
- Same data, different size

#### Implementation
- `pdf` package — `Document` with `MultiPage`
- Thai font: bundle `NotoSansThai-Regular.ttf` + `Bold.ttf` in `assets/fonts/`
- Width detection: setting `receiptSize` (`80mm` | `A4`)

#### Integration points
- After successful sale → action sheet: `Print` / `Share PDF` / `Done`
- History detail → `Print receipt` button
- Use `printing` package: `Printing.layoutPdf()` for print, `Printing.sharePdf()` for share

### 2. PromptPay QR

#### Settings
- New field: `promptpayId` (text input, supports phone `0812345678` or citizen ID `1234567890123`)
- Optional toggle: "Show PromptPay in payment sheet"

#### EMVCo QR Generation

`lib/features/payment/data/services/promptpay_qr_service.dart`:

```dart
class PromptpayQrService {
  /// Returns EMVCo-compliant QR string for static (no amount) or dynamic (with amount).
  String generatePayload({
    required String promptpayId,  // 0812345678 or 1234567890123
    double? amount,
  });
}
```

#### EMVCo Format (TLV — Tag-Length-Value)

```
00 02 01                                    // Payload format
01 02 12 (or 11 for static)                 // Point of init
29 37                                        // Merchant account
   00 16 A000000677010111                    // PromptPay AID
   01 13 0066812345678 (formatted phone)
       OR
   02 13 1234567890123 (citizen ID)
53 03 764                                    // Currency THB
54 XX 0.00 (if dynamic)                      // Amount
58 02 TH                                     // Country
63 04 XXXX                                   // CRC16
```

> Validate by scanning with real banking app (K-Plus, Bualuang, SCB Easy) before merge.

#### UI Flow

##### Payment sheet
- Add 4th button: `PromptPay`
- When selected → show:
  - QR code (large, centered)
  - Total amount text
  - Reference (sale ID short hash)
  - "I received the money" confirm button (cashier presses after seeing payment in their banking app)

##### Confirm flow
- Press confirm → same as cash flow but `paymentMethod='promptpay'`, `amountReceived=null`, `changeAmount=null`
- Optional reference field (pre-filled with last 8 chars of receipt number)

#### Edge cases
- `promptpayId` empty → hide PromptPay button + show settings hint
- Generate offline (no network needed for QR)
- Receipt shows "Paid via PromptPay" + reference

### 3. Backup System

#### Export SQLite file
`lib/features/backup/data/services/backup_service.dart`:

```dart
Future<File> exportDatabase() async {
  // 1. Force Drift to flush WAL: customStatement('PRAGMA wal_checkpoint(TRUNCATE)')
  // 2. Locate db file via path_provider
  // 3. Copy to temp dir with name: promsell_pos_backup_{YYYYMMDD_HHMMSS}.db
  // 4. Return File for sharing
}

Future<void> importDatabase(File backup) async {
  // 1. Validate file (open as Drift, check schemaVersion)
  // 2. Confirm dialog (irreversible)
  // 3. Close current db connection
  // 4. Replace file
  // 5. Reopen + verify
}
```

#### Export CSV
- Sales CSV: receipt#, date, items, subtotal, discount, vat, total, payment, status, void reason
- Products CSV: id, name, sku, barcode, price, cost, stock, category, active
- Date range picker for sales CSV
- Use `csv` package + `share_plus`

#### UI
Settings page → new section "Data":
- Button: "Export database (full backup)" → share sheet
- Button: "Export sales (CSV, last 30 days)" → date picker → share
- Button: "Export products (CSV)" → share
- Button: "Restore from backup..." → file picker → confirm → restart app

#### Backup reminder
- Setting: `backupReminderDays` (default 7, 0 = off)
- Setting: `lastBackupAt`
- Banner on Settings page if `lastBackupAt` > N days ago: "Backup recommended"

### 4. Receipt Settings UI Expansion

Settings → Receipt section:
- Receipt size: 80mm / A4 toggle
- Shop logo upload (optional, R5 polish if time tight)
- Receipt note (existing)
- Show shop info toggle (existing)

### 5. Tests

#### Unit
- `PromptpayQrService.generatePayload`:
  - Phone format conversion
  - Citizen ID format
  - Static vs dynamic
  - CRC16 calculation correct
  - Test against known good payloads from spec
- `BackupService`:
  - Export creates valid SQLite
  - Roundtrip: export → wipe → import → data matches (use temp dir)
  - Reject invalid file
- CSV export format matches expected

#### Widget
- Payment sheet shows QR when promptpay selected
- Receipt PDF preview renders without overflow

#### Integration
- Full sale → print PDF (use `Printing.layoutPdf` capture buffer)
- Backup roundtrip with real DB

#### Manual
- **MUST**: Scan generated QR with K-Plus or another bank app, verify amount + recipient correct
- Print PDF on actual thermal printer (or Windows print preview)

---

## Success Gate

### Core R4 (shipped in v0.6.0)

- ✅ Receipt PDF generator (80mm + A4) with TH font
- ✅ Print + Share actions after sale + from history
- ✅ PromptPay payload generator + CRC16
- ✅ PromptPay QR display in payment sheet
- ✅ Backup export (SQLite full) + import with version check
- ✅ CSV export (sales + products)
- ✅ Backup reminder banner
- ✅ Settings UI: receipt size, promptpay id, backup section
- ✅ Test count ~243 (v0.6.0), **258/258 passing** (v0.6.3), **279/279 passing** (v0.7.1)
- ✅ CHANGELOG + v0.6.0 → v0.6.3

### R4 UX Enhancement Backlog — ✅ DONE in v0.6.3

- ✅ **E1** Category Autocomplete in `ProductFormPage` — `Autocomplete<String>` with free-text, shipped v0.6.3
- ✅ **E2** Cart Item Direct Qty Input — tap qty → numeric dialog with stock clamping, shipped v0.6.3
- ✅ **E3** `InventoryLogPage` Clean Architecture refactor — `InventoryLogCubit` + repository + entity, shipped v0.6.3
- ✅ **E4** History Search / Filter Bar — `SearchBar` + `filteredSales` getter, shipped v0.6.3
- ❌ Manual PromptPay QR scan verified with real banking app (pre-flight item still open — manual verification required)

> **Note:** v0.6.0 shipped core R4 (PDF, PromptPay, Backup). v0.6.1 added Cart UX Redesign. v0.6.2 added UX Polish & Performance. v0.6.3 cleared the entire R4 UX enhancement backlog (E1–E4).

---

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| PromptPay QR format wrong | Test with real banking app before merge; include known-good payload tests |
| PDF Thai font rendering broken | Bundle proper Noto Sans Thai TTF; test with mixed TH/EN content |
| Backup file corruption | WAL checkpoint before copy; checksum optional; document warning |
| Restore destroys data | Confirm dialog x2; auto-create pre-restore backup |
| Large CSV memory issues | Stream rows instead of loading all in memory |
| Permission issues on Android 13+ | Use share_plus instead of writing to public dirs |

---

## UX Enhancements (Backlog — implement before R4 ships or in R5)

These were identified in the Round-2 bug analysis but are small UX improvements, not new merchant features. Implement alongside R4 tasks or in a dedicated patch.

### E1 — Category Autocomplete in ProductFormPage

**Problem:** Category is plain free-text. `"beverages"` and `"Beverages"` create two separate filter chips.

**Implementation:**
- Replace `_ProductTextField` for category with `Autocomplete<String>`
- Options source: `context.read<ProductBloc>().state.products.map((p) => p.category).whereType<String>().toSet().toList()`
- Allows free-text entry (user can still type a new category) — `Autocomplete` supports this via `fieldViewBuilder`

**Files:** `product_form_page.dart`

---

### E2 — Cart Item Direct Qty Input

**Problem:** `+` / `−` buttons only. Entering qty = 50 requires 49 taps.

**Implementation:**
- Wrap qty `Text` widget in `GestureDetector(onTap: ...)`
- On tap → `showDialog` with a `TextField` (numeric, pre-filled with current qty)
- On confirm → dispatch `SaleItemQtyChanged(productId: ..., qty: parsed)` (clamped to stock)

**Files:** `sale_page_redesign.dart` (`_CartItemRow`)

---

### E3 — InventoryLogPage Clean Architecture Refactor

**Problem:** `InventoryLogPage` queries `AppDatabase` directly — bypasses repository layer, untestable, no proper error state.

**Implementation:**
- Create `InventoryLogCubit` (domain: `WatchInventoryLogs` use case)
- `InventoryLogRepository` + `InventoryLogRepositoryImpl` → `InventoryLogLocalDatasource`
- Move Drift query out of widget into datasource
- `InventoryLogPage` uses `BlocBuilder<InventoryLogCubit, InventoryLogState>` with proper loading/error states
- Add unit tests: cubit, repository, datasource

**Files:** new files + `inventory_log_page.dart`

---

### E4 — History Search / Filter Bar

**Problem:** Only date-range filter available. Can't find a specific sale by receipt number, payment method, or amount.

**Implementation:**
- Add `SearchBar` above the list in `HistoryPage` (similar to `ProductListPage`)
- Filter logic in `HistoryBloc`: `_applyFilter(List<Sale> sales, String query)` — matches receipt number substring, payment method, or amount prefix
- `HistoryEvent`: `HistorySearchChanged(query)` → re-emit with filtered list
- UI: show active filter chip when query is non-empty (tap chip to clear)

**Files:** `history_page.dart`, `history_bloc.dart`, `history_event.dart`, `history_state.dart`

---

## Out of Scope for R4

- ❌ Daily close (R5)
- ❌ Onboarding wizard (R5)
- ❌ Cloud backup (Phase 2)
- ❌ Email receipt (Phase 2)

---

## Definition of Done

```
✅ Receipt PDF generator (80mm + A4) with TH font
✅ Print + Share actions after sale + from history
✅ PromptPay payload generator + CRC16
✅ PromptPay QR display in payment sheet
❌ Manual scan verified with real banking app  ← still pending
✅ Backup export (SQLite full)
✅ Backup import with confirmation + version check
✅ CSV export (sales + products)
✅ Backup reminder banner
✅ Settings UI: receipt size, promptpay id, backup section
✅ All tests pass (~243 total)
✅ CHANGELOG + v0.6.0
✅ PR merged (as v0.6.0)
```

### R4 UX Backlog (completed in v0.6.3)

```
✅ E1 Category Autocomplete in ProductFormPage
✅ E2 Cart Item Direct Qty Input
✅ E3 InventoryLogPage Clean Architecture Refactor
✅ E4 History Search / Filter Bar
```
