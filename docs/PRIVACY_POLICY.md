# Privacy Policy — Promsell

Last updated: June 26, 2026

## 1. Data Collection
Promsell does **not** collect any personal data. All sales, inventory, and settings are stored locally on your device using SQLite. No data is transmitted to our servers.

## 2. Third-Party Services
We do not use analytics, advertising, or cloud services. The app works entirely offline.

## 3. Data Storage
Your data remains on your device. You can export or delete it at any time via the Backup/Restore feature. Product images are stored locally in the app's private `/images/` directory and are subject to automatic LRU cache eviction (50MB limit) to prevent excessive disk usage.

## 4. Backup Encryption (Optional)
Starting with v0.7.2, Promsell offers optional AES-256-GCM encryption for database backups. If enabled, backups are encrypted with a key derived from a user-supplied PIN via PBKDF2. The PIN is never stored on the device or transmitted anywhere. Forgetting the PIN makes the backup unrecoverable — we cannot reset or recover it.

## 5. Crash Logging (v0.8.3+)
If the app crashes, a local crash log entry is written to the device containing the error message, stack trace, and timestamp. Sensitive data (phone numbers, PromptPay IDs, citizen IDs) is automatically sanitized before storage. Crash logs are never transmitted off-device. You can view, export (via share sheet), and clear crash logs in Settings → About → Crash Logs.

## 6. Permissions
- **Camera**: Used for taking product photos and scanning product barcodes. No photos or scans are transmitted off-device.
- **Storage**: Used only for saving backups and receipts.
- **Internet**: Optional, used only for loading product images if URLs are provided. When sharing product images, URLs are sent to the platform's native share sheet (local device only, not to our servers).

## 7. Contact
For questions: mnlizard.official@gmail.com
