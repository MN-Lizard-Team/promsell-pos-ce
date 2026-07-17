const fs = require('fs');
const path = 'CHANGELOG.md';
let t = fs.readFileSync(path, 'utf8');

const start = t.indexOf('## [0.9.0] - 2026-07-15');
if (start < 0) {
  // already updated?
  if (t.includes('## [0.9.0] - 2026-07-17')) {
    console.log('already 2026-07-17');
    process.exit(0);
  }
  console.error('0.9.0 header not found');
  process.exit(1);
}
const end = t.indexOf('\n## [Unreleased]', start);
if (end < 0) {
  console.error('Unreleased after 0.9.0 not found');
  process.exit(1);
}

const newBlock = `## [0.9.0] - 2026-07-17

### Highlights

- **Money-path freeze (hard)** — Confirm freezes cart lines onto CheckoutState.frozenItems; CartPaymentLockChanged blocks live cart mutations during waitingPayment/processing; PromptPay UI prefers freeze over live cart; complete sale no longer falls back to live cart when snapshot is missing.
- **Atomic stock SQL** — Sale deduct / void restore / inventory adjust use stock = stock +/- ? (with floor checks) and re-read balanceAfter for inventory logs (schema **v28** runtime). Concurrent double-sale characterization tests (C4) assert stock conservation and never-negative stock when oversell is off.
- **Same-device backup restore** — BackupRestoreService decrypts optional AES-GCM .enc, rejects plain SQLite, closes DB, keeps .pre_restore_*, replaces promsell_pos.db; Settings Backup UI restore CTA; export fails closed on wal_checkpoint failure. Automated encrypt→restore round-trip suite (C2).
- **Store PIN lock (hardened)** — AppLockService: min PIN **6**, PBKDF2-HMAC-SHA256 (v2) with legacy v1 upgrade on successful unlock, CSPRNG salt, attempt lockout; re-auth for void, backup export/restore, PromptPay ID/biller changes, and turning backup encryption off; session cleared on app background; FLAG_SECURE on PIN dialog and PromptPay page (Android).
- **Release hygiene** — CI coverage floor **50%**; Android release fails without \`android/app/keystore.properties\`; **Release Trust** workflow (fail-closed money path); **Release AAB** workflow (trust always; signed prod AAB when \`ANDROID_KEYSTORE_*\` secrets present); store packaging staged (10 phone screenshots + 1024×500 feature graphic + EN/TH listing honesty).
- **God-file splits (maintainability)** — Sale write path facade + query/void/insert writers; cart handlers as mixins (line/discount/barcode/promo/meta); checkout body listener/nav/restaurant/tender helpers; product form price/stock/visibility sections.

### Fixed

- PromptPay / payment wait could diverge from sale lines when cart mutated mid-wait (UI + bloc soft lock only).
- Stock RMW absolute writes on sale/void/adjust (lost-update risk under concurrent TX).
- Backup export continued after failed WAL checkpoint (inconsistent file risk).
- Release signing silently fell back to debug when keystore missing.
- Docs/SECURITY/privacy/features/roadmap contradicted code on in-app restore and schema version (SSOT: same-device restore yes; cross-device no; schema **v28** / 15 tables).
- App lock used weak single SHA-256 and 4-digit minimum; no lockout / no background session clear / no screen capture flag on sensitive surfaces.
- Main CI soft-failed all integration without a separate fail-closed money-path gate.

### Added

- CartPaymentLockChanged / CartState.paymentLocked / CheckoutState.frozenItems.
- BackupRestoreService, Settings restore flow, EN/TH backup restore + app lock l10n (\`appLockLockedOut\`).
- AppLockService (v2 KDF + lockout), ensureAppUnlocked, AppLockSettingsPage; SecureScreen + MainActivity FLAG_SECURE channel.
- Sale data split: \`sale_write_helpers\`, \`sale_write_side_effects\`, \`sale_query_local_datasource\`, \`sale_void_writer\`, \`sale_insert_writer\` (facade API unchanged).
- CartBloc handler mixins + \`CartDiscountPolicy\`; checkout \`CheckoutStatusListener\`, \`CheckoutShellNav\`, \`CheckoutRestaurantSection\`, \`CheckoutTenderHelpers\`.
- Product form sections: \`product_form_price_section\`, \`product_form_stock_section\`, \`product_form_visibility_strip\`.
- CI: \`.github/workflows/release-trust.yml\` (C7 fail-closed trust suite); \`.github/workflows/release-aab.yml\` (E4 secrets-optional signed AAB).
- Store assets: \`fastlane/metadata/android/*/images/phoneScreenshots/\` (10), \`featureGraphic.png\` (1024×500), generator \`tool/generate_feature_graphic.dart\`.
- Trust plan epic: \`docs/plan/V090-TRUST/*\`.
- Tests: payment-lock matrix; app lock (mock storage, lockout); backup restore encrypt→restore + pre_restore + wrong PIN; concurrent stock/double-sale (C4); sale write helpers; cart discount policy; checkout tender/shell nav; expanded smoke checklist.

### Changed

- docs/testing/RELEASE_0.9_SMOKE.md — device UI Pass for cash, draft park/reopen, daily close (2026-07-17 emulator); restore automated Pass; PIN min 6.
- SECURITY.md, PRIVACY_POLICY, DATABASE/schema docs, DEPLOY signing path, Fastlane EN/TH copy, STORE_SUBMISSION checklist (teeprakorn1 privacy URL, AGPL, not tax invoice).
- Schema docs / SECURITY / Fastlane aligned to **v28**, \`sale_payments\`, same-device restore honesty.
- \`ci.yml\` documents soft device \`integration_test/\`; money path gated by Release Trust.

### Security

- PIN: PBKDF2 100k, min length 6, lockout, secure-storage options explicit; background \`lockSession\`.
- Backup encryption off requires store PIN (when enabled) + confirm.
- FLAG_SECURE on store PIN entry and PromptPay QR screen (Android).
- Release AAB in CI only when operator supplies keystore secrets (never commit JKS).

### Known limitations

- Cross-device restore and SQLCipher **key recovery** still not available (Phase 2b).
- Production Play upload still requires operator production keystore (not throwaway E2 key), Data safety form, and console submit.
- OS share-sheet → re-import on device remains optional beyond automated restore round-trip.
- Full-tree **Unreleased** UX waves may still sit in the working tree alongside this trust cut — see Unreleased until fully folded.

`;

t = t.slice(0, start) + newBlock + t.slice(end);

// Stale deferred restore note deeper in file
t = t.replace(
  '- **In-app backup restore** is deferred (export + share works; restore = manual file replace / offline decrypt). Target 0.9.1+.\n',
  '- **Cross-device restore / key recovery** still deferred (same-device in-app restore is shipped in 0.9.0).\n',
);

if (!t.includes('Minimum length raised to **6**')) {
  t = t.replace(
    '- **SQLCipher key loss** — Losing the device secure-storage key (or uninstall without backup) makes the local DB unrecoverable. There is **no** key recovery in 0.9.0.\n',
    '- **SQLCipher key loss** — Losing the device secure-storage key (or uninstall without backup) makes the local DB unrecoverable. There is **no** key recovery in 0.9.0.\n' +
      '- **Store PIN** — Minimum length raised to **6**; existing short PINs must be re-set. Successful unlock upgrades legacy v1 hashes to PBKDF2 v2.\n',
  );
}

fs.writeFileSync(path, t);
console.log('updated', path, 'bytes', t.length);
