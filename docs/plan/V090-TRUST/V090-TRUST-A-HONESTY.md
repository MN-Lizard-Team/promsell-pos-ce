# W-A — Honesty SSOT (P0)

**Parent:** [V090-TRUST-OVERVIEW.md](./V090-TRUST-OVERVIEW.md)  
**Status:** ⬜ Not started  
**Risk if skipped:** Store/trust rejection, merchant confusion on restore/key loss

---

## Problem

`SECURITY.md`, `docs/PRIVACY_POLICY.md`, features/roadmap, and Fastlane copy disagree on:

- In-app **backup restore** (same-device)
- Schema version (**v26 / v27 / v28**)
- Secondary overclaims (loyalty, Unreleased vs tagged 0.9.0)

Code truth anchors:

- Schema: `schemaVersion => 28` in `lib/core/database/app_database.dart`
- Restore services under `lib/features/settings/data/services/backup_restore_service.dart` (verify behavior before rewriting claims)

---

## Tasks

| ID | Task | Target files | Done |
|----|------|--------------|------|
| **A1** | Write one master paragraph SSOT: same-device restore (yes/no per code) · cross-device unsupported · key loss = data loss | Master note → propagate | ⬜ |
| **A2** | Align `SECURITY.md` bullets with capability table | `SECURITY.md` | ⬜ |
| **A3** | Align privacy policy with restore + encryption reality | `docs/PRIVACY_POLICY.md` | ⬜ |
| **A4** | Fix features / roadmap R22 / Fastlane metadata if wrong | `docs/readme/features.md`, `docs/readme/roadmap.md`, `fastlane/metadata/**` | ⬜ |
| **A5** | Schema string SSOT = **v28** + `sale_payments` / table count | `docs/DATABASE.md`, `docs/database/*`, README if needed | ⬜ |
| **A6** | Reduce overclaim: loyalty → CRM; receipt ≠ tax invoice; Unreleased ≠ 0.9.0 | roadmap / CHANGELOG hygiene | ⬜ |

---

## Exit criteria

- [ ] Repo-wide search for restore / schema version shows **no contradictions**
- [ ] Store-bound privacy URL points at corrected policy
- [ ] SECURITY table and narrative match implemented backup restore

---

## Notes

- Docs-only workstream — low implementation risk, high compliance impact.
- Do **not** invent Phase 2b key recovery claims.
