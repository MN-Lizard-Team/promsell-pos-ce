# E2E Test Infrastructure — Status (honest)

**Last updated:** 2026-08-14  
**Verdict:** Scaffold is in-tree. **Main CI does not run** device E2E (format + analyze only). **Trust blocks** emulator `--flavor dev` on tags / money-path PRs. That is **not** “E2E ready” or 1.0 Go. Money integrity is gated by **host** trust suite + manual smoke. Map: [`CI.md`](./CI.md).

---

## Status summary

| Area | State |
|------|--------|
| Helpers + robot pattern files | Present |
| Scenario files (sale, draft, product, promo, restaurant, report, screenshot) | Present (structure complete) |
| `flutter analyze integration_test/` | Expected clean (re-check after large refactors) |
| Runtime on `ci.yml` | **Not run** — format + analyze `integration_test/` only |
| Runtime on local desktop without Android/iOS device | **No supported devices** |
| Fail-closed money path | Host `test/integration/` + `release-trust.yml` (V092-D.1 VAT+void+close, V092-D.4 void after day-close). Device job on trust is blocking but **dev** flavor / scaffold |
| Manual device evidence | `docs/testing/RELEASE_0.9_SMOKE.md` · `docs/testing/RELEASE_0.9.2_SMOKE.md` |
| TestApp flake (V092-D.5) | `pumpAndSettle` dropped in `restartApp`; `TestKeys` constants added for 5 core cases. EN-string finders still in older tests — migrate when touching. |

**Do not claim:** “30 tests compiling, ready for runtime validation” as if CI guarantees green E2E.

---

## What was delivered (scaffold)

1. `integration_test/helpers/` — `test_app.dart`, `test_fixtures.dart`, `test_utils.dart`  
2. `integration_test/robot_pattern/` — sale / checkout / product / restaurant robots  
3. Journey test files + `all_tests.dart`  
4. Main CI: format + analyze `integration_test/` only. Trust: blocking `all_tests.dart --flavor dev`  
5. Docs: this file, `E2E_TEST_GUIDE.md`, `integration_test/README.md`  

---

## Historical compile issues (mostly addressed in tree)

Older blockers (Drift `Value` on ids, missing drift import, `Finder.or`, `Money.format`) were documented when the scaffold landed. **Re-verify with analyze** after schema changes; do not assume forever-broken or forever-ready.

If analyze fails again, fix before spending time on emulator flakes.

---

## Known runtime / reliability risks (open)

| Risk | Detail |
|------|--------|
| DI / DB bootstrap | `TestApp` registers test DB then may re-enter app `configureDependencies()` / `runPromsellApp` — risk of double init |
| Money UI asserts | Prefer `CurrencyFormatter` / displayed baht text — not `Money.toString()` (`Money(x.xx)`) |
| Selectors | EN text / icon chains; few stable `Key`s on cart/checkout/pay |
| CI device | No emulator on `ci.yml`. Trust emulator can flake and **block** tags |
| Locale | App is TH/EN; robots often EN-oriented |

Tracked for fix order: `docs/plan/UN-COMPLETE/POST-090-MANAGE/WS-B-QA-HARDENING.md` **B4**.

---

## Path to fail-closed E2E (not done)

1. Fix TestApp DI + currency asserts + Keys  
2. Emulator (or Firebase Test Lab) job  
3. Hard-gate **3–5** smokes after 3 consecutive greens  
4. Keep full suite soft until stable  
5. Align marketing/docs only after step 3  

---

## Related SSOT

| Doc | Role |
|-----|------|
| `docs/codebase/testing.md` | Pyramid + honest E2E status |
| `docs/testing/E2E_TEST_GUIDE.md` | How to run + prerequisites |
| `docs/testing/RELEASE_0.9_SMOKE.md` | Device smoke evidence (0.9) |
| `docs/testing/RELEASE_1.0_SMOKE.md` | 1.0 smoke plan (when present) |
| `.github/workflows/release-trust.yml` | Fail-closed money host suite |
| `docs/plan/UN-COMPLETE/POST-090-MANAGE/WS-B-QA-HARDENING.md` | QA workstream |

---

<sub>Promsell POS CE · E2E status · honesty over optimism</sub>
