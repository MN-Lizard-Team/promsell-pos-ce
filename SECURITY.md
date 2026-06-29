# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.8.x   | Active |
| 0.7.x   | Security fixes only |
| 0.6.x   | No longer supported |
| < 0.6   | No longer supported |

## Reporting a vulnerability

**Do NOT file a public GitHub issue for security vulnerabilities.**

### How to report

1. Go to the [Security tab](https://github.com/teeprakorn1/promsell-pos-ce/security)
2. Click "Report a vulnerability"
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Affected versions
   - Potential impact
   - Suggested fix (if any)

### Response timeline

| Stage | Target time |
|-------|-------------|
| Acknowledgment | 48 hours |
| Initial assessment | 5 business days |
| Fix development | 14 business days (critical), 30 days (high) |
| Advisory published | After fix is released |

## What we consider security issues

- **SQL injection** via unsanitized Drift query inputs
- **Path traversal** in file read/write operations (PDF, image)
- **Insecure local storage** of sensitive shop or payment data
- **Void/refund bypass** — circumventing atomic void flow to manipulate stock or revenue
- **Inventory log tampering** — modifying audit trail records outside application flow
- **Dependency vulnerabilities** in third-party packages

## What we do NOT consider security issues

- UI bugs or UX issues
- Missing features
- Configuration errors by the user
- Device-level security (screen lock, etc.) — outside app scope

## Security architecture

Promsell is an **offline-first local app** with no network access by default:

1. **Local-only storage** — all data stays on device via SQLite
2. **No server communication** — no API keys, no remote calls in core flow
3. **App settings table** (Drift-backed) — stores non-sensitive settings (locale, theme, shop name, VAT mode, stock policy); also stores receipt sequence counter and device prefix
4. **Atomic transactions** — sale creation, void, and stock adjustments run inside Drift DB transactions to prevent partial writes
5. **Inventory audit trail** — all stock changes (SALE, VOID_REVERSAL, ADJUSTMENT_IN/OUT) are logged immutably in `inventory_logs` table
6. **Backup encryption v2** (v0.7.5+) — AES-256-GCM with PIN-derived PBKDF2-HMAC-SHA256 at 100,000 iterations (RFC 2898). v1 format (weak ~3 HMAC rounds) still decrypts for backward compatibility but new backups use v2. Toggle in Settings → Backup
7. **Image format validation** (v0.7.5+) — `ProductImageService._isValidImage()` rejects non-image files (`.jpg`, `.jpeg`, `.png`, `.webp`, `.gif`, `.bmp`, `.heic` only); prevents malicious file upload via picker
8. **Image cache eviction** (v0.7.5+) — `ImageCacheService` enforces 50MB LRU limit on `/images/` directory; prevents disk space exhaustion from uncompressed product photos
9. **PDF generation** — local only, no upload
10. **Orphaned image cleanup** (v0.8.0+) — `ProductFormPage` tracks temp image paths and deletes orphaned files on dispose/discard; `ClearOrphanedImages` usecase removes unused images from `/images/` directory. Prevents disk space exhaustion from abandoned temp files
11. **Dependency hygiene** — keep `flutter pub upgrade` current; CI runs `tool/check_outdated.dart` to flag direct dependencies behind by ≥ 1 major version; Dependabot opens PRs for security + version updates (see `.github/dependabot.yml`)
12. **Barcode case normalization** (v0.8.1+) — barcodes normalized to uppercase on save and lookup; prevents case-mismatch bypass of duplicate detection and lookup
13. **Barcode manual entry validation** (v0.8.1+) — inline alphanumeric validation before submission; prevents unhandled `ArgumentError` from reaching downstream use cases
14. **Crash log PII sanitization** (v0.8.3+) — `CrashLogService` sanitizes phone numbers, PromptPay IDs, and citizen IDs in crash logs before persistence; prevents accidental PII leakage in exported crash reports
15. **Barcode deduplication migration** (v0.8.3+) — schema v17 automatically clears duplicate barcodes before unique index creation; prevents `StateError` crash on barcode scan when pre-migration duplicates exist
16. **Dev/prod flavor separation** (v0.8.3+) — separate entry points (`main_dev.dart`, `main_prod.dart`) prevent development configurations from leaking into production builds
17. **Barcode image generation isolation** (v0.8.6+) — `BarcodeImageService` uses off-screen `RenderRepaintBoundary` for barcode image generation; no external rendering dependencies, no network calls, images saved locally to `/barcodes/` directory only
18. **Ean13Generator instance isolation** (v0.8.6+) — refactored from static mutable counter to `@injectable` per-instance counter; eliminates cross-test counter contamination and ensures counter state isolation between concurrent operations
19. **Cubit disposal guard** (v0.8.8+) — `ProductFormCubit._loadDraftFromStorage` checks `isClosed` before `emit` after async storage read; prevents dirty widget build scope errors and potential state leaks when navigating away during draft load

## Security changelog

For the full fix history, see [CHANGELOG.md](CHANGELOG.md) (current versions 0.8.x). Older versions archived in [`docs/changelog/`](docs/changelog/).
