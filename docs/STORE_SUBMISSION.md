# Store Submission Checklist

Last updated: **2026-07-17** | Version: **0.9.0+1**  
Trust package: `docs/plan/V090-TRUST/` · Smoke: `docs/testing/RELEASE_0.9_SMOKE.md`

---

## Pre-Flight (Code)

- [x] Version `0.9.0+1` in `pubspec.yaml`
- [x] Android / iOS display name **Promsell**
- [x] Permissions: CAMERA (product photos + barcode), storage for exports; INTERNET optional (remote product images only)
- [x] iOS privacy usage strings present (`Info.plist`)
- [x] Release signing fail-closed without `android/app/keystore.properties`
- [x] Keystore artifacts gitignored (`*.jks`, `keystore.properties`)
- [x] Money-path trust suite + device smoke cash/draft/daily close (2026-07-17)
- [x] Release Trust CI (fail-closed): `.github/workflows/release-trust.yml`
- [x] Signed **prod** AAB dry-run (throwaway keystore only — **not** for Play upload)

---

## Pre-Flight (Listing metadata)

| Asset | Path | Status |
|-------|------|--------|
| Play title EN/TH | `fastlane/metadata/android/{en-US,th}/title.txt` | ✅ TH ≤30 (`Promsell — POS ร้านค้าเล็ก`) |
| Play short EN/TH | `.../short_description.txt` (≤80 chars) | ✅ 2026-07-17 |
| Play full EN/TH | `.../full_description.txt` (restore honesty, AGPL, not tax invoice) | ✅ 2026-07-17 |
| Privacy policy | `docs/PRIVACY_POLICY.md` | ✅ |
| Privacy URL | `fastlane/metadata/android/*/privacy_url.txt` | ✅ **teeprakorn1** |
| iOS metadata stubs | `fastlane/metadata/ios/en-US/*` | ✅ |
| iOS marketing/support URLs | fixed to teeprakorn1 | ✅ |

---

## Screenshots & feature graphic (E5)

### Phone screenshots (1080×2400) — staged

**10 phone shots** under:

- `fastlane/metadata/android/en-US/images/phoneScreenshots/`
- `fastlane/metadata/android/th/images/phoneScreenshots/` (mirror)

| # | File | Content |
|---|------|---------|
| 01 | `01_home.png` | Home dashboard |
| 02 | `02_sale.png` | Sale catalog |
| 03 | `03_checkout.png` | Checkout |
| 04 | `04_receipt.png` | Cash receipt |
| 05 | `05_products.png` | Products |
| 06 | `06_history.png` | History |
| 07 | `07_report.png` | Report |
| 08 | `08_settings.png` | Settings |
| 09 | `09_draft.png` | Draft reopen |
| 10 | `10_daily_close.png` | Daily close |

Also kept under repo `screenshots/`.

### Feature graphic (Play)

| Item | Value |
|------|--------|
| Size | **1024 × 500** PNG |
| EN | `fastlane/metadata/android/en-US/images/featureGraphic.png` |
| TH | `fastlane/metadata/android/th/images/featureGraphic.png` |
| Regenerate | `dart run tool/generate_feature_graphic.dart` |
| Status | ✅ 2026-07-17 (brand banner; replace with designer art if desired) |

### Tablet / iOS

| Slot | Status |
|------|--------|
| Play 7" / 10" | ⬜ Empty (README placeholders). Capture if claiming tablet. |
| App Store sets | ⬜ Use phone PNGs as start on macOS. |

### Listing checklist before **Submit for review**

**In-repo (code/docs/metadata)**

- [x] ≥2 phone screenshots staged (we have **10**)
- [x] Feature graphic 1024×500 staged EN + TH
- [x] Descriptions: offline-first, AGPL source, **not tax invoice**, same-device restore honesty
- [x] Privacy policy wording: developer does **not** collect server-side PII; local device may store sales/customers
- [x] Privacy URL uses **teeprakorn1** (not teepakorn1)
- [x] Play title EN ≤30 · TH ≤30 (`Promsell — POS ร้านค้าเล็ก`)
- [ ] Optional: polish feature graphic / tablet shots

**Play Console (human — not done by git alone)**

- [ ] Data safety form in Play Console
- [ ] Production release keystore (not throwaway E2) + dual custody
- [ ] Upload production-signed AAB
- [ ] Content rating + Free pricing + Thailand
- [ ] Contact `mnlizard.official@gmail.com`

---

## Manual steps (operator)

### 1. Production keystore

```bash
cd android/app
keytool -genkey -v -keystore promsell-release-key.jks   -keyalg RSA -keysize 2048 -validity 10000   -alias promsell   -storepass YOUR_STRONG_PASSWORD   -keypass YOUR_STRONG_PASSWORD   -dname "CN=Promsell, O=Promsell, C=TH"
```

`keystore.properties` (gitignored):

```properties
storeFile=promsell-release-key.jks
storePassword=YOUR_STRONG_PASSWORD
keyAlias=promsell
keyPassword=YOUR_STRONG_PASSWORD
```

### 2. Build

```bash
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
# → build/app/outputs/bundle/prodRelease/app-prod-release.aab
```

### 3. Play Console

1. Create app **Promsell** · Business/Shopping
2. Data safety: no server collection; local POS data; camera for barcode/photos
3. Privacy: https://github.com/teeprakorn1/promsell-pos-ce/blob/main/docs/PRIVACY_POLICY.md
4. Upload AAB + assets from `fastlane/metadata/android/`
5. Free · Thailand · contact `mnlizard.official@gmail.com`

### 4. App Store Connect (optional)

Bundle `com.promsell.promsellPosCe` · same privacy URL · export compliance for SQLCipher/AES

---

## Data safety notes

| Topic | Guidance |
|-------|----------|
| Developer servers collect data? | **No** |
| Local data | Sales, stock, optional customers, PromptPay ID |
| Encryption | SQLCipher + AES-GCM backup (default **on** for new installs) |
| User-initiated share | Backup/share sheet / crash export — not developer collection |
| Analytics | None |
| License | AGPL-3.0 |
| Receipts | **Not** tax invoices |

---

## Quick reference

| Item | Value |
|------|--------|
| Version | 0.9.0+1 |
| Privacy URL | https://github.com/teeprakorn1/promsell-pos-ce/blob/main/docs/PRIVACY_POLICY.md |
| Source | https://github.com/teeprakorn1/promsell-pos-ce |
| Android ID | `com.promsell.promsell_pos_ce` |
| Phone screenshots | `fastlane/metadata/android/en-US/images/phoneScreenshots/` |
| Feature graphic | `fastlane/metadata/android/en-US/images/featureGraphic.png` |

---

## E4 / E5 (trust package)

| ID | Status |
|----|--------|
| **E4** CI release + secrets-optional AAB | ✅ `release-aab.yml` (2026-07-17) |
| **E5** Screenshots + graphic + privacy + listing honesty | ✅ **Staged 2026-07-17** — operator still submits in consoles |
