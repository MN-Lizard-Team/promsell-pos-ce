# W-D — God-file Extract Map (P0 sale → P1 product)

**Parent:** [V090-TRUST-OVERVIEW.md](./V090-TRUST-OVERVIEW.md)  
**Status:** 🟢 D1–D3 + **G1** (product form coordinators) + **G2** (barcode session)  
**Risk if skipped:** Maintainability only (product still runs) — **risk if done wrong:** money breakage

---

## Rules of engagement (repo conventions)

| Rule | Detail |
|------|--------|
| Domain/money | Pure static services (`SalePayableCalculator` style) — no DI required |
| Infra | `@lazySingleton` / `@LazySingleton(as:)` + `dart run build_runner build` |
| UI | Public widgets + sibling folders (ADR-024) — not `part` as primary strategy |
| Transactions | **Never** split outer `_db.transaction` for insert/void |
| Docs | Update `docs/codebase/file-dependency-map.md` when DS/BLoC move |
| Gate per PR | `flutter analyze` + trust suite / touched tests |

**Non-goals:** vanity splits of `app_theme.dart`, `app_database.dart` migrations, l10n, `*.g.dart`.

---

## D0 — Safety net

- [x] Trust suite from W-C green on current branch (DS + integrity + cart + app_lock + restore)
- [ ] Note baseline commit SHA in PR description when extracts start

---

## D1 — Sale data P0 (highest priority)

**Target:** `lib/features/sale/data/datasources/sale_local_datasource.dart` (~827 LOC)

**Keep:** abstract `SaleLocalDatasource` public API + `SaleRepositoryImpl` 1:1 signatures.

| PR | Content | New files (approx) | Must stay green |
|----|---------|--------------------|-----------------|
| **D1.1** ✅ | Helpers only | `sale_write_helpers.dart` and/or vat + customer delta modules | DS + `sale_integrity_test` |
| **D1.2** ✅ | Query / watch + hydrate | `sale_query_*`; facade delegates | query/watch + soft-delete tests |
| **D1.3** ✅ | Void writer | `sale_void_writer.dart` | integrity void + `void_sale_test` |
| **D1.4** ✅ | Insert pipeline writer | `sale_insert_writer.dart` — **same transaction** | insert, multi-tender, customer aggregation, integrity create |

### Public API to preserve

```dart
Future<Sale> insertSaleWithItems({ ... });
Future<List<Sale>> querySales({DateTime? from, DateTime? to});
Future<Sale?> querySaleById(String id);
Stream<List<Sale>> watchRecentSales({int limit});
Stream<List<Sale>> watchSales({DateTime? from, DateTime? to});
Future<void> voidSale(String saleId, {String? reason});
```

### Insert seams (do not reorder casually)

1. Payable totals (`SalePayableCalculator`)  
2. Multi-tender / legacy + mismatch checks  
3. Promo assert  
4. Tx: receipt # retry  
5. Sale header + payments  
6. Oversell / product load / stock pre-check  
7. Line snapshot + line VAT allocate  
8. Atomic stock + inventory log  
9. Customer spent delta  
10. Post-tx hydrate  

---

## D2 — Cart / Checkout presentation P0

| PR | Target | Approach | Tests |
|----|--------|----------|-------|
| **D2.1** ✅ | `cart_bloc` mixins: line / discount / barcode / promo / meta handlers + `CartDiscountPolicy` | Sibling handlers: lines · discount · barcode · promo — **same events** | `cart_bloc_test*` |
| **D2.2** ✅ | `checkout_body` — status listener, shell nav, restaurant section, tender helpers; public API `CheckoutBody` unchanged |

Do **not** change `CheckoutBloc` public events unless required and tested.

---

## D3 — Product form P1 (after sale stable)

| PR | Target | Approach | Tests |
|----|--------|----------|-------|
| **D3.1** ✅ | Price cluster → `product_form_price_section.dart` | Follow existing `product_form_*` extract pattern | `product_form_page_test` |
| **D3.2** ✅ | Stock cluster → `product_form_stock_section.dart` | section + threshold sheet | same |
| **D3.3** ✅ | Visibility strip → `product_form_visibility_strip.dart`; tab shell remains in view | view keeps TabController + `revealFirstInvalidTab` | same |
| **D3.4 / G1** ✅ | page commands | draft / lifecycle / stock actions (sibling coordinators) | cubit + page tests (49/49) |
| **D3.5** | optional `product_bloc` import/batch split | later | `product_bloc_test` |

### G1 — `product_form_page` residual extract (post-D3 sections)

| PR | Content | New files | Gate |
|----|---------|-----------|------|
| **G1.1** ✅ | Draft autosave / restore (create-only rules) | `product_form_draft_coordinator.dart` | draft group + full page suite |
| **G1.2** ✅ | Submit / delete / unsaved pop | `product_form_lifecycle.dart` | submit/edit/delete/unsaved |
| **G1.3** ✅ | Adjust stock + trackStock toggle | `product_form_stock_actions.dart` | stock sync tests |
| **G1.4** ✅ | Media (image + generate barcode) | `product_form_media_actions.dart` | full page suite |

**Page shell after G1:** ~516 LOC orchestration (controllers + build + menu).  
Further &lt;400 optional only if hot-path pain.

### G2 — `barcode_scanner_dialog` (P1)

| PR | Content | New files | Gate |
|----|---------|-----------|------|
| **G2.1** ✅ | Session: permission-adjacent detect, gallery, continuous reset, not-found CTA | `barcode_scanner_session.dart` | `flutter analyze` + `test/core/widgets/barcode/*` |

Dialog shell ~436 LOC (UI chrome + overlay); session ~256 LOC.
### Do not change (domain)

- `SubmitProductUseCase` money/cost rules  
- `ProductFormCubit.resolveStock` / trackStock restore  
- Draft create-only rules  
- Validators + tab order Product→Price→Stock→Codes  
- Pricing math in `product_pricing_insights.dart`

---

## Classification reminder (post G1)

| File | Label |
|------|--------|
| `sale_local_datasource.dart` | ✅ facade ~154 — **not god** |
| `cart_bloc.dart` | ✅ ~108 + mixins — **not god** |
| `checkout_body.dart` | ⚠️ ~538 + helpers — borderline |
| `product_form_page.dart` | ✅ ~516 + coordinators — **true god cleared** |
| `product_form_view.dart` | ~494 + sections — not god |
| `barcode_scanner_dialog.dart` | ✅ ~436 + session — **G2 done** (borderline cleared) |
| `product_bloc.dart` | soft-god |
| `sale_page.dart` | soft-god orchestration |
| `app_theme.dart`, `app_database.dart`, `draft_bloc.dart` | large cohesive — leave |

---

## Exit criteria

- [x] D1 complete (facade + query/void/insert/helpers/side-effects)
- [x] D2.1 + D2.2 complete
- [x] D3 sections + G1 page coordinators (+ media G1.4)
- [x] G2 barcode scanner session
- [x] `product_form_page_test` + barcode widget tests green after G1/G2
- [ ] No public Sale DS API break without coordinated repo/test update
