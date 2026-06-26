# Usage guide — Promsell POS CE

> Complete guide for installing, building, and using Promsell POS Community Edition.

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
│  flutter run (debug) · flutter run --release (perf test)         │
│  Flavors: dev (main_dev.dart) · prod (main_prod.dart)            │
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
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

---

## Running the app

### Debug mode (with hot reload)

```bash
flutter run
```

### With flavor

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor prod -t lib/main_prod.dart
```

### Release mode (performance testing)

```bash
flutter run --release
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
flutter build ios --release
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
| [`docs/usage/features.md`](usage/features.md) | Features walkthrough (Sale, Products, History, Report, Settings tabs) + all settings pages with detailed tables |
| [`docs/usage/development.md`](usage/development.md) | Localization (i18n), Database (Drift), Architecture overview, Testing (1269 tests), Troubleshooting |

---

## Need help?

- **GitHub Issues** — https://github.com/teeprakorn1/promsell-pos-ce/issues
- **Discussions** — https://github.com/teeprakorn1/promsell-pos-ce/discussions

---

<sub>Promsell POS Community Edition · © 2026 MN Lizard Team · AGPL-3.0</sub>