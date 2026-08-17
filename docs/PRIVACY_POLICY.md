# Privacy Policy — Promsell

Last updated: August 17, 2026

## 1. Data Collection
Promsell does **not** collect or transmit personal data to **developer servers**. We do not run analytics, ads, or developer cloud sync. The app is offline-first.

**Local data on your device** may include business and optional contact data you enter, for example: sales and inventory; shop profile; optional customer name/phone/email; PromptPay ID; product photos; and local crash logs (with phone / PromptPay / citizen ID sanitization). That data stays on the device unless **you** export or share it (backup/share sheet). The live database uses SQLite with SQLCipher encryption at rest on supported builds.

## 2. Third-Party Services
We do not use analytics, advertising, or developer cloud services. **Core POS is offline.** Optional `INTERNET` is used only to load merchant-supplied product image URLs (see §7). There is no required network for selling.

## 3. Data Storage
Your data remains on your device. You can **export** a backup (and share it via the OS share sheet), **restore a backup on the same device** from Settings → Backup (encrypted `.enc` or SQLCipher `.db` only), or clear data by uninstalling / clearing app storage.

**Restore limits (v0.9.2):** in-app restore is **same-device only** — it reuses the SQLCipher key already stored on this phone/tablet. **Cross-device restore and restore after uninstall / keystore wipe are not supported in v0.9.2.** Without a prior off-device export, losing the device encryption key means permanent data loss. Recovery-kit export/import (`RecoveryKitService`) is **code complete but device validation pending** — unit tests cover wrap/unwrap logic only; on-device cross-device restore (D2) is not yet tested. Not released.

Product images are stored locally in the app's private `/images/` directory and are subject to automatic LRU cache eviction (50MB limit).

## 4. Backup Encryption
From v0.7.2 (default **on** for new installs / missing setting in v0.9.2), database **exports** can use AES-256-GCM with a PIN-derived key (PBKDF2; PIN at least 6 characters). The PIN is never stored on the device or transmitted. Forgetting the PIN makes that export unrecoverable. Separately, the live database is protected by SQLCipher; losing the device encryption key without an export means permanent data loss.

## 5. Customer Data (v0.8.9+)
If you use the customer management feature, customer information (name, phone, email) is stored locally on your device. This data is user-entered and never transmitted off-device. You can delete customer records at any time.

## 6. Crash Logging (v0.8.3+)
If the app crashes, a local crash log entry is written to the device containing the error message, stack trace, and timestamp. Sensitive data (phone numbers, PromptPay IDs, citizen IDs) is automatically sanitized before storage. Crash logs are never transmitted off-device. You can view, export (via share sheet), and clear crash logs in Settings → About → Crash Logs.

## 7. Permissions
- **Camera**: Used for taking product photos and scanning product barcodes. No photos or scans are transmitted off-device.
- **Storage**: Used only for saving backups and receipts.
- **Internet**: Optional, used only for loading product images if URLs are provided. When sharing product images, URLs are sent to the platform's native share sheet (local device only, not to our servers).

## 8. Contact
For questions: mnlizard.official@gmail.com
