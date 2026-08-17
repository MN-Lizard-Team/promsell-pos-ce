# Release smoke checklist — v1.0.0

**Status:** Partial device walk **2026-07-20** (POST-090 **B2**) — honest Pass/Fail/Blocked.  
**Still No-Go for production.** Do not treat a green `release-trust` emulator job as 1.0 Pass.  
**Do not** treat empty rows as Pass.  
**Predecessor evidence (0.9):** [`RELEASE_0.9_SMOKE.md`](./RELEASE_0.9_SMOKE.md)

**Management:** [`docs/plan/UN-COMPLETE/POST-090-MANAGE/WS-B-QA-HARDENING.md`](../plan/UN-COMPLETE/POST-090-MANAGE/WS-B-QA-HARDENING.md)

---

## Matrix (required for store production A5)

| Slot | Device / build | OS / API | Locale | Filled? |
|------|----------------|----------|--------|---------|
| M1 | `emulator-5554` Medium_Phone · `app-dev-debug.apk` | Android 17 / **API 37** | TH | ✅ 2026-07-20 |
| M2 | ________________ (2nd device **or** 2nd API) | ________ | TH or EN | ⬜ |
| Prod | **prod** AAB dry-run (throwaway JKS only — **not** Play) | host build | — | ✅ throwaway AAB 2026-07-20; production keystore still operator |

Minimum for production Go: **M1 + Prod (real keystore)**. Should: M2 physical if M1 is emulator.

---

## Must cases

| # | Case | Pass? | Evidence (date / note) |
|---|------|-------|------------------------|
| 1 | Cold start: encrypted DB opens (or first-run migrate) | **Pass (device)** | 2026-07-20 log: `Starting Promsell POS CE (dev flavor)` + `sqlcipher`. Screenshot: `screenshots/smoke_1_0_home_2026-07-20.png` |
| 2 | Sale: add → cart → **cash** checkout → receipt | **Pass (device)** | Cart Hot Americano ฿59 → ชำระ → เงินสด → รับพอดี → ยืนยัน → receipt **#260720-LSR-0001** เงินสด ฿59.00; disclaimer not tax invoice. Screenshots: `smoke_1_0_sale_tab_*`, `smoke_1_0_checkout_*`, `smoke_1_0_cash_done_*` |
| 3 | **Void** sale → stock restored / audit log | **Blocked (device) / Pass (host)** | Device: History → ยกเลิกบิล → reason → **store PIN dialog** (`ยืนยันยกเลิกบิลด้วย PIN ร้าน`) — PIN unknown on emulator (pre-enabled lock); void not completed. Host: `sale_integrity_test` + `void_sale_test` green 2026-07-20 |
| 4 | **Day lock:** after daily close, new sale blocked | **Pass (device retest)** | **2026-07-20 retest:** Settings → การขาย → **บล็อกการขายหลังปิดยอด ON** (`checked=true`). Sale tab banner: **「วันนี้ปิดยอดแล้ว กรุณาเปิดยอดใหม่เพื่อขายต่อ」**. Cart had ฿59; **ชำระเงิน** did **not** open payment sheet (no receipt). Prior false alarm: with lock **off** (default), sale `#260720-LSR-0002` after close is expected. Screenshots: `smoke_1_0_daily_close_lock_on_2026-07-20.png`, `smoke_1_0_day_lock_on_block_2026-07-20.png` |
| 5 | Draft: park bill → reopen → totals sensible | **Not re-walked** | UI shows บิลเปิด on sale; full park/reopen not exercised this run. 0.9 device Pass retained as prior evidence only |
| 6 | **PromptPay** wait freeze **or** multi-tender complete | **Pass (host) / N/A device** | Host: `multi_tender_daily_close_test` green. Device PromptPay not re-walked (0.9 retained) |
| 7 | Store PIN enable → gate void **or** stock adjust | **Pass (device)** | Void path showed PIN re-auth dialog; cancel left sale unvoided. Aligns with domain gate + UI |
| 8 | Backup encrypt export (PIN ≥ 6) + **same-device** restore | **Pass (automated)** | Host: `backup_encryption_service_test`, `backup_restore_service_test`, `backup_money_continuity_test` green 2026-07-20. Device full export UI not re-walked |
| 9 | Automated trust suite green (`release-trust` file list) | **Pass** | 2026-07-20: **281** tests passed (expanded trust list incl. golden, multi-tender close, backup continuity, PIN/CSV/settings gates) |
| 10 | `flutter analyze` clean on release branch | **Pass** | 2026-07-20: `flutter analyze lib` → **No issues found** |

## Should cases

| # | Case | Pass? | Notes |
|---|------|-------|-------|
| S1 | Product + sale full search | ⬜ | Not exercised |
| S2 | CSV import gated when PIN on | **Pass (unit)** | `import_products_test` domain gate |
| S3 | Barcode scan add-to-cart (device camera) | ⬜ | Emulator camera N/A |
| S4 | Checkout failure unlocks cart without clearing lines | **Pass (unit)** | `checkout_bloc_test` |
| S5 | PIN lockout survives cold start | **Pass (unit)** | `app_lock_service_test` |

## N/A / out of scope for 1.0 smoke

- Cross-device restore / key export (Phase 2b)
- ~~INTEGER money on disk (Phase M)~~ **Shipped in v0.9.2** (schema v32 satang columns, dual-write, satang-first reads)
- Full soft `integration_test/` suite green on CI — **confirmed still broken** on flavor/APK path 2026-07-20 (`sale_happy_path` Gradle APK not found for default flavor)

---

## Device evidence (2026-07-20)

- Device: `emulator-5554` · Android **API 37** (Medium_Phone)  
- Build: `flutter build apk --debug --flavor dev -t lib/main_dev.dart` → `app-dev-debug.apk` · `adb install -r`  
- Package: `com.promsell.promsell_pos_ce.dev`  
- Cash sale: `#260720-LSR-0001` ฿59  
- Day close: **20/07/2026 ปิดแล้ว** · 1 bill · net ฿59 · cash ฿59  
- With **dailyCloseLock OFF** (default): second cash sale `#260720-LSR-0002` after close (expected)  
- With **dailyCloseLock ON**: banner + checkout blocked (Must #4 Pass retest)  
- Screenshots: `screenshots/smoke_1_0_*.png` incl. `*_daily_close_lock_on_*`, `*_day_lock_on_block_*`  

---

## Automated trust command (host)

```bash
flutter test \
  test/features/sale/data/datasources/sale_local_datasource_test.dart \
  test/features/sale/data/datasources/sale_write_helpers_test.dart \
  test/integration/sale_integrity_test.dart \
  test/integration/checkout_flow_test.dart \
  test/integration/multi_tender_daily_close_test.dart \
  test/integration/backup_money_continuity_test.dart \
  test/features/sale/domain/usecases/create_sale_test.dart \
  test/features/sale/domain/usecases/void_sale_test.dart \
  test/features/sale/domain/services/sale_payable_calculator_test.dart \
  test/features/sale/domain/services/sale_payable_golden_test.dart \
  test/features/sale/domain/services/sales_day_lock_test.dart \
  test/features/sale/presentation/bloc/cart_bloc_test.dart \
  test/features/sale/presentation/bloc/checkout_bloc_test.dart \
  test/features/sale/presentation/bloc/draft_bloc_test.dart \
  test/features/sale/presentation/bloc/cart_discount_policy_test.dart \
  test/features/sale/data/services/receipt_number_service_test.dart \
  test/core/services/app_lock_service_test.dart \
  test/core/services/store_pin_setup_test.dart \
  test/core/services/crash_log_service_test.dart \
  test/core/image/image_cache_service_sandbox_test.dart \
  test/core/database/db_key_store_test.dart \
  test/features/product/domain/usecases/import_products_test.dart \
  test/features/settings/domain/usecases/settings_usecases_test.dart \
  test/features/settings/domain/services/settings_sensitive_fields_test.dart \
  test/features/settings/data/services/backup_encryption_service_test.dart \
  test/features/settings/data/services/backup_restore_service_test.dart \
  test/features/daily_close
```

(Keep in sync with `.github/workflows/release-trust.yml`.)

---

## Sign-off

| Role | Name | Date | Result |
|------|------|------|--------|
| QA / operator | ZCode agent (emulator) | 2026-07-20 | **No-Go production** — M2 missing; prod keystore operator; void full path needs known PIN; draft not re-walked |
| Maintainer | | | Trust suite Pass; analyze Pass; day-lock Pass with lock setting ON |

### P0 follow-up from this smoke

1. ~~Retest day lock with dailyCloseLock ON~~ **Done Pass 2026-07-20**.  
2. Clean emulator install with known onboarding PIN → full void + stock.  
3. Draft park/reopen device re-walk.  
4. M2 physical or second API.  
5. Production keystore (not throwaway) for A4/A5.  
6. Optional UX: default dailyCloseLock ON or prompt when closing day.  

---

<sub>Promsell POS CE · RELEASE_1.0_SMOKE · 2026-07-20 partial</sub>
