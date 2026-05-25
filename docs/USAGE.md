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

1. Tap any product card to add to cart
2. Adjust quantity with `+` / `-` buttons or tap the number
3. Tap **Checkout** → payment sheet opens
4. Select **Cash / Transfer / Card**
5. For cash, enter amount received — change is calculated automatically
6. Optionally add a sale note
7. Tap **Confirm** — sale is saved to history

### Products tab

- Tap **+** in app bar → opens product form
- Required fields: name, price (quantity defaults to 0)
- Tap any product row → opens 3-dot menu → **Edit** / **Delete**
- Search field filters by name in real time

### History tab

- Lists all sales, newest first
- Tap any row → expands per-item breakdown
- Long press → (future) delete or refund

### Report tab

- Tap **Date range** in app bar to pick custom range (default: last 30 days)
- Shows three cards: revenue, payment method breakdown, top 5 products

### Settings tab

See [Settings](#settings) below.

---

## Settings

All settings persist via `SharedPreferences` and apply **immediately** (no app restart needed).

| Setting | Description |
|---------|-------------|
| **Language** | Thai (`th`) or English (`en`) — live reload |
| **Theme** | Light, Dark, or System (follows OS) — live reload |
| **Shop name** | Displayed on receipts |
| **Shop address** | Displayed on receipts |
| **Shop phone** | Displayed on receipts |
| **Currency symbol** | Default `฿` — used in money formatting |
| **Date format** | Default `dd/MM/yyyy` — `intl` format pattern |
| **Receipt note** | Optional footer text on receipts |
| **Show shop info on receipt** | Toggle on/off |

To save changes, tap the **Save** button at the bottom of the page.

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
├── app_database.dart       # Database class with tables, DAOs
├── app_database.g.dart     # GENERATED — do not edit
└── tables/
    ├── products_table.dart
    ├── sales_table.dart
    └── sale_items_table.dart
```

### Regenerating after schema change

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch mode for continuous regeneration during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Schema migrations

When you change a table, bump `schemaVersion` in `app_database.dart` and add a migration step. See the [Drift migration docs](https://drift.simonbinder.eu/Migrations/) for details.

---

## Architecture overview

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
│  Drift / SharedPreferences                      │
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

<sub>Promsell POS Community Edition · v0.1.0 · © 2026 MN Lizard Team · AGPL-3.0</sub>
