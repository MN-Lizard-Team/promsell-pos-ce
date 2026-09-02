import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/database/recovery_kit_service.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/recovery_kit/recovery_kit_errors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/recovery_kit/recovery_kit_secret_dialog.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Full-screen gate shown at cold start when the SQLCipher key cannot be
/// accessed ([DbKeyUnavailable]) — guides the merchant to import a recovery
/// kit instead of dropping into a shell whose every query fails.
///
/// The store-PIN gate is intentionally skipped here: with secure storage
/// broken, PIN verification can never succeed and the merchant would be
/// deadlocked out of the only recovery path. Physical device access plus the
/// kit passphrase remains the trust boundary.
class DbRecoveryGate extends StatelessWidget {
  const DbRecoveryGate({super.key});

  Future<void> _importKit(BuildContext context) async {
    final l10n = context.l10n;
    try {
      final picked = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['promkey'],
      );
      if (!context.mounted) return;
      if (picked == null || picked.files.isEmpty) return;
      final path = picked.files.single.path;
      if (path == null) {
        AppSnackBar.error(context, l10n.backupFailed);
        return;
      }

      final secret = await showRecoveryKitSecretDialog(
        context,
        l10n: l10n,
        title: l10n.recoveryKitImportSecretTitle,
      );
      if (secret == null || !context.mounted) return;

      try {
        await sl<RecoveryKitService>().importKit(
          filePath: path,
          secret: secret,
        );
      } on StateError catch (e) {
        if (e.message != 'KEY_ALREADY_EXISTS') rethrow;
        if (!context.mounted) return;
        final replace = await showAppConfirm(
          context,
          title: l10n.recoveryKitImportReplaceTitle,
          message: l10n.recoveryKitImportReplaceMessage,
          confirmLabel: l10n.confirm,
          destructive: true,
        );
        if (!replace || !context.mounted) return;
        await sl<RecoveryKitService>().importKit(
          filePath: path,
          secret: secret,
          replaceExisting: true,
        );
      }
      if (!context.mounted) return;
      AppSnackBar.success(context, l10n.recoveryKitImportSuccess);
      await context.read<SettingsCubit>().load();
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.error(context, recoveryKitErrorMessage(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      key: const Key('db_recovery_gate'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    TablerIcons.alertTriangle,
                    size: 56,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.dbRecoveryTitle,
                    key: const Key('db_recovery_title'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dbRecoveryMessage,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    key: const Key('db_recovery_import_kit'),
                    onPressed: () => _importKit(context),
                    icon: const Icon(TablerIcons.databaseExport),
                    label: Text(l10n.recoveryKitImportAction),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const Key('db_recovery_retry'),
                    onPressed: () => context.read<SettingsCubit>().load(),
                    child: Text(l10n.dbRecoveryRetry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
