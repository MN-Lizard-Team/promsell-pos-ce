# W-B — Security Hardening (P0)

**Parent:** [V090-TRUST-OVERVIEW.md](./V090-TRUST-OVERVIEW.md)  
**Status:** ⬜ Not started  
**Risk if skipped:** Staff fraud (void / PromptPay), weak offline PIN, backup mishandling

---

## Problem

- App lock (**was** min PIN 4 / single SHA-256 / no lockout; **now** min 6 + PBKDF2 v2 + lockout + background session clear — see implementation)
- Backup encryption can still be turned off by user
- Secure storage options not always explicit

---

## Tasks

| ID | Task | Primary paths | Done |
|----|------|---------------|------|
| **B1** | PIN min length ≥ 6 (align with backup) | `app_lock_service.dart`, PIN dialog, l10n | ⬜ |
| **B2** | CSPRNG salt + KDF (PBKDF2 / scrypt / Argon2id) instead of single SHA-256 | `app_lock_service.dart` | ⬜ |
| **B3** | Lockout / exponential backoff after N failures | service + dialog | ⬜ |
| **B4** | Explicit `FlutterSecureStorage` options (Android encrypted prefs / iOS accessibility) | `app_lock_service`, `db_key_store` | ⬜ |
| **B5** | Backup: keep default encrypt on; remove plain export from prod **or** stronger re-auth + typed confirm | `backup_*`, settings UI | ⬜ |
| **B6** | Session lock on resume + FLAG_SECURE on PIN/PromptPay | `_MainShell` lifecycle; `SecureScreen` + MainActivity channel | ✅ |

---

## Migration / UX constraints

- Existing PIN hashes: plan **re-enroll** or dual-verify transition — document in PR
- Prefer sensitive-action gates first; full session lock is B6
- Merchant copy must warn: uninstall / keystore wipe without export = permanent loss

---

## Exit criteria

- [ ] Expanded `app_lock_service` tests: set / verify / wrong / disable / grace / lockout
- [ ] No debug desktop fixed-key path on mobile release (review or assert)
- [ ] Backup policy discourages or blocks plaintext export in prod flavor
- [ ] Pair with W-C **C3** test expansion

---

## Related

- Threat notes from elite audit: weak optional lock, doc restore drift, backup share chain
- Pair docs updates with W-A where security policy text changes
