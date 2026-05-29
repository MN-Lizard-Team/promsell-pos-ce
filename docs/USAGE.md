# Usage guide — Promsell POS CE

> Complete guide for installing, building, and using Promsell POS Community Edition.

---

## Table of contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the app](#running-the-app)
- [Building for production](#building-for-production)
- [Features walkthrough](#features-walkthrough)
- [Settings](#settings)
- [Localization (i18n)](#localization-i18n)
- [Database (Drift)](#database-drift)
- [Architecture overview](#architecture-overview)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

| Tool | Minimum version |
|------|----------------|
| Flutter SDK | 3.11+ |
| Dart SDK | 3.11+ (bundled with Flutter) |
| Android Studio | Hedgehog (2023.1.1)+ |
| Xcode (macOS only) | 15+ |
| Git | 2.30+ |

Verify your environment:

```bash
flutter doctor -v
```

All sections under "Flutter", "Android toolchain", and "Connected device" should show green checkmarks.

---

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/teeprakorn1/promsell-pos-ce.git
cd promsell-pos-ce
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Generate code

Promsell uses two code generators — **Flutter localization** for ARB → Dart, and **Drift** for SQLite schema → Dart.

```bash
# Generate AppLocalizations from ARB files
flutter gen-l10n

# Generate Drift database code
dart run build_runner build --delete-conflicting-outputs
```

Re-run these whenever you add new ARB keys or change Drift schema.

---

## Running the app

### Debug mode (with hot reload)

```bash
# List available devices
flutter devices

# Run on connected device or emulator
flutter run

# Run on a specific device
flutter run -d <device-id>
```

### Common commands during development

| Action | Shortcut |
|--------|----------|
| Hot reload | `r` |
| Hot restart | `R` |
| Quit | `q` |
| Toggle performance overlay | `P` |
| Toggle debug paint | `p` |

---

## Building for production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode and archive for distribution.

### Split APKs per ABI (smaller downloads)

```bash
flutter build apk --release --split-per-abi
```

Produces three APKs in `build/app/outputs/flutter-apk/`:
- `app-armeabi-v7a-release.apk` (old 32-bit ARM)
- `app-arm64-v8a-release.apk` (modern 64-bit ARM — most devices)
- `app-x86_64-release.apk` (emulators / Intel Chromebooks)

---

## Features walkthrough

### Sale tab

1. Use the search bar or category chips to narrow the product catalog
2. Tap any product card to add it to the cart
3. Adjust quantity with `+` / `-` controls in the cart panel
4. **Apply discounts** (optional):
   - Tap the 🏷️ tag icon on any cart item → choose **%** or **฿**, enter value, tap Apply
   - Tap **Apply cart discount** below the subtotal for a bill-wide discount
   - Payment sheet shows the full breakdown: Subtotal → discounts → Total
5. **Switch drafts** (optional): tap the 🔖 bookmarks icon in the app bar to open the Drafts sheet — create new drafts, rename, switch between customers / tables, or delete; cart auto-saves every 500 ms
6. Tap **Checkout** → payment sheet opens
7. Select **Cash / Transfer / Card**
8. For cash, use quick cash chips or enter the amount received — change is calculated automatically
9. Optionally add a sale note
10. Tap **Confirm Payment** — sale is saved; if **Auto print prompt** is on, a receipt preview dialog appears with Print / Share / Close options; closing the dialog resets the cart and creates a fresh empty draft

On compact phones, the cart appears as a bottom command panel. On tablet or expanded width layouts, the cart remains visible beside the product grid.

### Products tab

- Toggle between **List** and **Grid** view with the icon pair in the app bar
- Use category **filter chips** to narrow the catalog; combined with the search bar
- Each product shows an image avatar (`Image.network` with icon fallback), a traffic-light **stock badge** (green > 5 / orange 1–5 / red 0), and inactive products appear dimmed with strikethrough
- Tap **Add Product** (➕ icon, app bar) to open the product form
- Product form: paste an image URL in the header for a live rounded preview; fill name, price, quantity, category; toggle **Track stock** (off = service item, shows ∞ in sale catalog, no stock deduction); **BASIC INFO** and **DETAILS** section labels guide the layout
- Tap a card to edit, or long-press (grid) / 3-dot menu (list) for **Edit** / **Delete**
- Search filters by name and category in real time

### History tab

- Lists all sales as receipt-like cards, newest first
- Each card shows receipt number (e.g. `260527-A1-0001`), total, timestamp, and payment method
- Tap any card to expand the per-item breakdown
- **Voided sales** display a red **VOIDED** badge, strikethrough amount, dimmed card, and a block icon
- Expanded card shows:
  - **VAT breakdown** — when `vatMode` is INCLUSIVE or EXCLUSIVE, Subtotal and VAT (with rate %) rows are shown above the total, using the VAT settings that were active at the time of sale
  - **Void Sale** button (red) — opens confirmation dialog with optional reason; atomically marks sale as voided, restores stock, and logs VOID_REVERSAL
  - **Print Receipt** and **Share Receipt** buttons — generates an 80 mm thermal receipt PDF with sale-time VAT values
- Use the date-range picker (calendar icon) to filter history by period

### Report tab

- Tap the date icon or date filter chip to pick a custom range (default: last 30 days)
- **Net Revenue** card — shows revenue from completed sales only (voided sales excluded)
- **Voided Total** card — appears when voided sales exist; shows voided amount and count
- Payment method breakdown and top 5 products only count completed (non-voided) sales
- Pull down to refresh the report dashboard
- Empty states are shown when there are no sales in the selected date range

### Settings tab

Settings are grouped into cards: general, shop info, sales, and receipt. See [Settings](#settings) below.

---

## Settings

All settings persist via `SettingsLocalDatasource` (Drift-backed typed key-value store). Locale, theme, currency, and date format apply immediately; shop and receipt text fields are saved with the **Save** action.

| Setting | Description |
|---------|-------------|
| **Language** | Thai (`th`) or English (`en`) — live reload |
| **Theme** | Light, Dark, or System (follows OS) — live reload |
| **Shop name** | Displayed on receipts and preview |
| **Shop address** | Displayed on receipts and preview |
| **Shop phone** | Displayed on receipts and preview |
| **Currency symbol** | Default `฿` — used in money formatting |
| **Date format** | Default `dd/MM/yyyy` — `intl` format pattern |
| **Receipt note** | Optional footer text on receipts |
| **Show shop info on receipt** | Toggle on/off |
| **Auto print prompt** | Ask to print receipt after sale |
| **VAT mode** | `NONE` / `INCLUSIVE` / `EXCLUSIVE` |
| **VAT rate** | Percentage (default `7.0`) |
| **Receipt preview style** | `thermal` / `card` / `none` |
| **Show pre-sale preview** | Show preview in PaymentSheet |
| **Show post-sale preview** | Show preview in success dialog |
| **Allow oversell** | Permit selling beyond available stock (default off) |
| **Low stock threshold** | Stock count at which the product card turns red (default `5`) |

To save text-field changes, tap the **Save** button in the app bar or at the bottom of the page.

---

## Localization (i18n)

Promsell uses Flutter's official ARB localization workflow.

### Files

```
lib/l10n/
├── app_th.arb            # Thai (template / source of truth)
└── app_en.arb            # English
```

Config: [`l10n.yaml`](../l10n.yaml)

```yaml
arb-dir: lib/l10n
template-arb-file: app_th.arb
output-localization-file: app_localizations.dart
```

### Adding a new string

1. Add the key + Thai value to `lib/l10n/app_th.arb`:

   ```json
   {
     "myNewKey": "ข้อความใหม่"
   }
   ```

2. Add the same key with the English translation to `lib/l10n/app_en.arb`:

   ```json
   {
     "myNewKey": "New text"
   }
   ```

3. Regenerate:

   ```bash
   flutter gen-l10n
   ```

4. Use in code:

   ```dart
   import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

   Text(context.l10n.myNewKey)
   ```

### Adding a new language

1. Create `lib/l10n/app_<code>.arb` (e.g. `app_lo.arb` for Lao)
2. Translate every key from `app_th.arb`
3. Add the locale to `MaterialApp.supportedLocales` in `lib/main.dart`
4. Run `flutter gen-l10n`

### Parametrized strings (plurals, numbers)

```json
{
  "salesCount": "{count, plural, =0{No sales} =1{1 sale} other{{count} sales}}",
  "@salesCount": {
    "placeholders": { "count": { "type": "int" } }
  }
}
```

Then call: `context.l10n.salesCount(42)` → `"42 sales"`

---

## Database (Drift)

Promsell uses [Drift](https://drift.simonbinder.eu/) (formerly Moor) for type-safe SQLite access.

### Schema location

```
lib/core/database/
├── app_database.dart       # Database class, schema v2, migration, indexes, seed
├── app_database.g.dart     # GENERATED — do not edit
└── tables/
    ├── products_table.dart
    ├── sales_table.dart
    ├── sale_items_table.dart
    ├── categories_table.dart
    ├── inventory_logs_table.dart
    ├── settings_table.dart
    ├── draft_carts_table.dart
    ├── draft_cart_items_table.dart
    └── daily_closes_table.dart
```

All tables use **UUIDv4 TEXT** primary keys generated by `IdGenerator.newId()`.

### Regenerating after schema change

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch mode for continuous regeneration during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Schema migrations

When you change a table, bump `schemaVersion` in `app_database.dart` and add a migration step in `onUpgrade`. Current schema version: **3** (v0.5.3). See the [Drift migration docs](https://drift.simonbinder.eu/Migrations/) for details.

> **Note:** v0.5.3 uses incremental migration (`addColumn`). Earlier v0.5.x used destructive drop+recreate (pre-release).

---

## Architecture overview

> **Deep dive:** See [`docs/ARCHITECTURE.md`](ARCHITECTURE.md) for C4 diagrams, full data flow sequences, transaction boundaries, DI graph, and Architecture Decision Records.

Promsell follows **Clean Architecture** with a **feature-first** folder layout.

### High-level flow

```
┌─────────────────────────────────────────────────┐
│  Presentation (Widgets + BLoC/Cubit)            │
│     ↓ events                  ↑ states          │
├─────────────────────────────────────────────────┤
│  Domain (Entities + UseCases + Repository abs.) │
│     ↓ calls                   ↑ returns         │
├─────────────────────────────────────────────────┤
│  Data (Repository impl + DAO)                   │
│     ↓ SQL                     ↑ rows            │
├─────────────────────────────────────────────────┤
│  Drift / SettingsLocalDatasource                │
└─────────────────────────────────────────────────┘
```

### Layer responsibilities

| Layer | Responsibility | Example |
|-------|----------------|---------|
| **Presentation** | Render UI, dispatch events, react to state | `SalePage`, `SaleBloc` |
| **Domain** | Pure business logic, no Flutter imports | `Product` entity, `GetProducts` usecase |
| **Data** | I/O, DB access, mapping to/from entities | `ProductRepositoryImpl`, Drift DAOs |
| **Core** | Cross-cutting helpers (DI, extensions, utils) | `injection_container.dart`, `l10n_extension.dart` |

### Dependency direction

Outer layers depend on inner layers. **Domain has zero external dependencies.**

```
Presentation → Domain ← Data
```

### Why BLoC + Cubit?

- **Cubit** — for simple state (e.g. `SettingsCubit`)
- **BLoC** — for event-driven flows (e.g. `ProductBloc`, `SaleBloc`)

Both are reactive and easy to test.

---

## Testing

Promsell has **216 automated tests** covering domain logic, state management, data access, services, widgets, integration, and localization parity.

### Running tests

```bash
# Run all tests
flutter test

# Run with coverage report
flutter test --coverage

# Run a specific test file
flutter test test/integration/checkout_flow_test.dart
```

### Test structure

Tests mirror `lib/` structure under `test/`:

- `test/helpers/` — shared mocks (`mocks.dart`), widget test helper (`pump_app.dart`), in-memory DB (`fake_database.dart`)
- `test/features/` — per-feature tests: domain, data, presentation
- `test/integration/` — end-to-end checkout flow + sale integrity (void, adjust stock) with real in-memory SQLite
- `test/l10n/` — EN/TH translation parity test

### In-memory database testing

Datasource and integration tests use a real SQLite database in memory via `sqlite3_flutter_libs` (FFI). This provides true SQL execution without disk I/O:

```dart
import 'package:drift/native.dart';

AppDatabase createInMemoryDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}
```

Add `sqlite3_flutter_libs` to `dev_dependencies` in `pubspec.yaml` for this to work on desktop test runners.

---

## Troubleshooting

### `flutter pub get` fails with version conflict

```bash
flutter pub upgrade --major-versions
```

### Generated code is out of sync

```bash
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

### App crashes on first launch — "table doesn't exist"

The Drift database file may be stale. Uninstall and reinstall the app, or delete app data:

```bash
adb shell pm clear com.mnlizard.promsell
```

### Hot reload not picking up changes

Some changes (new providers, generated code, native plugins) require a **full restart** (`R`), not hot reload (`r`).

### UI overflows on compact screens

Run the app on a small emulator or device and check the Sale, Product form, and payment sheet flows. Compact panels should use scrollable sheets or compact empty states instead of fixed-height content.

```bash
flutter analyze lib test
flutter test
```

If the overflow appears after adding text, verify that the string is localized and fits in Thai and English at larger font scale.

### `flutter analyze` reports unrelated errors

Errors in **other workspace projects** (e.g. `busit_flutter_project`) are not part of Promsell — they can be ignored when scoping analysis to this repo:

```bash
flutter analyze lib test
```

---

## Need help?

- **GitHub Issues** — https://github.com/teeprakorn1/promsell-pos-ce/issues
- **Discussions** — https://github.com/teeprakorn1/promsell-pos-ce/discussions

---

<sub>Promsell POS Community Edition · © 2026 MN Lizard Team · AGPL-3.0</sub>
