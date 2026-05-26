import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/section_card.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (ctx, state) {
        return _SettingsView(settings: state.settings);
      },
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView({required this.settings});
  final AppSettings settings;

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  late AppSettings _draft;
  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _receiptNoteCtrl;
  bool _manualSave = false;

  bool get _hasTextChanges =>
      _shopNameCtrl.text.trim() != _draft.shopName ||
      _addressCtrl.text.trim() != _draft.address ||
      _phoneCtrl.text.trim() != _draft.phone ||
      _receiptNoteCtrl.text.trim() != _draft.receiptNote;

  @override
  void initState() {
    super.initState();
    _draft = widget.settings;
    _shopNameCtrl = TextEditingController(text: _draft.shopName);
    _addressCtrl = TextEditingController(text: _draft.address);
    _phoneCtrl = TextEditingController(text: _draft.phone);
    _receiptNoteCtrl = TextEditingController(text: _draft.receiptNote);
  }

  @override
  void didUpdateWidget(_SettingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.settings != oldWidget.settings) {
      _draft = widget.settings;
      if (_shopNameCtrl.text == oldWidget.settings.shopName) {
        _shopNameCtrl.text = widget.settings.shopName;
      }
      if (_addressCtrl.text == oldWidget.settings.address) {
        _addressCtrl.text = widget.settings.address;
      }
      if (_phoneCtrl.text == oldWidget.settings.phone) {
        _phoneCtrl.text = widget.settings.phone;
      }
      if (_receiptNoteCtrl.text == oldWidget.settings.receiptNote) {
        _receiptNoteCtrl.text = widget.settings.receiptNote;
      }
    }
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _receiptNoteCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_hasTextChanges) return;
    _manualSave = true;
    final updated = _draft.copyWith(
      shopName: _shopNameCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      receiptNote: _receiptNoteCtrl.text.trim(),
    );
    context.read<SettingsCubit>().update(updated);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocListener<SettingsCubit, SettingsState>(
      listenWhen: (_, curr) =>
          curr.status == SettingsStatus.saved ||
          curr.status == SettingsStatus.failure,
      listener: (ctx, state) {
        if (state.status == SettingsStatus.saved && _manualSave) {
          _manualSave = false;
          AppSnackBar.success(ctx, ctx.l10n.settingsSaved);
        } else if (state.status == SettingsStatus.failure) {
          _manualSave = false;
          AppSnackBar.error(ctx, ctx.l10n.errorOccurred);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTitle),
          actions: [
            ListenableBuilder(
              listenable: Listenable.merge([
                _shopNameCtrl,
                _addressCtrl,
                _phoneCtrl,
                _receiptNoteCtrl,
              ]),
              builder: (_, _) => TextButton(
                onPressed: _hasTextChanges ? _save : null,
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            children: [
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _SectionHeader(l10n.settingsGeneral),
                    _LanguageTile(
                      current: _draft.locale,
                      onChanged: (locale) {
                        setState(
                          () => _draft = _draft.copyWith(locale: locale),
                        );
                        context.read<SettingsCubit>().update(
                          _draft.copyWith(locale: locale),
                        );
                      },
                    ),
                    _ThemeTile(
                      current: _draft.themeMode,
                      onChanged: (mode) {
                        setState(
                          () => _draft = _draft.copyWith(themeMode: mode),
                        );
                        context.read<SettingsCubit>().update(
                          _draft.copyWith(themeMode: mode),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _SectionHeader(l10n.settingsShopInfo),
                    _TextField(
                      controller: _shopNameCtrl,
                      label: l10n.settingsShopName,
                      icon: Icons.store_outlined,
                    ),
                    _TextField(
                      controller: _addressCtrl,
                      label: l10n.settingsAddress,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    _TextField(
                      controller: _phoneCtrl,
                      label: l10n.settingsPhone,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _SectionHeader(l10n.settingsSales),
                    _CurrencyTile(
                      current: _draft.currency,
                      onChanged: (currency) {
                        final updated = _draft.copyWith(currency: currency);
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                    _DateFormatTile(
                      current: _draft.dateFormat,
                      onChanged: (format) {
                        final updated = _draft.copyWith(dateFormat: format);
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _SectionHeader(l10n.settingsReceipt),
                    _TextField(
                      controller: _receiptNoteCtrl,
                      label: l10n.settingsReceiptNote,
                      icon: Icons.receipt_long_outlined,
                      maxLines: 3,
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.info_outline),
                      title: Text(l10n.settingsShowShopInfo),
                      value: _draft.showShopInfoOnReceipt,
                      onChanged: (value) {
                        final updated = _draft.copyWith(
                          showShopInfoOnReceipt: value,
                        );
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ListenableBuilder(
                listenable: Listenable.merge([
                  _shopNameCtrl,
                  _addressCtrl,
                  _phoneCtrl,
                  _receiptNoteCtrl,
                ]),
                builder: (_, _) => FilledButton.icon(
                  onPressed: _hasTextChanges ? _save : null,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l10n.save),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Promsell POS CE',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.current, required this.onChanged});
  final Locale current;
  final ValueChanged<Locale> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ResponsiveSettingsPicker(
      icon: Icons.language,
      title: l10n.settingsLanguage,
      child: DropdownButton<String>(
        value: current.languageCode,
        isExpanded: true,
        items: [
          DropdownMenuItem(value: 'th', child: Text(l10n.langThai)),
          DropdownMenuItem(value: 'en', child: Text(l10n.langEnglish)),
        ],
        onChanged: (code) {
          if (code != null) onChanged(Locale(code));
        },
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.current, required this.onChanged});
  final ThemeMode current;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _ResponsiveSettingsPicker(
      icon: Icons.brightness_6_outlined,
      title: l10n.settingsTheme,
      child: DropdownButton<ThemeMode>(
        value: current,
        isExpanded: true,
        items: [
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text(l10n.settingsThemeLight),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text(l10n.settingsThemeDark),
          ),
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text(l10n.settingsThemeSystem),
          ),
        ],
        onChanged: (m) {
          if (m != null) onChanged(m);
        },
      ),
    );
  }
}

class _CurrencyTile extends StatelessWidget {
  const _CurrencyTile({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveSettingsPicker(
      icon: Icons.attach_money,
      title: context.l10n.settingsCurrency,
      child: DropdownButton<String>(
        value: current,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: '฿', child: Text('฿ (THB)')),
          DropdownMenuItem(value: '\$', child: Text('\$ (USD)')),
          DropdownMenuItem(value: '€', child: Text('€ (EUR)')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _DateFormatTile extends StatelessWidget {
  const _DateFormatTile({required this.current, required this.onChanged});
  final String current;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveSettingsPicker(
      icon: Icons.calendar_today_outlined,
      title: context.l10n.settingsDateFormat,
      child: DropdownButton<String>(
        value: current,
        isExpanded: true,
        items: const [
          DropdownMenuItem(value: 'dd/MM/yyyy', child: Text('dd/MM/yyyy')),
          DropdownMenuItem(value: 'MM/dd/yyyy', child: Text('MM/dd/yyyy')),
          DropdownMenuItem(value: 'yyyy-MM-dd', child: Text('yyyy-MM-dd')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

class _ResponsiveSettingsPicker extends StatelessWidget {
  const _ResponsiveSettingsPicker({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(icon),
                    const SizedBox(width: 16),
                    Expanded(child: Text(title)),
                  ],
                ),
                const SizedBox(height: 8),
                child,
              ],
            ),
          );
        }

        return ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: SizedBox(width: 180, child: child),
        );
      },
    );
  }
}
