import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/database/recovery_kit_service.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Asks for the recovery-kit secret.
///
/// Used both when creating a kit (export: choose a new secret via
/// [l10n.recoveryKitExportSecretTitle]) and when installing one (import:
/// enter the existing secret via [l10n.recoveryKitImportSecretTitle]).
/// Client-side validation only — [kRecoveryKitMinSecretLength] is
/// re-enforced by the service.
///
/// Returns the trimmed secret, or `null` when cancelled.
Future<String?> showRecoveryKitSecretDialog(
  BuildContext context, {
  required AppLocalizations l10n,
  required String title,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => RecoveryKitSecretDialog(l10n: l10n, title: title),
  );
}

class RecoveryKitSecretDialog extends StatefulWidget {
  const RecoveryKitSecretDialog({
    super.key,
    required this.l10n,
    required this.title,
  });

  final AppLocalizations l10n;
  final String title;

  @override
  State<RecoveryKitSecretDialog> createState() =>
      _RecoveryKitSecretDialogState();
}

class _RecoveryKitSecretDialogState extends State<RecoveryKitSecretDialog> {
  late final TextEditingController _secretCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _secretCtrl = TextEditingController();
  }

  @override
  void dispose() {
    disposeTextEditingControllerAfterFrame(_secretCtrl);
    super.dispose();
  }

  void _pop([String? secret]) {
    unfocusForDialogClose();
    Navigator.pop(context, secret);
  }

  void _submit() {
    final secret = _secretCtrl.text.trim();
    if (secret.isEmpty) {
      setState(() => _error = widget.l10n.recoveryKitSecretRequired);
      return;
    }
    if (secret.length < kRecoveryKitMinSecretLength) {
      setState(() => _error = widget.l10n.recoveryKitSecretTooShort);
      return;
    }
    _pop(secret);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const Key('recovery_kit_secret_field'),
        controller: _secretCtrl,
        obscureText: true,
        autofocus: true,
        decoration: InputDecoration(
          labelText: l10n.recoveryKitSecretLabel,
          helperText: l10n.recoveryKitSecretHelper,
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => _pop(), child: Text(l10n.cancel)),
        FilledButton(
          key: const Key('recovery_kit_secret_confirm'),
          onPressed: _submit,
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
