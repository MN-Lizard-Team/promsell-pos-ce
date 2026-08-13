# W-B — Security Hardening (P0)

**Parent:** [V090-TRUST-OVERVIEW.md](./V090-TRUST-OVERVIEW.md)  
**Status:** ✅ Done for v0.9.0 trust cut (local ship bar)  
**Risk if skipped:** Staff fraud (void / PromptPay / stock), weak offline PIN, backup mishandling

---

## Problem (historical)

- App lock was min PIN 4 / single SHA-256 / no durable lockout
- Backup encryption could be turned off without friction
- Secure storage options not always explicit

---

## Tasks

| ID | Task | Primary paths | Done |
|----|------|---------------|------|
| **B1** | PIN min length ≥ 6 (align with backup) | `app_lock_service.dart`, PIN dialog, l10n | ✅ |
| **B2** | CSPRNG salt + PBKDF2-HMAC-SHA256 (v2) + legacy v1 upgrade | `app_lock_service.dart` | ✅ |
| **B3** | Lockout after N failures — **persisted** in secure storage | service + dialog | ✅ |
| **B4** | Explicit `FlutterSecureStorage` options | `app_lock_service`, `db_key_store` | ✅ |
| **B5** | Backup encrypt default on; encryption-off needs store PIN + confirm | `backup_*`, settings UI | ✅ |
| **B6** | Session clear on background + FLAG_SECURE on PIN/PromptPay | `_MainShell`, `SecureScreen` | ✅ |
| **B7** | Gate stock adjust + CSV import with store PIN | `adjust_stock_sheet`, `openProductCsvImport` | ✅ |
| **B8** | Checkout failure unlocks cart (no stuck `paymentLocked`) | `checkout_bloc.dart` | ✅ |

---

## Exit criteria

- [x] Expanded `app_lock_service` tests: set / verify / wrong / disable / grace / lockout / cold-start persist
- [x] Mobile release path does not use desktop debug fixed key
- [x] Backup default encrypt on; plain SQLite restore rejected
- [x] Pair with W-C trust tests (`release-trust.yml`)

---

## Residual (accepted / later)

- PIN remains **optional** (opt-in) — not forced onboarding
- No multi-user RBAC
- Cross-device restore / key export = Phase 2b
- R8 minify / deeper crash sanitize = post-0.9 polish

---

## Related

- `SECURITY.md`, `docs/PRIVACY_POLICY.md`, smoke #11–#13 in `docs/testing/RELEASE_0.9_SMOKE.md`
