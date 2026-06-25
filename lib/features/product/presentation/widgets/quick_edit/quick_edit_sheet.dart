import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/stock/stock_stepper.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum QuickEditField { name, price, stock }

enum _StockMode { set, adjust }

class QuickEditSheet extends StatefulWidget {
  const QuickEditSheet({
    super.key,
    required this.field,
    required this.initialValue,
    this.productName,
  });

  final QuickEditField field;
  final String initialValue;
  final String? productName;

  @override
  State<QuickEditSheet> createState() => _QuickEditSheetState();
}

class _QuickEditSheetState extends State<QuickEditSheet> {
  late final TextEditingController _ctrl;
  late final TextEditingController _adjustCtrl;
  late int _stockValue;
  _StockMode _stockMode = _StockMode.set;
  bool _isAdd = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _adjustCtrl = TextEditingController();
    _stockValue = int.tryParse(widget.initialValue) ?? 0;
    _ctrl.addListener(_validate);
    _adjustCtrl.addListener(_validate);
  }

  @override
  void didUpdateWidget(covariant QuickEditSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _stockValue = int.tryParse(widget.initialValue) ?? 0;
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_validate);
    _adjustCtrl.removeListener(_validate);
    _ctrl.dispose();
    _adjustCtrl.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _errorText = _computeError();
    });
  }

  String? _computeError() {
    switch (widget.field) {
      case QuickEditField.name:
        final text = _ctrl.text.trim();
        if (text.isEmpty) return null;
        if (text.length > 100) return context.l10n.productNameTooLong;
        return null;
      case QuickEditField.price:
        final price = double.tryParse(_ctrl.text.trim());
        if (_ctrl.text.trim().isEmpty) return null;
        if (price == null || price < 0) return context.l10n.invalidPrice;
        return null;
      case QuickEditField.stock:
        if (_stockMode == _StockMode.adjust) {
          final delta = int.tryParse(_adjustCtrl.text.trim());
          if (_adjustCtrl.text.trim().isEmpty) return null;
          if (delta == null || delta == 0) return context.l10n.invalidQuantity;
          final result = _isAdd ? _stockValue + delta : _stockValue - delta;
          if (result < 0) return context.l10n.invalidQuantity;
        }
        return null;
    }
  }

  bool get _canSave {
    switch (widget.field) {
      case QuickEditField.name:
        final text = _ctrl.text.trim();
        return text.isNotEmpty &&
            text.length <= 100 &&
            text != widget.initialValue;
      case QuickEditField.price:
        final price = double.tryParse(_ctrl.text.trim());
        return price != null &&
            price >= 0 &&
            price != double.tryParse(widget.initialValue);
      case QuickEditField.stock:
        if (_stockMode == _StockMode.set) {
          return _stockValue != int.tryParse(widget.initialValue);
        }
        final delta = int.tryParse(_adjustCtrl.text.trim());
        if (delta == null || delta <= 0) return false;
        final result = _isAdd ? _stockValue + delta : _stockValue - delta;
        return result >= 0 && result != _stockValue;
    }
  }

  String _resultValue() {
    if (widget.field == QuickEditField.stock) {
      if (_stockMode == _StockMode.set) return _stockValue.toString();
      final delta = int.tryParse(_adjustCtrl.text.trim()) ?? 0;
      return (_isAdd ? _stockValue + delta : _stockValue - delta).toString();
    }
    return _ctrl.text.trim();
  }

  int get _previewStock {
    if (widget.field != QuickEditField.stock) return _stockValue;
    if (_stockMode == _StockMode.set) return _stockValue;
    final delta = int.tryParse(_adjustCtrl.text.trim()) ?? 0;
    return _isAdd ? _stockValue + delta : _stockValue - delta;
  }

  void _onSave() {
    HapticFeedback.mediumImpact();
    Navigator.pop(context, _resultValue());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(theme),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _title(context, currency),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.productName != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      widget.productName!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 28),
                  if (widget.field == QuickEditField.stock)
                    _buildStockEditor(theme)
                  else
                    _buildTextField(theme, currency),
                  if (_errorText != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _errorText!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildHelperCard(context, theme),
                ],
              ),
            ),
          ),
          _buildBottomBar(theme, bottomInset),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, double bottomInset) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomInset),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.cancel),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _canSave ? _onSave : null,
              child: Text(context.l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(ThemeData theme, String currency) {
    return TextField(
      controller: _ctrl,
      keyboardType: _keyboardType,
      inputFormatters: _inputFormatters,
      autofocus: true,
      textAlign: TextAlign.center,
      style: theme.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: _fieldHint(context, currency),
        errorText: null,
        prefixIcon: widget.field == QuickEditField.price
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  currency,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 0),
      ),
    );
  }

  Widget _buildStockEditor(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SegmentedButton<_StockMode>(
          segments: [
            ButtonSegment(
              value: _StockMode.set,
              label: Text(context.l10n.quickEditStockSet),
            ),
            ButtonSegment(
              value: _StockMode.adjust,
              label: Text(context.l10n.quickEditStockAdjust),
            ),
          ],
          selected: {_stockMode},
          onSelectionChanged: (s) => setState(() {
            _stockMode = s.first;
            _errorText = _computeError();
          }),
        ),
        const SizedBox(height: 16),
        if (_stockMode == _StockMode.set)
          StockStepper(
            value: _stockValue,
            onChanged: (v) => setState(() {
              _stockValue = v;
              _errorText = _computeError();
            }),
            onQtyTap: () => _showInlineStockInput(theme),
          )
        else
          _buildAdjustRow(theme),
        const SizedBox(height: 12),
        _buildStockPreview(theme),
      ],
    );
  }

  Widget _buildAdjustRow(ThemeData theme) {
    return Row(
      children: [
        IconButton.filled(
          onPressed: () => setState(() {
            _isAdd = false;
            _errorText = _computeError();
          }),
          icon: const Icon(Icons.remove),
          style: IconButton.styleFrom(
            backgroundColor: _isAdd
                ? theme.colorScheme.surfaceContainerHigh
                : theme.colorScheme.primary,
            foregroundColor: _isAdd
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _adjustCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofocus: true,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '0',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Icon(
                  _isAdd ? Icons.add : Icons.remove,
                  size: 24,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 0,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton.filled(
          onPressed: () => setState(() {
            _isAdd = true;
            _errorText = _computeError();
          }),
          icon: const Icon(Icons.add),
          style: IconButton.styleFrom(
            backgroundColor: _isAdd
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHigh,
            foregroundColor: _isAdd
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildStockPreview(ThemeData theme) {
    final preview = _previewStock;
    final original = int.tryParse(widget.initialValue) ?? 0;
    final changed = preview != original;
    return Center(
      child: Text(
        '$original → $preview',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: changed
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
          fontWeight: changed ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  void _showInlineStockInput(ThemeData theme) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => _InlineStockInputDialog(
        initialValue: _stockValue,
        onSaved: (qty) => setState(() {
          _stockValue = qty;
          _errorText = _computeError();
        }),
      ),
    );
  }

  String _title(BuildContext context, String currency) {
    switch (widget.field) {
      case QuickEditField.name:
        return context.l10n.edit;
      case QuickEditField.price:
        return context.l10n.priceLabel(currency);
      case QuickEditField.stock:
        return context.l10n.quantityLabel;
    }
  }

  String _fieldHint(BuildContext context, String currency) {
    switch (widget.field) {
      case QuickEditField.name:
        return context.l10n.productNameLabel;
      case QuickEditField.price:
        return '0.00';
      case QuickEditField.stock:
        return '0';
    }
  }

  Widget _buildHelperCard(BuildContext context, ThemeData theme) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _helperText(context),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _helperText(BuildContext context) {
    switch (widget.field) {
      case QuickEditField.name:
        return context.l10n.quickEditNameHint;
      case QuickEditField.price:
        return context.l10n.quickEditPriceHint;
      case QuickEditField.stock:
        return _stockMode == _StockMode.set
            ? context.l10n.quickEditStockSetHint
            : context.l10n.quickEditStockAdjustHint;
    }
  }

  TextInputType? get _keyboardType {
    switch (widget.field) {
      case QuickEditField.name:
        return TextInputType.text;
      case QuickEditField.price:
        return const TextInputType.numberWithOptions(decimal: true);
      case QuickEditField.stock:
        return TextInputType.number;
    }
  }

  List<TextInputFormatter>? get _inputFormatters {
    switch (widget.field) {
      case QuickEditField.name:
        return null;
      case QuickEditField.price:
        return [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$'))];
      case QuickEditField.stock:
        return [FilteringTextInputFormatter.digitsOnly];
    }
  }
}

class _InlineStockInputDialog extends StatefulWidget {
  const _InlineStockInputDialog({
    required this.initialValue,
    required this.onSaved,
  });

  final int initialValue;
  final ValueChanged<int> onSaved;

  @override
  State<_InlineStockInputDialog> createState() =>
      _InlineStockInputDialogState();
}

class _InlineStockInputDialogState extends State<_InlineStockInputDialog> {
  late final TextEditingController _ctrl;
  String? _dialogError;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: '${widget.initialValue}');
    _ctrl.addListener(_dialogValidate);
  }

  @override
  void dispose() {
    _ctrl.removeListener(_dialogValidate);
    _ctrl.dispose();
    super.dispose();
  }

  void _dialogValidate() {
    setState(() {
      final text = _ctrl.text.trim();
      if (text.isEmpty) {
        _dialogError = null;
      } else {
        final qty = int.tryParse(text);
        _dialogError = (qty == null || qty < 0) ? 'Invalid' : null;
      }
    });
  }

  bool get _dialogCanSave {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return false;
    final qty = int.tryParse(text);
    return qty != null && qty >= 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.quantityLabel),
      content: TextField(
        controller: _ctrl,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.quantityLabel,
          errorText: _dialogError,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _dialogCanSave
              ? () {
                  final qty = int.tryParse(_ctrl.text);
                  if (qty != null && qty >= 0) {
                    Navigator.pop(context);
                    widget.onSaved(qty);
                  }
                }
              : null,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

Future<String?> showQuickEditSheet(
  BuildContext context, {
  required QuickEditField field,
  required String initialValue,
  String? productName,
}) {
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
    builder: (_) => QuickEditSheet(
      field: field,
      initialValue: initialValue,
      productName: productName,
    ),
  );
}
