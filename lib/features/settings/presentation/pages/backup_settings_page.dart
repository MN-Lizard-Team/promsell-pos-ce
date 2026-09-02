import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/database/recovery_kit_service.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_restore_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/core/utils/secure_screen.dart';
import 'package:promsell_pos_ce/features/settings/data/services/backup_export_service.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/pages/backup_settings_page/backup_reminder_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/backup/backup_info_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/backup/backup_status_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/recovery_kit/recovery_kit_errors.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/recovery_kit/recovery_kit_secret_dialog.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/recovery_kit/recovery_kit_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_state_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class BackupSettingsPage extends StatefulWidget {
  const BackupSettingsPage({super.key});

  @override
  State<BackupSettingsPage> createState() => _BackupSettingsPageState();
}

class _BackupSettingsPageState extends State<BackupSettingsPage> {
  bool _busy = false;

  Future<String?> _askPin(BuildContext context, AppLocalizations l10n) {
    return showDialog<String>(
      context: context,
      builder: (_) => _BackupPinDialog(l10n: l10n),
    );
  }

  Future<void> _runBackup(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
    AppLocalizations l10n,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final unlocked = await ensureAppUnlocked(
        context,
        title: l10n.backupConfirmExportTitle,
      );
      if (!unlocked || !context.mounted) return;
      String? pin;
      if (s.backupConfig.encryptionEnabled) {
        pin = await _askPin(context, l10n);
        if (!context.mounted) return;
        if (pin == null || pin.trim().isEmpty) {
          AppSnackBar.error(context, l10n.backupPinRequired);
          return;
        }
      }
      await sl<BackupExportService>().exportAndShare(
        encrypt: s.backupConfig.encryptionEnabled,
        pin: pin,
        shareSubject: l10n.backupShareSubject,
      );
      if (!context.mounted) return;
      final now = DateTime.now().toIso8601String();
      cubit.updateField((settings) => settings.copyWith(lastBackupAt: now));
      AppSnackBar.success(context, l10n.backupSuccess);
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is StateError
          ? switch (e.message) {
              'PIN_REQUIRED' => l10n.backupPinRequired,
              'PIN_TOO_SHORT' => l10n.backupPinTooShort,
              _ => l10n.backupFailed,
            }
          : l10n.backupFailed;
      AppSnackBar.error(context, msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _runRestore(
    BuildContext context,
    Settings s,
    AppLocalizations l10n,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final unlocked = await ensureAppUnlocked(
        context,
        title: l10n.backupConfirmRestoreTitle,
      );
      if (!unlocked || !context.mounted) return;

      final confirmed = await showAppConfirm(
        context,
        title: l10n.backupRestoreConfirmTitle,
        message: l10n.backupRestoreConfirmMessage,
        confirmLabel: l10n.confirm,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['db', 'enc'],
      );
      if (result == null || result.files.isEmpty) return;
      final path = result.files.single.path;
      if (path == null) {
        if (!context.mounted) return;
        AppSnackBar.error(context, l10n.backupFailed);
        return;
      }

      String? pin;
      if (path.toLowerCase().endsWith('.enc')) {
        if (!context.mounted) return;
        pin = await _askPin(context, l10n);
        if (!context.mounted) return;
        if (pin == null || pin.trim().isEmpty) {
          AppSnackBar.error(context, l10n.backupPinRequired);
          return;
        }
      }

      await sl<BackupRestoreService>().restoreFromPath(
        sourcePath: path,
        pin: pin,
      );
      if (!context.mounted) return;
      AppSnackBar.success(context, l10n.backupRestoreSuccess);
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is StateError
          ? switch (e.message) {
              'PIN_REQUIRED' => l10n.backupPinRequired,
              'PIN_TOO_SHORT' => l10n.backupPinTooShort,
              'PLAIN_SQLITE_UNSUPPORTED' => l10n.backupRestorePlainUnsupported,
              'INVALID_BACKUP' => l10n.backupRestoreInvalid,
              'SOURCE_MISSING' => l10n.backupRestoreSourceMissing,
              _ => l10n.backupFailed,
            }
          : l10n.backupFailed;
      AppSnackBar.error(context, msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Exports the SQLCipher key as a password-wrapped `.promkey` kit file and
  /// shares it the same way backup exports are shared.
  Future<void> _runExportRecoveryKit(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      final unlocked = await ensureAppUnlocked(
        context,
        title: l10n.recoveryKitExportConfirmTitle,
      );
      if (!unlocked || !context.mounted) return;

      final secret = await showRecoveryKitSecretDialog(
        context,
        l10n: l10n,
        title: l10n.recoveryKitExportSecretTitle,
      );
      if (secret == null || !context.mounted) return;

      final confirmed = await showAppConfirm(
        context,
        title: l10n.recoveryKitExportConfirmTitle,
        message: l10n.recoveryKitExportConfirmMessage,
        confirmLabel: l10n.confirm,
        destructive: true,
      );
      if (!confirmed || !context.mounted) return;

      final result = await sl<RecoveryKitService>().exportKit(secret: secret);
      if (!context.mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(result.filePath)],
          subject: l10n.recoveryKitShareSubject,
        ),
      );
      if (!context.mounted) return;
      AppSnackBar.success(context, l10n.recoveryKitExportSuccess);
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.error(context, recoveryKitErrorMessage(l10n, e));
    }
  }

  /// Imports a `.promkey` kit. When a key already exists on this device,
  /// asks for explicit confirmation before replacing it.
  Future<void> _runImportRecoveryKit(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    try {
      final unlocked = await ensureAppUnlocked(
        context,
        title: l10n.settingsBackup,
      );
      if (!unlocked || !context.mounted) return;

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
      // Warning tone on purpose: data written with the previous key still
      // requires that old key to restore.
      AppSnackBar.warning(context, l10n.recoveryKitImportSuccess);
    } catch (e) {
      if (!context.mounted) return;
      AppSnackBar.error(context, recoveryKitErrorMessage(l10n, e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.settings != curr.settings || prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final st = context.settingsTheme;

        return SettingsStateView(
          state: state,
          onRetry: cubit.load,
          builder: (s) => SettingsLeafChrome(
            title: l10n.settingsBackup,
            heroIcon: TablerIcons.databaseExport,
            heroAccent: AppColors.neutralAccent,
            header: BackupStatusCard(
              lastBackupAt: s.lastBackupAt,
              reminderDays: s.backupReminderDays,
              st: st,
              l10n: l10n,
            ),
            children: [
              _buildReminderTile(context, s, cubit, st, l10n),
              SettingsSectionCard(
                title: l10n.backupEncryptionTitle,
                accent: AppColors.neutralAccent,
                children: [
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    secondary: Container(
                      width: st.iconSize,
                      height: st.iconSize,
                      decoration: BoxDecoration(
                        color: st.iconContainerBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        TablerIcons.lock,
                        color: st.softAccent,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      l10n.backupEncryptionLabel,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      l10n.backupEncryptionDesc,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: st.mutedText,
                        fontSize: 14,
                      ),
                    ),
                    value: s.backupEncryptionEnabled,
                    activeTrackColor: st.softAccent,
                    onChanged: (v) async {
                      if (!v && s.backupEncryptionEnabled) {
                        final unlocked = await ensureAppUnlocked(
                          context,
                          title: l10n.backupEncryptionOffTitle,
                        );
                        if (!unlocked || !context.mounted) return;
                        final ok = await showAppConfirm(
                          context,
                          title: l10n.backupEncryptionOffTitle,
                          message: l10n.backupEncryptionOffConfirm,
                          confirmLabel: l10n.confirm,
                          destructive: true,
                        );
                        if (!ok || !context.mounted) return;
                      }
                      cubit.updateField(
                        (settings) =>
                            settings.copyWith(backupEncryptionEnabled: v),
                      );
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: AppColors.accent,
                  ),
                  onPressed: _busy
                      ? null
                      : () => _runBackup(context, s, cubit, l10n),
                  icon: const Icon(TablerIcons.databaseExport),
                  label: Text(l10n.backupNow),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: _busy ? null : () => _runRestore(context, s, l10n),
                  icon: const Icon(TablerIcons.history),
                  label: Text(l10n.backupRestoreTitle),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  l10n.backupActionSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: st.mutedText,
                    fontSize: 14,
                  ),
                ),
              ),
              BackupInfoCard(st: st, l10n: l10n),
              RecoveryKitSectionCard(
                onExport: () => _runExportRecoveryKit(context, l10n),
                onImport: () => _runImportRecoveryKit(context, l10n),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderTile(
    BuildContext context,
    Settings s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final enabled = s.backupReminderDays > 0;

    return SettingsSectionCard(
      title: l10n.backupReminderLabel,
      accent: AppColors.neutralAccent,
      children: [
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            l10n.backupReminderLabel,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            enabled
                ? l10n.backupEveryNDays(s.backupReminderDays)
                : l10n.backupOff,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: enabled ? st.softAccent : st.mutedText,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          value: enabled,
          activeTrackColor: st.softAccent,
          onChanged: (v) {
            if (v) {
              cubit.updateField(
                (settings) => settings.copyWith(backupReminderDays: 7),
              );
            } else {
              cubit.updateField(
                (settings) => settings.copyWith(backupReminderDays: 0),
              );
            }
          },
        ),
        if (enabled)
          ListTile(
            minTileHeight: st.tileMinHeight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: const SizedBox(width: 48),
            title: Text(
              l10n.backupFrequency,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              l10n.backupEveryNDays(s.backupReminderDays),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: st.softAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: st.softTextSecondary,
              size: 24,
            ),
            onTap: () => BackupReminderDialog.show(context, s, cubit, st, l10n),
          ),
      ],
    );
  }
}

class _BackupPinDialog extends StatefulWidget {
  const _BackupPinDialog({required this.l10n});

  final AppLocalizations l10n;

  @override
  State<_BackupPinDialog> createState() => _BackupPinDialogState();
}

class _BackupPinDialogState extends State<_BackupPinDialog> {
  late final TextEditingController _pinCtrl;
  late final TextEditingController _confirmCtrl;

  @override
  void initState() {
    super.initState();
    SecureScreen.setSecure(true);
    _pinCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
  }

  @override
  void dispose() {
    SecureScreen.setSecure(false);
    disposeTextEditingControllerAfterFrame(_pinCtrl);
    disposeTextEditingControllerAfterFrame(_confirmCtrl);
    super.dispose();
  }

  void _pop([String? pin]) {
    unfocusForDialogClose();
    Navigator.pop(context, pin);
  }

  void _submit() {
    final l10n = widget.l10n;
    final pin = _pinCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (pin.isEmpty) {
      AppSnackBar.error(context, l10n.backupPinRequired);
      return;
    }
    if (pin.length < BackupExportService.minPinLength) {
      AppSnackBar.error(context, l10n.backupPinTooShort);
      return;
    }
    if (pin != confirm) {
      AppSnackBar.error(context, l10n.backupPinMismatch);
      return;
    }
    _pop(pin);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(l10n.backupPinTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _pinCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l10n.backupPinHint),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: l10n.backupPinConfirmHint),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => _pop(), child: Text(l10n.cancel)),
        FilledButton(onPressed: _submit, child: Text(l10n.save)),
      ],
    );
  }
}
