import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_leaf_chrome.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shared/settings_state_view.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_info_form.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_preview_card.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class ShopInfoSettingsPage extends StatefulWidget {
  const ShopInfoSettingsPage({super.key});

  @override
  State<ShopInfoSettingsPage> createState() => _ShopInfoSettingsPageState();
}

class _ShopInfoSettingsPageState extends State<ShopInfoSettingsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// Stable key so [ShopInfoForm] is not recreated on every settings rebuild
  /// (which would dispose TextEditingControllers mid-frame).
  final _formKey = GlobalKey<ShopInfoFormState>();

  void _save(BuildContext context) {
    final form = _formKey.currentState;
    if (form == null) return;
    form.submit();
  }

  Future<bool> _confirmExit(BuildContext context) async {
    final form = _formKey.currentState;
    if (form == null || !form.isDirty) return true;
    final l10n = context.l10n;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.unsavedChangesTitle),
        content: Text(l10n.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.discardChanges),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (prev, curr) =>
          prev.settings != curr.settings || prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<SettingsCubit>();
        final l10n = context.l10n;

        return SettingsStateView(
          state: state,
          onRetry: cubit.load,
          builder: (s) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) async {
              if (didPop) return;
              if (await _confirmExit(context) && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: SettingsLeafChrome(
              title: l10n.settingsShopInfo,
              heroIcon: TablerIcons.buildingStore,
              heroAccent: AppColors.primary,
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
                  initialTaxId: s.taxId,
                  onSave: (values) {
                    cubit.updateField(
                      (settings) => settings.copyWith(
                        shopName: values.shopName,
                        address: values.address,
                        phone: values.phone,
                        taxId: values.taxId,
                      ),
                    );
                    if (!context.mounted) return;
                    AppSnackBar.success(context, l10n.settingsSaved);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
