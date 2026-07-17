import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/utils/secure_screen.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';

/// Prompts for store PIN when [AppLockService] is enabled and session expired.
///
/// Returns `true` if the action may proceed (lock off / session / correct PIN).
Future<bool> ensureAppUnlocked(
  BuildContext context, {
  String? title,
  String? wrongPinMessage,
}) async {
  final lock = sl<AppLockService>();
  if (!await lock.isEnabled()) return true;
  if (lock.isSessionUnlocked) return true;
  if (!context.mounted) return false;
  final l10n = context.l10n;

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _AppLockPinDialog(
      title: title ?? l10n.appLockEnterPin,
      wrongPinMessage: wrongPinMessage ?? l10n.appLockIncorrectPin,
      pinLabel: l10n.appLockPinLabel,
      cancelLabel: l10n.cancel,
      unlockLabel: l10n.appLockUnlock,
    ),
  );
  return ok == true;
}

class _AppLockPinDialog extends StatefulWidget {
  const _AppLockPinDialog({
    required this.title,
    required this.wrongPinMessage,
    required this.pinLabel,
    required this.cancelLabel,
    required this.unlockLabel,
  });

  final String title;
  final String wrongPinMessage;
  final String pinLabel;
  final String cancelLabel;
  final String unlockLabel;

  @override
  State<_AppLockPinDialog> createState() => _AppLockPinDialogState();
}

class _AppLockPinDialogState extends State<_AppLockPinDialog> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    SecureScreen.setSecure(true);
  }

  @override
  void dispose() {
    SecureScreen.setSecure(false);
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final lock = sl<AppLockService>();
    try {
      final ok = await lock.verifyPin(_controller.text);
      if (!mounted) return;
      if (ok) {
        Navigator.pop(context, true);
        return;
      }
      setState(() {
        _busy = false;
        _error = widget.wrongPinMessage;
      });
    } on StateError catch (e) {
      if (!mounted) return;
      if (e.message == 'PIN_LOCKED') {
        final left = lock.lockoutRemaining;
        final secs = left?.inSeconds ?? 0;
        setState(() {
          _busy = false;
          _error = context.l10n.appLockLockedOut(secs);
        });
        return;
      }
      setState(() {
        _busy = false;
        _error = widget.wrongPinMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        obscureText: true,
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
          labelText: widget.pinLabel,
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _busy ? null : _submit(),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _busy ? null : _submit,
          child: Text(widget.unlockLabel),
        ),
      ],
    );
  }
}

/// Optional convenience snack when user cancels unlock.
void showUnlockCancelled(BuildContext context) {
  AppSnackBar.error(context, context.l10n.appLockActionRequired);
}
