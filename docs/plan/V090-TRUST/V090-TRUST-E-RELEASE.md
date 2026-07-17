# W-E — Release Path (P0 partial / P1 store)

**Parent:** [V090-TRUST-OVERVIEW.md](./V090-TRUST-OVERVIEW.md)  
**Status:** 🟢 E1–E5 path closed for CE trust cut — E4 CI **implemented secrets-optional** (signed AAB when secrets present)  
**Risk if skipped:** Failed first signed build; store delay; merchant data-loss support load

---

## Problem

- Signing doc paths disagree (`key.properties` vs `android/app/keystore.properties`)
- No CI signed prod AAB/IPA; Fastlane metadata only
- Merchant backup discipline under-documented for key-loss world

Gradle fail-closed for Release without keystore is correct — keep it.

---

## Tasks

| ID | Task | Notes | Done |
|----|------|-------|------|
| **E1** | Align signing docs to `android/app/keystore.properties` + fail-closed Gradle | `docs/DEPLOY.md`, `docs/STORE_SUBMISSION.md`, `android/app/build.gradle.kts` | ✅ |
| **E2** | Dry-run signed AAB prod flavor (local/manual) | **Pass 2026-07-17:** throwaway JKS + `keystore.properties` (gitignored) → `app-prod-release.aab` 91.5MB | ✅ |
| **E3** | Merchant backup runbook (onboarding / USAGE) | `docs/USAGE.md` | ✅ |
| **E4** | CI release job: analyze + trust suite + appbundle artifact | **✅ 2026-07-17:** `.github/workflows/release-aab.yml` — always runs `release-trust.yml` (fail-closed); signed prod AAB **if** `ANDROID_KEYSTORE_*` secrets set; otherwise trust-only + skip artifact (secrets-optional). Strict mode: `workflow_dispatch` input `require_signed_aab=true` | ✅ |
| **E5** | Screenshots, feature graphic, stable privacy URL, AGPL in listing | 10 phone shots + 1024×500 + EN/TH metadata · `docs/STORE_SUBMISSION.md` | ✅ staged |

---

## E4 — CI contract (formal)

| Mode | Behavior |
|------|----------|
| **Default** (tag `v*` / dispatch) | Job `money-path` **must** pass. Job `signed-aab` builds AAB only when all four secrets exist; otherwise **skips AAB with notice** (workflow still green). |
| **Strict store cut** | `workflow_dispatch` + `require_signed_aab=true` → **fails** if secrets missing. |
| **Secrets** | `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` — never commit JKS/properties. |
| **Local without GitHub secrets** | E2 throwaway keystore dry-run remains valid evidence for packaging path; production Play key is operator-owned. |

**Why secrets-optional (not hard-fail without secrets):** CE open-source CI cannot hold the production Play signing key. Fail-closed money path is non-negotiable; signed artifact is opt-in via repo secrets or local keystore.

---

## Tag readiness (GitHub)

- [x] W-A exit criteria  
- [x] W-B exit criteria (incl. session lock + FLAG_SECURE)  
- [x] W-C trust suite + smoke + C1–C7  
- [x] W-D D1 + D2.1 + D2.2 (+ D3 form sections)  
- [x] E1–E5 (E4 secrets-optional as above)  

## Store readiness (operator console)

- [x] E2 successful (throwaway keystore dry-run; replace with production keystore for store)  
- [x] E5 assets staged (operator uploads + Data safety in console)  
- [ ] 0 critical security issues open (ongoing)  
- [x] Listing: offline-first, not tax invoice, AGPL source link  
- [ ] Production keystore dual custody + Play upload (human)  

---

## Explicit non-goals for 0.9.0 tag

- Automated Play/App Store upload  
- Multi-region / crash SaaS (optional later opt-in only with privacy update)  
- Committing production signing material to the repo or CI logs  
