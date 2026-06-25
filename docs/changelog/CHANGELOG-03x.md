# Changelog — v0.3.x — Promsell POS CE

> For the most up-to-date changes and release information, see [CHANGELOG.md](/CHANGELOG.md) for version 0.8.x, including feature additions, system improvements, performance enhancements, and bug fixes.

---

## [0.3.0] - 2026-05-26

Product management UI overhaul with offline font bundling, PDF receipt export, centralised feedback system, and database upgrade hardening.

### Highlights

- **Product catalog:** Toggleable list/grid views, category filter chips, traffic-light `_StockBadge`, and `Image.network` avatar with fallback.
- **Product form:** Live image URL preview, `BASIC INFO` / `DETAILS` section grouping, and `imageUrl` wired to `ProductAdded`.
- **Offline fonts:** `NotoSansThai` bundled locally — no network call on first launch; `google_fonts` dependency removed.
- **PDF receipts:** 80 mm thermal receipt PDF with Print and Share actions in history page.
- **Feedback system:** `AppSnackBar` + `OverlayToast` replace all 9 inline `ScaffoldMessenger` calls; cart toast no longer blocks the checkout panel.
- **DB safety:** Step-based `onUpgrade` loop — an incomplete schema bump fails at the exact step, not silently at startup.

### Added

#### Product page redesign
- **List/Grid toggle** — `_ViewMode` enum; AppBar shows `view_list` / `grid_view` icon pair with active colour highlight.
- **Category filter chips** — horizontal scroll row below SearchBar; categories derived live from products; combined with search filter; hidden when no categories exist.
- **`_ProductTile` upgrade** — `_ProductAvatar` (`Image.network` + icon fallback), `_StockBadge` (green > 5 / orange 1–5 / red 0), inactive dim 40 % + strikethrough name.
- **`_ProductGridCard`** — 2-column `GridView.builder`, aspect ratio 0.76; tap = edit, long-press = context menu bottom sheet.
- **Product form: image URL + preview** — `imageUrl` field in header row with live `_FormAvatar` (80 px rounded); wired to `ProductAdded.imageUrl`.
- **Form section grouping** — `BASIC INFO` / `DETAILS` uppercase section labels.

#### Local font bundling (offline-first)
- Removed `google_fonts` dependency; bundled four `NotoSansThai` weights (400/500/600/700) under `assets/fonts/`.
- `AppTheme` rewritten to use `TextStyle(fontFamily: 'NotoSansThai', ...)` throughout.

#### PDF receipt export
- `ReceiptPdfService` — 80 mm thermal PDF with `printReceipt` / `shareReceipt` methods.
- Print / Share buttons added to each sale's `ExpansionTile` in history page.
- `printReceipt` / `shareReceipt` localisation keys added to `app_en.arb` and `app_th.arb`.
- Registered as `lazySingleton` in `injection_container.dart`.

#### AppSnackBar + OverlayToast — centralised feedback
- `AppSnackBar` — static `success` (2 s) / `error` (4 s) / `info` (1.2 s) helpers with `context.mounted` guard.
- Refactored all 9 inline `ScaffoldMessenger` callsites across 5 pages to use `AppSnackBar`.
- `OverlayToast` — fade-in pill toast via Flutter `Overlay`; `IgnorePointer` prevents checkout panel obstruction.

#### ReportCubit — state management consistency
- `ReportPage` migrated from `StatefulWidget` + `StreamSubscription` to `BlocProvider<ReportCubit>`.
- Added `report_cubit_test.dart` covering load success, failure, and `changeDateRange`.
- Registered as `factory` in `injection_container.dart`.

#### DB migration loop framework
- `onUpgrade` replaced with step-based `for` loop; each schema version bump requires an explicit `case N:` block.

### Fixed

- **RenderFlex overflow** in sale product card padding
- **`_StockBadge` dark-theme contrast** — improved visibility in dark mode
- **Add product button visibility** in dark theme — improved contrast and foreground color

### Changed

- Add product AppBar button: `FilledButton.icon` → compact `IconButton.filled` (M3 pattern, tooltip retained).
- `README.md` screenshots section: replaced "Coming soon" placeholder with contributor call-to-action.
- `pubspec.yaml` version bumped to `0.3.0+1`.

`flutter analyze` → **0 issues** · `flutter test` → **135/135 passing**

---

[0.3.0]: https://github.com/teeprakorn1/promsell-pos-ce/compare/v0.2.3...v0.3.0
