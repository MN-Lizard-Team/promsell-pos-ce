import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/services/store_pin_setup.dart';
import 'package:promsell_pos_ce/core/utils/secure_screen.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';

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

/// First-run / create flow: returns trimmed PIN or null if cancelled.
///
/// Does **not** call [AppLockService.setPin] — caller persists.
Future<String?> showCreateStorePinDialog(
  BuildContext context, {
  bool barrierDismissible = false,
}) async {
  final l10n = context.l10n;
  final c1 = TextEditingController();
  final c2 = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      return AlertDialog(
        title: Text(l10n.onboardingStorePinTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.onboardingStorePinBody(AppLockService.minPinLength),
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: c1,
              obscureText: true,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.appLockPinLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: c2,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.appLockConfirmPin,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          if (barrierDismissible)
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
          FilledButton(
            onPressed: () {
              final err = StorePinSetup.validateNewPin(c1.text, c2.text);
              if (err == 'too_short' || err == 'empty') {
                AppSnackBar.error(
                  ctx,
                  l10n.appLockPinTooShort(AppLockService.minPinLength),
                );
                return;
              }
              if (err == 'mismatch') {
                AppSnackBar.error(ctx, l10n.appLockPinsMismatch);
                return;
              }
              Navigator.pop(ctx, c1.text.trim());
            },
            child: Text(l10n.confirm),
          ),
        ],
      );
    },
  );
  disposeTextEditingControllerAfterFrame(c1);
  disposeTextEditingControllerAfterFrame(c2);
  return result;
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
