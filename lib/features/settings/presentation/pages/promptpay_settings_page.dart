import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay_info_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/promptpay_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_section_card.dart';

class PromptpaySettingsPage extends StatelessWidget {
  const PromptpaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final st = context.settingsTheme;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.promptpay)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              PromptpayPreviewCard(
                promptpayId: s.promptpayId,
                st: st,
                l10n: l10n,
                overlayIcon: s.qrOverlayIcon,
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.promptpayAccount,
                children: [
                  _buildIdTile(context, s, cubit, st, l10n),
                  _buildBillerIdTile(context, s, cubit, st, l10n),
                ],
              ),
              const SizedBox(height: 24),
              SettingsSectionCard(
                title: l10n.settingsTitle,
                children: [
                  ListTile(
                    minTileHeight: st.tileMinHeight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(l10n.promptpayTimeoutSetting),
                    subtitle: Text(
                      '${s.promptPayTimeout ~/ 60} ${l10n.minutes}',
                    ),
                    trailing: SizedBox(
                      width: 160,
                      child: Slider(
                        value: s.promptPayTimeout.toDouble(),
                        min: 60,
                        max: 300,
                        divisions: 4,
                        label: '${s.promptPayTimeout ~/ 60} min',
                        onChanged: (v) {
                          HapticFeedback.selectionClick();
                          cubit.updateField(
                            (current) =>
                                current.copyWith(promptPayTimeout: v.round()),
                          );
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    minTileHeight: st.tileMinHeight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(l10n.promptpaySoundEnabled),
                    trailing: Switch(
                      value: s.promptPaySoundEnabled,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        cubit.updateField(
                          (current) =>
                              current.copyWith(promptPaySoundEnabled: v),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    minTileHeight: st.tileMinHeight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(l10n.settingsDefaultQrType),
                    trailing: SizedBox(
                      width: 200,
                      child: SegmentedButton<String>(
                        segments: [
                          ButtonSegment(
                            value: 'transfer',
                            label: Text(l10n.settingsDefaultQrTypeTransfer),
                          ),
                          ButtonSegment(
                            value: 'bill',
                            label: Text(l10n.settingsDefaultQrTypeBill),
                          ),
                        ],
                        selected: {s.defaultQrType},
                        onSelectionChanged: (v) {
                          HapticFeedback.selectionClick();
                          cubit.updateField(
                            (current) =>
                                current.copyWith(defaultQrType: v.first),
                          );
                        },
                      ),
                    ),
                  ),
                  ListTile(
                    minTileHeight: st.tileMinHeight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(l10n.settingsAutoConfirmAfterSlip),
                    subtitle: Text(
                      l10n.settingsAutoConfirmAfterSlipHint,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: st.mutedText),
                    ),
                    trailing: Switch(
                      value: s.autoConfirmAfterSlip,
                      onChanged: (v) {
                        HapticFeedback.selectionClick();
                        cubit.updateField(
                          (current) =>
                              current.copyWith(autoConfirmAfterSlip: v),
                        );
                      },
                    ),
                  ),
                  ListTile(
                    minTileHeight: st.tileMinHeight,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(l10n.settingsQrOverlayIcon),
                    subtitle: Wrap(
                      spacing: 8,
                      children: [
                        _buildIconChip(context, s, cubit, '', Icons.block),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'wallet',
                          Icons.account_balance_wallet_outlined,
                        ),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'store',
                          Icons.store_outlined,
                        ),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'person',
                          Icons.person_outline,
                        ),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'payment',
                          Icons.payment_outlined,
                        ),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'credit_card',
                          Icons.credit_card_outlined,
                        ),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'shopping_bag',
                          Icons.shopping_bag_outlined,
                        ),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'local_atm',
                          Icons.local_atm_outlined,
                        ),
                        _buildIconChip(
                          context,
                          s,
                          cubit,
                          'qr_code',
                          Icons.qr_code_outlined,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              PromptpayInfoCard(st: st, l10n: l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIdTile(
    BuildContext context,
    dynamic s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final hasId = s.promptpayId.isNotEmpty;

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
        hasId ? s.promptpayId : l10n.settingsPromptpayIdHint,
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
      onTap: () => _showIdDialog(context, s, cubit, st, l10n),
    );
  }

  Widget _buildIconChip(
    BuildContext context,
    dynamic s,
    SettingsCubit cubit,
    String iconName,
    IconData iconData,
  ) {
    final isSelected = s.qrOverlayIcon == iconName;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        cubit.updateField(
          (current) => current.copyWith(qrOverlayIcon: iconName),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: theme.colorScheme.primary, width: 2)
              : null,
        ),
        child: Icon(
          iconData,
          size: 20,
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  void _showIdDialog(
    BuildContext context,
    dynamic s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final ctrl = TextEditingController(text: s.promptpayId);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsPromptpayId),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 17,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.settingsPromptpayIdHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
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
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                HapticFeedback.lightImpact();
                final raw = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
                cubit.updateField(
                  (settings) => settings.copyWith(promptpayId: raw),
                );
                Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Widget _buildBillerIdTile(
    BuildContext context,
    dynamic s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final hasId = s.billerId.isNotEmpty;

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
          Icons.receipt_long_outlined,
          color: st.softAccent,
          size: 24,
        ),
      ),
      title: Text(
        l10n.settingsBillerId,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        hasId ? s.billerId : l10n.settingsBillerIdHint,
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
      onTap: () => _showBillerIdDialog(context, s, cubit, st, l10n),
    );
  }

  void _showBillerIdDialog(
    BuildContext context,
    dynamic s,
    SettingsCubit cubit,
    SettingsThemeExtension st,
    AppLocalizations l10n,
  ) {
    final ctrl = TextEditingController(text: s.billerId);
    final formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsBillerId),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 280,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              maxLength: 15,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.settingsBillerIdHint,
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final clean = v.replaceAll(RegExp(r'[^0-9]'), '');
                if (clean.length != 13 && clean.length != 15) {
                  return 'Must be 13 or 15 digits';
                }
                return null;
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                HapticFeedback.lightImpact();
                final raw = ctrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim();
                cubit.updateField(
                  (settings) => settings.copyWith(billerId: raw),
                );
                Navigator.of(ctx).pop();
              }
            },
            style: FilledButton.styleFrom(backgroundColor: st.softAccent),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
