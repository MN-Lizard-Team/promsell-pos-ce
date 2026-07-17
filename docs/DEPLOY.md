# Deployment guide — Promsell POS CE

> How to build, sign, and distribute Promsell for Android and iOS.
>
> **Related docs:** [`ARCHITECTURE.md`](ARCHITECTURE.md) (system design) · [`DATABASE.md`](DATABASE.md) (schema) · [`USAGE.md`](USAGE.md) (setup & usage)

---

## Android

### Debug build (testing)

```bash
flutter run --debug --flavor dev -t lib/main_dev.dart
```

### Release APK (sideload)

```bash
flutter build apk --release --flavor prod -t lib/main_prod.dart
```

Output: `build/app/outputs/flutter-apk/app-prod-release.apk`

Transfer to device via USB or share link for manual installation.

### Split APKs (smaller per-device downloads)

```bash
flutter build apk --release --flavor prod -t lib/main_prod.dart --split-per-abi
```

Outputs:
- `app-arm64-v8a-prod-release.apk` — modern Android (recommended)
- `app-armeabi-v7a-prod-release.apk` — older 32-bit devices
- `app-x86_64-prod-release.apk` — emulators

### App Bundle (Google Play Store)

```bash
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

Output: `build/app/outputs/bundle/prodRelease/app-prod-release.aab`

Upload to Google Play Console under your app listing.

### Signing

1. Generate a keystore (one-time):

```bash
keytool -genkey -v -keystore promsell-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias promsell
```

2. Create `android/app/keystore.properties` (path required by `android/app/build.gradle.kts` — Release tasks **fail closed** if this file is missing):

```properties
storeFile=promsell-release-key.jks
storePassword=<your-store-password>
keyAlias=promsell
keyPassword=<your-key-password>
```

Place the `.jks` next to that properties file under `android/app/` (or set `storeFile` to a path relative to `android/app/`).

3. Build a signed app bundle:

```bash
flutter build appbundle --release --flavor prod -t lib/main_prod.dart
```

See also [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app) and `docs/STORE_SUBMISSION.md`.

> **Never commit `keystore.properties`, `key.properties`, or `.jks` files to git.** They are in `.gitignore`.

---

## iOS (macOS only)

### Prerequisites

- Xcode 15+
- Apple Developer account
- Provisioning profile and signing certificate configured

### Build

```bash
flutter build ios --release --flavor prod -t lib/main_prod.dart
```

Then open Xcode:

```bash
open ios/Runner.xcworkspace
```

Archive via **Product → Archive**, then distribute via TestFlight or App Store Connect.

### iOS Scheme Setup for Flavors

To support `dev` and `prod` flavors on iOS, create Xcode schemes:

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **Product → Scheme → Manage Schemes**.
3. Duplicate the default `Runner` scheme → name it `dev`.
4. Duplicate again → name it `prod`.
5. For each scheme, under **Run** and **Archive**, set the **Build Configuration** to the matching flavor.
6. In `ios/Flutter/Info.plist`, ensure `FLUTTER_FLAVOR` is set per scheme (use User-Defined Settings in Build Settings).

> See [Flutter flavors iOS guide](https://docs.flutter.dev/deployment/flavors) for detailed steps.

---

## Version management

Version format: `major.minor.patch+buildNumber` in `pubspec.yaml`.

```yaml
version: 0.9.0+1
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
- [ ] `flutter test` — the unit/widget suite (`flutter test --exclude-tags stress`) pass
- [ ] Integration tests pass (checkout flow + sale integrity)
- [ ] `flutter gen-l10n` — localization up to date
- [ ] `dart run build_runner build` — generated code up to date (files not committed to git)
- [ ] Version bumped in `pubspec.yaml`
- [ ] `CHANGELOG.md` updated with release notes (archive old versions to `docs/changelog/` if needed)
- [ ] Signed with release keystore (Android)
- [ ] Tested on physical device
- [ ] Sale flow smoke-tested on compact phone layout
- [ ] Sale flow smoke-tested on tablet or expanded-width layout
- [ ] Home dashboard verified (hero card, stats row, menu grid, promotion banner)
- [ ] Navbar floating center button renders with bounce animation on tab change
- [ ] Restaurant mode: order type/channel selector, table selector, service charge (if enabled)
- [ ] Customer management: add/search/edit customer
- [ ] Promotion management: create percent/fixed discount promotion with date range
- [ ] Product options: add option groups, select options in cart, verify price delta
- [ ] Report/History merged: verify TabBar sub-tabs in Report page
- [ ] Product form and payment sheet checked for keyboard/overflow behavior
- [ ] Light, dark, and system theme modes checked
- [ ] Thai and English locale checked after `flutter gen-l10n`
- [ ] Barcode generation and display checked (generate from Product Preview, verify image quality)

### UI release smoke test

Before distributing a build with UI changes:

1. Add a product (set trackStock=off on one service item to verify ∞ display). Verify the unified Product Form page with Hybrid Collapsible layout: basic fields (name, price, stock, image, category) visible by default, advanced fields (SKU, barcode, cost, show product toggle) in expandable ExpansionTile.
2. Search and filter products in the Sale tab.
3. Add items to cart and adjust quantity.
3b. **Tap the quantity number** in cart → verify numeric input dialog opens with stock info and clamping.
4. Open a cart line menu (⋯) → discount / note / duplicate / remove; confirm remove shows undo snackbar.
5. Verify receipt-style cart lines (avatar, name, qty steppers, line total, discount badge when applied). Verify sticky payable total and Park / Pay CTAs. Verify totals match checkout with VAT/SC enabled.
6. Tap the bottom cart bar (or compact FAB) → verify full-page `CartReviewPage` opens; product image zoom; row detail; qty +/− / long-press keypad; line ⋯ actions; live payable; **Add items** / back returns to catalog with cart preserved.
7. From cart, tap **Pay** (retail) → cart review pops, payment sheet on sale root (no empty cart under payment). Restaurant: Pay → `CheckoutPage`; cart icon on checkout reopens `CartReviewPage`.
8. Enable ultra-compact in Settings → sale shows FAB instead of bottom bar; long-press FAB to exit compact.
9. Line action sheet → apply a 10% discount — verify discount badge and updated subtotal.
10. Tap **Apply cart discount** → apply a fixed amount — verify breakdown on payment / checkout (Subtotal → discounts → Total); verify receipt preview pinch-to-zoom works.
11. Tap the bookmarks icon → create a second draft, switch between drafts — cart content should swap; verify draft count badge (e.g. "Cart · 1/5") and draft search/sort functionality; kill and relaunch app to verify draft restore.
12. Complete one cash sale using quick cash chips.
13. Open History, expand the saved sale — verify receipt number; if VAT mode is INCLUSIVE or EXCLUSIVE, verify Subtotal + VAT rows appear; verify discount rows if discount was applied.
14. Tap **Void Sale** on a sale, enter a reason, confirm — verify VOIDED badge appears and stock is restored.
15. Open History again — voided sale shows strikethrough amount and red badge.
16. Open Report and verify net revenue excludes voided sales; voided summary card appears.
17. Tap **Print Receipt** or **Share Receipt** on any sale.
18. Open Settings root page — verify 2-level hierarchy: section headers (General, Store & Sales, Discounts, Payments, System & Data, About) → individual pages (1 tap to reach any page). Verify cross-section search bar filters all settings. Verify gradient dashboard card with 5 summary badges (shop name, language, theme, backup status, PromptPay status); verify colored status chips on every tile.
18b. Open **General Settings** — verify gradient summary card with language, theme, and accessibility badges; tap language/theme tiles to open visual dialog pickers with icon-based option cards; verify accessibility mode toggle; verify "Reset to Defaults" tile with confirmation dialog.
18c. Open **Shop Info** — verify live preview card showing shop name/address/phone; verify inline form with character counters and phone auto-format (`081-234-5678`); verify receipt size dropdown.
18d. Open **PromptPay Settings** — verify gradient preview card showing configured/not-configured state with QR icon; verify PromptPay ID tile with validation dialog (phone 10 digits / citizen ID 13 digits); verify info card explaining PromptPay usage.
18e. Open **Backup Settings** — verify gradient status card (Safe/Warning/Overdue); verify backup reminder switch + frequency picker dialog with preset chips (3/7/14/30 days); verify "Backup Now" action tile; verify **Encryption** toggle and PIN setup dialog.
18f. Open Stock Policy section (Allow oversell + Low stock threshold) and Discount Policy section (presets, max limits, toggles); switch theme/locale, and save shop info.
19. Open Products, tap Add Product, tap the image avatar — verify Gallery / Camera / Remove bottom sheet; pick an image and verify skeleton loading shimmer appears briefly before image fades in; verify it displays in the form and list/grid; verify thumbnail is used for small avatar sizes and full image for larger views; verify dark-mode placeholder uses neutral gray (not green); delete the product and verify both image files are removed from storage.
19b. In the Products tab, verify **category picker** — tap the category field to open a bottom sheet with searchable category list and "No category" option; selecting a category assigns it to the product.
19c. Open **Category Management** (overflow menu on Product List AppBar) — verify drag & drop reordering works; add a category with color + icon picker (10 colors / 21 icons); verify product count badge on each category; verify search filters categories; verify bulk delete mode (select multiple → delete all).
20. In Settings, verify **Image max width** and **Image quality** settings appear with correct defaults (800 / 80); tap **Export Database** — verify share sheet appears with `.db` file (or `.db.enc` if encryption is enabled); tap **Export Sales CSV** and **Export Products CSV** — verify CSV files are generated and shareable.
21. In the Products tab, long-press a product image → verify `ImageViewerDialog` opens with pinch zoom; tap **share** button (file/URL) and **info** button (source, path, size bottom sheet).
22. In Settings, verify **Max drafts** input (default 30, range 5–100), **Compact cart**, and **Ultra-compact cart** toggles appear.
23. In History tab, verify **search bar** appears — filter by receipt number, payment method, or amount.
24. In Settings, verify **Backup reminder** banner appears if `backupReminderDays` threshold is exceeded.
25. In Settings → **About** section, tap **About App** — verify app icon, name "Promsell POS CE", version + build number, description, tech stack, and contact email. Tap **Privacy Policy** — verify in-app page renders 6 sections (Data Collection, Third-Party Services, Data Storage, Backup Encryption, Permissions, Contact). Tap **Open Source License** — verify full AGPL-3.0 license text is displayed and selectable. Verify footer "© 2026 Promsell POS CE · AGPL-3.0".

---

## Firebase App Distribution (optional)

For internal beta distribution without Play Store:

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Distribute APK
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-prod-release.apk \
  --app <YOUR_FIREBASE_APP_ID> \
  --groups "internal-testers"
```

---

## Dependabot security alerts

Dependabot is configured for weekly `pub` package updates (see `.github/dependabot.yml`). To enable security alerts:

1. Go to **Settings → Security & analysis** in the GitHub repository.
2. Enable **Dependabot security updates**.
3. Enable **Dependabot alerts** for the `pub` ecosystem.
4. Dependabot will automatically scan dependencies against the GitHub Advisory Database and open PRs for vulnerable packages.

The CI workflow also runs `dart pub outdated` and `tool/check_outdated.dart` to flag direct dependencies behind by ≥ 1 major version.

---

<sub>Promsell POS CE · MN Lizard Team</sub>
