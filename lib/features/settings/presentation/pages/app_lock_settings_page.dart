import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/services/app_lock_service.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/secure_screen.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/safe_text_controller.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_section_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

/// Enable/disable store PIN, change PIN, and configure session grace +
/// lockout policy.
class AppLockSettingsPage extends StatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  State<AppLockSettingsPage> createState() => _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends State<AppLockSettingsPage> {
  final _lock = sl<AppLockService>();
  bool _loading = true;
  bool _enabled = false;
  bool _hasPin = false;
  DateTime? _pinSetAt;
  int _sessionGraceSeconds = AppLockService.defaultSessionGrace.inSeconds;
  int _maxFailedAttempts = AppLockService.defaultMaxFailedAttempts;
  int _baseLockoutSeconds = AppLockService.defaultBaseLockout.inSeconds;

  @override
  void initState() {
    super.initState();
    // V092-B.5: hide PIN entry from screenshots / Recents preview.
    SecureScreen.setSecure(true);
    _refresh();
  }

  @override
  void dispose() {
    SecureScreen.setSecure(false);
    super.dispose();
  }

  Future<void> _refresh() async {
    final enabled = await _lock.isEnabled();
    final hasPin = await _lock.hasPin();
    final pinSetAt = await _lock.pinSetAt();
    final grace = await _lock.getSessionGrace();
    final policy = await _lock.getLockoutPolicy();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _hasPin = hasPin;
      _pinSetAt = pinSetAt;
      _sessionGraceSeconds = grace.inSeconds;
      _maxFailedAttempts = policy.maxFailedAttempts;
      _baseLockoutSeconds = policy.baseLockout.inSeconds;
      _loading = false;
    });
  }

  Future<void> _enable() async {
    if (_hasPin) {
      // PIN already stored — verify it, then re-enable.
      final pin = await _askPin(context);
      if (pin == null || !mounted) return;
      try {
        final ok = await _lock.ensureUnlocked(pin: pin);
        if (!ok) {
          if (mounted) {
            AppSnackBar.error(context, context.l10n.appLockIncorrectPin);
          }
          return;
        }
        await _lock.enable();
        await _refresh();
        if (mounted) {
          AppSnackBar.success(context, context.l10n.appLockEnabled);
        }
      } catch (e) {
        if (mounted) {
          AppSnackBar.error(context, context.l10n.appLockEnableFailed);
        }
      }
      return;
    }
    // No PIN stored — set a new one.
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
              : e is StateError && e.message == 'PIN_TOO_TRIVIAL'
              ? context.l10n.appLockPinTooTrivial
              : context.l10n.appLockEnableFailed,
        );
      }
    }
  }

  Future<void> _disable() async {
    final l10n = context.l10n;
    final pin = await _askPin(context);
    final ok = await _lock.ensureUnlocked(pin: pin);
    if (!ok || !mounted) {
      if (mounted) {
        AppSnackBar.error(context, context.l10n.appLockDisableNeedsPin);
      }
      return;
    }
    // Confirm the user understands the risk of disabling PIN.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.appLockDisableConfirmTitle),
        content: Text(l10n.appLockDisableConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.appLockConfirmDisable),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _lock.disable();
    await _refresh();
    if (mounted) {
      AppSnackBar.success(context, context.l10n.appLockDisabled);
    }
  }

  Future<void> _erasePin() async {
    final l10n = context.l10n;
    final pin = await _askPin(context, title: l10n.appLockEnterCurrentPin);
    if (pin == null || !mounted) return;
    final ok = await _lock.ensureUnlocked(pin: pin);
    if (!ok || !mounted) {
      if (mounted) {
        AppSnackBar.error(context, l10n.appLockIncorrectPin);
      }
      return;
    }
    // Confirm before permanent deletion.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.appLockErasePinTitle),
        content: Text(l10n.appLockErasePinConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton.tonal(
            style: FilledButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.appLockErasePin),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _lock.erasePin();
    await _refresh();
    if (mounted) {
      AppSnackBar.success(context, l10n.appLockPinErased);
    }
  }

  Future<void> _changePin() async {
    final l10n = context.l10n;
    final currentPin = await _askPin(
      context,
      title: l10n.appLockEnterCurrentPin,
    );
    if (currentPin == null || !mounted) return;
    final newPin = await _askPin(
      context,
      confirm: true,
      title: l10n.appLockCreatePin,
    );
    if (newPin == null || !mounted) return;
    try {
      await _lock.changePin(currentPin: currentPin, newPin: newPin);
      await _refresh();
      if (mounted) {
        AppSnackBar.success(context, l10n.appLockPinChanged);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          e is StateError && e.message == 'PIN_WRONG'
              ? l10n.appLockIncorrectPin
              : e is StateError && e.message == 'PIN_TOO_SHORT'
              ? l10n.appLockPinTooShort(AppLockService.minPinLength)
              : e is StateError && e.message == 'PIN_TOO_TRIVIAL'
              ? l10n.appLockPinTooTrivial
              : l10n.appLockEnableFailed,
        );
      }
    }
  }

  Future<void> _setSessionGrace(int seconds) async {
    try {
      await _lock.setSessionGrace(Duration(seconds: seconds));
      await _refresh();
      if (mounted) {
        AppSnackBar.success(context, context.l10n.appLockSessionGraceChanged);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, context.l10n.appLockEnableFailed);
      }
    }
  }

  Future<void> _setLockoutPolicy({
    int? maxAttempts,
    int? baseLockoutSeconds,
  }) async {
    try {
      await _lock.setLockoutPolicy(
        maxFailedAttempts: maxAttempts,
        baseLockout: baseLockoutSeconds != null
            ? Duration(seconds: baseLockoutSeconds)
            : null,
      );
      await _refresh();
      if (mounted) {
        AppSnackBar.success(context, context.l10n.appLockLockoutPolicyChanged);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, context.l10n.appLockEnableFailed);
      }
    }
  }

  Future<String?> _askPin(
    BuildContext context, {
    bool confirm = false,
    String? title,
  }) async {
    final l10n = context.l10n;
    final c1 = TextEditingController();
    final c2 = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          title ?? (confirm ? l10n.appLockCreatePin : l10n.appLockEnterPin),
        ),
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
    disposeTextEditingControllerAfterFrame(c1);
    disposeTextEditingControllerAfterFrame(c2);
    return result;
  }

  String _formatGrace(int seconds) {
    if (seconds == 0) return context.l10n.appLockGraceSingleAction;
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  String _formatLockout(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '${m}m' : '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final l10n = context.l10n;
    return SettingsLeafChrome(
      title: l10n.appLockTitle,
      heroIcon: TablerIcons.pin,
      heroAccent: AppColors.primary,
      children: [
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          )
        else ...[
          // --- PIN status + enable/disable ---
          SettingsSectionCard(
            title: l10n.appLockSectionTitle,
            accent: AppColors.primary,
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
                  _enabled
                      ? l10n.appLockRequirePinHint(
                          _sessionGraceSeconds ~/ 60 > 0
                              ? _sessionGraceSeconds ~/ 60
                              : 1,
                        )
                      : l10n.appLockSubtitle,
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
              if (_hasPin) ...[
                const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(Icons.lock_clock, color: st.mutedText),
                  title: Text(
                    l10n.appLockPinStatus,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    _pinSetAt != null
                        ? l10n.appLockPinSetDate(_formatDate(_pinSetAt!))
                        : l10n.appLockPinSetUnknown,
                    style: TextStyle(color: st.mutedText, fontSize: 13),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(Icons.key, color: st.mutedText),
                  title: Text(
                    l10n.appLockChangePin,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    l10n.appLockChangePinHint,
                    style: TextStyle(color: st.mutedText, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _changePin,
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    l10n.appLockErasePin,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  subtitle: Text(
                    l10n.appLockErasePinHint,
                    style: TextStyle(color: st.mutedText, fontSize: 13),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _erasePin,
                ),
              ],
            ],
          ),
          // --- Session grace ---
          if (_enabled) ...[
            SizedBox(height: st.sectionGap),
            SettingsSectionCard(
              title: l10n.appLockSessionGraceTitle,
              accent: AppColors.primary,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    l10n.appLockSessionGraceHint,
                    style: TextStyle(color: st.mutedText, fontSize: 13),
                  ),
                ),
                RadioGroup<int>(
                  groupValue: _sessionGraceSeconds,
                  onChanged: (v) {
                    if (v != null) _setSessionGrace(v);
                  },
                  child: Column(
                    children: [
                      for (final s in AppLockService.sessionGraceOptionsSeconds)
                        RadioListTile<int>(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          dense: true,
                          title: Text(_formatGrace(s)),
                          value: s,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            // --- Lockout policy ---
            SizedBox(height: st.sectionGap),
            SettingsSectionCard(
              title: l10n.appLockLockoutPolicyTitle,
              accent: AppColors.primary,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Text(
                    l10n.appLockLockoutPolicyHint,
                    style: TextStyle(color: st.mutedText, fontSize: 13),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    l10n.appLockMaxFailedAttempts,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    l10n.appLockMaxFailedAttemptsValue(_maxFailedAttempts),
                    style: TextStyle(color: st.mutedText, fontSize: 13),
                  ),
                  trailing: DropdownButton<int>(
                    value: _maxFailedAttempts,
                    items: AppLockService.maxFailedAttemptsOptions
                        .map(
                          (n) => DropdownMenuItem(value: n, child: Text('$n')),
                        )
                        .toList(),
                    onChanged: (v) =>
                        v != null ? _setLockoutPolicy(maxAttempts: v) : null,
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    l10n.appLockBaseLockout,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    l10n.appLockBaseLockoutValue(
                      _formatLockout(_baseLockoutSeconds),
                    ),
                    style: TextStyle(color: st.mutedText, fontSize: 13),
                  ),
                  trailing: DropdownButton<int>(
                    value: _baseLockoutSeconds,
                    items: AppLockService.baseLockoutOptionsSeconds
                        .map(
                          (s) => DropdownMenuItem(
                            value: s,
                            child: Text(_formatLockout(s)),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => v != null
                        ? _setLockoutPolicy(baseLockoutSeconds: v)
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final d = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
