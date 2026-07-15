import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_root/settings_tile_builders.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

class PromptpayIdTile extends StatelessWidget {
  const PromptpayIdTile({
    super.key,
    required this.settings,
    required this.cubit,
    required this.st,
    required this.l10n,
  });

  final Settings settings;
  final SettingsCubit cubit;
  final SettingsThemeExtension st;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final hasId = settings.promptpayId.isNotEmpty;

    return ListTile(
      minTileHeight: st.tileMinHeight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: st.iconSize,
        height: st.iconSize,
        decoration: BoxDecoration(
          color: st.iconContainerBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.account_balance_wallet_outlined,
          color: st.softAccent,
          size: 24,
        ),
      ),
      title: Text(
        l10n.settingsPromptpayId,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        hasId
            ? SettingsTileBuilders.maskSensitiveId(settings.promptpayId)
            : l10n.settingsPromptpayIdHint,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: hasId ? st.softAccent : st.mutedText,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: st.softTextSecondary,
        size: 24,
      ),
      onTap: () => _showIdDialog(context),
    );
  }

  void _showIdDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _PromptpayIdDialog(
        initialValue: settings.promptpayId,
        title: l10n.settingsPromptpayId,
        hint: l10n.settingsPromptpayIdHint,
        cancelLabel: l10n.cancel,
        saveLabel: l10n.save,
        accent: st.softAccent,
        onSave: (raw) {
          cubit.updateField((s) => s.copyWith(promptpayId: raw));
        },
      ),
    );
  }
}

class _PromptpayIdDialog extends StatefulWidget {
  const _PromptpayIdDialog({
    required this.initialValue,
    required this.title,
    required this.hint,
    required this.cancelLabel,
    required this.saveLabel,
    required this.accent,
    required this.onSave,
  });

  final String initialValue;
  final String title;
  final String hint;
  final String cancelLabel;
  final String saveLabel;
  final Color accent;
  final ValueChanged<String> onSave;

  @override
  State<_PromptpayIdDialog> createState() => _PromptpayIdDialogState();
}

class _PromptpayIdDialogState extends State<_PromptpayIdDialog> {
  late final TextEditingController _ctrl;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    disposeTextEditingControllerAfterFrame(_ctrl);
    super.dispose();
  }

  void _pop() {
    unfocusForDialogClose();
    Navigator.of(context).pop();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final raw = _ctrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
    final unlocked = await ensureAppUnlocked(
      context,
      title: context.l10n.appLockConfirmPromptPay,
    );
    if (!unlocked || !mounted) return;
    HapticFeedback.lightImpact();
    widget.onSave(raw);
    _pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 280,
          child: TextFormField(
            controller: _ctrl,
            keyboardType: TextInputType.number,
            maxLength: 17,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            onFieldSubmitted: (_) => _submit(),
            validator: (v) {
              try {
                Validators.promptpayId(v);
                return null;
              } on ArgumentError catch (e) {
                return e.message as String?;
              }
            },
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _pop, child: Text(widget.cancelLabel)),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: widget.accent),
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}
