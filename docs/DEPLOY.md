# Deployment guide — Promsell POS CE

> How to build, sign, and distribute Promsell for Android and iOS.
>
> **Related docs:** [`ARCHITECTURE.md`](ARCHITECTURE.md) (system design) · [`DATABASE.md`](DATABASE.md) (schema) · [`USAGE.md`](USAGE.md) (setup & usage)

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
version: 0.4.2+1
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
- [ ] `flutter test` — all 187+ tests pass
- [ ] Integration tests pass (checkout flow + sale integrity)
- [ ] `flutter gen-l10n` — localization up to date
- [ ] `dart run build_runner build` — generated code up to date
- [ ] Version bumped in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated with release notes
- [ ] Signed with release keystore (Android)
- [ ] Tested on physical device
- [ ] Sale flow smoke-tested on compact phone layout
- [ ] Sale flow smoke-tested on tablet or expanded-width layout
- [ ] Product form and payment sheet checked for keyboard/overflow behavior
- [ ] Light, dark, and system theme modes checked
- [ ] Thai and English locale checked after `flutter gen-l10n`
- [ ] Screenshots updated (if UI changed)

### UI release smoke test

Before distributing a build with UI changes:

1. Add a product.
2. Search and filter products in the Sale tab.
3. Add items to cart and adjust quantity.
4. Complete one cash sale using quick cash chips.
5. Open History, expand the saved sale — verify receipt number is shown; if VAT mode is INCLUSIVE or EXCLUSIVE, verify Subtotal + VAT rows appear.
6. Tap **Void Sale** on a sale, enter a reason, confirm — verify VOIDED badge appears and stock is restored.
7. Open History again — voided sale shows strikethrough amount and red badge.
8. Open Report and verify net revenue excludes voided sales; voided summary card appears.
9. Tap **Print Receipt** or **Share Receipt** on any sale.
10. Open Settings, switch theme/locale, and save shop info.

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

<sub>Promsell POS CE · MN Lizard Team</sub>
