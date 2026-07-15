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
- Missing features (including deferred in-app backup restore)
- Configuration errors by the user
- Device-level security (screen lock, full-disk encryption) — outside app scope
- Data loss after **user-initiated** uninstall or keystore wipe without a backup

## Security architecture (v0.9)

Promsell is an **offline-first local app** with no required network for core POS:

1. **Local-only storage** — sales, catalog, drafts via Drift/SQLite
2. **SQLCipher at rest (Phase 2a)** — database file encrypted; key in platform secure storage (Keystore / Keychain) on mobile; debug desktop may use a fixed dev key (never for production builds)
3. **Key loss = data loss** — there is **no** key recovery or multi-device key export in 0.9.0. Uninstall, factory reset, or secure-storage wipe without an export backup makes the DB unreadable
4. **Atomic transactions** — sale create, void, stock adjust inside DB transactions
5. **Inventory audit trail** — stock changes logged in `inventory_logs`
6. **Backup export** — WAL checkpoint → DB copy → optional AES-256-GCM (PBKDF2 PIN, min length 6). Default encryption **on** when the setting key is missing (v0.9)
7. **Backup restore** — **not in-app in 0.9.0**. Merchants export/share a file; restore is manual (replace DB after decrypt offline). In-app restore targeted for a later 0.9.x
8. **Crash logs** — PII patterns sanitized **on write**
9. **Image sandbox** — product image delete restricted under app `images/` directory
10. **No server by default** — no remote API keys in core flow
11. **Dependency hygiene** — CI outdated check + Dependabot

## Backup & recovery (honest limits)

| Capability | 0.9.0 |
|------------|--------|
| Export encrypted/plain DB | Yes |
| Share via OS sheet | Yes |
| In-app restore UI | **Yes (same-device)** |
| SQLCipher key backup / Phase 2b | **No** |
| Survive app uninstall without export | **No** |

**Recommended practice:** enable backup encryption, use a strong PIN (≥ 6), export regularly, store the file off-device.

## Security changelog (recent)

- **0.9.0** — SQLCipher production path; backup encrypt default on; PIN min 6; crash sanitize on write; image delete sandbox; schema v28
- **0.8.x** — See prior SECURITY entries and CHANGELOG (barcode uniqueness, orphaned images, crash export sanitize, restaurant/CRM isolation)

## Security testing expectations

- Unit/widget tests on CI; integration suite may be non-blocking
- Manual smoke: encrypted open, sale, void, backup export (see `docs/testing/RELEASE_0.9_SMOKE.md`)
