# Supply-chain register

**Scope:** direct Flutter/Dart dependencies and GitHub Actions used to build, test, and release PromSell POS CE.

## Review policy

- `pubspec.lock` is committed and is the resolution source for reproducible CI installs.
- CI runs `dart pub outdated --json`, `tool/check_outdated.dart`, and `dart pub outdated --no-dev-dependencies` on every normal test job.
- A direct dependency that is one or more major versions behind fails the audit unless it is listed in the checked-in holdback register below with a migration reason.
- Dependency upgrades require `flutter analyze`, the host trust suite, and the performance suite. Encryption/database upgrades additionally require migration fixtures.
- GitHub Actions are pinned to full commit SHAs and reviewed with least-privilege workflow permissions; release signing secrets are only consumed by the release workflow and missing secrets fail closed.
- This register does not claim vulnerability-free status. Review `pub outdated`, advisories, and licenses before each release cut.

## Intentional major-version holdbacks

| Package | Current line | Holdback reason | Revisit trigger |
|---|---:|---|---|
| `sqlite3` | 2.x | 3.x removes `open.overrideFor`; migration requires Drift/build-hook coordination with SQLCipher. | SQLCipher/Drift migration plan is tested. |
| `fl_chart` | 0.70.x | 1.x chart API break while report charts are stable. | Report chart refactor. |
| `flutter_secure_storage` | 10.x | 11.x initialization API changes affect onboarding and key storage. | Secure-storage migration fixture and device smoke. |
| `permission_handler` | 12.x | 13.x permission-model changes require a runtime-permission audit. | Android/iOS permission smoke. |
| `shimmer` | 3.x | 4.x loading widget API changes require catalog migration and device smoke. | Catalog loading migration. |

The canonical checked gate is `tool/check_outdated.dart`; keep this table synchronized with its `_intentionallyHeldBack` map.

## Sensitive build inputs

- Production signing uses `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD` in `.github/workflows/release-aab.yml`.
- No signing material, database keys, PromptPay credentials, or customer data belongs in the repository or test fixtures.
- `sqlcipher_flutter_libs` and `flutter_secure_storage` are security-sensitive dependencies; changes require a security review and backup/restore continuity tests.

## Current limitations

- GitHub Action references are pinned to full commit SHAs; the remaining supply-chain limitation is that this repository does not run a separate OSV/Snyk scan.
- The scheduled stress reporter is the only workflow job with `issues: write`; PR-triggered stress execution is restricted to `contents: read`.
- Device E2E requires an Android/iOS runner and is not reproducible on this Windows host without a device.
