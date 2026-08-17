# How CI actually works

**Machine SSOT:** `.github/workflows/{ci,release-trust,release-aab,screenshots,stress-test}.yml`  
This page is the **human** map. Other docs should link here instead of restating YAML.

---

## Workflows

| Workflow | When | Device | Gate |
|----------|------|--------|------|
| [`ci.yml`](../../.github/workflows/ci.yml) | push/PR `main` / `develop` | **No** | `flutter analyze`; `flutter test --coverage --exclude-tags stress`; `test/performance/`; format + analyze `integration_test/`; coverage **60% global / 80% sale-logic** via `tool/check_path_coverage.dart`; format `lib/` `test/`; outdated; debug **dev** APK |
| [`release-trust.yml`](../../.github/workflows/release-trust.yml) | `workflow_call` / dispatch / tag `v*` / money-path PRs to `main` | **Yes** (job 2) | Host money-path list **fail-closed** + blocking `flutter test integration_test/all_tests.dart --flavor dev -t lib/main_dev.dart` |
| [`release-aab.yml`](../../.github/workflows/release-aab.yml) | dispatch / tag `v*` | via trust | Calls trust (money + android-smoke), then signed **prod** AAB. Missing `ANDROID_KEYSTORE_*` → **exit 1**. No `require_signed_aab` input |
| [`screenshots.yml`](../../.github/workflows/screenshots.yml) | PR paths on `lib/**` / `integration_test/**` | emulator | Visual only — **not** a money assert |
| [`stress-test.yml`](../../.github/workflows/stress-test.yml) | Monday cron / label `performance` | no | Not a merge gate |

---

## What green means

| Green job | Does **not** mean |
|-----------|-------------------|
| `ci.yml` | Device E2E ran. Main CI only formats/analyzes `integration_test/` |
| `release-trust` android-smoke | “E2E ready” or Play Go. Suite is still scaffold/flake; flavor is **dev** |
| `release-aab.yml` | Play upload. Artifacts stay on GitHub |
| [`RELEASE_1.0_SMOKE.md`](./RELEASE_1.0_SMOKE.md) | **Still No-Go** (2026-07-20). Do not treat a green trust job as 1.0 Pass |

Device E2E honesty tables live with [V092-D.3](../plan/UN-COMPLETE/V092-INTEGRITY/WS-V092-D-QA.md). Coverage policy: 60 / 80 — not `very_good_coverage`. Phase M (schema v32 satang columns) is implemented in v0.9.2; legacy REAL baht retained for rollback.

---

<sub>Promsell POS CE · CI map · 2026-08-17</sub>
