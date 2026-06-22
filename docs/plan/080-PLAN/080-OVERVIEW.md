# v0.8.1 — Release Plan Overview

**Version target:** `0.8.1+1`
**Base:** v0.8.0 (351 tests, 0 analyze issues)
**Theme:** Phase 4 Pre-work + Quality

---

## Goal

ลบ `AppSettings` facade ที่ `@Deprecated` ออกจาก codebase ทั้งหมด และปิดรายการค้างจาก Phase 1 ก่อนเริ่ม Phase 4 (multi-device sync)

---

## Phase Overview

| Phase | Theme | Tasks | Effort | Risk |
|-------|-------|-------|--------|------|
| **P1** | Quick Wins | PromptPay tests + Theme fix | ~1 day | 🟢 Low |
| **P2** | AppSettings Migration | Facade removal (~28 files) | ~2 days | 🟡 Medium |
| **P3** | Performance + Release | Stress tool + CHANGELOG + tag | ~0.5 day | 🟢 Low |
| **รวม** | | | ~3.5 days | |

---

## Why This Order

```
P1 (Quick Wins)
  → เสร็จก่อน เพราะ independent tasks ที่ไม่ต้องรอ migration
  → PromptPay tests เพิ่ม confidence ก่อนแตะ core code

P2 (AppSettings Migration)  ← งานใหญ่สุด
  → Atomic refactor ทั้งหมด — type system enforce ว่าต้อง compile pass
  → ทำเป็น 4 sub-phase: Core → Widgets → Pages → Tests + Delete

P3 (Performance + Release)
  → Run หลัง P2 เสมอ
  → stress tool verify ว่า migration ไม่กระทบ performance
  → CHANGELOG + tag
```

---

## Decisions (Locked)

| Topic | Decision |
|-------|----------|
| `AppSettings` removal scope | ลบทั้ง class + file — ไม่เหลือ deprecated code |
| Migration pattern | แต่ละ consumer เข้าถึง typed sub-entity โดยตรง (`s.taxConfig.vatRate`) |
| Test strategy | 14 test files อัปเดตพร้อม P2-D — ไม่แยก PR |
| UTC timestamps | ไม่ต้องแก้ — ms timestamps เป็น timezone-independent อยู่แล้ว |
| Stress test | Standalone `tool/seed_db.dart` — ไม่อยู่ใน test suite หลัก |

---

## AppSettings → Settings Field Mapping Reference

ใช้ตารางนี้ในทุก phase สำหรับ access pattern ที่ถูกต้อง:

| AppSettings flat field | Settings typed path |
|------------------------|---------------------|
| `locale` | `uiConfig.locale` (String) |
| `themeMode` | `uiConfig.themeMode` (String) |
| `shopName` | `shopInfo.name` |
| `address` | `shopInfo.address` |
| `phone` | `shopInfo.phone` |
| `currency` | `paymentConfig.currency` |
| `dateFormat` | `uiConfig.dateFormat` |
| `receiptNote` | `receiptConfig.receiptNote` |
| `showShopInfoOnReceipt` | `receiptConfig.showShopInfo` |
| `autoPrintPrompt` | `receiptConfig.autoPrintPrompt` |
| `vatRate` | `taxConfig.vatRate` |
| `vatMode` | `taxConfig.vatMode` |
| `receiptPreviewStyle` | `receiptConfig.receiptPreviewStyle` |
| `showPreSalePreview` | `receiptConfig.showPreSalePreview` |
| `showPostSalePreview` | `receiptConfig.showPostSalePreview` |
| `allowOversell` | `stockConfig.allowOversell` |
| `lowStockThreshold` | `stockConfig.lowStockThreshold` |
| `enableItemDiscount` | `discountConfig.enableItemDiscount` |
| `enableCartDiscount` | `discountConfig.enableCartDiscount` |
| `maxDiscountPercent` | `discountConfig.maxDiscountPercent` |
| `maxDiscountAmount` | `discountConfig.maxDiscountAmount` |
| `defaultDiscountType` | `discountConfig.defaultDiscountType` |
| `discountPresets` | `discountConfig.discountPresets` |
| `activeDiscountPresetId` | `discountConfig.activeDiscountPresetId` |
| `activeDiscountPreset` | `discountConfig.activeDiscountPreset` |
| `promptpayId` | `paymentConfig.promptpayId` |
| `billerId` | `paymentConfig.billerId` |
| `promptPayTimeout` | `paymentConfig.promptPayTimeout` |
| `promptPaySoundEnabled` | `paymentConfig.promptPaySoundEnabled` |
| `defaultQrType` | `paymentConfig.defaultQrType` |
| `autoConfirmAfterSlip` | `paymentConfig.autoConfirmAfterSlip` |
| `qrOverlayIcon` | `paymentConfig.qrOverlayIcon` |
| `receiptSize` | `receiptConfig.receiptSize` |
| `backupReminderDays` | `backupConfig.reminderDays` |
| `lastBackupAt` | `backupConfig.lastBackupAt` |
| `imageMaxWidth` | `imageConfig.maxWidth` |
| `imageQuality` | `imageConfig.quality` |
| `maxDrafts` | `draftConfig.maxDrafts` |
| `cartCompactMode` | `uiConfig.cartCompactMode` |
| `ultraCompactMode` | `uiConfig.ultraCompactMode` |
| `accessibilityMode` | `uiConfig.accessibilityMode` |
| `deviceId` | `deviceConfig.deviceId` |
| `devicePrefix` | `deviceConfig.devicePrefix` |
| `onboardingCompleted` | `onboardingCompleted` |
| `dailyCloseLock` | `dailyCloseConfig.dailyCloseLock` |
| `lastClosedDate` | `dailyCloseConfig.lastClosedDate` |
| `backupEncryptionEnabled` | `backupConfig.encryptionEnabled` |
| `barcodeScanEnabled` | `barcodeConfig.scanEnabled` |
| `barcodeAutoGeneratePrefix` | `barcodeConfig.autoGeneratePrefix` |
| `barcodeBeepOnScan` | `barcodeConfig.beepOnScan` |

### copyWith pattern migration

```dart
// Before (AppSettings flat copyWith)
cubit.updateField((s) => s.copyWith(barcodeScanEnabled: value));

// After (Settings nested copyWith)
cubit.updateField(
  (s) => s.copyWith(barcodeConfig: s.barcodeConfig.copyWith(scanEnabled: value)),
);
```

---

## Success Gate (Phase 3 Exit)

- `flutter analyze` → **0 issues**
- `flutter test` → **≥ 370 passing** (+PromptPay tests)
- `grep -r "AppSettings" lib/` → **0 results**
- `dart run tool/seed_db.dart --products 1000 --sales 5000` → exits cleanly
- `CHANGELOG.md` section `[0.8.1]` complete

---

## File Index

| File | Content |
|------|---------|
| `080-OVERVIEW.md` | This file — master plan, field mapping, success gate |
| `080-P1-QUICK-WINS.md` | Phase 1 — PromptPay tests + Theme token fix |
| `080-P2-APPSETTINGS-MIGRATION.md` | Phase 2 — Full AppSettings facade removal |
| `080-P3-RELEASE.md` | Phase 3 — Stress tool + CHANGELOG + tag |
