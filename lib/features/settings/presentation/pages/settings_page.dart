import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/section_card.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/language_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/theme_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/currency_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/date_format_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/responsive_settings_picker.dart';

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
  late final TextEditingController _lowStockCtrl;
  late final TextEditingController _vatRateCtrl;
  bool _manualSave = false;

  bool get _hasTextChanges =>
      _shopNameCtrl.text.trim() != _draft.shopName ||
      _addressCtrl.text.trim() != _draft.address ||
      _phoneCtrl.text.trim() != _draft.phone ||
      _receiptNoteCtrl.text.trim() != _draft.receiptNote ||
      (int.tryParse(_lowStockCtrl.text) ?? 5) != _draft.lowStockThreshold ||
      (double.tryParse(_vatRateCtrl.text) ?? 7.0) != _draft.vatRate;

  @override
  void initState() {
    super.initState();
    _draft = widget.settings;
    _shopNameCtrl = TextEditingController(text: _draft.shopName);
    _addressCtrl = TextEditingController(text: _draft.address);
    _phoneCtrl = TextEditingController(text: _draft.phone);
    _receiptNoteCtrl = TextEditingController(text: _draft.receiptNote);
    _lowStockCtrl = TextEditingController(
      text: _draft.lowStockThreshold.toString(),
    );
    _vatRateCtrl = TextEditingController(text: _draft.vatRate.toString());
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
      if (_vatRateCtrl.text == oldWidget.settings.vatRate.toString()) {
        _vatRateCtrl.text = widget.settings.vatRate.toString();
      }
    }
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _receiptNoteCtrl.dispose();
    _lowStockCtrl.dispose();
    _vatRateCtrl.dispose();
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
      lowStockThreshold:
          int.tryParse(_lowStockCtrl.text.trim()) ?? _draft.lowStockThreshold,
      vatRate: double.tryParse(_vatRateCtrl.text.trim()) ?? _draft.vatRate,
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
                    SettingsSectionHeader(l10n.settingsGeneral),
                    LanguageTile(
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
                    ThemeTile(
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
                    SettingsSectionHeader(l10n.settingsShopInfo),
                    SettingsTextField(
                      controller: _shopNameCtrl,
                      label: l10n.settingsShopName,
                      icon: Icons.store_outlined,
                    ),
                    SettingsTextField(
                      controller: _addressCtrl,
                      label: l10n.settingsAddress,
                      icon: Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    SettingsTextField(
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
                    SettingsSectionHeader(l10n.settingsSales),
                    CurrencyTile(
                      current: _draft.currency,
                      onChanged: (currency) {
                        final updated = _draft.copyWith(currency: currency);
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                    DateFormatTile(
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
                    SettingsSectionHeader(l10n.settingsReceipt),
                    SettingsTextField(
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
                    SwitchListTile(
                      secondary: const Icon(Icons.print_outlined),
                      title: Text(l10n.settingsAutoPrintPrompt),
                      value: _draft.autoPrintPrompt,
                      onChanged: (value) {
                        final updated = _draft.copyWith(autoPrintPrompt: value);
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.preview_outlined),
                      title: Text(l10n.settingsShowPreSalePreview),
                      value: _draft.showPreSalePreview,
                      onChanged: (value) {
                        final updated = _draft.copyWith(
                          showPreSalePreview: value,
                        );
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.receipt_outlined),
                      title: Text(l10n.settingsShowPostSalePreview),
                      value: _draft.showPostSalePreview,
                      onChanged: (value) {
                        final updated = _draft.copyWith(
                          showPostSalePreview: value,
                        );
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                    ResponsiveSettingsPicker(
                      icon: Icons.receipt_long_outlined,
                      title: l10n.settingsReceiptPreviewStyle,
                      child: DropdownButton<String>(
                        value: _draft.receiptPreviewStyle,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'thermal',
                            child: Text(l10n.receiptPreviewStyleThermal),
                          ),
                          DropdownMenuItem(
                            value: 'card',
                            child: Text(l10n.receiptPreviewStyleCard),
                          ),
                          DropdownMenuItem(
                            value: 'none',
                            child: Text(l10n.receiptPreviewStyleNone),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            final updated = _draft.copyWith(
                              receiptPreviewStyle: v,
                            );
                            setState(() => _draft = updated);
                            context.read<SettingsCubit>().update(updated);
                          }
                        },
                      ),
                    ),
                    ResponsiveSettingsPicker(
                      icon: Icons.percent_outlined,
                      title: l10n.settingsVatMode,
                      child: DropdownButton<String>(
                        value: _draft.vatMode,
                        isExpanded: true,
                        items: [
                          DropdownMenuItem(
                            value: 'NONE',
                            child: Text(l10n.vatModeNone),
                          ),
                          DropdownMenuItem(
                            value: 'INCLUSIVE',
                            child: Text(l10n.vatModeInclusive),
                          ),
                          DropdownMenuItem(
                            value: 'EXCLUSIVE',
                            child: Text(l10n.vatModeExclusive),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            final updated = _draft.copyWith(vatMode: v);
                            setState(() => _draft = updated);
                            context.read<SettingsCubit>().update(updated);
                          }
                        },
                      ),
                    ),
                    if (_draft.vatMode != 'NONE')
                      SettingsTextField(
                        controller: _vatRateCtrl,
                        label: l10n.settingsVatRate,
                        icon: Icons.percent,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SectionCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    SettingsSectionHeader(l10n.settingsStockPolicy),
                    SwitchListTile(
                      secondary: const Icon(Icons.shopping_cart_outlined),
                      title: Text(l10n.allowOversell),
                      subtitle: Text(l10n.allowOversellHint),
                      value: _draft.allowOversell,
                      onChanged: (value) {
                        final updated = _draft.copyWith(allowOversell: value);
                        setState(() => _draft = updated);
                        context.read<SettingsCubit>().update(updated);
                      },
                    ),
                    SettingsTextField(
                      controller: _lowStockCtrl,
                      label: l10n.lowStockThreshold,
                      icon: Icons.warning_amber_outlined,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
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
                  _lowStockCtrl,
                  _vatRateCtrl,
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
