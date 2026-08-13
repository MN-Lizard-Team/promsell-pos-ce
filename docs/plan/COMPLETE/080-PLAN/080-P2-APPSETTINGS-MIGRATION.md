# v0.8.1 — Phase 2: AppSettings Facade Removal

**Theme:** ลบ `AppSettings` facade (`@Deprecated`) ออกจาก codebase ทั้งหมด
**Effort:** ~2 days
**Risk:** 🟡 Medium — Atomic refactor, type system enforce ว่าต้อง compile pass ก่อน run ได้
**Depends on:** Phase 1 ✅

---

## Why This Matters

`AppSettings` เป็น flat facade ครอบ `Settings` aggregate:
- `@Deprecated` ตั้งแต่ architecture ถูก refactor เป็น typed sub-entities
- เป็น blocker ก่อน Phase 4 sync — sync layer ต้องอ่าน `Settings` typed fields
- ทุกครั้งที่เพิ่ม config group ใหม่ ต้องเพิ่ม flat fields ใน `AppSettings` ด้วย = double maintenance

---

## Scope — 28 Files

| Sub-phase | Files | Description |
|-----------|-------|-------------|
| **P2-A** Core | 3 files | State, Cubit, PersistenceService |
| **P2-B** Widgets | 5 files | Settings form widgets |
| **P2-C** Pages | 12 files | Settings pages + consuming features |
| **P2-D** Tests + Delete | 15 files | 14 test files + delete app_settings.dart |

---

## Pre-flight

- [ ] Phase 1 complete ✅
- [ ] `flutter test` → 371+ passing
- [ ] `flutter analyze` → 0 issues

---

## P2-A — Core Layer (3 files) ← ทำก่อนสุด

หลังทำ P2-A เสร็จ `flutter analyze` จะ report errors ใน widget/page files ทั้งหมด — นั่นคือสิ่งที่ถูกต้อง ทำต่อจนถึง P2-D

### File 1: `lib/features/settings/presentation/cubit/settings_state.dart`

**Before:**
```dart
class SettingsState extends Equatable {
  SettingsState({
    this.status = SettingsStatus.initial,
    AppSettings? settings,
    this.errorMessage,
  }) : settings = settings ?? AppSettings();

  final AppSettings settings;
  // ...
  SettingsState copyWith({AppSettings? settings, ...})
}
```

**After:**
```dart
class SettingsState extends Equatable {
  SettingsState({
    this.status = SettingsStatus.initial,
    Settings? settings,
    this.errorMessage,
  }) : settings = settings ?? const Settings();

  final Settings settings;
  // ...
  SettingsState copyWith({Settings? settings, ...})
}
```

### File 2: `lib/features/settings/presentation/cubit/settings_cubit.dart`

**Before:**
```dart
void updateField(AppSettings Function(AppSettings) mapper) {
  final updated = mapper(state.settings);
  // ...
}

Future<void> update(AppSettings settings) async { ... }
```

**After:**
```dart
void updateField(Settings Function(Settings) mapper) {
  final updated = mapper(state.settings);
  // ...
}

Future<void> update(Settings settings) async { ... }
```

เปลี่ยน `AppSettings.fromSettings(settings)` → `settings` ตรงๆ ใน `load()`:
```dart
// Before
emit(state.copyWith(settings: AppSettings.fromSettings(settings)));

// After
emit(state.copyWith(settings: settings));
```

### File 3: `lib/features/settings/presentation/services/settings_persistence_service.dart`

**Before:**
```dart
AppSettings? _lastSettings;
void scheduleSave(AppSettings settings) { ... }
Future<void> saveImmediately(AppSettings settings) async { ... }
Future<void> _save(AppSettings settings) async {
  await _repository.save(settings.toSettings());
}
```

**After:**
```dart
Settings? _lastSettings;
void scheduleSave(Settings settings) { ... }
Future<void> saveImmediately(Settings settings) async { ... }
Future<void> _save(Settings settings) async {
  await _repository.save(settings);  // ตรงๆ ไม่ต้อง .toSettings()
}
```

---

## P2-B — Widgets (5 files)

Pattern ที่ต้องเปลี่ยนในทุก widget:
```dart
// Before
final AppSettings settings;
final ValueChanged<AppSettings> onUpdate;

// After
final Settings settings;
final ValueChanged<Settings> onUpdate;
```

### File 4: `lib/features/settings/presentation/widgets/general_settings_form.dart`

| Field access | Before | After |
|---|---|---|
| locale | `s.locale` | `Locale(s.uiConfig.locale)` |
| themeMode | `s.themeMode` | `ThemeMode.values.byName(s.uiConfig.themeMode)` |
| cartCompactMode | `s.cartCompactMode` | `s.uiConfig.cartCompactMode` |
| ultraCompactMode | `s.ultraCompactMode` | `s.uiConfig.ultraCompactMode` |
| accessibilityMode | `s.accessibilityMode` | `s.uiConfig.accessibilityMode` |

copyWith pattern:
```dart
// Before
onUpdate(s.copyWith(cartCompactMode: value));

// After
onUpdate(s.copyWith(uiConfig: s.uiConfig.copyWith(cartCompactMode: value)));
```

### File 5: `lib/features/settings/presentation/widgets/receipt_settings_form.dart`

| Field access | Before | After |
|---|---|---|
| vatRate | `s.vatRate` | `s.taxConfig.vatRate` |
| vatMode | `s.vatMode` | `s.taxConfig.vatMode` |
| receiptNote | `s.receiptNote` | `s.receiptConfig.receiptNote` |
| receiptSize | `s.receiptSize` | `s.receiptConfig.receiptSize` |
| showShopInfoOnReceipt | `s.showShopInfoOnReceipt` | `s.receiptConfig.showShopInfo` |
| receiptPreviewStyle | `s.receiptPreviewStyle` | `s.receiptConfig.receiptPreviewStyle` |

### File 6: `lib/features/settings/presentation/widgets/sales_settings_form.dart`

| Field access | Before | After |
|---|---|---|
| allowOversell | `s.allowOversell` | `s.stockConfig.allowOversell` |
| lowStockThreshold | `s.lowStockThreshold` | `s.stockConfig.lowStockThreshold` |

### File 7: `lib/features/settings/presentation/widgets/discount_policy_settings_form.dart`

| Field access | Before | After |
|---|---|---|
| enableItemDiscount | `s.enableItemDiscount` | `s.discountConfig.enableItemDiscount` |
| enableCartDiscount | `s.enableCartDiscount` | `s.discountConfig.enableCartDiscount` |
| maxDiscountPercent | `s.maxDiscountPercent` | `s.discountConfig.maxDiscountPercent` |
| maxDiscountAmount | `s.maxDiscountAmount` | `s.discountConfig.maxDiscountAmount` |
| defaultDiscountType | `s.defaultDiscountType` | `s.discountConfig.defaultDiscountType` |
| discountPresets | `s.discountPresets` | `s.discountConfig.discountPresets` |
| activeDiscountPresetId | `s.activeDiscountPresetId` | `s.discountConfig.activeDiscountPresetId` |
| activeDiscountPreset | `s.activeDiscountPreset` | `s.discountConfig.activeDiscountPreset` |

### File 8: `lib/features/settings/presentation/widgets/settings_dashboard_card.dart`

```dart
// Before
final AppSettings settings;

// After
final Settings settings;
```

Dashboard card ใช้ `settings.locale`, `settings.themeMode`, `settings.shopName` → เปลี่ยนเป็น typed path ตาม mapping

---

## P2-C — Pages (12 files)

### File 9: `lib/features/settings/presentation/pages/stock_settings_page.dart`

```dart
// Before: AppSettings s → s.allowOversell, s.lowStockThreshold
// After: Settings s → s.stockConfig.allowOversell, s.stockConfig.lowStockThreshold

// copyWith before:
cubit.updateField((s) => s.copyWith(allowOversell: value));
// copyWith after:
cubit.updateField((s) => s.copyWith(stockConfig: s.stockConfig.copyWith(allowOversell: value)));

cubit.updateField((s) => s.copyWith(lowStockThreshold: value));
// →
cubit.updateField((s) => s.copyWith(stockConfig: s.stockConfig.copyWith(lowStockThreshold: value)));
```

### File 10: `lib/features/settings/presentation/pages/image_settings_page.dart`

```dart
// s.imageMaxWidth → s.imageConfig.maxWidth
// s.imageQuality → s.imageConfig.quality

cubit.updateField((s) => s.copyWith(imageMaxWidth: value));
// →
cubit.updateField((s) => s.copyWith(imageConfig: s.imageConfig.copyWith(maxWidth: value)));
```

### File 11: `lib/features/settings/presentation/pages/barcode_settings_page.dart`

```dart
// s.barcodeScanEnabled → s.barcodeConfig.scanEnabled
// s.barcodeBeepOnScan → s.barcodeConfig.beepOnScan
// s.barcodeAutoGeneratePrefix → s.barcodeConfig.autoGeneratePrefix

cubit.updateField((s) => s.copyWith(barcodeScanEnabled: value));
// →
cubit.updateField((s) => s.copyWith(barcodeConfig: s.barcodeConfig.copyWith(scanEnabled: value)));
```

### File 12: `lib/features/settings/presentation/pages/backup_settings_page.dart`

```dart
// s.backupReminderDays → s.backupConfig.reminderDays
// s.lastBackupAt → s.backupConfig.lastBackupAt
// s.backupEncryptionEnabled → s.backupConfig.encryptionEnabled

cubit.updateField((s) => s.copyWith(lastBackupAt: now));
// →
cubit.updateField((s) => s.copyWith(backupConfig: s.backupConfig.copyWith(lastBackupAt: now)));
```

### File 13: `lib/features/settings/presentation/pages/settings_root_page.dart`

ไฟล์ใหญ่ มี 4 private methods `_storeSubTopics`, `_paymentSubTopics`, `_generalSubTopics`, `_systemSubTopics` แต่ละอันรับ `AppSettings s` — เปลี่ยนทุก signature เป็น `Settings s` แล้วอัปเดต access pattern

### File 14: `lib/features/settings/presentation/pages/shop_info_settings_page.dart`

```dart
// s.shopName → s.shopInfo.name
// s.address → s.shopInfo.address
// s.phone → s.shopInfo.phone

cubit.updateField((s) => s.copyWith(shopName: value));
// →
cubit.updateField((s) => s.copyWith(shopInfo: s.shopInfo.copyWith(name: value)));
```

### File 15: `lib/features/settings/presentation/pages/general_settings_page.dart`

ใช้ `GeneralSettingsForm` ที่อัปเดตใน P2-B แล้ว — เปลี่ยน type parameter เท่านั้น

### File 16: `lib/features/settings/presentation/pages/receipt_settings_page.dart`

ใช้ `ReceiptSettingsForm` — เปลี่ยน type parameter

### File 17: `lib/features/settings/presentation/pages/sales_settings_page.dart`

ใช้ `SalesSettingsForm` — เปลี่ยน type parameter

### File 18: `lib/features/settings/presentation/pages/discount_policy_settings_page.dart`

ใช้ `DiscountPolicySettingsForm` — เปลี่ยน type parameter

### File 19: `lib/features/settings/presentation/pages/promptpay_settings_page.dart`

```dart
// s.promptpayId → s.paymentConfig.promptpayId
// s.promptPayTimeout → s.paymentConfig.promptPayTimeout
// s.billerId → s.paymentConfig.billerId
// s.defaultQrType → s.paymentConfig.defaultQrType
// s.autoConfirmAfterSlip → s.paymentConfig.autoConfirmAfterSlip
// s.promptPaySoundEnabled → s.paymentConfig.promptPaySoundEnabled
// s.qrOverlayIcon → s.paymentConfig.qrOverlayIcon
```

### File 20: `lib/main.dart`

`main.dart` บรรทัดที่ใช้ `state.settings`:

```dart
// Before
locale: state.settings.locale,
themeMode: state.settings.themeMode,
// และ
if (!state.settings.onboardingCompleted)

// After
locale: Locale(state.settings.uiConfig.locale),
themeMode: ThemeMode.values.byName(state.settings.uiConfig.themeMode),
// และ
if (!state.settings.onboardingCompleted)   // ← field นี้ flat อยู่แล้ว ไม่ต้องเปลี่ยน
```

---

## P2-C — Features ที่ consume SettingsCubit ภายนอก settings feature

### File 21: `lib/features/sale/presentation/widgets/cart_total_bar.dart`

```dart
final settings = context.read<SettingsCubit>().state.settings;
// Before
settings.dailyCloseLock
settings.lastClosedDate
// After
settings.dailyCloseConfig.dailyCloseLock
settings.dailyCloseConfig.lastClosedDate
```

### File 22: `lib/features/sale/presentation/widgets/checkout_body.dart`

เหมือน `cart_total_bar.dart` — เปลี่ยน `settings.dailyCloseLock` และ `settings.lastClosedDate`

### File 23: `lib/features/sale/presentation/widgets/cart_bottom_sheet.dart`

เหมือนกัน — `dailyCloseLock` + `lastClosedDate`

---

## P2-D — Tests + Delete (14 test files + 1 delete)

### Test file update pattern

```dart
// Before (fixtures.dart หรือ test files)
AppSettings()
AppSettings(shopName: 'Test Shop', vatMode: 'INCLUSIVE')

// After
const Settings()
const Settings(shopInfo: ShopInfo(name: 'Test Shop'), taxConfig: TaxConfig(vatMode: 'INCLUSIVE'))
```

### Files to update

| File | Change |
|------|--------|
| `test/helpers/fixtures.dart` | `AppSettings()` → `const Settings()` |
| `test/features/settings/cubit/settings_cubit_test.dart` | Update emit assertions, `AppSettings` → `Settings` |
| `test/features/settings/domain/entities/app_settings_test.dart` | **DELETE** — facade ถูกลบแล้ว |
| `test/core/services/receipt_pdf_service_test.dart` | `AppSettings(vatMode:...)` → `const Settings(taxConfig: TaxConfig(vatMode:...))` |
| `test/core/widgets/receipt_preview_test.dart` | `AppSettings(...)` → `const Settings(...)` |
| `test/features/daily_close/presentation/cubit/daily_close_cubit_test.dart` | Update settings access |
| `test/features/sale/data/services/receipt_number_service_test.dart` | Update settings fixture |
| `test/features/settings/presentation/pages/settings_page_test.dart` | Update widget test helper |
| `test/features/product/presentation/pages/product_form_page_test.dart` | Update mock settings |
| `test/features/product/presentation/pages/product_list_page_test.dart` | Update mock settings |
| `test/features/sale/presentation/pages/cart_review_page_test.dart` | Update mock settings |
| `test/features/sale/presentation/pages/checkout_page_test.dart` | Update mock settings |
| `test/features/sale/presentation/pages/payment_sheet_test.dart` | Update mock settings |
| `test/features/sale/presentation/pages/sale_page_test.dart` | Update mock settings |

### Delete

```
lib/features/settings/domain/entities/app_settings.dart  ← ลบทิ้ง
```

ก่อนลบ ให้ verify: `grep -r "app_settings.dart" lib/` → 0 results

---

## Execution Order Within P2

```
P2-A: Core 3 files (settings_state, settings_cubit, persistence_service)
   ↓ flutter analyze → expect errors in widgets/pages (OK, expected)
P2-B: 5 widget files
   ↓ flutter analyze → errors should drop significantly
P2-C: 12 page/feature files
   ↓ flutter analyze → 0 errors
P2-D: 14 test files → delete app_settings.dart
   ↓ flutter test → 100% pass
   ↓ grep -r "AppSettings" lib/ → 0 results ✅
```

---

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| `SettingsState.initial()` factory ต้องใช้ `const Settings()` | `Settings` มี `const` constructor แล้ว — OK |
| Widget tests fail เพราะ `BlocProvider<SettingsCubit>` emit type เปลี่ยน | อัปเดต `SettingsState` type ใน test pump/provider |
| `Locale` conversion — `String` vs `Locale` object | `Locale(s.uiConfig.locale)` แทน `s.locale`; `ThemeMode.values.byName(s.uiConfig.themeMode)` แทน `s.themeMode` |
| SettingsMapper (data layer) ยังส่ง Settings → ไม่ต้องเปลี่ยน | SettingsRepository ส่ง `Settings` ตรงอยู่แล้ว |

---

## Success Gate — Phase 2

- [ ] `flutter analyze` → **0 issues**
- [ ] `flutter test` → **≥ 371 passing** (no regression)
- [ ] `grep -r "AppSettings" lib/` → **0 results**
- [ ] `grep -r "app_settings.dart" lib/` → **0 results**
- [ ] `lib/features/settings/domain/entities/app_settings.dart` — ไฟล์ถูกลบแล้ว
- [ ] `test/features/settings/domain/entities/app_settings_test.dart` — ไฟล์ถูกลบแล้ว

> 📄 Next: [080-P3-RELEASE.md](080-P3-RELEASE.md)
