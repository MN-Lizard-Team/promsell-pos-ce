import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/section_card.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/app_settings.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_preset.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_text_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/language_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/theme_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/currency_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/date_format_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/responsive_settings_picker.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/discount_preset_card.dart';

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
  late final TextEditingController _maxDiscountCtrl;
  late final TextEditingController _maxDiscountAmountCtrl;
  bool _manualSave = false;

  bool get _hasTextChanges =>
      _shopNameCtrl.text.trim() != _draft.shopName ||
      _addressCtrl.text.trim() != _draft.address ||
      _phoneCtrl.text.trim() != _draft.phone ||
      _receiptNoteCtrl.text.trim() != _draft.receiptNote ||
      (int.tryParse(_lowStockCtrl.text) ?? 5) != _draft.lowStockThreshold ||
      (double.tryParse(_vatRateCtrl.text) ?? 7.0) != _draft.vatRate ||
      (double.tryParse(_maxDiscountCtrl.text) ?? 100.0) !=
          _draft.maxDiscountPercent ||
      (double.tryParse(_maxDiscountAmountCtrl.text) ?? 0.0) !=
          _draft.maxDiscountAmount;

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
    _maxDiscountCtrl = TextEditingController(
      text: _draft.maxDiscountPercent.toString(),
    );
    _maxDiscountAmountCtrl = TextEditingController(
      text: _draft.maxDiscountAmount.toString(),
    );
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
      if (_maxDiscountCtrl.text ==
          oldWidget.settings.maxDiscountPercent.toString()) {
        _maxDiscountCtrl.text = widget.settings.maxDiscountPercent.toString();
      }
      if (_maxDiscountAmountCtrl.text ==
          oldWidget.settings.maxDiscountAmount.toString()) {
        _maxDiscountAmountCtrl.text = widget.settings.maxDiscountAmount
            .toString();
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
    _maxDiscountCtrl.dispose();
    _maxDiscountAmountCtrl.dispose();
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
      maxDiscountPercent:
          double.tryParse(_maxDiscountCtrl.text.trim()) ??
          _draft.maxDiscountPercent,
      maxDiscountAmount:
          double.tryParse(_maxDiscountAmountCtrl.text.trim()) ??
          _draft.maxDiscountAmount,
    );
    context.read<SettingsCubit>().update(updated);
  }

  void _updateDraft(AppSettings updated) {
    setState(() => _draft = updated);
    context.read<SettingsCubit>().update(updated);
  }

  void _updatePreset(int index, DiscountPreset preset) {
    final presets = [..._draft.discountPresets];
    presets[index] = preset;
    _updateDraft(_draft.copyWith(discountPresets: presets));
  }

  void _addPreset() {
    final id = 'preset-${DateTime.now().millisecondsSinceEpoch}';
    final preset = DiscountPreset(
      id: id,
      name: 'New Preset',
      type: 'PERCENT',
      values: const [5.0, 10.0],
    );
    _updateDraft(
      _draft.copyWith(discountPresets: [..._draft.discountPresets, preset]),
    );
  }

  void _deletePreset(int index) {
    if (_draft.discountPresets.length <= 1) return;
    final presets = [..._draft.discountPresets]..removeAt(index);
    final deletedId = _draft.discountPresets[index].id;
    final newActiveId = _draft.activeDiscountPresetId == deletedId
        ? presets.first.id
        : _draft.activeDiscountPresetId;
    _updateDraft(
      _draft.copyWith(
        discountPresets: presets,
        activeDiscountPresetId: newActiveId,
      ),
    );
  }

  void _setActivePreset(String id) {
    _updateDraft(_draft.copyWith(activeDiscountPresetId: id));
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
                    SettingsSectionHeader(l10n.settingsDiscountPolicy),
                    SwitchListTile(
                      secondary: const Icon(Icons.local_offer_outlined),
                      title: Text(l10n.enableItemDiscount),
                      value: _draft.enableItemDiscount,
                      onChanged: (value) {
                        _updateDraft(
                          _draft.copyWith(enableItemDiscount: value),
                        );
                      },
                    ),
                    SwitchListTile(
                      secondary: const Icon(Icons.local_offer),
                      title: Text(l10n.enableCartDiscount),
                      value: _draft.enableCartDiscount,
                      onChanged: (value) {
                        _updateDraft(
                          _draft.copyWith(enableCartDiscount: value),
                        );
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SettingsTextField(
                            controller: _maxDiscountCtrl,
                            label: l10n.maxDiscountPercent,
                            icon: Icons.percent_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        Expanded(
                          child: SettingsTextField(
                            controller: _maxDiscountAmountCtrl,
                            label: l10n.maxDiscountAmount,
                            icon: Icons.trending_down_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            l10n.discountPresetsTitle,
                            style: theme.textTheme.titleSmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._draft.discountPresets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final preset = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        child: DiscountPresetCard(
                          preset: preset,
                          isActive: preset.id == _draft.activeDiscountPresetId,
                          canDelete: _draft.discountPresets.length > 1,
                          onChanged: (p) => _updatePreset(index, p),
                          onDelete: () => _deletePreset(index),
                          onSetActive: () => _setActivePreset(preset.id),
                        ),
                      );
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: OutlinedButton.icon(
                        onPressed: _addPreset,
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addDiscountPreset),
                      ),
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
