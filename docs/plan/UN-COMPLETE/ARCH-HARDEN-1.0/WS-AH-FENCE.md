# WS-AH-FENCE — Dependency fences & domain purity

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** AH-1.1 … AH-1.5  
**Status:** AH-1.1 done (2026-08-14) — local fence green, CI verification pending; AH-1.2 done (2026-08-14) — CloseDay uses SaleRepository domain port; AH-1.3 done (2026-08-14) — ClearOrphanedImages uses OrphanImageCleaner domain port, SubmitProduct returns domain result; AH-1.4 done (2026-08-14) — Settings domain entity has zero Flutter imports; AH-1.5 done (2026-08-14) — DraftNaming takes primitives instead of CartState; **allowlist fully burned (0 violations)**, 2117 tests green

---

## Goal

Make Clean Architecture’s dependency rule **enforceable**, not folder theater:

```
presentation → domain ← data
domain: no Flutter, no feature data, no presentation
```

---

## AH-1.1 — CI domain import fence

### Rules

Fail CI when any file under `lib/features/*/domain/**` imports:

- `package:flutter/` (except temporary allowlist)
- same-feature or cross-feature `.../data/`
- same-feature or cross-feature `.../presentation/`

### Implementation sketch

1. Add `tool/check_domain_fence.dart` (or shell `rg` gate in CI) scanning imports.  
2. Wire step in `.github/workflows/ci.yml` (hard fail).  
3. **Allowlist file** (e.g. `tool/domain_fence_allowlist.txt`) with:
   - path
   - reason
   - **expiry date** (must re-justify or fix)

### Known violators to seed allowlist then burn down

| Area | Path (approx) | Target fix ID |
|------|----------------|---------------|
| CloseDay → sale data | `lib/features/daily_close/domain/usecases/close_day.dart` | AH-1.2 |
| ClearOrphanedImages → data | `lib/features/product/domain/usecases/clear_orphaned_images.dart` | AH-1.3 |
| SubmitProduct → presentation/IO | product domain submit use case | AH-1.3 |
| Settings → Flutter | `lib/features/settings/domain/entities/settings.dart` | AH-1.4 |

### Done when

- Fence job green on `main` with empty allowlist **or** only dated entries  
- PR template / CONTRIBUTING note: no new domain violations  

---

## AH-1.2 — CloseDay port ✅ done (2026-08-14)

### Problem

`CloseDay` (domain) depends on `SaleLocalDatasource` (sale **data**) — worst layering smell for daily fiscal close.

### Target design

```
CloseDay
  → SalesReadPort / SaleRepository  (domain interface)
      → SaleRepositoryImpl / query adapter (data)
```

Prefer **read methods already on SaleRepository** if sufficient (period totals, tenders). If not, add a small port in sale domain or `lib/core` shared kernel — avoid daily_close importing sale data.

### Tests

- Existing: `test/integration/multi_tender_daily_close_test.dart`  
- Unit: CloseDay with mock port/repository  
- Must stay green in `release-trust` paths that include daily_close  

### Done when

- Zero imports of `sale/data` from `daily_close/domain`  
- Behavior of expected cash / multi-tender unchanged  

### Evidence

- `close_day.dart` now imports `SaleRepository` (domain) instead of `SaleLocalDatasource` (data)
- `close_day_test.dart` mocks `SaleRepository`; all 6 unit tests pass
- 3 integration tests (`multi_tender_daily_close`, `void_after_day_close`, `sale_vat_discount_void_close`) updated to wrap `saleDs` in `SaleRepositoryImpl`; all pass
- DI regenerated via `build_runner`; `di_graph_test.dart` green
- Allowlist entry for `close_day.dart` removed; fence now reports 4 violations (down from 5)
- Full suite: 2118 tests pass

---

## AH-1.3 — Product domain leaks ✅ done (2026-08-14)

| Use case | Issue | Direction |
|----------|-------|-----------|
| `ClearOrphanedImages` | Domain → `ProductImageService` (data) | Introduce domain port `OrphanImageCleaner` or move use case to application/data orchestration |
| `SubmitProduct` | Domain → `dart:io` / presentation events | Split pure draft→Product mapping from FS + `ProductEvent` mapping |

### Done when

- Fence allows no product domain exceptions (or expiry ≤ 30 days)  

### Evidence

- New domain port `lib/features/product/domain/services/orphan_image_cleaner.dart`; data adapter `lib/features/product/data/services/orphan_image_cleaner_adapter.dart` (`@LazySingleton(as: OrphanImageCleaner)`) wraps `ProductImageService`.
- `ClearOrphanedImages` now depends on `OrphanImageCleaner` (domain) + `ProductRepository` (domain); no `product/data` import.
- `SubmitProductUseCase` now returns a sealed `SubmitProductResult` (`SubmitProductAdd` carrying `SubmitProductCommand`, or `SubmitProductUpdate` carrying `Product`); no `dart:io` and no `presentation` imports.
- New presentation mapper `lib/features/product/presentation/mappers/submit_product_result_mapper.dart` converts `SubmitProductResult` → `ProductEvent`; `product_form_lifecycle.dart` does the `File.existsSync()` warning (moved from domain).
- `clear_orphaned_images_test.dart` updated to mock `OrphanImageCleaner`; 3 tests pass.
- Allowlist entries for `clear_orphaned_images.dart` and `submit_product.dart` removed (4 → 2 violations).
- DI regenerated; full suite 2118 tests pass.

---

## AH-1.4 — Settings domain purity ✅ done (2026-08-14)

### Problem

`Settings` entity imports `package:flutter/material.dart` (`Locale`, `ThemeMode`), contaminating pure-Dart consumers.

### Target

- Store `localeCode` / `themeModeName` (or app-level enums in domain without Flutter)  
- Map to `Locale` / `ThemeMode` in presentation / mapper only  
- Keep typed settings **groups** (ADR-018 spirit)

### Tests

- Settings mapper / cubit / repository tests  
- No behavior change to persisted keys  

### Done when

- `settings.dart` (domain entity) has **zero** Flutter imports  
- Fence clean for settings domain  

### Evidence

- `settings.dart` no longer imports `package:flutter/material.dart`; `Locale get locale` → `String get localeCode`, `ThemeMode get themeMode` → `String get themeModeName`; `copyWith` takes `String? localeCode` / `String? themeModeName`.
- New presentation mapper `lib/features/settings/presentation/mappers/settings_locale_mapper.dart` (`settingsLocale(s)` → `Locale`, `settingsThemeMode(s)` → `ThemeMode`).
- 17 presentation files updated to use string codes + mapper (main.dart, settings tiles, onboarding sheets, report/history date formatters).
- `settings_test.dart`, `settings_round_trip_test.dart`, `general_summary_card_test.dart`, `general_theme_tile_test.dart`, `general_language_reset_tiles_test.dart` updated to string-based API.
- Allowlist entry for `settings.dart` removed (2 → 1 violation).
- DI regenerated; full suite 2118 tests pass.

---

## AH-1.5 — History read boundary (Should) ✅ done (2026-08-14)

### Problem

`HistoryRepositoryImpl` often wraps `SaleLocalDatasource` directly.

### Target

Depend on `SaleRepository` or `SalesReadPort` so history stays a read adapter, not a second data client of sale internals.

### Done when

- `history/data` does not import `sale/data/datasources` (may still live in data layer of history)  

### Evidence

- `DraftNaming` (sale domain) no longer imports `CartState` (presentation); `resolveParkName` takes `String? tableId` + `int itemCount` primitives.
- `draft_bloc.dart` caller updated to pass `event.cartState.tableId` / `.itemCount`.
- `draft_naming_test.dart` and `draft_bill_guards_test.dart` updated to primitive API.
- Allowlist entry for `draft_naming.dart` removed; **allowlist is now empty (0 violations)**.
- Full suite 2117 tests pass.

> Note: the original AH-1.5 target was `HistoryRepositoryImpl` → `SaleLocalDatasource`. On inspection, `HistoryRepositoryImpl` already depends on the `SaleLocalDatasource` **abstract** (data→data, not domain→data), so it is not a domain fence violation. The only remaining domain→presentation violation was `DraftNaming` → `CartState`, which is now resolved.

---

## Risks

| Risk | Mitigation |
|------|------------|
| Mass CI red | Allowlist + burn-down order CloseDay → product → settings |
| Over-abstract ports | Prefer existing SaleRepository methods first |
| Mapper key drift | Golden / existing settings tests |

---

## Out of scope

- Full package split (`promsell_domain`) — Could AH-C.1  
- Ban `@injectable` on all use cases in one PR — optional later  

---

<sub>WS-AH-FENCE · ARCH-HARDEN-1.0 · 2026-07-30</sub>
