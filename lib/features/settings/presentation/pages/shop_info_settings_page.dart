import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop_info_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop_preview_card.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/settings_dropdown_tile.dart';

class ShopInfoSettingsPage extends StatelessWidget {
  const ShopInfoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;
        final accent = context.settingsTheme.softAccent;

        return Scaffold(
          appBar: AppBar(title: Text(l10n.settingsShopInfo)),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              ShopPreviewCard(
                shopName: s.shopName,
                address: s.address,
                phone: s.phone,
              ),
              const SizedBox(height: 24),
              ShopInfoForm(
                initialShopName: s.shopName,
                initialAddress: s.address,
                initialPhone: s.phone,
                onSave: (values) {
                  cubit.updateField(
                    (s) => s.copyWith(
                      shopName: values.shopName,
                      address: values.address,
                      phone: values.phone,
                    ),
                  );
                  HapticFeedback.lightImpact();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.settingsSaved),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              SettingsDropdownTile<String>(
                icon: Icons.receipt_long_outlined,
                title: l10n.settingsReceiptSize,
                accentColor: accent,
                value: s.receiptSize,
                items: const ['80mm', 'A4'],
                itemLabelBuilder: (v) {
                  if (v == '80mm') return l10n.receiptSize80mm;
                  return l10n.receiptSizeA4;
                },
                onChanged: (v) {
                  cubit.updateField((s) => s.copyWith(receiptSize: v));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
