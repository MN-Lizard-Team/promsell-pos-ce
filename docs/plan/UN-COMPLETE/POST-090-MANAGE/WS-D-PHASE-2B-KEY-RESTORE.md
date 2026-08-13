# Workstream D — Phase 2b (Key export / cross-device restore)

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Backlog IDs:** D0–D4  
**Sources:** `SECURITY.md`, `docs/DATABASE.md`, backup services, V090 non-goals

---

## Goal

ลด **data-loss / device-lock-in** ของ SQLCipher โดยมีทาง **ส่งออกกุญแจหรือกู้คืนข้ามเครื่อง** ที่ threat-model ชัด — ไม่ปล่อย feature ที่ brute-force offline ได้ง่ายกว่า backup PIN ปัจจุบันโดยไม่มี control

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

- [ ] Settings entry: “Export recovery kit” / “เตรียมย้ายเครื่อง”  
- [ ] Strong secret rules (length, confirm, optional diceware)  
- [ ] Clear copy TH/EN: **anyone with export + secret can read sales**  
- [ ] Flow: re-auth store PIN → create export → share sheet  
- [ ] Import on new device: enter secret → install key → restore DB  
- [ ] Failure modes: wrong secret, wrong file, version mismatch  

Interim if D2 delayed: **D4** first-run / periodic backup education only.

---

## D2 — Implementation (after D0–D1)

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

- D0 written and accepted  
- D1 UX locked TH/EN  
- D2 + tests green for ship  
- D3 docs match code  
- Smoke: device A export → device B restore sale visible  

---

<sub>WS-D · PLAN ONLY · Security-sensitive</sub>
