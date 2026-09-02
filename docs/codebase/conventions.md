# Conventions — Promsell POS CE (v0.9.4)

State management, settings persistence, localization, dependency injection, and code generation conventions.

> **Main reference:** [`CODEBASE.md`](../../CODEBASE.md) — system overview, architecture, links

---

## State management patterns

| Pattern | When used |
|---------|-----------|
| **BLoC** (event → state) | Complex flows with multiple event types — sale, product, history |
| **Cubit** (method → state) | Simpler state without event classes — settings, report, `ProductFormCubit` (typed draft state) |
| **`SettingsStateView`** (shared wrapper) | All Settings pages wrap their body in this `StatelessWidget` to render consistent loading / failure / retry states from `SettingsState.status`. The page passes `state`, `onRetry`, and a `builder(Settings)` that renders the loaded content. |

All state classes extend `Equatable` for efficient rebuilds.

### Rebuild performance rules

| Rule | Details |
|------|--------|
| **`context.select` over `context.watch`** | When a widget needs only 1–2 fields from a Cubit/Bloc, use `context.select((Cubit c) => c.state.field)` to rebuild only when that field changes. `context.watch<Cubit>()` rebuilds on **any** state change. |
| **No state mutation in `BlocBuilder.builder`** | Never assign to instance fields inside `builder`. Compute local variables instead; defer side-effects to `addPostFrameCallback` or `BlocListener`. |
| **Single `setState` per action** | Merge all state changes into one `setState(() { ... })` call. Calling `setState` twice in the same callback causes a double rebuild. |
| **Long-lived streams** | Create `StreamController` in `initState`, cancel in `dispose`. Never create `Stream.periodic(...)` inline in `build()` — it leaks on every rebuild. |
| **Catch specific exceptions** | Use `on ProviderNotFoundException` (or the exact type) instead of `catch (_)` to avoid hiding real errors. |

> Deep-dive: [`docs/architecture/technical-deep-dive.md`](../architecture/technical-deep-dive.md)

---

## Settings persistence

`SettingsRepositoryImpl` reads and writes a `Settings` aggregate root via `SettingsLocalDatasource`. `SettingsMapper` handles serialization to/from `Map<String,String>`.

### Architecture

```
SettingsCubit
  └── SettingsPersistenceService (debounce + save)
        └── SettingsRepositoryImpl
              ├── SettingsMapper (Settings ↔ Map<String,String>)
              └── SettingsLocalDatasource (Drift key-value store)
```

### `Settings` aggregate root — 14 typed group entities

| Group | Entity | Key fields |
|-------|--------|-----------|
| Shop | `ShopInfo` | name, address, phone |
| Receipt | `ReceiptConfig` | receiptSize, receiptPreviewStyle, receiptNote, showShopInfo, autoPrintPrompt, showPreSalePreview, showPostSalePreview |
| Tax | `TaxConfig` | vatRate, vatMode |
| Discount | `DiscountConfig` | enableItemDiscount, enableCartDiscount, maxDiscountPercent, maxDiscountAmount, defaultDiscountType, discountPresets, activeDiscountPresetId |
| Stock | `StockConfig` | allowOversell, lowStockThreshold |
| Image | `ImageConfig` | maxWidth, quality |
| Barcode | `BarcodeConfig` | scanEnabled, beepOnScan (haptic), autoGeneratePrefix (default `200`, EAN-13 numeric), enabledFormats (List<String>, default = all 12), autoOpenManualDelay (int seconds, 0=disabled) |
| Payment | `PaymentConfig` | currency, promptpayId, billerId, promptPayTimeout, promptPaySoundEnabled, defaultQrType, autoConfirmAfterSlip, qrOverlayIcon |
| Device | `DeviceConfig` | deviceId, devicePrefix |
| UI | `UiConfig` | locale, themeMode, dateFormat, cartCompactMode, ultraCompactMode, accessibilityMode |
| Daily Close | `DailyCloseConfig` | dailyCloseLock, lastClosedDate |
| Backup | `BackupConfig` | reminderDays, lastBackupAt, encryptionEnabled |
| Draft | `DraftConfig` | maxDrafts |
| Business | `BusinessConfig` | businessType (retail/restaurant), serviceChargeRate (v0.8.9+) |

### Flat getters + flat `copyWith`

`Settings` exposes flat convenience getters (e.g. `shopName`, `vatRate`, `promptpayId`) and a flat `copyWith` method mirroring the former `AppSettings` facade interface. This allows presentation-layer consumers to access fields directly without navigating sub-entities. Use `copyWithEntities()` for sub-entity-level updates.

### Legacy migration

`SettingsMapper` normalizes legacy integer `themeMode` values (`0`→`light`, `1`→`dark`, `2`→`system`) and falls back invalid values to `system`.

---

## Database and money persistence

- `AppDatabase` is schema **v32** with 32 nullable `*_satang` columns across 10 money tables.
- Domain `Money` uses integer satang. Writers dual-write exact satang plus legacy REAL baht for rollback compatibility.
- Data readers prefer satang and fall back to REAL baht for pre-v32 rows via `NullableMoneySatangConverter` and `moneyFromSatangOrBaht`.
- Percentage rates and percentage-valued discounts stay REAL; conditional `AMOUNT` values also receive satang storage.
- A table change requires `dart run build_runner build`, an idempotent migration, and a file-backed legacy-fixture test.

---

## Localization system

- **Template:** `lib/l10n/app_th.arb` (Thai — source of truth)
- **Translation:** `lib/l10n/app_en.arb` (English)
- **Config:** `l10n.yaml` (`template-arb-file: app_th.arb`)
- **Generated:** `lib/l10n/app_localizations.dart` — do not edit
- **Access:** `context.l10n.keyName` via `l10n_extension.dart`

To regenerate after adding keys:

```bash
flutter gen-l10n
```

---

## Dependency injection

`lib/core/di/injection_container.dart` — `configureDependencies()` generated by `injectable`.

Annotations on implementation classes drive registration:

| Scope | Annotation | Examples |
|-------|-----------|----------|
| Lazy singleton | `@LazySingleton(as: Abc)` | datasources, repositories, services |
| Lazy singleton | `@lazySingleton` | `ProductBloc`, `CategoryBloc`, `CartBloc`, `DraftBloc`, `CheckoutBloc`, `SettingsCubit`, `ReportCubit`, … |
| Factory (per route) | `@injectable` | `ProductFormCubit` (and other form-scoped cubits) |
| Factory | `@injectable` | use cases, `Ean13Generator` |
| Module | `@module` | `DatabaseModule` provides `AppDatabase` |
| Skip param | `@ignoreParam` | `BackupRestoreService` optional params (`candidateValidator`, `skipSqlCipherHeaderCheck`) — prevents injectable from trying to resolve them from the GetIt container |

Access anywhere via `sl<T>()`.

After adding/changing annotations, run:
```bash
dart run build_runner build
```

> Deep-dive: [`docs/architecture/technical-deep-dive.md`](../architecture/technical-deep-dive.md)

---

## UI conventions (v0.9.4)

### Icon system

- **`tabler_icons_plus` (^3.44.0)** is the app-wide icon library — use `TablerIcons.*` for all feature icons
- Avoid Material `Icons.*` in presentation code unless a Tabler equivalent is unavailable (rare)
- Used in 103+ files across Settings, onboarding, report, product, history, and home features

### Theme tokens

- **`AppColors` / `AppTheme`** (`lib/core/theme/`) — global palette and Material 3 `ThemeData`
- **`SettingsThemeExtension`** (`lib/features/settings/presentation/theme/`) — Settings + onboarding surface tokens: `cardRadius`, `actionCardRadius`, `actionCardMinHeight`, `statusBadgeRadius`, `heroProgressHeight` (active in Settings); `heroGradientStart/End`, `heroTextPrimary/Secondary`, `accentStripeWidth`, `pillRadius` (retained for onboarding)
- All hardcoded `Color(0xFF...)` outside `lib/core/theme/` is forbidden

### UI patterns (Settings vs onboarding)

Settings uses a **POS-native flat paper-card** language (shared with Sale/Product pages); onboarding uses a **gradient-hero + accent-stripe** language.

| Pattern | Where | Widget / token |
|---------|-------|----------------|
| Thin border + flat card | Settings | `SettingsSectionCard`, `SettingsActionCard` (0.5dp border; 1.5px teal when `emphasized`) |
| Plain section header | Settings | `SettingsSectionHeader` (`titleMedium/w700`, no pill) |
| Teal app bar + search strip | Settings | `SettingsRootPage` (matches `SaleAppBar`); search pushes `SettingsSearchPage` |
| White hero card + teal progress bar | Settings | `SettingsRootPage` hero (`heroProgressHeight`) |
| Compact status badge | Settings | `SettingsStatusChip` (`statusBadgeRadius` 20) |
| Action card grid (2-col wide, 1-col phone) | Settings | `SettingsActionCard` (64dp min height, 12dp radius, 32dp icon well) |
| Accent stripe (4px left) | Onboarding | `OnboardingSection`, `OnboardingDoneSection` (`accentStripeWidth`) |
| Pill header | Onboarding | Onboarding step labels (`pillRadius`) |
| Tinted icon well (40–44px) | Onboarding | `OnboardingSection` |
| Gradient hero (primary → primaryDark) | Onboarding | `OnboardingHeroSection`, `OnboardingDoneSection` (`heroGradientStart/End`) |

### Toast / snackbar

- Use `AppSnackBar.info/success/error/warning/withAction` — never raw `ScaffoldMessenger.showSnackBar`
- v0.9.4: `AppSnackBar` wraps `Text` in `Flexible` + `ConstrainedBox(maxWidth: 320)` + `maxLines: 2` to prevent `RenderFlex` overflow

> See [ADR-037](../architecture/adr/index.md#adr-037-command-dashboard-visual-language) for the full design decision.

---

## Code generation

Two generators must be run after changes:

| Generator | Trigger | Command |
|-----------|---------|---------|
| Drift | Schema change | `dart run build_runner build` |
| Injectable | DI annotation change | `dart run build_runner build` |
| Flutter l10n | New ARB key | `flutter gen-l10n` |

> **Note:** Generated files (`*.g.dart`, `*.config.dart`) are **not committed** to git. Run `dart run build_runner build` after `flutter pub get` to generate them locally. See `.gitignore` and `.gitattributes` for details.

---

<sub>Promsell POS CE · v0.9.4 · Conventions</sub>
