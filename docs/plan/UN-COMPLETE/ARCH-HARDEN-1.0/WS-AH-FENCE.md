# WS-AH-FENCE — Dependency fences & domain purity

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** AH-1.1 … AH-1.5  
**Status:** todo (wave AH-1)

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

## AH-1.2 — CloseDay port

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

---

## AH-1.3 — Product domain leaks

| Use case | Issue | Direction |
|----------|-------|-----------|
| `ClearOrphanedImages` | Domain → `ProductImageService` (data) | Introduce domain port `OrphanImageCleaner` or move use case to application/data orchestration |
| `SubmitProduct` | Domain → `dart:io` / presentation events | Split pure draft→Product mapping from FS + `ProductEvent` mapping |

### Done when

- Fence allows no product domain exceptions (or expiry ≤ 30 days)  

---

## AH-1.4 — Settings domain purity

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

---

## AH-1.5 — History read boundary (Should)

### Problem

`HistoryRepositoryImpl` often wraps `SaleLocalDatasource` directly.

### Target

Depend on `SaleRepository` or `SalesReadPort` so history stays a read adapter, not a second data client of sale internals.

### Done when

- `history/data` does not import `sale/data/datasources` (may still live in data layer of history)  

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
