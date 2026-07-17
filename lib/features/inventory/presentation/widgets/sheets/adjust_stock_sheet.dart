import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/theme/app_colors.dart';
import 'package:promsell_pos_ce/core/utils/currency_formatter.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_lock_pin_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:promsell_pos_ce/features/inventory/domain/usecases/adjust_stock.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Bottom-sheet adjust stock with +/- mode, live preview, reason chips.
///
/// Returns the **new stock balance** on success, or `null` if cancelled / failed.
/// When store PIN lock is enabled, prompts before opening the sheet.
Future<int?> showAdjustStockSheet(
  BuildContext context, {
  required String productId,
  required String productName,
  required int currentStock,
  String? unit,
}) async {
  final unlocked = await ensureAppUnlocked(
    context,
    title: context.l10n.appLockConfirmStock,
  );
  if (!unlocked || !context.mounted) return null;

  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    showDragHandle: false,
    elevation: 0,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => _AdjustStockSheet(
      productId: productId,
      productName: productName,
      currentStock: currentStock,
      unit: unit,
    ),
  );
}

class _AdjustStockSheet extends StatefulWidget {
  const _AdjustStockSheet({
    required this.productId,
    required this.productName,
    required this.currentStock,
    this.unit,
  });

  final String productId;
  final String productName;
  final int currentStock;
  final String? unit;

  @override
  State<_AdjustStockSheet> createState() => _AdjustStockSheetState();
}

class _AdjustStockSheetState extends State<_AdjustStockSheet> {
  final _qtyCtrl = TextEditingController();
  final _reasonCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// true = add stock, false = remove stock
  bool _isAdd = true;
  bool _saving = false;
  String? _selectedPreset;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _reasonCtrl.dispose();
    super.dispose();
  }

  int get _deltaAbs => int.tryParse(_qtyCtrl.text.trim()) ?? 0;

  int get _signedDelta => _isAdd ? _deltaAbs : -_deltaAbs;

  int get _previewStock => widget.currentStock + _signedDelta;

  bool get _previewValid => _deltaAbs > 0 && _previewStock >= 0;

  List<String> _presets(AppLocalizations l10n) {
    if (_isAdd) {
      return [
        l10n.adjustReasonRestock,
        l10n.adjustReasonCountCorrection,
        l10n.adjustReasonReturn,
        l10n.adjustReasonOther,
      ];
    }
    return [
      l10n.adjustReasonDamaged,
      l10n.adjustReasonLost,
      l10n.adjustReasonCountCorrection,
      l10n.adjustReasonOther,
    ];
  }

  void _selectPreset(String label, AppLocalizations l10n) {
    setState(() {
      _selectedPreset = label;
      if (label == l10n.adjustReasonOther) {
        if (_presets(l10n).contains(_reasonCtrl.text.trim()) ||
            _reasonCtrl.text.trim().isEmpty) {
          _reasonCtrl.clear();
        }
      } else {
        _reasonCtrl.text = label;
      }
    });
  }

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = context.l10n;
    final formOk = _formKey.currentState?.validate() ?? false;
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      AppSnackBar.error(context, l10n.adjustReasonRequired);
      return;
    }
    if (!formOk || !_previewValid) return;

    final delta = _signedDelta;
    final newStock = _previewStock;

    setState(() => _saving = true);
    try {
      await sl<AdjustStock>().call(
        productId: widget.productId,
        qtyChange: delta,
        reason: reason,
      );
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      AppSnackBar.success(context, l10n.adjustSuccess);
      Navigator.pop(context, newStock);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      final msg = e.toString();
      final clean = msg
          .replaceFirst(RegExp(r'^(Bad state|StateError):\s*'), '')
          .trim();
      AppSnackBar.error(context, clean.isEmpty ? l10n.errorOccurred : clean);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final unit = (widget.unit ?? '').trim();
    final unitLabel = unit.isEmpty ? l10n.quantityLabel : unit;
    final currentText = CurrencyFormatter.formatGroupedInt(widget.currentStock);
    final previewText = CurrencyFormatter.formatGroupedInt(_previewStock);
    final delta = _deltaAbs;
    final showPreview = delta > 0;
    final previewBad = showPreview && _previewStock < 0;
    final presets = _presets(l10n);
    final otherSelected = _selectedPreset == l10n.adjustReasonOther;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: 16 + bottomInset,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.adjustStockTitle(widget.productName),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                // Current stock — solid surface, high contrast
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        color: cs.onSurface,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.adjustCurrentStock(currentText, unitLabel),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Mode: solid filled / outlined — avoid low-contrast SegmentedButton
                Row(
                  children: [
                    Expanded(
                      child: _ModeButton(
                        selected: _isAdd,
                        icon: Icons.add,
                        label: l10n.adjustModeAdd,
                        selectedColor: cs.primary,
                        selectedFg: cs.onPrimary,
                        enabled: !_saving,
                        onTap: () => setState(() {
                          _isAdd = true;
                          final next = _presets(l10n);
                          if (_selectedPreset != null &&
                              _selectedPreset != l10n.adjustReasonOther &&
                              !next.contains(_selectedPreset)) {
                            _selectedPreset = null;
                            _reasonCtrl.clear();
                          }
                        }),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeButton(
                        selected: !_isAdd,
                        icon: Icons.remove,
                        label: l10n.adjustModeRemove,
                        selectedColor: cs.error,
                        selectedFg: cs.onError,
                        enabled: !_saving,
                        onTap: () => setState(() {
                          _isAdd = false;
                          final next = _presets(l10n);
                          if (_selectedPreset != null &&
                              _selectedPreset != l10n.adjustReasonOther &&
                              !next.contains(_selectedPreset)) {
                            _selectedPreset = null;
                            _reasonCtrl.clear();
                          }
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  controller: _qtyCtrl,
                  labelText: l10n.adjustQtyAmountLabel,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  enabled: !_saving,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return l10n.quantityRequired;
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n <= 0) return l10n.invalidQuantity;
                    final next = _isAdd
                        ? widget.currentStock + n
                        : widget.currentStock - n;
                    if (next < 0) return l10n.adjustWouldGoNegative;
                    return null;
                  },
                ),
                if (showPreview) ...[
                  const SizedBox(height: 12),
                  Container(
                    key: const ValueKey('adjust-stock-preview'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: previewBad
                          ? cs.errorContainer
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: previewBad ? cs.error : cs.outline,
                        width: previewBad ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              previewBad
                                  ? Icons.warning_amber_rounded
                                  : (_isAdd
                                        ? Icons.trending_up
                                        : Icons.trending_down),
                              color: previewBad
                                  ? cs.error
                                  : (_isAdd ? cs.primary : cs.error),
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                previewBad
                                    ? l10n.adjustWouldGoNegative
                                    : l10n.adjustPreviewResult(
                                        currentText,
                                        previewText,
                                        unitLabel,
                                      ),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: previewBad
                                      ? cs.onErrorContainer
                                      : cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!previewBad) ...[
                          const SizedBox(height: 6),
                          Text(
                            _isAdd
                                ? '+${CurrencyFormatter.formatGroupedInt(delta)} $unitLabel'
                                : '−${CurrencyFormatter.formatGroupedInt(delta)} $unitLabel',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _isAdd ? cs.primary : cs.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  l10n.adjustReasonLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in presets)
                      ChoiceChip(
                        label: Text(
                          p,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _selectedPreset == p
                                ? cs.onPrimary
                                : cs.onSurface,
                          ),
                        ),
                        selected: _selectedPreset == p,
                        selectedColor: cs.primary,
                        backgroundColor: cs.surface,
                        side: BorderSide(
                          color: _selectedPreset == p ? cs.primary : cs.outline,
                          width: 1.2,
                        ),
                        showCheckmark: false,
                        onSelected: _saving
                            ? null
                            : (selected) {
                                if (selected) {
                                  _selectPreset(p, l10n);
                                } else if (_selectedPreset == p) {
                                  setState(() {
                                    _selectedPreset = null;
                                    _reasonCtrl.clear();
                                  });
                                }
                              },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (otherSelected)
                  AppTextField(
                    controller: _reasonCtrl,
                    labelText: l10n.adjustReasonOtherHint,
                    textInputAction: TextInputAction.done,
                    enabled: !_saving,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.adjustReasonRequired
                        : null,
                  )
                else if (_reasonCtrl.text.trim().isEmpty)
                  Text(
                    l10n.adjustReasonRequired,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Text(
                      _reasonCtrl.text.trim(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: cs.onSurface,
                          side: BorderSide(color: cs.outline),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          l10n.cancel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: const ValueKey('adjust-stock-save'),
                        onPressed: _saving ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.onWarning,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onWarning,
                                ),
                              )
                            : Text(
                                l10n.save,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// High-contrast mode toggle (Add / Remove).
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.selectedColor,
    required this.selectedFg,
    required this.enabled,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final Color selectedColor;
  final Color selectedFg;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: selected ? selectedColor : cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? selectedColor : cs.outline,
          width: selected ? 0 : 1.5,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: selected ? selectedFg : cs.onSurface),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? selectedFg : cs.onSurface,
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
