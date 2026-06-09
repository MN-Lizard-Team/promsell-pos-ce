# Store Submission Checklist

Last updated: 2026-06-09 | Version: 0.7.5+1

---

## Pre-Flight (Code — DONE)

- [x] Version bumped to `0.7.5+1` in `pubspec.yaml`
- [x] Android app label = "Promsell"
- [x] iOS display name = "Promsell"
- [x] iOS bundle name = "Promsell"
- [x] Android permissions (INTERNET, CAMERA, storage)
- [x] iOS privacy strings + ATS + encryption compliance
- [x] Release signing config with keystore fallback
- [x] `.gitignore` excludes keystore files
- [x] `flutter analyze` → 0 issues
- [x] `flutter test` → 343 passing

---

## Pre-Flight (Metadata — DONE)

- [x] Play Store EN metadata (title, short, full description)
- [x] Play Store TH metadata
- [x] App Store metadata (subtitle, keywords, promo text, URLs)
- [x] Privacy policy (`docs/PRIVACY_POLICY.md`)

---

## Manual Steps Required (User)

### 1. Create Android Release Keystore

```bash
cd android/app
keytool -genkey -v -keystore promsell-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias promsell \
  -storepass YOUR_STRONG_PASSWORD \
  -keypass YOUR_STRONG_PASSWORD \
  -dname "CN=Promsell, O=Promsell, C=TH"
```

Then create `android/app/keystore.properties`:

```properties
storeFile=promsell-release-key.jks
storePassword=YOUR_STRONG_PASSWORD
keyAlias=promsell
keyPassword=YOUR_STRONG_PASSWORD
```

> This file is already `.gitignore`d. Never commit it.

### 2. Take Screenshots

| Store | Minimum | Recommended |
|-------|---------|-------------|
| Play Store | 2 phone | 8 phone + 4 tablet (7" + 10") |
| App Store | 3 iPhone | 10 iPhone + 5 iPad |

Use emulator or physical device. Capture key screens:
- Sale / Cart (single-row 3-zone layout, inline discount chips)
- Product list
- Receipt / QR
- Inventory
- Settings (3-level hierarchy with search)
- Reports

Save to:
- `fastlane/metadata/android/en-US/images/phoneScreenshots/`
- `fastlane/metadata/android/en-US/images/sevenInchScreenshots/`
- `fastlane/metadata/android/en-US/images/tenInchScreenshots/`
- `fastlane/metadata/ios/screenshots/`

### 3. Design Feature Graphic (Play Store)

- Size: **1024 x 500 px**
- Content: App name + tagline + visual (receipt + phone mockup)
- Tool: Canva, Figma, Photoshop
- Save to: `fastlane/metadata/android/en-US/images/featureGraphic.png`

### 4. Build & Verify

```bash
# Android AAB (required for Play Store)
flutter build appbundle
# Output: build/app/outputs/bundle/release/app-release.aab

# iOS IPA (required for App Store)
flutter build ipa
# Output: build/ios/ipa/Promsell.ipa
```

### 5. Play Console Setup

1. Go to [play.google.com/console](https://play.google.com/console)
2. Pay $25 one-time developer fee (if new account)
3. Create app → "Promsell"
4. App category: **Shopping** or **Business**
5. Content rating: Fill questionnaire → likely **Everyone**
6. Data safety form:
   - Does your app collect data? → **No**
   - Provide privacy policy URL → `https://github.com/teepakorn1/promsell-pos-ce/blob/main/docs/PRIVACY_POLICY.md`
7. Upload AAB + screenshots + feature graphic + descriptions
8. Set pricing: **Free**
9. Set countries: **Thailand** (+ others if desired)
10. Contact email: `teepakorn.official@gmail.com`

### 6. App Store Connect Setup

1. Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Requires Apple Developer Program ($99/year)
3. Create app:
   - Name: **Promsell**
   - Bundle ID: `com.promsell.promsellPosCe`
   - SKU: `promsell-pos-ce`
4. Primary category: **Shopping** or **Business**
5. Secondary: **Productivity**
6. Age rating: **4+**
7. Upload IPA via Transporter or Xcode
8. Add screenshots for iPhone + iPad
9. Privacy policy URL: same as above
10. Contact info: `teepakorn.official@gmail.com`

---

## Post-Launch

- [ ] Monitor crash reports (Play Console / Xcode Organizer)
- [ ] Respond to user reviews
- [ ] Update screenshots after major UI changes
- [ ] Keep privacy policy updated if data practices change

---

## Quick Reference

| Item | Value |
|------|-------|
| App name | Promsell |
| Version | 0.7.5+1 |
| Contact | teepakorn.official@gmail.com |
| Privacy URL | https://github.com/teepakorn1/promsell-pos-ce/blob/main/docs/PRIVACY_POLICY.md |
| Bundle ID (Android) | com.promsell.promsell_pos_ce |
| Bundle ID (iOS) | com.promsell.promsellPosCe |
