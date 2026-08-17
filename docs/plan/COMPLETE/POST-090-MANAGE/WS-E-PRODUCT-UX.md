# Workstream E — Product UX Gaps

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Backlog IDs:** E0, E0c, E1–E4  
**Sources:** elite mobile UX report; `CODEBASE.md` UI notes; `docs/readme/roadmap.md`; `AppLockService`

---

## Goal

Close the **cashier-first UX** gaps after 0.9 without breaking money-path: PIN trust, tablet counter layout, (later) thermal, a11y, discoverability

---

## E0 — Spec: Store PIN default-on + domain gates (Must — spec first)

### Problem (from security audit)
- Store PIN is **optional**  
- Many gates are **UI-only** (`ensureAppUnlocked`); domain void/stock/backup do not re-check session  

### Spec decisions — **LOCKED 2026-07-20** (E0)

| Topic | **Decision (locked)** | Rejected alt |
|-------|----------------------|--------------|
| New installs | PIN **required** before first sensitive action (onboarding step or hard gate on first void/backup/stock/CSV/PromptPay/export) | Soft skip after 3 prompts |
| Existing installs | One-time **enable PIN** banner (non-dismiss forever without enabling **or** explicit “remind later” max 7 days) — no data wipe | Silent grandfather forever without banner |
| Session | Keep grace ~2m + clear on background; optional biometric later (out of E0c) | Biometric-only without PIN |
| Domain gate | **Required:** use cases / writers check session via `AppLockService` (or injected port) — **UI-only is not enough** | UI-only `ensureAppUnlocked` alone |
| Gated actions | void, backup export/restore, encrypt-off, stock adjust, CSV import, PromptPay ID edit, destructive settings reset | Gate every settings keystroke (too noisy) |
| Lockout | Keep PBKDF2 + **persisted** lockout | In-memory-only lockout |
| Min length | **6** (already) | Drop below 6 |

### First-run flow (TH/EN intent)

1. After shop basics (or on first gated action): “ตั้งรหัสร้าน / Set store PIN” — explain gates + offline risk.  
2. Enter PIN twice → hash store → session unlock.  
3. Cannot complete void/backup/stock/CSV/PromptPay edit without unlock.  
4. Copy: Lost PIN = can set a new one but cannot recover PIN history; shop data remains if SQLCipher key exists  

### Call sites to move UI-only → domain/session (implement E0c)

| Action | Today (typical) | Target |
|--------|-----------------|--------|
| Void sale | UI `ensureAppUnlocked` | `VoidSale` / void writer path checks session |
| Stock adjust | UI sheet | inventory adjust use case |
| CSV import | UI entry | import use case |
| Backup export/restore | UI | backup services |
| PromptPay ID edit | UI settings | settings update path |
| Backup encrypt off | UI | settings mutation |

### Test plan (E0c)

- [ ] Lock on → each gated action fails closed without session  
- [ ] Unlock → action succeeds once within grace  
- [ ] Background → session cleared → re-auth  
- [ ] Lockout persist across restart (existing unit + one integration)  
- [ ] New install cannot skip PIN permanently without explicit product decision review  

### Acceptance (spec done)
- [x] Written flow TH/EN for first-run  
- [x] List of call sites to move from UI-only → domain/service  
- [x] Test plan: lock on → action blocked; unlock → ok; lockout persist  
- [ ] SECURITY.md update draft when implementing (E0c)  

### E0c — Implementation (Should / Wave 2)
- [x] `AppLockService.requireSensitiveSession()` domain API  
- [x] `VoidSale` + `AdjustStock` call domain gate (UI still prompts first)  
- [x] `BackupExportService` + `BackupRestoreService` domain gate  
- [x] `ImportProducts` (CSV) domain gate  
- [x] PromptPay `promptpayId` / `billerId` via `UpdateSettings` / `UpdateSettingGroup` + `settingsSensitivePaymentChanged`  
- [x] Unit tests: void/CSV/PromptPay blocked when lock on / session cold  
- [x] Default-on PIN for new installs: onboarding finish/skip require `setPin` (2026-07-20)  
- [x] `StorePinSetup.validateNewPin` + `showCreateStorePinDialog`  
- [ ] Optional: force PIN on first sensitive action for **legacy** installs without PIN  
- [ ] Settings migration flags (legacy banner)  
- [x] No money formula changes

---

## E1 — Tablet dual-pane sale (Should)

### Problem
- Adaptive breakpoints exist but sale is **phone stack** (catalog + bottom cart)  
- Docs historically mentioned dual-pane; code is delivery-style full-page cart review  

### Scope
- [x] Expanded width (≥840dp): catalog | cart pane visible — `SaleDualPane` + `DockedCartPanel` (2026-08-14)
- [x] Compact: keep current CartBottomBar / review page — Stack fallback in `SaleDualPane`
- [x] Orientation policy: portrait primary; landscape usable on tablet — `_applyOrientationForDevice` (≥600dp shortest → landscape allowed)
- [x] PromptPay already has wide split — align tokens (existing wide layout)
- [ ] Smoke on tablet emulator or device — **operator-only**
- [ ] Optional store tablet screenshots (A6) — **operator-only**

### Non-goals
- Desktop Windows POS shell  
- Multi-window  

---

## E2 — Bluetooth thermal print (Could / CE help-wanted)

### Scope (scaffold)
- [ ] Plugin research (ESC/POS) + AGPL compatibility  
- [ ] Abstraction: `ReceiptPrinter` port; PDF remains default  
- [ ] Settings: pair printer, paper width 58/80  
- [ ] Map `ReceiptDocument` → ESC/POS commands  
- [ ] Mark help-wanted in README/roadmap if community-owned  

### Non-goals
- Cloud print  
- Fiscal printer certification  

---

## E3 — Accessibility (Could / P1–P2)

### Current
- `accessibilityMode` UI largely **hidden** / incomplete  
- Partial Semantics; large settings tiles good  

### Scope
- [ ] Wire accessibilityMode to text scale / contrast tokens  
- [ ] Semantics on sale add, cart qty, checkout confirm, PIN pad  
- [ ] Manual TalkBack pass on Must cashier path  
- [ ] Do not block 1.0 store on full a11y if Must money paths still usable  

---

## E4 — Discoverability (Could)

- [ ] Surface long-press exact cash pay (tooltip / onboarding tip)  
- [ ] Multi-tender entry hint on checkout  
- [ ] Drafts / saved bills discoverability  
- [ ] Avoid feature sprawl: retail default vs restaurant advanced  

---

## Priority vs 1.0

| Item | 1.0 Must | 1.0.x | Later |
|------|----------|-------|-------|
| E0 spec | ✅ | | |
| E0c implement | | ✅ recommended | |
| E1 tablet | | ✅ | |
| E2 thermal | | | ✅ CE |
| E3 a11y | | partial | full |
| E4 microcopy | | optional | |

---

## Risks

| Risk | Mitigation |
|------|------------|
| Forced PIN hurts first-run conversion | Clear copy; still safer for POS |
| Dual-pane regresses phone | Breakpoints + golden/widget tests |
| Thermal plugin license conflict | AGPL review before depend |
| Scope steals store cut focus | Waves; Must = E0 spec only |

---

## Exit criteria

- E0 spec locked in this doc (checkboxes)  
- E0c/E1+ only `done` with PR + smoke evidence  
- Roadmap Future/Next updated when items ship  

---

<sub>WS-E · COMPLETE (historical record)</sub>
