# Screenshots

Play Store screenshots and smoke test evidence for Promsell POS CE.

## Structure

```
screenshots/
├── store/                    # Play Store screenshots (canonical)
│   ├── en/                   # English (10 images, 1080×2400)
│   └── th/                   # Thai (10 images, 1080×2400)
└── smoke/                    # Device smoke test evidence (historical)
    ├── 2026-07-17/           # v1.0 smoke run (8 images)
    └── 2026-07-20/           # v1.0 smoke run (17 images)
```

## Store Screenshots (`store/`)

10 screenshots per locale, captured by `integration_test/screenshot_test.dart`
on an Android emulator. These mirror the files in
`fastlane/metadata/android/{locale}/images/phoneScreenshots/`.

| # | Name | Description |
|---|------|-------------|
| 01 | home | Home tab |
| 02 | sale | Sale tab with cart |
| 03 | checkout | Checkout page |
| 04 | receipt | Receipt after payment |
| 05 | products | Products tab |
| 06 | history | Report tab + history sub-tab |
| 07 | report | Report tab (summary) |
| 08 | settings | Settings tab |
| 09 | draft | Sale tab with draft saved |
| 10 | daily_close | Daily close page |

### Regenerating

```bash
# Run on emulator (produces 20 images: 10 EN + 10 TH)
flutter test integration_test/screenshot_test.dart --flavor dev -d emulator-5554

# Pull from device and copy to fastlane + screenshots/store/
adb -s emulator-5554 pull /storage/emulated/0/Android/data/com.promsell.promsell_pos_ce.dev/files/screenshots/en %TEMP%\screenshots_en
adb -s emulator-5554 pull /storage/emulated/0/Android/data/com.promsell.promsell_pos_ce.dev/files/screenshots/th %TEMP%\screenshots_th
Copy-Item %TEMP%\screenshots_en\*.png fastlane\metadata\android\en-US\images\phoneScreenshots\
Copy-Item %TEMP%\screenshots_th\*.png fastlane\metadata\android\th\images\phoneScreenshots\
Copy-Item %TEMP%\screenshots_en\*.png screenshots\store\en\
Copy-Item %TEMP%\screenshots_th\*.png screenshots\store\th\
```

## Smoke Screenshots (`smoke/`)

Manual device smoke test evidence from physical devices. Kept for historical
reference — not regenerated automatically.

| Date | Device | Images | Notes |
|------|--------|--------|-------|
| 2026-07-17 | Physical device | 8 | First smoke run |
| 2026-07-20 | Physical device | 17 | v1.0 release smoke |
