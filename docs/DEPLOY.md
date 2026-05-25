# Deployment guide — Promsell POS CE

> How to build, sign, and distribute Promsell for Android and iOS.

---

## Android

### Debug build (testing)

```bash
flutter run --debug
```

### Release APK (sideload)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

Transfer to device via USB or share link for manual installation.

### Split APKs (smaller per-device downloads)

```bash
flutter build apk --release --split-per-abi
```

Outputs:
- `app-arm64-v8a-release.apk` — modern Android (recommended)
- `app-armeabi-v7a-release.apk` — older 32-bit devices
- `app-x86_64-release.apk` — emulators

### App Bundle (Google Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Upload to Google Play Console under your app listing.

### Signing

1. Generate a keystore (one-time):

```bash
keytool -genkey -v -keystore promsell-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias promsell
```

2. Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=promsell
storeFile=../../promsell-release.jks
```

3. Reference in `android/app/build.gradle` — see [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app).

> **Never commit `key.properties` or `.jks` files to git.** Both are in `.gitignore`.

---

## iOS (macOS only)

### Prerequisites

- Xcode 15+
- Apple Developer account
- Provisioning profile and signing certificate configured

### Build

```bash
flutter build ios --release
```

Then open Xcode:

```bash
open ios/Runner.xcworkspace
```

Archive via **Product → Archive**, then distribute via TestFlight or App Store Connect.

---

## Version management

Version format: `major.minor.patch+buildNumber` in `pubspec.yaml`.

```yaml
version: 0.1.0+1
#        ^^^^^  semantic version (shown to users)
#              ^ build number (auto-increment for stores)
```

Increment before each release:

```yaml
# Patch release (bug fixes)
version: 0.1.1+2

# Minor release (new features)
version: 0.2.0+3
```

Update `CHANGELOG.md` with a new entry for every public release.

---

## Checklist before release

- [ ] `flutter analyze lib test` — zero errors
- [ ] `flutter test` — all tests pass
- [ ] `flutter gen-l10n` — localization up to date
- [ ] `dart run build_runner build` — generated code up to date
- [ ] Version bumped in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated with release notes
- [ ] Signed with release keystore (Android)
- [ ] Tested on physical device
- [ ] Screenshots updated (if UI changed)

---

## Firebase App Distribution (optional)

For internal beta distribution without Play Store:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Distribute APK
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <YOUR_FIREBASE_APP_ID> \
  --groups "internal-testers"
```

---

<sub>Promsell POS CE · v0.1.0 · MN Lizard Team</sub>
