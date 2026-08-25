# Usage guide — Promsell POS CE

> Complete guide for installing, building, and using Promsell POS Community Edition.
>
> Release notes: **v0.9.4** · package version: **0.9.4+2** · database schema: **v32**

---

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| Flutter SDK | 3.11+ |
| Dart SDK | 3.11+ (bundled with Flutter) |
| Android Studio | Hedgehog (2023.1.1)+ |
| Xcode (macOS only) | 15+ |
| Git | 2.30+ |

Verify your environment:

```bash
flutter doctor -v
```

All sections under "Flutter", "Android toolchain", and "Connected device" should show green checkmarks.

### Dev environment setup

```
┌──────────────────────────────────────────────────────────────────┐
│  Prerequisites                                                   │
│  Flutter 3.11+ · Dart 3.11+ · Android Studio / Xcode · Git       │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  1. Clone & Install                                              │
│  git clone → cd → flutter pub get                                │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Generate Code                                                │
│  build_runner build → flutter gen-l10n                           │
│  Produces: app_database.g.dart, *.config.dart, app_localizations │
└───────────────────────────┬──────────────────────────────────────┘
                            ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Run                                                          │
│  flutter run --flavor dev -t lib/main_dev.dart                   │
│  Release: --release --flavor prod -t lib/main_prod.dart          │
└──────────────────────────────────────────────────────────────────┘
```

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/teeprakorn1/promsell-pos-ce.git
cd promsell-pos-ce
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate code (Drift + Injectable + l10n)

Generated files are not committed to git. Run after every `flutter pub get`:

```bash
dart run build_runner build
flutter gen-l10n
```

---

## Running the app

Bare `flutter run` is **not** supported. Flavors `dev` / `prod` are required.

### Debug mode (with hot reload)

```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### Production flavor (still debug runtime)

```bash
flutter run --flavor prod -t lib/main_prod.dart
```

### Release mode (performance testing)

```bash
flutter run --release --flavor prod -t lib/main_prod.dart
```

---

## Building for production

### Android APK

```bash
flutter build apk --release --flavor prod -t lib/main_prod.dart
```

Output: `build/app/outputs/flutter-apk/app-prod-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

### iOS

```bash
flutter build ios --release --flavor prod -t lib/main_prod.dart
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and submit.

> **Note:** iOS builds require a macOS machine with Xcode.

### Build pipeline

```
┌──────────────┐     ┌────────────────┐      ┌──────────────────────┐
│  Source Code │ ──▶ │  build_runner  │ ──▶ │  Generated Code      │
│  (lib/)      │     │  (Drift + DI)  │      │  *.g.dart            │
│              │     │                │      │  *.config.dart       │
└──────────────┘     └────────────────┘      └──────────┬───────────┘
                                                        │
                              ┌─────────────────────────┘
                              ▼
                     ┌──────────────────┐     ┌──────────────────┐
                     │ flutter gen-l10n │     │ Flutter Compiler │
                     │  (ARB → Dart)    │ ──▶ │  (AOT / JIT)     │
                     └──────────────────┘     └────────┬─────────┘
                                                       │
                          ┌────────────────────────────┘
                          ▼
               ┌─────────────────────┐
               │  Build Output       │
               │  APK / AAB / IPA    │
               └─────────────────────┘
```

---

## Reference documents

| Document | Content |
|----------|---------|
| [`docs/usage/features.md`](usage/features.md) | Features walkthrough (tabs + settings) — includes **Store PIN**, same-device backup restore |
| [`docs/usage/development.md`](usage/development.md) | Localization, Drift/SQLCipher, architecture, testing, troubleshooting |
| [`docs/testing/RELEASE_0.9.3_SMOKE.md`](testing/RELEASE_0.9.3_SMOKE.md) | v0.9.3 release smoke checklist |
| [`SECURITY.md`](../SECURITY.md) | Encryption, PIN gates, backup honesty |
| [`docs/PRIVACY_POLICY.md`](PRIVACY_POLICY.md) | Privacy (local data vs developer servers) |
| [`CHANGELOG.md`](../CHANGELOG.md) | v0.9.4 notes + archive links |

---


## Backup and recovery (merchant runbook)

Promsell stores all POS data in an encrypted SQLite file on the device (SQLCipher). Treat backups as mandatory.

1. **Settings → Backup** — keep **Encrypt backups** on (default). Choose a PIN of at least **6** characters and store it offline.
2. **Backup Now** regularly (or enable the reminder). Share the file to cloud/USB you control — not only on the same phone.
3. **Same-device restore** — use **Restore** on the same device to re-apply a previous `.enc` or SQLCipher `.db` export. Restart the app after restore.
4. **Not supported in v0.9.4** — restoring onto a different phone, or after uninstall / factory reset / keystore wipe (the SQLCipher key is gone).
5. **Key loss = data loss** without an off-device export. Recovery-kit export/import (`RecoveryKitService`) is **code complete but device validation pending** — unit tests cover wrap/unwrap logic only; on-device cross-device restore (D2) is not yet tested. Not released.

See also [SECURITY.md](../SECURITY.md) and [Privacy Policy](PRIVACY_POLICY.md).

## Need help?

- **GitHub Issues** — https://github.com/teeprakorn1/promsell-pos-ce/issues
- **Discussions** — https://github.com/teeprakorn1/promsell-pos-ce/discussions

---

<sub>Promsell POS Community Edition · © 2026 MN Lizard Team · AGPL-3.0</sub>