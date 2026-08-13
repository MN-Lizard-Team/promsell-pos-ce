import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/validators.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class ShopInfoValues {
  const ShopInfoValues({
    required this.shopName,
    required this.address,
    required this.phone,
    required this.taxId,
  });

  final String shopName;
  final String address;
  final String phone;
  final String taxId;
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
    required this.initialTaxId,
    required this.onSave,
  });

  final String initialShopName;
  final String initialAddress;
  final String initialPhone;
  final String initialTaxId;
  final ValueChanged<ShopInfoValues> onSave;

  @override
  State<ShopInfoForm> createState() => ShopInfoFormState();
}

class ShopInfoFormState extends State<ShopInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _taxIdCtrl;
  late final FocusNode _nameFocus;
  late final FocusNode _addressFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _taxIdFocus;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialShopName);
    _addressCtrl = TextEditingController(text: widget.initialAddress);
    _phoneCtrl = TextEditingController(
      text: _formatPhoneDisplay(widget.initialPhone),
    );
    _taxIdCtrl = TextEditingController(text: widget.initialTaxId);
    _nameFocus = FocusNode();
    _addressFocus = FocusNode();
    _phoneFocus = FocusNode();
    _taxIdFocus = FocusNode();
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
    if (oldWidget.initialTaxId != widget.initialTaxId) {
      _syncIfUnfocused(
        focus: _taxIdFocus,
        controller: _taxIdCtrl,
        next: widget.initialTaxId,
      );
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _addressFocus.dispose();
    _phoneFocus.dispose();
    _taxIdFocus.dispose();
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _taxIdCtrl.dispose();
    super.dispose();
  }

  /// Whether any field differs from its initial value (unsaved changes).
  /// Normalizes both sides consistently: trim for text fields, digit-strip
  /// for phone/taxId so formatting differences don't cause false positives.
  bool get isDirty {
    String normalizeDigits(String s) =>
        s.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (_nameCtrl.text.trim() != widget.initialShopName.trim()) return true;
    if (_addressCtrl.text.trim() != widget.initialAddress.trim()) return true;
    if (normalizeDigits(_phoneCtrl.text) !=
        normalizeDigits(widget.initialPhone)) {
      return true;
    }
    if (normalizeDigits(_taxIdCtrl.text) !=
        normalizeDigits(widget.initialTaxId)) {
      return true;
    }
    return false;
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
        taxId: _taxIdCtrl.text.replaceAll(RegExp(r'[^0-9]'), '').trim(),
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
          icon: TablerIcons.buildingStore,
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
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9\-\s]')),
                ],
                validator: (v) {
                  final raw = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                  if (raw.isNotEmpty && (raw.length < 9 || raw.length > 10)) {
                    return l10n.phoneInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _taxIdCtrl,
                focusNode: _taxIdFocus,
                labelText: l10n.settingsTaxId,
                hintText: l10n.taxIdHint,
                keyboardType: TextInputType.number,
                maxLength: 13,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => submit(),
                validator: (v) {
                  final raw = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                  if (raw.isEmpty) return null;
                  if (raw.length != 13) {
                    return l10n.taxIdInvalid;
                  }
                  // Validate Thai tax ID checksum (mod-11).
                  try {
                    Validators.thaiTaxId(raw);
                  } on ArgumentError {
                    return l10n.taxIdChecksumInvalid;
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
  // Don't truncate — return raw digits for unusual lengths (international, etc.)
  return digits;
}
