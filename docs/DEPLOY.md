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
keytool -genkey -v -keystore promsell-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias promsell
```

2. Create `android/key.properties`:

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=promsell
storeFile=../../promsell-release-key.jks
```

3. Reference in `android/app/build.gradle.kts` — see [Flutter signing docs](https://docs.flutter.dev/deployment/android#signing-the-app).

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
version: 0.7.3+1
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
- [ ] `flutter test` — all 286+ tests pass
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

1. Add a product (set trackStock=off on one service item to verify ∞ display).
2. Search and filter products in the Sale tab.
3. Add items to cart and adjust quantity.
3b. **Tap the quantity number** in cart → verify numeric input dialog opens with stock info and clamping.
4. Long-press a cart item → enter multi-select mode → select multiple items → tap bulk delete or clear discount.
5. Verify items display in single-row 3-zone layout (avatar | name+price | stepper+total). Verify discount chip appears inline with price when applied. Swipe right to delete (with undo snackbar); swipe left to increment quantity. Long-press to drag-and-reorder items.
6. Tap the density toggle button in the cart header → cycle through Normal ↔ Ultra-Compact. Verify layout adapts (padding, avatar size, font size).
7. Drag the resize handle between catalog and cart to resize the panel; use the size slider for Small/Large presets.
8. Tap the cart icon with the item-count badge in the app bar → verify `CartReviewPage` opens with interactive cart editing; tap a product image for zoom dialog; tap a row for product detail sheet; adjust quantities and verify total updates live; tap **Back to Sale** and verify the cart reflects changes. Verify stepper buttons have press-scale animation and haptic feedback.
9. Tap the tag icon on a cart item → apply a 10% discount — verify discount badge and updated subtotal.
10. Tap **Apply cart discount** → apply a fixed amount — verify breakdown in full-screen `CheckoutPage` (Subtotal → discounts → Total); verify receipt preview pinch-to-zoom works.
11. Tap the bookmarks icon → create a second draft, switch between drafts — cart content should swap; verify draft count badge (e.g. "Cart · 1/5") and draft search/sort functionality; kill and relaunch app to verify draft restore.
12. Complete one cash sale using quick cash chips.
13. Open History, expand the saved sale — verify receipt number; if VAT mode is INCLUSIVE or EXCLUSIVE, verify Subtotal + VAT rows appear; verify discount rows if discount was applied.
14. Tap **Void Sale** on a sale, enter a reason, confirm — verify VOIDED badge appears and stock is restored.
15. Open History again — voided sale shows strikethrough amount and red badge.
16. Open Report and verify net revenue excludes voided sales; voided summary card appears.
17. Tap **Print Receipt** or **Share Receipt** on any sale.
18. Open Settings root page — verify 3-level hierarchy: topic groups (General, Store, Payment, System) → sub-topics → individual pages. Verify cross-sub-topic search bar filters all settings. Verify gradient dashboard card with 5 summary badges (shop name, language, theme, backup status, PromptPay status); verify colored status chips on every tile.
18b. Open **General Settings** — verify gradient summary card with language, theme, and accessibility badges; tap language/theme tiles to open visual dialog pickers with icon-based option cards; verify accessibility mode toggle; verify "Reset to Defaults" tile with confirmation dialog.
18c. Open **Shop Info** — verify live preview card showing shop name/address/phone; verify inline form with character counters and phone auto-format (`081-234-5678`); verify receipt size dropdown.
18d. Open **PromptPay Settings** — verify gradient preview card showing configured/not-configured state with QR icon; verify PromptPay ID tile with validation dialog (phone 10 digits / citizen ID 13 digits); verify info card explaining PromptPay usage.
18e. Open **Backup Settings** — verify gradient status card (Safe/Warning/Overdue); verify backup reminder switch + frequency picker dialog with preset chips (3/7/14/30 days); verify "Backup Now" action tile; verify **Encryption** toggle and PIN setup dialog.
18f. Open Stock Policy section (Allow oversell + Low stock threshold) and Discount Policy section (presets, max limits, toggles); switch theme/locale, and save shop info.
19. Open Products, tap Add Product, tap the image avatar — verify Gallery / Camera / Remove bottom sheet; pick an image and verify it displays in the form and list/grid; verify thumbnail is used for small avatar sizes and full image for larger views; delete the product and verify both image files are removed from storage.
19b. In the Products tab, verify **category autocomplete** — type in the category field and see suggestions from existing categories; enter a new category freely.
20. In Settings, verify **Image max width** and **Image quality** settings appear with correct defaults (800 / 80); tap **Export Database** — verify share sheet appears with `.db` file (or `.db.enc` if encryption is enabled); tap **Export Sales CSV** and **Export Products CSV** — verify CSV files are generated and shareable.
21. In the Products tab, long-press a product image → verify `ImageViewerDialog` opens with pinch zoom and close button.
22. In Settings, verify **Max drafts** input (default 30, range 5–100), **Compact cart**, and **Ultra-compact cart** toggles appear.
23. In History tab, verify **search bar** appears — filter by receipt number, payment method, or amount.
24. In Settings, verify **Backup reminder** banner appears if `backupReminderDays` threshold is exceeded.

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
