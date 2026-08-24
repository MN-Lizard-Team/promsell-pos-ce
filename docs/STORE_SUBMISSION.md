# Store Submission Checklist

Last updated: **2026-08-17** | Release: **v0.9.3** | `pubspec`: **0.9.3**<br>
Trust package: `docs/plan/COMPLETE/V090-TRUST/` · Smoke v0.9.3: `docs/testing/RELEASE_0.9.3_SMOKE.md` · Smoke 1.0 plan: `docs/testing/RELEASE_1.0_SMOKE.md`<br>
Post-0.9 management: `docs/plan/COMPLETE/POST-090-MANAGE/` · Play WS: `docs/plan/COMPLETE/POST-090-MANAGE/WS-A-PLAY-PRODUCTION.md`

---

## A0 — Release-day freeze (Must vs Should)

**Frozen 2026-07-20** for POST-090 Wave 0. Operator signs production only when **Must** is complete.

### Must (block production Play)

| ID | Item | Owner | In-repo? | Status |
|----|------|-------|----------|--------|
| A1 | Production keystore + dual custody (not throwaway JKS) | Operator | Runbook only | ⬜ |
| A2 | Play Data safety form ตรง `PRIVACY_POLICY` (local PII, no dev collection) | Operator | Guidance | ⬜ |
| A2b | Content rating + Free + Thailand (+ contact email) | Operator | — | ⬜ |
| A3 | Signed **prod** AAB with real keystore (CI **requires** secrets on `v*` tags) | Operator + DevOps | `release-aab.yml` fail-closed on tags (2026-07-20) | ⬜ secrets still operator |
| A4 | Upload AAB to Play (internal/closed first) | Operator | — | ⬜ |
| A5 | Post-submit smoke on **prod** build per `RELEASE_1.0_SMOKE` Must | QA/Operator | Smoke template | ⬜ |
| B-trust | `release-trust.yml` green on release tag | Maintainer | Yes | ✅ path exists |
| Honesty | Listing: not tax invoice, same-device restore, AGPL | Maintainer | Metadata staged | ✅ |

### Should (1.0.x / polish — do not block internal track)

| Item | Notes |
|------|--------|
| Tablet 7"/10" screenshots | Empty slots today |
| Feature graphic designer refresh | Staged brand banner OK |
| Stable privacy URL (not only GitHub blob) | Preferred for long-term |
| PIN default-on (E0c) | **Shipped in 0.9.1** (onboarding finish/skip). Not a Console-form blocker |

### Explicit non-blockers for internal testing

- Device `integration_test/` not run on main CI (format/analyze only). Trust **blocks** emulator `--flavor dev` on tags / money-path PRs — see [`docs/testing/CI.md`](testing/CI.md)
- Phase M v32 is shipped; recovery-kit export/import is **code complete, device validation pending** ([Unreleased]) — full cross-device device smoke (Phase 2b D2) is still pending
- iOS App Store full cut (separate track)  

---

## Pre-Flight (Code)

- [x] `pubspec.yaml` version bumped to `0.9.3` for release v0.9.3
- [x] Android / iOS display name **Promsell**
- [x] Permissions: CAMERA (product photos + barcode), storage for exports; INTERNET optional (remote product images only)
- [x] iOS privacy usage strings present (`Info.plist`)
- [x] Release signing fail-closed without `android/app/keystore.properties`
- [x] Keystore artifacts gitignored (`*.jks`, `keystore.properties`)
- [x] Money-path trust suite, Phase M migration/satang coverage, and host suite green (2129 tests, 2026-08-17); device smoke remains operator-owned
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

- [ ] Data safety form in Play Console (use **A2 draft answers** below)
- [ ] Production release keystore (not throwaway E2) + dual custody
- [ ] Upload production-signed AAB
- [ ] Content rating + Free pricing + Thailand
- [ ] Contact `mnlizard.official@gmail.com`

### A2 — Play Data safety draft answers (fill Console; 2026-07-20)

Align with `docs/PRIVACY_POLICY.md`. **No developer-operated collection/server.**

| Console topic | Answer (draft) |
|---------------|----------------|
| Does the app collect/share user data with the developer? | **No** developer collection; data stays on device |
| Location | Not collected by app for analytics |
| Personal info | **May be stored on device only:** shop name/phone, optional customer name/phone/email, PromptPay ID, product photos |
| Financial info | Sales totals/payment method labels stored **on device** for POS; not sent to Promsell servers |
| Photos | Product images chosen by merchant — local storage |
| App activity / crash | Local crash log only (PII sanitized); no Firebase Analytics by default |
| Encryption in transit | N/A for core offline POS (no required network) |
| Encryption at rest | SQLCipher + optional AES-GCM backup; key in platform secure storage |
| Data deletion | Uninstall / clear app data; merchant can delete customers/sales in-app; **SQLCipher key loss without backup = permanent** |
| Children | Not directed at children |
| Account creation | No cloud account |

Operator still must click through Play Console forms — this table is the honesty SSOT.

---

## Manual steps (operator)

### 1. Production keystore + dual custody (A1 runbook)

**Never use** `promsell-throwaway-release.jks` for Play. Loss of the production keystore = cannot update the app on Play.

#### Generate (once)

```bash
cd android/app
keytool -genkey -v -keystore promsell-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias promsell \
  -storepass YOUR_STRONG_PASSWORD \
  -keypass YOUR_STRONG_PASSWORD \
  -dname "CN=Promsell, O=Promsell, C=TH"
```

#### Dual custody (required)

| Copy | Location | Access |
|------|----------|--------|
| **Primary** | Operator password manager + encrypted disk (not git) | Day-to-day signing / CI secrets |
| **Sealed backup** | Second person or offline sealed media | Break-glass only; inventory annually |
| **CI** | GitHub Actions secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` | Repo admin only |

Checklist:

- [ ] Primary JKS stored outside repo  
- [ ] Sealed backup exists and is tested (list aliases with `keytool -list`)  
- [ ] Passwords not in chat/email plaintext  
- [ ] Throwaway keystore never uploaded to Play
- [ ] Tag releases fail without CI secrets (`release-aab.yml` A3)

#### Play App Signing (enroll at first upload)

Enroll in **Play App Signing** when uploading the first AAB: Google holds the app signing key, and the `promsell-release-key.jks` above becomes the **upload key** used only to sign AABs for upload. Keep the upload key under the same dual-custody rules; if it is ever lost, a Play Console reset requires verified identity and downtime. The throwaway warning still applies: **never** sign anything with `promsell-throwaway-release.jks` for Play.

#### Local `keystore.properties` (gitignored)

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

Bundle `com.promsell.promsell_pos_ce` · same privacy URL · export compliance for SQLCipher/AES

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
| Release notes | v0.9.3 (`pubspec` 0.9.3) |
| Privacy URL | https://github.com/teeprakorn1/promsell-pos-ce/blob/main/docs/PRIVACY_POLICY.md |
| Source | https://github.com/teeprakorn1/promsell-pos-ce |
| Android ID | `com.promsell.promsell_pos_ce` |
| Phone screenshots | `fastlane/metadata/android/en-US/images/phoneScreenshots/` |
| Feature graphic | `fastlane/metadata/android/en-US/images/featureGraphic.png` |

---

## E4 / E5 (trust package)

| ID | Status |
|----|--------|
| **E4** CI release + **fail-closed** signed AAB on `v*` / dispatch | ✅ `release-aab.yml` (secrets required; no `require_signed_aab` input) |
| **E5** Screenshots + graphic + privacy + listing honesty | ✅ **Staged 2026-07-17** — operator still submits in consoles |
