import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';

/// Preset retail / food-service units (same list as legacy UnitField).
const kProductUnits = <String>[
  'ชิ้น',
  'ขวด',
  'กระป๋อง',
  'กล่อง',
  'ถุง',
  'แพ็ก',
  'กก.',
  'กรัม',
  'ลิตร',
  'มล.',
  'ชุด',
  'จาน',
  'แก้ว',
];

/// Opens a bottom sheet to pick a product unit. Returns null if dismissed.
Future<String?> showUnitPicker(BuildContext context, {String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    showDragHandle: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => _UnitPickerSheet(current: current ?? ''),
  );
}

class _UnitPickerSheet extends StatefulWidget {
  const _UnitPickerSheet({required this.current});

  final String current;

  @override
  State<_UnitPickerSheet> createState() => _UnitPickerSheetState();
}

class _UnitPickerSheetState extends State<_UnitPickerSheet> {
  late final TextEditingController _customCtrl;
  late bool _isCustom;

  @override
  void initState() {
    super.initState();
    final current = widget.current.trim();
    _isCustom = current.isNotEmpty && !kProductUnits.contains(current);
    _customCtrl = TextEditingController(text: _isCustom ? current : '');
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _selectPreset(String unit) {
    HapticFeedback.selectionClick();
    Navigator.pop(context, unit);
  }

  void _applyCustom() {
    final value = _customCtrl.text.trim();
    if (value.isEmpty) return;
    HapticFeedback.selectionClick();
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height * 0.72;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.productUnitLabel,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView(
                    children: [
                      for (final unit in kProductUnits)
                        ListTile(
                          title: Text(unit),
                          trailing: widget.current == unit
                              ? Icon(Icons.check_circle, color: cs.primary)
                              : null,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () => _selectPreset(unit),
                        ),
                      const Divider(height: 24),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.productUnitOther),
                        value: _isCustom,
                        onChanged: (v) => setState(() => _isCustom = v),
                      ),
                      if (_isCustom) ...[
                        const SizedBox(height: 8),
                        AppTextField(
                          controller: _customCtrl,
                          labelText: l10n.productCustomUnit,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _applyCustom(),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _applyCustom,
                          child: Text(l10n.save),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
