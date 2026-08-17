# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| **0.9.x** | Active |
| 0.8.x   | Security fixes only |
| 0.7.x   | No longer supported |
| < 0.7   | No longer supported |

## Reporting a vulnerability

**Do NOT file a public GitHub issue for security vulnerabilities.**

### How to report

1. Go to the [Security tab](https://github.com/teeprakorn1/promsell-pos-ce/security)
2. Click "Report a vulnerability"
3. Include: description, steps to reproduce, affected versions, impact, suggested fix if any

### Response timeline

| Stage | Target time |
|-------|-------------|
| Acknowledgment | 48 hours |
| Initial assessment | 5 business days |
| Fix development | 14 business days (critical), 30 days (high) |
| Advisory published | After fix is released |

## What we consider security issues

- **SQL injection** via unsanitized Drift query inputs
- **Path traversal** in file read/write (PDF, images, backup)
- **Insecure local storage** of sensitive shop or payment data
- **Void/refund bypass** — circumventing atomic void to manipulate stock or revenue
- **Inventory log tampering** — modifying audit trail outside app flow
- **SQLCipher key exposure** or bypass of at-rest encryption
- **Dependency vulnerabilities** in third-party packages

## What we do NOT consider security issues

- UI bugs or UX issues
- Missing features (including **cross-device** restore / SQLCipher key export — Phase 2b)
- Configuration errors by the user
- Device-level security (screen lock, full-disk encryption) — outside app scope
- Data loss after **user-initiated** uninstall or keystore wipe without a backup

## Security architecture (v0.9)

Promsell is an **offline-first local app** with no required network for core POS:

1. **Local-only storage** — sales, catalog, drafts via Drift/SQLite
2. **SQLCipher at rest (Phase 2a)** — database file encrypted; key in platform secure storage (Keystore / Keychain) on mobile; debug desktop may use a fixed dev key (never for production builds)
3. **Key loss = data loss** — there is **no** key recovery or multi-device key export in 0.9.0 / 0.9.2. Uninstall, factory reset, or secure-storage wipe without an export backup makes the DB unreadable. **Additionally (v0.9.2 known limitation, V092-B.7):** `FlutterSecureStorage` defaults to `resetOnError: true` on Android, so if the Android Keystore is corrupted (rare OS-upgrade edge cases, OEM Keystore bugs) the SQLCipher key is **silently deleted and regenerated**, making the encrypted DB permanently unreadable with no warning and no on-device recovery path. The fix (`resetOnError: false` + separate namespaces + user-managed recovery key) is deferred to Phase 2b (POST-090 D) so that it ships together with a recovery path — setting `resetOnError: false` alone would turn silent data loss into a hard crash loop with no escape hatch. **Mitigation today:** keep backup encryption on, export encrypted backups regularly, store the `.enc` file off-device.
4. **Atomic transactions** — sale create, void, stock adjust inside DB transactions
5. **Inventory audit trail** — stock changes logged in `inventory_logs`
6. **Backup export** — WAL checkpoint → DB copy → AES-256-GCM (PBKDF2 PIN, min length 6). Encryption default **on** when the setting key is missing (v0.9); can be turned off with store PIN (if enabled) + confirmation
7. **Backup restore (same-device)** — Settings → Backup can restore a `.enc` / SQLCipher `.db` export on **this device** (needs the existing SQLCipher key in secure storage). Cross-device / after uninstall is **not** supported. Plain SQLite files are rejected
8. **Store PIN lock** — PIN (min **6**) with PBKDF2 hashing + attempt lockout **persisted in secure storage** (survives cold start). **Default-on for new installs (POST-090 E0c):** onboarding **finish** and **skip** prompt to create a store PIN before `onboardingCompleted` (`showCreateStorePinDialog` + `setPin`). **As of v0.9.2 the user may skip PIN setup** — the dialog shows a "Skip" button; if tapped, a confirmation dialog explains the risk (void/backup/stock/CSV/PromptPay are not gated) and offers "Set up PIN instead" vs "Skip, I understand". Existing installs that already completed onboarding without a PIN are unchanged until the user enables PIN in Settings. **Domain re-check:** `VoidSale`, `AdjustStock`, `ImportProducts` (CSV), `BackupExportService` / `BackupRestoreService`, and settings updates that change `promptpayId` / `billerId` call `AppLockService.requireSensitiveSession()`. **Not gated:** product-form / quick-edit writes of `stock` / `price` / `cost` (see V092-B.1). PIN does **not** protect inventory on every path. **Configurable (v0.9.2):** session grace (default 2m; can be set to single-action / 30s / 1m / 5m), max failed attempts (default 5; 3–10), and base lockout (default 30s; 10s–120s) are adjustable in Settings → Store PIN lock and persisted in secure storage. Changing them requires an unlocked sensitive session. **Enable/disable vs erase (v0.9.2):** `disable()` toggles `enabled=0` but **keeps** the PIN hash — re-enabling via `enable()` only requires verifying the existing PIN (use case: temporarily off for staff training). `erasePin()` permanently deletes the hash/salt/scheme/pinSetAt and disables the lock — re-enabling requires `setPin` (a new PIN). Both require an unlocked sensitive session; `erasePin` additionally requires a confirmation dialog in the UI.

9. **Stock CAS (V092-C.1)** — operational stock paths (sale / void / `adjustStock`) use atomic `stock = stock ± ?` with `version = version + 1` in a single `UPDATE`. The product form does **not** write `stock` on edit (it uses the latest DB value); quick-edit stock routes through `AdjustStock` (delta). The `version`-based optimistic lock in `updateProduct` rejects stale form saves when `version` has changed. This prevents the failure where a form opened with stock=10, a sale reduced it to 7, and the form save wrote stock back to 10. Initial stock on product insert is still allowed.
9. **Crash logs** — PII patterns sanitized **on write**
10. **Image sandbox** — product image delete restricted under app `images/` directory
11. **No server by default** — no remote API keys in core flow
12. **Dependency hygiene** — CI outdated check + Dependabot

## Backup & recovery (honest limits)

**SSOT:** Same-device in-app restore **yes**; cross-device / key recovery **no**; key loss without export = permanent data loss.

| Capability | 0.9.0 | 0.9.2 |
|------------|--------|------|
| Export encrypted/plain DB | Yes (encrypt default on) | Yes |
| Share via OS sheet | Yes | Yes |
| In-app restore UI | **Yes (same-device only)** | Yes (same-device only) |
| Cross-device restore / key export | **No** (Phase 2b) | **No** (Phase 2b) |
| SQLCipher key backup | **No** | **No** |
| Survive app uninstall without export | **No** | **No** |
| Survive Keystore corruption (Android) | **No** — `resetOnError: true` silently regenerates key → permanent data loss | **No** (V092-B.7 deferred — known breaking limitation, see CHANGELOG) |

**Recommended practice:** keep backup encryption on, use a strong PIN (≥ 6), export regularly, store the file off-device. Same-device restore still needs this device’s SQLCipher key. After a Keystore wipe the only recovery is restoring the `.enc` backup on a different device that still has its key.

## Security changelog (recent)

- **0.9.2 (V092-B, 2026-08-17)** — staff control & sensitive-action gating: B.1 product PIN gate (UpdateProduct / AddProduct non-default / quick-edit / form submit); B.2 cold-start + resume lock via `AppLockLifecycleObserver`; B.3 CloseDay + report export + discount/oversell/day-lock/backup-encryption settings now sensitive; B.4 pre-restore DB cleanup on startup; B.5 FLAG_SECURE on PIN + PromptPay settings pages; B.6 trivial-PIN blocklist. **Known breaking limitation (V092-B.7 deferred):** `resetOnError: true` default means Keystore corruption can silently wipe the SQLCipher key → permanent data loss; fix deferred to Phase 2b with key-export recovery. **Phase M (C1–C3):** schema **v32** adds nullable INTEGER `*_satang` dual-write columns to all 10 money tables (32 columns) and backfills from REAL baht. `NullableMoneySatangConverter` is active; writers dual-write, readers are satang-first with REAL fallback, and report/tender aggregation uses integer satang before display conversion. No security impact; legacy REAL columns remain temporarily for rollback compatibility, and the encrypted pre-M backup-restore fixture is still pending.
- **0.9.1** — schema **v31** (`barcode_lower` / `sku_lower` uniques + v31 dedupe repair). PIN still default-on for new installs. Stock PIN remains AdjustStock + CSV only.
- **0.9.0** — SQLCipher production path; backup encrypt default on; **same-device in-app restore**; store PIN min 6 + PBKDF2 + **persisted** lockout; gates void/backup/AdjustStock/CSV/PromptPay; crash sanitize on write; image delete sandbox; schema **v28** at that cut; checkout failure unlocks cart
- **0.8.x** — See prior SECURITY entries and CHANGELOG (barcode uniqueness, orphaned images, crash export sanitize, restaurant/CRM isolation)

## Security testing expectations

- Unit/widget tests on CI. Device E2E is **not** on main CI — see [`docs/testing/CI.md`](docs/testing/CI.md)
- Manual smoke: encrypted open, cash/PromptPay sale, void, draft, daily close, backup export/restore (see `docs/testing/RELEASE_0.9_SMOKE.md`). `RELEASE_1.0_SMOKE` is still **No-Go**
- CI: unit/widget coverage floor 60% (global) + sale-logic ≥80% via `tool/check_path_coverage.dart`; money-path + **blocking** emulator smoke via `.github/workflows/release-trust.yml` on tags / money-path PRs; signed prod AAB on `v*` **requires** `ANDROID_KEYSTORE_*` (`release-aab.yml` fail-closed — no optional / `require_signed_aab` input)
