import 'package:promsell_pos_ce/core/database/db_key_store.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Maps recovery-kit and key-storage failures to localized messages.
String recoveryKitErrorMessage(AppLocalizations l10n, Object e) {
  if (e is StateError) {
    return switch (e.message) {
      'SECRET_TOO_SHORT' => l10n.recoveryKitSecretTooShort,
      'KIT_FILE_NOT_FOUND' => l10n.recoveryKitErrorFileNotFound,
      'KIT_CORRUPT' => l10n.recoveryKitErrorCorrupt,
      'KIT_VERSION_UNSUPPORTED' => l10n.recoveryKitErrorVersionUnsupported,
      'WRONG_SECRET' => l10n.recoveryKitErrorWrongSecret,
      'NO_DB_KEY' => l10n.recoveryKitErrorNoKey,
      _ => l10n.backupFailed,
    };
  }
  // Secure-storage failure or lost key over an existing DB — direct the
  // merchant to import their recovery kit instead of a generic failure.
  if (e is DbKeyUnavailable) return l10n.recoveryKitErrorKeyUnavailable;
  return l10n.backupFailed;
}
