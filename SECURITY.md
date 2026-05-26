# Security Policy

## Supported versions

| Version | Supported |
|---------|-----------|
| 0.2.x   | Active |
| 0.1.x   | Security fixes only |

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
- **Dependency vulnerabilities** in third-party packages

## What we do NOT consider security issues

- UI bugs or UX issues
- Missing features
- Configuration errors by the user
- Device-level security (screen lock, etc.) — outside app scope

## Security architecture

Promsell is an **offline-first local app** with no network access by default. The v0.2.0 UX/UI refresh does not change the local-only security model:

1. **Local-only storage** — all data stays on device via SQLite
2. **No server communication** — no API keys, no remote calls in core flow
3. **SharedPreferences** — only stores non-sensitive settings (locale, theme, shop name)
4. **PDF generation** — local only, no upload
5. **Dependency hygiene** — keep `flutter pub upgrade` current; run `flutter pub audit`

## Security changelog

For the full fix history, see [CHANGELOG.md](CHANGELOG.md).
