# WS-DOC-ARCH — Architecture / ADR honesty

**Parent:** [OVERVIEW.md](./OVERVIEW.md) · **Backlog:** [BACKLOG.md](./BACKLOG.md)  
**IDs:** DOC-A.1 … DOC-A.3  
**Status:** todo (wave DOC-3)  
**ADR-content owner:** [AH-0.3](../ARCH-HARDEN-1.0/BACKLOG.md) — this WS is the implement slice. Do not mark AH-0.3 done until the ADR PR merges.

---

## Goal

Architecture docs describe **what the code does**, then what the fence *will* do. No product code.

---

## DOC-A.3 — Purity is a target

**Files:** `docs/ARCHITECTURE.md`, `CODEBASE.md`, `docs/architecture/c4-diagrams.md`

**Replace**
- `Pure Dart models (no Flutter imports)` → `Domain models should be Flutter-free; settings still import Flutter (AH-1.4).`
- `Domain has zero external dependencies.` → `Rule: presentation → domain ← data. Not CI-enforced (AH-1.1). Known leaks: settings Locale/ThemeMode; CloseDay → sale data; product image/submit.`

**Do not** add `tool/check_domain_fence` or say the fence exists.

---

## DOC-A.1 — WatchReport / Void / sync (AH-0.3)

**Files:** `docs/architecture/technical-deep-dive.md`, `c4-diagrams.md`, `sequence-void.puml`, AH BACKLOG AH-0.3 row

**Replace**
- `WatchReport → HistoryRepository` → `WatchReport → ReportRepository` (`watch_report.dart`).
- `CheckoutBloc → CreateSale, VoidSale` → `CheckoutBloc → CreateSale` only; `HistoryBloc → VoidSale`.
- AH-0.3 description: WatchReport→**ReportRepository** (not SaleRepository).

**ADR-015 / DATABASE “sync-ready”**
- Columns = metadata (`updatedAt`, `deletedAt`, `version`, `deviceId`).
- **Not** a sync engine. CE is single-device; no outbox, no multi-master.
- Soft-delete: columns exist; product UI still uses `isActive` in places.

Broader marketing sweep: **V092-A.4**.

---

## DOC-A.2 — ADRs this round

Append thin Context / Decision / Consequences in `docs/architecture/adr/index.md`. Bump “001–026” headers.

| ID | Draft now | Defer |
|----|-----------|--------|
| **ADR-027** | Payable pipeline (item → cart → promo → SC → VAT). SSOT: `SalePayableCalculator` / `payableTotals`. Supersedes ADR-011 scope. | — |
| **ADR-028** | Sync **metadata** non-goals. Amends ADR-015. | — |
| — | SQLCipher, PIN, multi-tender, Money-on-disk, domain fence | After those ship or AH-1.1 lands. Do not mark Accepted early. |

---

## Do not

- Claim “Clean Architecture complete.”
- Implement AH-1.1.
- Touch `lib/` except citing evidence.
- Flip AH-2.1 here without DOC-N.8 (same evidence, one PR preferred).

---

## Verify

```bash
rg -n "no Flutter imports|zero external dependencies" docs/ARCHITECTURE.md CODEBASE.md docs/architecture
rg -n "WatchReport ──→ HistoryRepository|CheckoutBloc ──→ CreateSale, VoidSale" docs/architecture
rg -n "all sync-ready|sync-ready without future" docs/DATABASE.md docs/architecture/adr
test -f tool/check_domain_fence.dart; echo $?   # expect 1
```

---

<sub>Promsell POS CE · DOC-SSOT · WS-ARCH · 2026-08-13</sub>
