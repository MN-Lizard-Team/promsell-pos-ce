import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_info_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_preview_card.dart';

class ShopInfoSettingsPage extends StatefulWidget {
  const ShopInfoSettingsPage({super.key});

  @override
  State<ShopInfoSettingsPage> createState() => _ShopInfoSettingsPageState();
}

class _ShopInfoSettingsPageState extends State<ShopInfoSettingsPage> {
  /// Stable key so [ShopInfoForm] is not recreated on every settings rebuild
  /// (which would dispose TextEditingControllers mid-frame).
  final _formKey = GlobalKey<ShopInfoFormState>();

  void _save(BuildContext context) {
    final form = _formKey.currentState;
    if (form == null) return;
    form.submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        final s = state.settings;
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;

        return SettingsLeafChrome(
          title: l10n.settingsShopInfo,
          header: ShopPreviewCard(
            shopName: s.shopName,
            address: s.address,
            phone: s.phone,
          ),
          bottomNavigationBar: StickyActionBar(
            primaryLabel: l10n.save,
            onPrimary: () => _save(context),
          ),
          children: [
            ShopInfoForm(
              key: _formKey,
              initialShopName: s.shopName,
              initialAddress: s.address,
              initialPhone: s.phone,
              onSave: (values) {
                cubit.updateField(
                  (settings) => settings.copyWith(
                    shopName: values.shopName,
                    address: values.address,
                    phone: values.phone,
                  ),
                );
                if (!context.mounted) return;
                AppSnackBar.success(context, l10n.settingsSaved);
              },
            ),
          ],
        );
      },
    );
  }
}
