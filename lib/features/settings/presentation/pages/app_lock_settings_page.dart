import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';

/// Enable/disable store PIN used for void, backup, and PromptPay changes.
class AppLockSettingsPage extends StatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  final _lock = sl<AppLockService>();
  bool _loading = true;
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final enabled = await _lock.isEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _loading = false;
    });
  }

  Future<void> _enable() async {
    final pin = await _askPin(context, confirm: true);
    if (pin == null || !mounted) return;
    try {
      await _lock.setPin(pin);
      await _refresh();
      if (mounted) {
        AppSnackBar.success(context, context.l10n.appLockEnabled);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          e is StateError && e.message == 'PIN_TOO_SHORT'
              ? context.l10n.appLockPinTooShort(AppLockService.minPinLength)
              : context.l10n.appLockEnableFailed,
        );
      }
    }
  }

  Future<void> _disable() async {
    final pin = await _askPin(context);
    final ok = await _lock.ensureUnlocked(pin: pin);
    if (!ok || !mounted) {
      if (mounted) {
        AppSnackBar.error(context, context.l10n.appLockDisableNeedsPin);
      }
      return;
    }
    await _lock.disable();
    await _refresh();
    if (mounted) {
      AppSnackBar.success(context, context.l10n.appLockDisabled);
    }
  }

  Future<String?> _askPin(BuildContext context, {bool confirm = false}) async {
    final l10n = context.l10n;
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(confirm ? l10n.appLockCreatePin : l10n.appLockEnterPin),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: c1,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.appLockPinLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            if (confirm) ...[
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
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final a = c1.text.trim();
              if (confirm && a != c2.text.trim()) {
                AppSnackBar.error(ctx, l10n.appLockPinsMismatch);
                return;
              }
              Navigator.pop(ctx, a);
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    c1.dispose();
    c2.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    return SettingsLeafChrome(
      title: l10n.appLockTitle,
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SettingsSectionCard(
            title: l10n.appLockSectionTitle,
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: Text(
                  l10n.appLockRequirePin,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  l10n.appLockRequirePinHint(
                    AppLockService.sessionGrace.inMinutes,
                  ),
                  style: TextStyle(color: st.mutedText, fontSize: 14),
                ),
                value: _enabled,
                onChanged: (v) async {
                  if (v) {
                    await _enable();
                  } else {
                    await _disable();
                  }
                },
              ),
            ],
          ),
      ],
    );
  }
}
