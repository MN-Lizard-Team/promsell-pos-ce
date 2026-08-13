# WS-AH-READMODEL — Read ports & presentation discipline

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** AH-3.1 … AH-3.4, AH-1.5  
**Status:** todo (wave AH-3 — after or slow-parallel with AH-1)  
**Priority vs gate:** **Should** for AH-GATE-1 (except as needed for CloseDay/History). Improves maintainability and testability.

---

## Goal

Stop treating **sale data internals** as a shared database API for every feature. Introduce explicit **read models / ports** and shrink service-locator use in money UI.

---

## AH-3.1 — SalesQueryPort (or expanded SaleRepository)

### Consumers today (leaky)

| Consumer | Typical dependency |
|----------|-------------------|
| History | `SaleLocalDatasource` via history repo |
| Report | `SaleRepository` (OK direction; docs once said HistoryRepository) |
| Daily close | sale data (fix in AH-1.2) |
| Home dashboard | `sl<SaleRepository>()` / ad-hoc futures |
| Sale dashboard header | `StreamBuilder` + repo watch |

### Target

```
SalesQueryPort (domain)
  watchHistory / watchReport / periodTotals / tenderBreakdown / recentSales ...
      ↑ implemented by sale data
Home / Report / History / CloseDay / strips
```

Start minimal: methods **actually needed** by CloseDay + History + Home stats — YAGNI on full CQRS.

### Done when

- ≥2 non-sale features depend only on port/repository interfaces  
- Docs (technical-deep-dive DI graph) match  

---

## AH-3.2 — Reduce `sl<>` on money paths

### Problem

Pages/widgets resolve repositories, datasources, `AppDatabase`, PDF/backup services via GetIt — hard to test; bypasses use cases.

### Policy

| Allowed | Discouraged |
|---------|-------------|
| `sl` in `main.dart` / DI modules / composition root | `sl<SaleRepository>` inside random widgets |
| `sl` for true UI services with no domain port yet (temporary) | `sl<AppDatabase>` outside db health use case |
| Constructor / `BlocProvider` injection | Hidden `_resolveX()` fallbacks that mask missing providers |

### Rollout

1. Home stats + open bills strip  
2. Sale dashboard header streams  
3. Checkout/receipt helpers  
4. DbHealth → read-only use case facade  

### Done when

- Code review gate: no new money-widget `sl<XRepository|LocalDatasource>` without justification  

---

## AH-3.3 — CheckoutBloc provider scope

### Problem

Cart/Draft provided at shell; Checkout often only under SalePage → asymmetric + `sl` fallbacks (e.g. saved bills).

### Target (pick one, document)

**A.** Provide CheckoutBloc at shell next to Cart/Draft (all lazySingletons already)  
**B.** Sale-scope only, but **every** sale sub-route gets the same `MultiBlocProvider` helper (no ad-hoc sl)

### Done when

- No ProviderNotFound workarounds for Checkout on sale flows  
- PromptPay abandon / unlock paths still correct  

---

## AH-3.4 — Boot recovery shell (Should)

### Problem

Optimistic boot: DI → settings load → runApp. DB/key/migrate failure → death or half-live UI; no merchant recovery surface.

### Minimum viable recovery

On DB open / migrate / key failure:

1. Full-screen error (not blank splash forever)  
2. Actions: **Retry** · **Export crash log** (if possible) · **Restore backup** (if app partially up) · link to docs honesty (key loss)  
3. Do not pretend catalog works if DB is down  

Full Phase 2b key kit remains POST-090 WS-D — out of scope here.

### Done when

- Documented behavior + either UI implementation or tracked issue with design accepted  
- Prefer implementation before production Go if capacity allows  

---

## Testability notes

- Prefer ctor-injected BLoCs in page tests (`pump_app`) over GetIt register soup  
- Host integration should call **use cases** where policy matters, not only datasources  
- See architecture-testability findings: clock port is a future Could  

---

## Out of scope

- go_router migration (Could later)  
- Multi-cashier session product (AH-C.3)  
- Full ban on GetIt  

---

<sub>WS-AH-READMODEL · ARCH-HARDEN-1.0 · 2026-07-30</sub>
