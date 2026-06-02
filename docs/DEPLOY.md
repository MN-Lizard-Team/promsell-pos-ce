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
version: 0.6.1+2
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
- [ ] `flutter test` — all 243+ tests pass
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
4. Long-press a cart item → enter multi-select mode → select multiple items → tap bulk delete or clear discount.
5. With more than 5 items in cart, verify the search bar appears and filters by product name; toggle between flat list and group-by-category views.
6. In flat list view, swipe right to delete (with undo snackbar); swipe left to increment quantity; drag the reorder handle to move items.
7. Tap the density cycle button in the cart header → cycle through Normal → Compact → Ultra-Compact.
8. Drag the resize handle between catalog and cart to resize the panel; use the size slider for Small/Large presets.
9. Tap the cart icon with the item-count badge in the app bar → verify `CartReviewPage` opens with interactive cart editing; tap a product image for zoom dialog; tap a row for product detail sheet; adjust quantities and verify total updates live; tap **Back to Sale** and verify the cart reflects changes.
10. Tap the tag icon on a cart item → apply a 10% discount — verify discount badge and updated subtotal.
11. Tap **Apply cart discount** → apply a fixed amount — verify breakdown in full-screen `CheckoutPage` (Subtotal → discounts → Total); verify receipt preview pinch-to-zoom works.
12. Tap the bookmarks icon → create a second draft, switch between drafts — cart content should swap; verify draft count badge (e.g. "Cart · 1/5") and draft search/sort functionality; kill and relaunch app to verify draft restore.
13. Complete one cash sale using quick cash chips.
14. Open History, expand the saved sale — verify receipt number; if VAT mode is INCLUSIVE or EXCLUSIVE, verify Subtotal + VAT rows appear; verify discount rows if discount was applied.
15. Tap **Void Sale** on a sale, enter a reason, confirm — verify VOIDED badge appears and stock is restored.
16. Open History again — voided sale shows strikethrough amount and red badge.
17. Open Report and verify net revenue excludes voided sales; voided summary card appears.
18. Tap **Print Receipt** or **Share Receipt** on any sale.
19. Open Settings, verify Stock Policy section (Allow oversell + Low stock threshold) and Discount Policy section (presets, max limits, toggles); verify PromptPay ID field and Receipt Size toggle; switch theme/locale, and save shop info.
20. Open Products, tap Add Product, tap the image avatar — verify Gallery / Camera / Remove bottom sheet; pick an image and verify it displays in the form and list/grid; verify thumbnail is used for small avatar sizes and full image for larger views; delete the product and verify both image files are removed from storage.
21. In Settings, verify **Image max width** and **Image quality** settings appear with correct defaults (800 / 80); tap **Export Database** — verify share sheet appears with `.db` file; tap **Export Sales CSV** and **Export Products CSV** — verify CSV files are generated and shareable.
22. In the Products tab, long-press a product image → verify `ImageViewerDialog` opens with pinch zoom and close button.
23. In Settings, verify **Max drafts** input (default 30, range 5–100), **Compact cart**, and **Ultra-compact cart** toggles appear.
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
