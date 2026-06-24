import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/features/settings/presentation/theme/settings_theme_extension.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_info_form/shop_contact_field.dart';
import 'package:promsell_pos_ce/features/settings/presentation/widgets/shop/shop_info_form/shop_name_field.dart';

class ShopInfoForm extends StatelessWidget {
  const ShopInfoForm({
    required this.initialShopName,
    required this.initialAddress,
    required this.initialPhone,
    required this.onSave,
    super.key,
  });

  final String initialShopName;
  final String initialAddress;
  final String initialPhone;
  final ValueChanged<({String shopName, String address, String phone})> onSave;

  @override
  Widget build(BuildContext context) {
    final st = context.settingsTheme;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 10, top: 8),
          child: Text(
            'Details'.toUpperCase(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: st.mutedText,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: st.cardBackground,
            borderRadius: BorderRadius.circular(st.cardRadius),
            border: Border.all(color: st.cardBorderColor, width: 0.8),
          ),
          child: Column(
            children: [
              ShopNameField(
                initialValue: initialShopName,
                onSave: (v) => onSave((
                  shopName: v,
                  address: initialAddress,
                  phone: initialPhone,
                )),
              ),
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: st.cardBorderColor,
              ),
              ShopContactField(
                initialAddress: initialAddress,
                initialPhone: initialPhone,
                onSaveAddress: (v) => onSave((
                  shopName: initialShopName,
                  address: v,
                  phone: initialPhone,
                )),
                onSavePhone: (v) => onSave((
                  shopName: initialShopName,
                  address: initialAddress,
                  phone: v,
                )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
