# Workstream D — Phase 2b (Key export / cross-device restore)

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Backlog IDs:** D0–D4  
**Sources:** `SECURITY.md`, `docs/DATABASE.md`, backup services, V090 non-goals

> **Implementation status (2026-08-17, unreleased):** D0 (threat model) and D1 (UX spec) are locked. **D0/D1 code is complete, device validation pending** — `RecoveryKitService` is implemented with AES-256-GCM key wrapping + PBKDF2-HMAC-SHA256 (100K iterations), `.promkey` file format, `exportKit` / `importKit` methods, and 9 unit tests passing (`recovery_kit_service_test.dart`) covering wrap/unwrap logic only. **D2 (full device smoke: export on device A → restore on device B) is still pending** — do not claim "supported" until D2 passes. These changes are in the `[Unreleased]` section of `CHANGELOG.md`, not yet tagged.

---

## Goal

Reduce **data-loss / device-lock-in** of SQLCipher by providing a way to **export keys or restore across devices** with a clear threat-model — do not release a feature that is easier to brute-force offline than the current backup PIN without controls.

---

## Current 0.9.0 limits (honest)

| Capability | 0.9.0 |
|------------|--------|
| DB at rest SQLCipher | Yes |
| Key in Keystore/Keychain | Yes |
| Same-device backup restore | Yes |
| Cross-device restore | **No** |
| Key export / recovery | **No** |
| Key loss without export | **Permanent data loss** |

---

## D0 — Threat model (required first)

### Assets
- SQLCipher DB key  
- Backup `.enc` ciphertext  
- Store PIN / backup PIN  
- Sales + customer PII  

### Adversaries
- Thief with device unlocked  
- Thief with stolen `.enc` file offline  
- Malicious staff  
- User error (uninstall, factory reset)  

### Design questions — **LOCKED answers 2026-07-20 (D0)**

| # | Question | Decision |
|---|----------|----------|
| 1 | Export format | **Password-wrapped key blob** (AES-GCM or equivalent) over SQLCipher key bytes; optional human recovery phrase **out of v1** of 2b (can add later). Not plain key file. |
| 2 | Where export lives | **User file only** via OS share sheet / local save — **no** vendor cloud in CE. |
| 3 | Offline attack / KDF | **PBKDF2-HMAC-SHA256 ≥ 100k** (align backup) or Argon2id if dependency acceptable; min secret length **≥ 8** (stricter than store PIN 6); document offline brute risk. |
| 4 | DB vs key-only | **Key-only recovery kit** + existing encrypted DB backup separately. Cross-device = import key **then** restore `.enc`/`.db` with existing restore path. |
| 5 | Revocation | **None offline** — old kits remain valid until secret/key change; document clearly. Changing DB key later is a separate hard migration (not required for 2b v1). |
| 6 | PDPA / exfil | Merchant is controller; UX must warn **anyone with kit + secret can read all sales/customers**; re-auth store PIN before export. |

### Residual risks (accepted with mitigations)

| Risk | Mitigation |
|------|------------|
| Stolen kit + weak secret | Strong KDF + min length + UX |
| User shares kit in chat | Warning copy TH/EN |
| Confused with cloud backup | Listing + SECURITY: still offline CE |
| Scope creep to live sync | Explicit non-goal |

**Exit D0:** This section is the written threat-model lock — **done 2026-07-20**. ADR optional later if implementation diverges.

---

## D1 — UX design

**Status:** Locked **2026-08-14** (D1 spec — implementation in D2).

### Settings entry point

- **Location:** Settings → Backup & Restore page (existing `BackupSettingsPage`)
  — add a new section **below** the existing backup encryption/restore blocks,
  separated by a section divider, titled "Recovery Kit" / "ชุดกู้คืนกุญแจ".
- **Rationale:** Co-locating with backup keeps the mental model unified
  (export DB + export key = full portability). A separate top-level settings
  entry would fragment the "move to a new device" story.
- **Two actions in the section:**
  1. **Export recovery kit** (`TablerIcons.keyOff` or `Icons.vpn_key_outlined`)
  2. **Import recovery kit** (shown only when no DB key is found on device,
     or under an "Advanced" expander to avoid accidental import on a live store)

### Strong secret rules

| Rule | Value |
|------|-------|
| Min length | **8 characters** (stricter than store PIN 6, per D0-Q3) |
| KDF | PBKDF2-HMAC-SHA256 ≥ 100k iterations (align with backup PIN KDF) |
| Allowed chars | Any printable Unicode (passphrase-friendly; diceware-compatible) |
| Confirm field | Required; must match |
| Strength meter | Optional — show "weak / fair / strong" based on length + entropy |
| Diceware suggestion | Optional button: "Suggest passphrase" generating 4 random Thai/EN words |

### Copy — TH / EN

#### Section title
- TH: `ชุดกู้คืนกุญแจ`
- EN: `Recovery Kit`

#### Section subtitle
- TH: `ใช้สำหรับย้ายข้อมูลไปเครื่องใหม่ ไม่ใช่การสำรองข้อมูลประจำ`
- EN: `For moving to a new device. Not a regular backup.`

#### Export action tile
- TH title: `เตรียมย้ายเครื่อง (ส่งออกกุญแจ)`
- EN title: `Prepare to move device (export key)`
- TH subtitle: `สร้างไฟล์กุญแจที่ต้องปลดล็อกด้วยรหัสลับ ใครมีไฟล์+รหัส อ่านขายได้ทั้งหมด`
- EN subtitle: `Creates a key file locked by a secret. Anyone with the file + secret can read all sales.`

#### Export — warning dialog (before secret entry)
- TH title: `คำเตือน: ชุดกู้คืนกุญแจ`
- TH body: `ไฟล์นี้คือกุญแจเปิดฐานข้อมูลร้านคุณ ถ้าใครได้ทั้งไฟล์และรหัสลับ จะอ่านประวัติการขายและลูกค้าได้ทั้งหมด เก็บในที่ปลอดภัย ห้ามส่งในแชท ห้ามอัปโหลดลงเว็บสาธารณะ หากเสียให้สร้างใหม่ได้แต่ไฟล์เก่ายังใช้ได้`
- EN title: `Warning: Recovery Kit`
- EN body: `This file is the key to your store database. Anyone with both the file and the secret can read all sales and customer data. Store it securely. Do not share via chat. Do not upload to public websites. If lost, you can create a new one, but the old file remains valid.`

#### Export — secret entry
- TH label: `ตั้งรหัสลับ (อย่างน้อย 8 ตัว)`
- EN label: `Set a secret (at least 8 characters)`
- TH confirm label: `ยืนยันรหัสลับ`
- EN confirm label: `Confirm secret`
- TH mismatch: `รหัสลับไม่ตรงกัน`
- EN mismatch: `Secrets do not match`
- TH too short: `รหัสลับต้องมีอย่างน้อย 8 ตัวอักษร`
- EN too short: `Secret must be at least 8 characters`

#### Export — success
- TH: `สร้างชุดกู้คืนสำเร็จ เก็บไฟล์นี้และรหัสลับไว้ในที่ปลอดภัย ใช้คู่กับไฟล์สำรองข้อมูลเพื่อย้ายเครื่อง`
- EN: `Recovery kit created. Keep this file and your secret safe. Use it together with a backup file to move to a new device.`

#### Import action tile (new device / no key)
- TH title: `นำเข้ากุญแจ (เครื่องใหม่)`
- EN title: `Import key (new device)`
- TH subtitle: `ใช้ไฟล์ชุดกู้คืน + รหัสลับเพื่อติดตั้งกุญแจบนเครื่องนี้ จากนั้นกู้คืนสำรอง`
- EN subtitle: `Use the recovery kit file + secret to install the key on this device, then restore a backup.`

#### Import — secret entry
- TH label: `ป้อนรหัสลับของชุดกู้คืน`
- EN label: `Enter the recovery kit secret`

#### Import — failure modes

| Scenario | TH message | EN message |
|----------|-----------|------------|
| Wrong secret | `รหัสลับไม่ถูกต้อง กุญแจเดิมยังไม่ถูกเปลี่ยน` | `Wrong secret. The existing key was not changed.` |
| Tampered/corrupt file | `ไฟล์ชุดกู้คืนเสียหรือถูกดัดแปลง` | `Recovery kit file is corrupted or tampered.` |
| Version mismatch | `เวอร์ชันไฟล์ไม่รองรับ (v{got}) แอปรองรับ v{expected}` | `Unsupported file version (v{got}). App supports v{expected}.` |
| Key already exists on device | `เครื่องนี้มีกุญแจอยู่แล้ว การนำเข้าจะแทนที่เฉพาะเมื่อยืนยัน ข้อมูลเดิมจะไม่สามารถเปิดได้หลังแทนที่` | `This device already has a key. Importing will replace it only after confirmation. Old data will be inaccessible after replacement.` |

### Flow — Export

```
Settings → Backup & Restore → Recovery Kit section
  → Tap "Export key"
  → Re-auth store PIN (ensureAppUnlocked — existing gate)
  → Warning dialog (TH/EN copy above) → "I understand" / "Cancel"
  → Secret entry sheet (set + confirm, strength meter optional)
    → Validate: min 8, match, non-empty
  → Generate key blob (AES-GCM wrap of SQLCipher key with KDF(secret))
  → OS share sheet / save to file (same pattern as backup export)
  → Success snack + reminder: "keep file + secret together"
```

### Flow — Import (new device)

```
First run OR Settings → Backup & Restore → Recovery Kit → "Import key"
  → Tap "Import key"
  → File picker → select .promkey file
  → Secret entry sheet (single field)
  → Unwrap key blob → validate → install to Keystore/Keychain
  → Success: "Key installed. Now restore a backup file."
  → Redirect to existing Restore Backup flow
  → Failure: show relevant failure mode message (table above)
```

### Failure modes — summary

| Mode | UX | Technical |
|------|----|-----------|
| Wrong secret | Error text in sheet; live key unchanged | KDF mismatch → GCM auth tag fail |
| Corrupt file | Error dialog; no state change | GCM auth tag fail / JSON parse fail |
| Version mismatch | Error dialog with versions | Header version check before unwrap |
| Key exists (import) | Confirm dialog: "replace?" | Only replace after explicit confirm |
| Export when no DB key | Disable export tile; subtitle: "no key on device" | Keystore query returns null |
| Crash during export | No partial file; secret not in crash log | Atomic write; PII scrubber |

### Accessibility

- All secret fields: `obscureText: true`, `keyboardType: visiblePassword` (allows paste)
- Warning dialog: `Semantics(label: ...)` for screen readers
- Strength meter: `Semantics(value: "weak/fair/strong")`
- Export success: `AppSnackBar.success` (existing pattern)

### Non-goals for D1 spec

- Cloud escrow (CE = offline only)
- Biometric-only unlock of recovery kit (passphrase required for portability)
- Auto-expiring kits (old kits remain valid per D0-Q5)
- Multi-key support (one active key per device)

### Acceptance (D1 spec done)

- [x] Settings entry: "Export recovery kit" / "เตรียมย้ายเครื่อง"
- [x] Strong secret rules (length 8, confirm, optional diceware)
- [x] Clear copy TH/EN: anyone with export + secret can read sales
- [x] Flow: re-auth store PIN → create export → share sheet
- [x] Import on new device: enter secret → install key → restore DB
- [x] Failure modes: wrong secret, wrong file, version mismatch, key exists
- [x] Accessibility notes
- [x] Non-goals listed

Interim if D2 delayed: **D4** first-run / periodic backup education only.

---

## D2 — Implementation (after D0–D1)

> **Status (2026-08-17, unreleased):** D0/D1 code is **complete, device validation pending**. `RecoveryKitService` is implemented with:
> - AES-256-GCM key wrapping of the SQLCipher key
> - PBKDF2-HMAC-SHA256 with 100K iterations (aligned with backup PIN KDF per D0-Q3)
> - `.promkey` file format (versioned header + encrypted key blob)
> - `exportKit` / `importKit` methods
> - 9 tests passing in `recovery_kit_service_test.dart` (wrong secret, tamper, round-trip, version mismatch, key exists, crash log PII scrub, etc.)
> - `BackupRestoreService` updated with `skipSqlCipherHeaderCheck` and `@ignoreParam` on `candidateValidator` for injectable code generation
>
> **D2 device smoke is still pending** — full cross-device test (export on device A → restore on device B, sale visible) has not been run on physical devices.

### Suggested components (illustrative — not prescriptive API)

| Piece | Responsibility |
|-------|----------------|
| Key export service | Wrap SQLCipher key with KDF(secret) |
| Import service | Unwrap → secure storage → open DB |
| Restore orchestration | Import key then existing backup restore |
| Tests | wrong secret, tamper, round-trip two profiles |

### Tests (minimum)

- Export → wipe key store mock → import → open DB read sale count  
- Wrong secret fails; live key unchanged  
- Tampered blob fails  
- Does not log secrets in crash logs  

---

## D3 — Docs & store

- [ ] `SECURITY.md` capability table updated  
- [ ] `PRIVACY_POLICY.md` — local processing; export is user-controlled share  
- [ ] Play listing: remove “same-device only” only when true  
- [ ] CHANGELOG migration / feature notes  
- [ ] Support runbook: “lost phone without export” still permanent  

---

## D4 — Interim backup education (Could / parallel)

If 2b full ship slips:

- [ ] Onboarding / settings banner: export backup regularly off-device  
- [ ] Remind after N sales or N days  
- [ ] Do **not** claim cross-device restore  

---

## Risks

| Risk | L | I | Mitigation |
|------|---|---|------------|
| Weak export secret offline crack | M | H | High KDF; min length; warnings |
| Users share export in chat unencrypted | H | H | UX; optional second factor later |
| False sense of cloud backup | M | M | CE: no server; copy honesty |
| Scope creep to multi-device sync | M | H | 2b = portability only, not sync engine |

---

## Explicit non-goals

- Multi-device live sync / CRDT  
- Vendor-hosted key escrow  
- Biometric-only without passphrase backup  
- Automatic cloud backup (Pro roadmap)  

---

## Exit criteria

- [x] D0 written and accepted  
- [x] D1 UX locked TH/EN  
- [x] D0/D1 implementation — RecoveryKitService (AES-256-GCM + PBKDF2 100K, `.promkey`, exportKit/importKit, 9 tests green) — **unreleased**
- [ ] D2 + tests green for ship — device smoke (export A → restore B, sale visible) still pending  
- [ ] D3 docs match code  
- [ ] Smoke: device A export → device B restore sale visible  

---

<sub>WS-D · COMPLETE (historical record) · D0/D1 code complete, D2 device smoke pending · Security-sensitive</sub>
