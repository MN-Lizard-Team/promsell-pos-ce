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

## Security architecture (v0.9.4)

Promsell is an **offline-first local app** with no required network for core POS:

1. **Local-only storage** — sales, catalog, drafts via Drift/SQLite
2. **SQLCipher at rest (Phase 2a)** — database file encrypted; key in platform secure storage (Keystore / Keychain) on mobile; debug desktop may use a fixed dev key (never for production builds)
3. **Key loss = data loss without an exported kit** — `RecoveryKitService` (v0.9.3) is code complete but **device validation pending — not released**; on-device cross-device restore (D2) is not yet tested. Uninstall, factory reset, or secure-storage wipe without an export backup makes the DB unreadable. **V092-B.7 (Keystore corruption) is now fixed (v0.9.4):** all three `FlutterSecureStorage` instances (DB key, store-PIN lock, recovery kit) use `AndroidOptions(resetOnError: false)`, so a corrupted Android Keystore can no longer silently delete and regenerate the SQLCipher key. Fail-closed read guards in `AppLockService` keep every PIN gate locked (never crash or open) when secure storage is unreadable, and a cold-start `DbRecoveryGate` screen directs the merchant to import their recovery kit instead of dropping into a broken shell. Namespace separation was intentionally **not** applied — moving existing keys to a new `storageNamespace` would orphan every current install's key. **Mitigation today:** keep backup encryption on, export encrypted backups regularly, store the `.enc` file off-device.
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

| Capability | 0.9.0 | 0.9.2 | 0.9.4 |
|------------|--------|------|------|
| Export encrypted/plain DB | Yes (encrypt default on) | Yes | Yes |
| Share via OS sheet | Yes | Yes | Yes |
| In-app restore UI | **Yes (same-device only)** | Yes (same-device only) | Yes (same-device only) |
| Cross-device restore / key export | **No** (Phase 2b) | **No** (Phase 2b) | **No** (Phase 2b — `RecoveryKitService` code complete v0.9.3, device validation pending) |
| SQLCipher key backup | **No** | **No** | **No** (recovery kit code complete, not released) |
| Survive app uninstall without export | **No** | **No** | **No** |
| Survive Keystore corruption (Android) | **No** — `resetOnError: true` silently regenerates key → permanent data loss | **No** (V092-B.7 deferred — known breaking limitation, see CHANGELOG) | **Fixed (v0.9.4)** — `resetOnError: false` + fail-closed lock guards + cold-start recovery gate; DB restorable from an exported recovery kit |

**Recommended practice:** keep backup encryption on, use a strong PIN (≥ 6), export regularly, store the file off-device. Same-device restore still needs this device’s SQLCipher key. After a Keystore wipe the only recovery is restoring the `.enc` backup on a different device that still has its key.

## Security changelog (recent)

- **0.9.4 (2026-09-02, V092-B.7 resolution + hardening pass)** — Keystore-corruption data loss fixed: `AndroidOptions(resetOnError: false)` on all three `FlutterSecureStorage` instances (`DbKeyStore`, `AppLockService`, `RecoveryKitService`) so a corrupted Android Keystore can no longer silently wipe the SQLCipher key; `AppLockService` read paths (`isEnabled`, PIN material, lockout, policy) now fail closed with logged warnings instead of throwing raw platform exceptions; new cold-start `DbRecoveryGate` (shown when `SettingsCubit.load` fails with `DbKeyUnavailable`) guides the merchant to import a recovery kit and retry, instead of dropping into a shell whose every query fails. Store-PIN hash comparison is now constant-time (XOR-accumulate) in `PinHasher.verify`, closing a timing side-channel. CI gains secret scanning (gitleaks) and dependency CVE scanning (osv-scanner), both fail-closed. Namespace separation was deliberately skipped — it would orphan existing installs' keys.
- **0.9.4 (2026-09-02)** — backup operation hardening & AppLock concurrency: backup PIN dialog wraps with `SecureScreen.setSecure(true)` (keeps PIN out of screenshots/recent-app previews); `BackupSettingsPage` is now a `StatefulWidget` with a `_busy` flag that rejects duplicate backup/restore callbacks and disables action buttons while in flight; concurrent `AppLockService.verifyPin()` calls are chained through a single `_verificationQueue` `Future` so lockout-counter reads/writes cannot race when multiple PIN verifications are submitted simultaneously (e.g. user double-tapping unlock). Settings UI gains shared `SettingsStateView` (loading/error/retry) across all settings pages. Cross-feature domain coupling reduced (`Sale`/`SaleItem`/`SalePayment`/`SelectedProductOption`/`SalesPeriodTotals` moved to `lib/shared/domain/entities/`). `product_audits` table repair on legacy v32 DBs via `ensureProductAuditsTable()` in `beforeOpen` + `onUpgrade`. **UI redesign (no security impact):** Settings root restyled to the POS-native flat paper-card language (teal app bar + search strip, white hero card with thin border, compact action cards with thin borders, plain section headers, dedicated `SettingsSearchPage`), onboarding visual language alignment (gradient hero, pill progress, accent-stripe sections, Tabler Icons Plus migration), and toast overflow fix (`Flexible` + `ConstrainedBox(maxWidth: 320)` + `maxLines: 2`). No security-sensitive flows (PIN entry, backup encryption, void/stock gates) were modified by the UI redesign.
- **0.9.3 (2026-08-17, not tagged)** — P1 database lifecycle & recovery: migration safety service (free-space preflight + status tracking + interrupted-migration detection), WAL checkpoint policy (PASSIVE/TRUNCATE modes, 10 MB/50 MB thresholds), database health report (DB/WAL/SHM sizes, integrity check, guardrail detection), backup export metadata (`BackupMetadata` with SHA-256 checksum, size preflight, progress callback), Phase 2b recovery kit (`RecoveryKitService` — AES-256-GCM + PBKDF2-HMAC-SHA256 100K iterations, `.promkey` format; **code complete, device validation pending — not released**), migration v31→v32 benchmark, and large encrypted fixture restore tests. God-file refactor (`app_database_migrations.dart`, `PinHasher`, `LockoutPolicy`, `DraftSaveCoordinator`, `SavedBillsCheckoutHelper`) with no contract changes. CI/DI fixes: Android smoke `-t` flag misuse (failing since v0.9.0) and `BackupRestoreService` injectable `@ignoreParam` crash on startup.
- **0.9.2 (V092-B, 2026-08-17)** — staff control & sensitive-action gating: B.1 product PIN gate (UpdateProduct / AddProduct non-default / quick-edit / form submit); B.2 cold-start + resume lock via `AppLockLifecycleObserver`; B.3 CloseDay + report export + discount/oversell/day-lock/backup-encryption settings now sensitive; B.4 pre-restore DB cleanup on startup; B.5 FLAG_SECURE on PIN + PromptPay settings pages; B.6 trivial-PIN blocklist. **Known breaking limitation (V092-B.7 deferred):** `resetOnError: true` default means Keystore corruption can silently wipe the SQLCipher key → permanent data loss; fix deferred to Phase 2b with key-export recovery. **Phase M (C1–C3):** schema **v32** adds nullable INTEGER `*_satang` dual-write columns to all 10 money tables (32 columns) and backfills from REAL baht. `NullableMoneySatangConverter` is active; writers dual-write, readers are satang-first with REAL fallback, and report/tender aggregation uses integer satang before display conversion. No security impact; legacy REAL columns remain temporarily for rollback compatibility, and the encrypted pre-M backup-restore fixture is still pending.
- **0.9.1** — schema **v31** (`barcode_lower` / `sku_lower` uniques + v31 dedupe repair). PIN still default-on for new installs. Stock PIN remains AdjustStock + CSV only.
- **0.9.0** — SQLCipher production path; backup encrypt default on; **same-device in-app restore**; store PIN min 6 + PBKDF2 + **persisted** lockout; gates void/backup/AdjustStock/CSV/PromptPay; crash sanitize on write; image delete sandbox; schema **v28** at that cut; checkout failure unlocks cart
- **0.8.x** — See prior SECURITY entries and CHANGELOG (barcode uniqueness, orphaned images, crash export sanitize, restaurant/CRM isolation)

## Security testing expectations

- Unit/widget tests on CI. Device E2E is **not** on main CI — see [`docs/testing/CI.md`](docs/testing/CI.md)
- Manual smoke: encrypted open, cash/PromptPay sale, void, draft, daily close, backup export/restore (see `docs/testing/RELEASE_0.9_SMOKE.md`). `RELEASE_1.0_SMOKE` is still **No-Go**
- CI: unit/widget coverage floor 60% (global) + sale-logic ≥92% via `tool/check_path_coverage.dart`; money-path + **blocking** emulator smoke via `.github/workflows/release-trust.yml` on tags / money-path PRs; signed prod AAB on `v*` **requires** `ANDROID_KEYSTORE_*` (`release-aab.yml` fail-closed — no optional / `require_signed_aab` input)
