# Workstream A — Play 1.0 Production Cut

**Parent:** [POST-090-OVERVIEW.md](./POST-090-OVERVIEW.md)  
**Backlog IDs:** A0–A6  
**Sources:** `docs/STORE_SUBMISSION.md`, `docs/DEPLOY.md`, `docs/plan/COMPLETE/V090-TRUST/V090-TRUST-E-RELEASE.md`, `.github/workflows/release-aab.yml`

---

## Goal

พา CE จาก **GitHub trust-cut (0.9.0)** ไปสู่ **Play distribution ที่ operator-owned** โดยไม่ claim production จนกว่า keystore + Data safety + signed AAB + post-smoke ครบ

---

## In-repo vs human (A0 freeze)

| Item | Owner | In-repo today | Human Console |
|------|-------|---------------|---------------|
| Version `pubspec` / CHANGELOG | Maintainer | Yes | — |
| EN/TH store listing metadata | Maintainer | `fastlane/metadata/` | Confirm in Console |
| Phone screenshots / feature graphic | Maintainer | Staged | Upload if needed |
| Privacy policy URL | Maintainer | `docs/PRIVACY_POLICY.md` | Stable host preferred |
| Production keystore | **Operator** | Throwaway only (gitignored) | Dual custody |
| Play signing secrets for CI | **Operator** | Optional secrets | Set `ANDROID_KEYSTORE_*` |
| Data safety form | **Operator** | Guidance in docs | **Must file** |
| Content rating / pricing / countries | **Operator** | — | Must |
| AAB upload | **Operator** | CI artifact when secrets set | Must |
| Tablet 7"/10" assets | Optional | Empty slots | If claiming tablet |

---

## Checklist

### A0 — Checklist freeze
- [x] Copy open Console items from `STORE_SUBMISSION.md` into release day checklist (**§A0 2026-07-20**)  
- [x] Mark Must (A1–A5) vs Should/Could (tablet shots, graphic polish)  
- [x] Contact email confirmed in checklist (`mnlizard.official@gmail.com`)

### A1 — Production keystore
- [x] Runbook dual custody in `docs/STORE_SUBMISSION.md` §Manual steps (2026-07-20)  
- [ ] Generate **production** keystore (not `promsell-throwaway-release.jks`) — **operator action**  
- [ ] Dual custody: primary + sealed backup location — **operator action**  
- [x] Document rotation / loss policy (loss = cannot update app)  
- [ ] Wire local `android/app/keystore.properties` (gitignored) — **operator**  
- [ ] CI secrets inventory listed offline (never commit) — **operator**

### A2 — Data safety & policy
- [x] Data safety draft answers in `docs/STORE_SUBMISSION.md` §A2 (2026-07-20)  
- [x] Align with `docs/PRIVACY_POLICY.md` + in-app honesty (SSOT)  
- [ ] Content rating questionnaire — **operator Console**  
- [ ] Free + Thailand (and others as needed) — **operator**  
- [x] Receipt **not tax invoice** remains in listing (metadata staged)

### A3 — Signed AAB fail-closed
- [x] Tags `v*`: signed AAB required (fail if secrets missing) — `release-aab.yml` 2026-07-20  
- [ ] Dry-run on `workflow_dispatch` with prod secrets (operator)  
- [x] Artifact retention noted (e.g. 14d)  
- [x] Document: unsigned tag = failed release  
- [x] `workflow_dispatch` is also fail-closed without `ANDROID_KEYSTORE_*` (no `require_signed_aab` input)

### A4 — Upload
- [ ] Internal testing track first (recommended)  
- [ ] Closed testing if needed  
- [ ] Production release only after A5  
- [ ] Version code monotonic  

### A5 — Post-submit smoke (prod)
- [ ] Install from Play track or sideload **prod** AAB  
- [ ] Cold start SQLCipher  
- [ ] Cash sale + draft + daily close (minimum)  
- [ ] Backup export PIN path  
- [ ] Record in smoke doc  

### A6 — Could polish
- [ ] Tablet screenshots  
- [ ] Feature graphic refresh  
- [ ] Stable privacy URL (not only GitHub blob)  

---

## Go / No-Go

| Gate | Go | No-Go |
|------|----|-------|
| Internal track | A1–A4 | Missing keystore or Data safety lie |
| Production | A1–A5 + B2 Must | Throwaway key; soft money trust red |
| Marketing “on Play” | Production live | Internal-only |

---

## Risks

| Risk | Mitigation |
|------|------------|
| Secrets-optional tag “passes” without AAB | A3 force signed |
| Wrong keystore forever | Dual custody + written runbook |
| Data safety mismatch local PII | A2 + privacy SSOT |
| Dev debug smoke ≠ prod | A5 prod build only |

---

## Exit criteria

- Operator can reproduce signed AAB without maintainer tribal knowledge  
- `STORE_SUBMISSION.md` open production items checked or explicitly deferred  
- No public claim of Play production until A5 Pass  

---

<sub>WS-A · PLAN ONLY</sub>
