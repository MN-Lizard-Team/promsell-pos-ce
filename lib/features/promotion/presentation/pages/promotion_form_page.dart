import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/promotion/domain/entities/promotion.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_bloc.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_event.dart';
import 'package:promsell_pos_ce/features/promotion/presentation/bloc/promotion_state.dart';

class PromotionFormPage extends StatefulWidget {
  const PromotionFormPage({super.key, this.promotion});
  final Promotion? promotion;

  @override
  State<PromotionFormPage> createState() => _PromotionFormPageState();
}

class _PromotionFormPageState extends State<PromotionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.promotion?.name);
  late final _valueCtrl = TextEditingController(
    text: widget.promotion?.value.toStringAsFixed(0) ?? '',
  );
  late final _minPurchaseCtrl = TextEditingController(
    text: widget.promotion?.minPurchaseAmount.toStringAsFixed(2) ?? '0',
  );

  late PromotionType _type = widget.promotion?.type ?? PromotionType.percent;
  late DateTime _startDate = widget.promotion?.startDate ?? DateTime.now();
  late DateTime? _endDate = widget.promotion?.endDate;
  late bool _isActive = widget.promotion?.isActive ?? true;

  bool _submitted = false;
  bool _deleting = false;

  bool get _isEditing => widget.promotion != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _valueCtrl.dispose();
    _minPurchaseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<PromotionBloc>();
    if (_submitted || bloc.state.saveStatus == PromotionSaveStatus.saving) {
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    _submitted = true;
    setState(() {});

    final value = double.tryParse(_valueCtrl.text) ?? 0;
    final minPurchase = double.tryParse(_minPurchaseCtrl.text) ?? 0;
    final now = DateTime.now();

    if (_isEditing) {
      bloc.add(
        PromotionUpdated(
          widget.promotion!.copyWith(
            name: _nameCtrl.text.trim(),
            type: _type,
            value: value,
            minPurchaseAmount: minPurchase,
            startDate: _startDate,
            endDate: _endDate,
            isActive: _isActive,
            updatedAt: now,
          ),
        ),
      );
    } else {
      bloc.add(
        PromotionAdded(
          Promotion(
            id: '',
            name: _nameCtrl.text.trim(),
            type: _type,
            value: value,
            minPurchaseAmount: minPurchase,
            startDate: _startDate,
            endDate: _endDate,
            isActive: _isActive,
            createdAt: now,
            updatedAt: now,
          ),
        ),
      );
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Promotion'),
        content: Text(
          'Are you sure you want to delete "${widget.promotion!.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    _deleting = true;
    setState(() {});
    context.read<PromotionBloc>().add(PromotionDeleted(widget.promotion!.id));
  }

  Future<void> _pickDate({
    required bool isStart,
    required DateTime initial,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PromotionBloc, PromotionState>(
      listenWhen: (prev, curr) =>
          (_submitted || _deleting) && prev.saveStatus != curr.saveStatus,
      listener: (ctx, state) {
        if (state.saveStatus == PromotionSaveStatus.saved) {
          AppSnackBar.success(ctx, 'Promotion saved');
          Navigator.pop(ctx, true);
        } else if (state.saveStatus == PromotionSaveStatus.error) {
          _submitted = false;
          _deleting = false;
          setState(() {});
          AppSnackBar.error(ctx, state.errorMessage ?? 'Error');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Promotion' : 'Add Promotion'),
        ),
        bottomNavigationBar: BlocBuilder<PromotionBloc, PromotionState>(
          builder: (_, state) {
            final isSaving = state.saveStatus == PromotionSaveStatus.saving;
            return StickyActionBar(
              primaryLabel: _isEditing ? 'Save' : 'Add Promotion',
              onPrimary: _submit,
              dangerLabel: _isEditing ? 'Delete' : null,
              onDanger: _isEditing ? _confirmDelete : null,
              isLoading: isSaving,
            );
          },
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormSectionCard(
                  icon: Icons.local_offer_outlined,
                  title: 'Promotion Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Promotion Name',
                          prefixIcon: Icon(Icons.label_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<PromotionType>(
                        segments: const [
                          ButtonSegment(
                            value: PromotionType.percent,
                            icon: Icon(Icons.percent),
                            label: Text('Percentage'),
                          ),
                          ButtonSegment(
                            value: PromotionType.amount,
                            icon: Icon(Icons.attach_money),
                            label: Text('Fixed Amount'),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (selection) =>
                            setState(() => _type = selection.first),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _valueCtrl,
                        decoration: InputDecoration(
                          labelText: _type == PromotionType.percent
                              ? 'Discount (%)'
                              : 'Discount Amount',
                          prefixIcon: Icon(
                            _type == PromotionType.percent
                                ? Icons.percent
                                : Icons.attach_money,
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Value is required';
                          }
                          final parsed = double.tryParse(value);
                          if (parsed == null || parsed <= 0) {
                            return 'Enter a valid value';
                          }
                          if (_type == PromotionType.percent && parsed > 100) {
                            return 'Percentage cannot exceed 100';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _minPurchaseCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Purchase Amount',
                          prefixIcon: Icon(Icons.shopping_cart_outlined),
                          border: OutlineInputBorder(),
                          helperText: '0 = no minimum',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FormSectionCard(
                  icon: Icons.date_range_outlined,
                  title: 'Schedule',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _DateTile(
                        label: 'Start Date',
                        date: _startDate,
                        onTap: () =>
                            _pickDate(isStart: true, initial: _startDate),
                      ),
                      const SizedBox(height: 8),
                      _DateTile(
                        label: 'End Date',
                        date: _endDate,
                        placeholder: 'No end date',
                        onTap: () => _pickDate(
                          isStart: false,
                          initial: _endDate ?? _startDate,
                        ),
                        onClear: _endDate != null
                            ? () => setState(() => _endDate = null)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FormSectionCard(
                  icon: Icons.toggle_on_outlined,
                  title: 'Status',
                  child: SwitchListTile(
                    title: Text(
                      _isActive ? 'Active' : 'Inactive',
                      style: theme.textTheme.bodyLarge,
                    ),
                    subtitle: Text(
                      _isActive
                          ? 'This promotion is currently active'
                          : 'This promotion is disabled',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
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

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
    this.placeholder,
    this.onClear,
  });

  final String label;
  final DateTime? date;
  final VoidCallback onTap;
  final String? placeholder;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    date != null ? _formatDate(date!) : (placeholder ?? ''),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: onClear,
              )
            else
              const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
