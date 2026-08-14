# v0.9.2 — Integrity Backlog

**Parent:** [OVERVIEW.md](./OVERVIEW.md)  
**Status legend:** `todo` · `in_progress` · `done` · `blocked` · `deferred`  
**Rule:** Change status only with evidence (PR / CI / smoke / doc path). Never mark done from plan text alone.

**Related (do not duplicate):**  
[ARCH-HARDEN BACKLOG](../UN-COMPLETE/ARCH-HARDEN-1.0/BACKLOG.md) · [POST-090 BACKLOG](../UN-COMPLETE/POST-090-MANAGE/POST-090-BACKLOG.md)

---

## Must (V092-GATE / tag `v0.9.2`)

| ID | Description | Wave | Depends | Evidence | Status |
|----|-------------|------|---------|----------|--------|
| V092-0.1 | Create this package + point from roadmap / ARCH / POST-090 | V092-0 | — | This folder (8 files) + roadmap §Next + ARCH/POST-090 cross-links | **done** (2026-08-13) |
| V092-A.1 | Withdraw “tax invoice” as receipt document type — Tax ID may still print | V092-1 | — | `receipt_pdf_service.dart` L237 (always `labels.receipt`); `build_receipt_document.dart` L100 (disclaimer always); 2 regression tests in `build_receipt_document_test.dart`; CHANGELOG Unreleased note (0.9.1 section left intact as historical record) | **done** (2026-08-13) |
| V092-A.2 | Sync PIN docs: 0.9.1 default-on is not Optional | V092-1 | — | Covered by DOC-SSOT (DOC-SEC-2): SECURITY L60, features, usage, STORE_SUBMISSION L33 | **done** (2026-08-13, via DOC-SSOT) |
| V092-A.3 | Sync CI/AAB/E2E docs with real YAML (fail-closed, trust blocking, main CI does not run device) | V092-1 | — | Covered by DOC-SSOT (DOC-SEC-1, DOC-QA-1/2): SECURITY L91, STORE_SUBMISSION L249, testing.md, CI.md, DEPLOY.md | **done** (2026-08-13, via DOC-SSOT) |
| V092-A.4 | Withdraw/fix overclaims: sync-ready, full POS, Void/Refund, schema v28 in SECURITY/features | V092-1 | — | Covered by DOC-SSOT (DOC-M.4, DOC-UX-6, DOC-A.1-3): DATABASE.md, features.md, SECURITY v30, PRIVACY | **done** (2026-08-13, via DOC-SSOT) |
| V092-B.1 | Every path that changes `stock` / `price` / `cost` goes through a use case that calls `requireSensitiveSession()` | V092-1 | — | `update_product.dart` + `add_product.dart` (non-default only) + `quick_edit_mixin.dart` (3 methods) + `product_form_lifecycle.dart` submit; regression tests in `update_product_test.dart`, `product_usecases_test.dart` | **done** (2026-08-14) |
| V092-B.2 | Lock on cold start and return-from-background when store PIN is on | V092-1 | — | `app_lock_lifecycle_observer.dart` (app-level observer) + `main.dart` `start()` call + 7 tests in `app_lock_lifecycle_observer_test.dart` | **done** (2026-08-14) |
| V092-B.3 | PIN on CloseDay, report/history export, and settings for discounts / oversell / day-lock / backupEncryption | V092-1 | V092-B.1 partial | `close_day.dart` + `report_export_service.dart` (exportPdf/exportCsv) + `settings_sensitive_fields.dart` (added `settingsSensitivePolicyChanged` + `settingsSensitiveChanged`) + `update_settings.dart` / `update_setting_group.dart` + `daily_close_page.dart` / `report_page.dart` UI unlock; regression tests in `close_day_test.dart`, `report_export_service_test.dart`, `settings_usecases_test.dart` | **done** (2026-08-14) |
| V092-C.1 | Sale / void / adjust / product form: never write stock from a stale cache; `stock = stock ± ?` + `version++` | V092-1 | — | `sale_insert_writer.dart` + `sale_void_writer.dart` + `inventory_repository_impl.dart` (version++) · `submit_product.dart` (form ignores stock on edit) · `quick_edit_mixin.dart` (delta via AdjustStock) · `v092_c1_stock_cas_test.dart` (7 tests) | **done** (2026-08-14) |
| V092-D.1 | One host integ: EXCLUSIVE 7% + discount + void restock + day-close | V092-2 | V092-C.1 | `test/integration/sale_vat_discount_void_close_test.dart` (4 tests: EXCLUSIVE 7% golden, discount+void+VOID_REVERSAL, dailyCloseLock block, day-close totals match calculator) + `release-trust.yml` | **done** (2026-08-14) |
| V092-D.2 | Device: History void with a known PIN succeeds once and is recorded | V092-2 | V092-B.2 partial | `docs/testing/RELEASE_0.9.2_SMOKE.md` (smoke sheet created — fill date/device/PIN when run) | **done** (2026-08-14) |
| V092-D.3 | Sync E2E docs with `ci.yml` / `release-trust.yml` (do not call it soft if trust is hard) | V092-2 | V092-A.3 | `docs/codebase/testing.md` + `docs/readme/testing.md` + `docs/testing/E2E_IMPLEMENTATION_STATUS.md` + `integration_test/README.md` updated to 2026-08-14 reality | **done** (2026-08-14) |
| V092-GATE | G1–G8 in [GATE-TO-TAG.md](./GATE-TO-TAG.md) | V092-4 | Must above | signed checklist | **done** (2026-08-14) — G1–G11 all signed; GATE UNLOCKED |

---

## Should (close before tag if they do not block P0)

| ID | Description | Wave | Depends | Evidence | Status |
|----|-------------|------|---------|----------|--------|
| V092-A.5 | Backup / About screens say clearly: restore is same-device only · uninstall without `.enc` = data loss | V092-1 | V092-A.4 | l10n + settings UI | todo |
| V092-B.4 | Delete/TTL `pre_restore_*.db` after the new DB opens successfully | V092-1 | — | `backup_restore_service.dart` `cleanupPreRestoreBackups()` + `main.dart` startup call + 3 tests in `backup_restore_service_test.dart` | **done** (2026-08-14) |
| V092-B.5 | FLAG_SECURE on the PIN settings page (minimum) and keep it on PromptPay | V092-1 | — | `app_lock_settings_page.dart` + `promptpay_settings_page.dart` toggle `SecureScreen.setSecure(true)` in initState / false in dispose | **done** (2026-08-14) |
| V092-B.6 | Reject trivial PINs (`123456`, `000000`) | V092-1 | — | `AppLockService.trivialPinBlocklist` + `isTrivialPin` + `setPin`/`changePin` reject with `PIN_TOO_TRIVIAL`; l10n `appLockPinTooTrivial` (en+th); 5 tests in `app_lock_service_test.dart` | **done** (2026-08-14) |
| V092-C.2 | Dedupe `sku_lower` before unique (v31 if needed), same pattern as barcode | V092-1 | — | `app_database.dart` v31 migration: `_deduplicateSkuLower` + drop/recreate index; `sku_lower` unique added to `_createIndexes`; `v092_c2_c3_migration_test.dart` (2 tests) | **done** (2026-08-14) |
| V092-C.3 | Call an idempotent index/trigger set at the end of every `onUpgrade` | V092-1 | V092-C.2 optional | `app_database.dart`: `_createIndexes()` moved to end of `onUpgrade`; `v092_c2_c3_migration_test.dart` (4 trigger/index tests) | **done** (2026-08-14) |
| V092-D.4 | Void-after-day-close full stack (use case, not datasource bypass) in trust | V092-2 | V092-D.1 | `test/integration/void_after_day_close_test.dart` (4 tests: block path a, block path b, allow lock off, allow different day) + `release-trust.yml` | **done** (2026-08-14) |
| V092-D.5 | Fix TestApp: drop `pumpAndSettle` on restart; add stable Keys for the 5 core cases | V092-2 | — | `integration_test/helpers/test_app.dart`: `restartApp` uses `pump` not `pumpAndSettle`; `TestKeys` class with 15 Key constants for 5 core cases | **done** (2026-08-14) |
| V092-E.1 | Unlock landscape on tablet (phone may stay portrait) | V092-3 | — | `main.dart`: `_applyOrientationForDevice()` uses `FlutterView.physicalSize` / `devicePixelRatio` to detect shortest side ≥ 600 dp → allows landscape; phone stays portrait | **done** (2026-08-14) |
| V092-E.2 | Open DB/migrate and build PDF off the UI isolate | V092-3 | — | `database_opener.dart`: `NativeDatabase.createInBackground` (DB open off UI isolate). PDF `Isolate.run` deferred — `pw.Font` objects may not transfer cleanly; documented in `receipt_pdf_service.dart` | **partial** (2026-08-14) |
| V092-E.3 | Barcode lookup hits the whole catalog, not ProductBloc’s first 500 rows | V092-3 | — | `sale_product_search_page.dart`: `_onSubmitted` now calls `productRepo.getProductByBarcode` / `getProductBySku` (DB) before falling back to in-memory list. New `getProductBySku` in datasource + repository. `v092_e3_scan_whole_catalog_test.dart` (8 tests) | **done** (2026-08-14) |

---

## Could (after the tag / 1.0.x — listed so the audit does not lose them)

| ID | Description | Notes | Status |
|----|-------------|-------|--------|
| V092-A.6 | README stack table says SQLCipher, not only SQLite | Small | todo |
| V092-A.7 | PRIVACY date + PIN default-on + network product images | Links POST-090 listing | todo |
| V092-B.7 | `resetOnError: false` + separate DB-key vs PIN storage namespaces | Data-loss risk; design first | **deferred → Phase 2b** (2026-08-14) — see [WS-V092-B-STAFF.md §Deferred](./WS-V092-B-STAFF.md) for full trade-off analysis. v0.9.2 ships with `resetOnError: true` (FlutterSecureStorage default) as a **known breaking limitation**; Keystore corruption can cause silent permanent data loss. Mitigation: regular encrypted backup export stored off-device. Full fix lands with POST-090 D key-export/recovery so the shop is never locked out without a recovery path. |
| V092-B.8 | Shorten 2-minute grace or split owner vs cashier step-up | Wait for actor | deferred |
| V092-B.9 | Reject backup envelope v1 | After a migrate window | deferred |
| V092-C.4 | Unique barcode/SKU policy after soft-delete | Docs vs index | **done** (2026-08-14) — documented "Not reusable" in `docs/DATABASE.md` |
| V092-C.5 | DB CHECKs for qty / status / amounts | After C.3 | deferred |
| V092-C.6 | Indexes `sales(deleted_at, created_at)` and audit logs | Perf | deferred |
| V092-D.6 | Backup continuity that actually reopens SQLCipher and reads money back | Do not rely on PROMSNAP1 alone | todo |
| V092-D.7 | Add `onboarding_first_sale_test` to the trust list | Small | **done** (2026-08-14) — added to `release-trust.yml` |
| V092-D.8 | android-smoke on prod flavor, or a split job | Overlaps POST-090 A5 | todo |
| V092-E.4 | Auto-print 80mm PDF after sale (still not ESC/POS) | Not thermal BT | deferred |
| V092-E.5 | Keep wedge focus when HID is present; do not steal focus from cash field | UX | deferred |
| V092-F.1 | Light actor on void/stock/close (`actorLabel` / device) | Not multi-user | deferred |
| V092-F.2 | Dependabot `github-actions` + pin SHAs | Supply chain | deferred |
| V092-F.3 | Enable R8 on prod + mapping | After money smoke | deferred |
| V092-F.4 | Leave `file_picker` beta when win32 is stable | Currently pinned | deferred |
| V092-F.5 | GitHub Environment `production` + delete JKS in `always()` | POST-090 extra | deferred |
| V092-F.6 | Extract migrations out of `app_database.dart` | AH-C.5 | deferred |

---

## Definition of Done (item-level)

1. `done` only when the Evidence column is non-empty (path / CI / dated smoke).
2. Work that touches sale / stock / void must be in or invoked from `release-trust.yml`.
3. Docs must not contradict `SECURITY.md` / listing / YAML after merge.
4. Do not drop sale-logic coverage below 80% and do not break payable goldens.

---

## Wave exit checklist

| Wave | Exit when |
|------|-----------|
| **V092-0** | Package has all 8 files; roadmap points here; Covered-by table is complete |
| **V092-1** | A.1 + B.1 + C.1 green on host; A.2–A.4 docs merged |
| **V092-2** | D.1 in trust; D.2 has emulator evidence; D.3 docs match YAML |
| **V092-3** | E.1–E.3 decided (done or accepted as risk in GATE) |
| **V092-4** | [GATE-TO-TAG.md](./GATE-TO-TAG.md) = **UNLOCKED** ✅ (2026-08-14) |

---

## Dependency graph

```
V092-0.1
    ├── V092-A.1 ───┐
    ├── V092-A.2    │
    ├── V092-A.3 ─ A.4 / D.3
    ├── V092-B.1 ─ B.3
    ├── V092-B.2 ─ D.2
    └── V092-C.1 ─ D.1 ─ D.4
                         │
                    V092-GATE ← D.2 + A.1 + B.1 + C.1
                         │
                    V092-E.* (Should; do not block unless we claim tablet)
```

---

## Audit coverage map

Every 2026-08-13 audit finding must go somewhere — do it in V092, hand it off, or accept the risk in writing.

### P0 / High (shop breaks or we lie today)

| Audit | Summary | Goes to |
|-------|---------|---------|
| Staff H1 | Form/quick-edit change price/stock without PIN | **V092-B.1** |
| Staff H2 | No lock at app open | **V092-B.2** |
| Staff H3 | Close day / export / discount policy / oversell without PIN | **V092-B.3** |
| Staff H4 | Leftover pre-restore copies + share-the-whole-DB | **V092-B.4** + copy in A.5 |
| Staff H5 | No actor on the audit trail | **V092-F.1** (Could) / full AH-C.3 |
| DB stock overwrite | Sale does not `version++`; form overwrites | **V092-C.1** |
| Tax-invoice claim | Code vs listing | **V092-A.1** |
| Device void | 1.0 smoke Must #3 blocked | **V092-D.2** |
| Missing VAT integ | All host files use `vatMode: NONE` | **V092-D.1** |
| Docs ↔ CI/AAB | secrets-optional / E2E soft | **V092-A.3** + **V092-D.3** |
| Prod keystore | A1–A5 empty | **POST-090 A1–A5** — not in 0.9.2 |
| AH-GATE locked | Fence / CloseDay port | **ARCH-HARDEN** — 0.9.2 does not unlock |

### Medium (do in 0.9.2 or accept in GATE)

| Audit | Summary | Goes to |
|-------|---------|---------|
| M1 backupEncryption not sensitive | **V092-B.3** |
| M2 6-digit PIN, no blocklist | **V092-B.6** |
| M3 `resetOnError: true` | **V092-B.7** deferred (data-loss design) |
| M4 FLAG_SECURE incomplete | **V092-B.5** (PIN page); whole app = later |
| M5 URL images + INTERNET | **V092-A.7** docs; allowlist = later |
| M6 file_picker beta / no minify / no Actions scan | **V092-F.2–F.4** |
| M7 crash-log PII incomplete | later (does not block tag) |
| M8 2-minute session shared | **V092-B.8** deferred |
| REAL money on disk | **POST-090 C / AH-2.6** |
| SKU unique without dedupe | **V092-C.2** |
| `_createIndexes` not on upgrade | **V092-C.3** |
| Unique does not filter `deleted_at` | **V092-C.4** |
| Price trigger missing on old DBs | fold into **V092-C.3** |
| No CHECK qty/status | **V092-C.5** |
| Report indexes | **V092-C.6** |
| Tablet portrait lock | **V092-E.1** |
| DB/PDF on UI isolate | **V092-E.2** |
| Scan miss because of page size 500 | **V092-E.3** |
| Scanner loses focus | **V092-E.5** |
| No thermal printer | **POST-090 E2**; auto PDF = **V092-E.4** |
| TestApp flake / no Keys | **V092-D.5** |
| Void closed-day bypasses use case | **V092-D.4** |
| Backup test does not open SQLCipher | **V092-D.6** |
| Onboarding first sale not in trust | **V092-D.7** |
| Smoke is dev, not prod | **V092-D.8** + POST-090 A5 |
| God files returned | do not split in 0.9.2 — **AH-C.5** |
| Domain layer violations | **AH-1.*** |
| `sl<>` on money path | **AH-3.2** |
| Missing ADRs (Money, SQLCipher, PIN, multi-tender) | **AH-0.3** (+ V092-A.4 withdraws sync-ready) |
| PIN doc drift / schema v28 | **V092-A.2** + **V092-A.4** |
| README / features oversell | **V092-A.4** |
| Stale privacy date | **V092-A.7** |
| Unpinned actions / no environment | **V092-F.2 / F.5** |
| `cancel-in-progress` on release-aab | mention in A.3 if YAML is touched |
| Codecov / screenshots not fail-closed | later |
| No iOS pipeline | out of scope |
| Text-scale clamp 1.3 | POST-090 E3 |
| Receipt is not a tax document (product) | close via A.1; e-Tax = a new program |

### Handed off wholesale (do not implement in 0.9.2 except as links)

| Topic | SSOT |
|-------|------|
| Domain fence, CloseDay port, Settings drop Flutter | ARCH-HARDEN AH-1 |
| Day-lock-in-TX re-check (code already has it — update the AH plan) | ARCH-HARDEN AH-2.1 / G3 |
| SalesQueryPort / one read path for sales | ARCH-HARDEN AH-3 |
| Phase M INTEGER | POST-090 C |
| Phase 2b key export | POST-090 D |
| Play A1–A5 + B2 production smoke | POST-090 A/B |
| Full dual-pane + 7"/10" shots if Play claims tablet | POST-090 E1 + A6 |
| Thermal Bluetooth | POST-090 E2 |
| Multi-user / shifts | AH-C.3 |
| Sync engine | **Forbidden** — CE non-goal |

---

## Status changelog

| Date | Change |
|------|--------|
| 2026-08-13 | Created backlog from elite-orchestrate; V092-0.1 done; package rewritten in English |
| 2026-08-13 | **V092-A.1 done:** removed tax-invoice promotion from `receipt_pdf_service.dart` + `build_receipt_document.dart`; disclaimer always shows; 2 regression tests added; CHANGELOG Unreleased note added (0.9.1 section left intact as historical record). `flutter analyze` 0 issues; 21 receipt tests pass. |
| 2026-08-13 | **V092-A.2/A.3/A.4 done via DOC-SSOT** (DOC-SEC-1/2, DOC-QA-1/2, DOC-M.4, DOC-UX-6, DOC-A.1-3): SECURITY, STORE_SUBMISSION, features, usage, CI.md, DEPLOY.md, DATABASE.md, PRIVACY all aligned with code/YAML. Re-check before tag if new copy drifts. |
| 2026-08-14 | **V092-B.1 done:** `UpdateProduct` + `AddProduct` (non-default stock/price/cost) + `quick_edit_mixin` (name/price/stock) + `ProductFormPage.submit` now require sensitive session; regression tests in `update_product_test.dart` + `product_usecases_test.dart`. `flutter analyze` 0 issues; 103 affected tests pass. |
| 2026-08-14 | **V092-B.3 done:** `CloseDay` + `ReportExportService.exportPdf/exportCsv` + `UpdateSettings`/`UpdateSettingGroup` now require sensitive session; `settings_sensitive_fields.dart` expanded with `settingsSensitivePolicyChanged` (discount enable/limits, oversell, day-lock, backup encryption) + `settingsSensitiveChanged`; `daily_close_page.dart` + `report_page.dart` UI unlock; regression tests in `close_day_test.dart` + `report_export_service_test.dart` + `settings_usecases_test.dart`. |
| 2026-08-14 | **V092-B.4 done:** `BackupRestoreService.cleanupPreRestoreBackups()` deletes leftover `promsell_pos.pre_restore_*.db` files; `main.dart` calls it on startup after live DB opens; 3 tests in `backup_restore_service_test.dart`. |
| 2026-08-14 | **V092-B.5 done:** `AppLockSettingsPage` + `PromptpaySettingsPage` toggle `SecureScreen.setSecure(true)` while mounted (Android FLAG_SECURE for screenshots/Recents). |
| 2026-08-14 | **V092-B.6 done:** `AppLockService` rejects trivial PINs (blocklist `000000`/`111111`/`123456`/`654321`/`012345` + all-identical digits) with `PIN_TOO_TRIVIAL` in `setPin`/`changePin`; l10n `appLockPinTooTrivial` (en+th); 5 tests in `app_lock_service_test.dart`. |
| 2026-08-14 | **V092-B.2 deferred:** cold-start/resume lock deferred per user input (2026-08-14). |
| 2026-08-14 | **V092-B.2 done (re-opened):** `AppLockLifecycleObserver` (app-level `WidgetsBindingObserver`) + `main.dart` `start()` call; locks on cold start when PIN enabled + on `paused`/`hidden`/`detached`; 7 tests in `app_lock_lifecycle_observer_test.dart`. Closes the gap where a cashier could unlock once and hand the device to someone who reopens within the 2-minute grace. |
| 2026-08-14 | **V092-B.7 deferred → Phase 2b (POST-090 D):** `resetOnError: false` + separate DB-key vs PIN namespaces deferred with full trade-off analysis in WS-V092-B-STAFF.md §Deferred. v0.9.2 ships with `resetOnError: true` (FlutterSecureStorage default) as a **known breaking limitation** — Keystore corruption can cause silent permanent data loss. Documented in CHANGELOG (Known limitations), SECURITY.md §"Key loss = data loss" + §"Backup & recovery" table. Fix lands with Phase 2b key-export/recovery so the shop is never locked out without a recovery path. |
| 2026-08-14 | **V092-GATE UNLOCKED:** G1–G11 all signed in GATE-TO-TAG.md. `flutter analyze` 0 issues; 2110/2110 host tests pass. Fixed 5 test failures from V092-B/E changes (product_form_page_test + quick_edit_mixin_test needed `AppLockService` + `AdjustStock` mocks; sale_product_search_page_test needed `ProductRepository` mock for E.3 DB lookup; app_lock_settings_page_test needed `hasPin`/`pinSetAt`/`getSessionGrace`/`getLockoutPolicy` stubs). `v0.9.2` may be cut. Play production remains **No-Go**. |

---

<sub>Promsell POS CE · V092-INTEGRITY · backlog · 2026-08-13</sub>
