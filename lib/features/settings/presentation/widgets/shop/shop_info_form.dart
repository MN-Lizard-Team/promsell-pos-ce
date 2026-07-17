import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';

class ShopInfoValues {
  const ShopInfoValues({
    required this.shopName,
    required this.address,
    required this.phone,
  });

  final String shopName;
  final String address;
  final String phone;
}

/// Shop identity form — peer style: [FormSectionCard] + [AppTextField].
///
/// Parent owns commit (e.g. [StickyActionBar]); call [ShopInfoFormState.submit]
/// after validation.
class ShopInfoForm extends StatefulWidget {
  const ShopInfoForm({
    super.key,
    required this.initialShopName,
    required this.initialAddress,
    required this.initialPhone,
    required this.onSave,
  });

  final String initialShopName;
  final String initialAddress;
  final String initialPhone;
  final ValueChanged<ShopInfoValues> onSave;

  @override
  State<ShopInfoForm> createState() => ShopInfoFormState();
}

class ShopInfoFormState extends State<ShopInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final FocusNode _nameFocus;
  late final FocusNode _addressFocus;
  late final FocusNode _phoneFocus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialShopName);
    _addressCtrl = TextEditingController(text: widget.initialAddress);
    _phoneCtrl = TextEditingController(
      text: _formatPhoneDisplay(widget.initialPhone),
    );
    _nameFocus = FocusNode();
    _addressFocus = FocusNode();
    _phoneFocus = FocusNode();
  }

  void _syncIfUnfocused({
    required FocusNode focus,
    required TextEditingController controller,
    required String next,
  }) {
    if (focus.hasFocus) return;
    if (controller.text == next) return;
    controller.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  void didUpdateWidget(covariant ShopInfoForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only push external settings into fields when that field is not focused
    // (avoids clobber / dispose races after save rebuild).
    if (oldWidget.initialShopName != widget.initialShopName) {
      _syncIfUnfocused(
        focus: _nameFocus,
        controller: _nameCtrl,
        next: widget.initialShopName,
      );
    }
    if (oldWidget.initialAddress != widget.initialAddress) {
      _syncIfUnfocused(
        focus: _addressFocus,
        controller: _addressCtrl,
        next: widget.initialAddress,
      );
    }
    if (oldWidget.initialPhone != widget.initialPhone) {
      _syncIfUnfocused(
        focus: _phoneFocus,
        controller: _phoneCtrl,
        next: _formatPhoneDisplay(widget.initialPhone),
      );
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Validates and invokes [ShopInfoForm.onSave]. Returns whether save ran.
  bool submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    HapticFeedback.lightImpact();
    // Unfocus before parent rebuilds from cubit so fields are not mid-edit.
    FocusManager.instance.primaryFocus?.unfocus();
    widget.onSave(
      ShopInfoValues(
        shopName: _nameCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        phone: _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim(),
      ),
    );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: FormSectionCard(
          icon: Icons.store_outlined,
          title: l10n.settingsDetails,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _nameCtrl,
                focusNode: _nameFocus,
                labelText: l10n.settingsShopName,
                hintText: l10n.shopNameHint,
                maxLength: 50,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return l10n.shopNameRequired;
                  if (text.length > 50) return l10n.shopNameTooLong;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _addressCtrl,
                focusNode: _addressFocus,
                labelText: l10n.settingsAddress,
                hintText: l10n.addressHint,
                maxLines: 3,
                maxLength: 200,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.length > 200) return l10n.addressTooLong;
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _phoneCtrl,
                focusNode: _phoneFocus,
                labelText: l10n.settingsPhone,
                hintText: l10n.phoneHint,
                keyboardType: TextInputType.phone,
                maxLength: 12,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\s]')),
                ],
                onFieldSubmitted: (_) => submit(),
                validator: (v) {
                  final raw = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                  if (raw.isNotEmpty && (raw.length < 9 || raw.length > 10)) {
                    return l10n.phoneInvalid;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatPhoneDisplay(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length <= 3) return digits;
  if (digits.length <= 6) {
    return '${digits.substring(0, 3)}-${digits.substring(3)}';
  }
  if (digits.length <= 10) {
    return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
  }
  return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6, 10)}';
}
