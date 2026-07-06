import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_event.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_state.dart';

class CustomerFormPage extends StatefulWidget {
  const CustomerFormPage({super.key, this.customer});
  final Customer? customer;

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final _nameCtrl = TextEditingController(text: widget.customer?.name);
  late final _phoneCtrl = TextEditingController(
    text: widget.customer?.phone ?? '',
  );
  late final _emailCtrl = TextEditingController(
    text: widget.customer?.email ?? '',
  );
  late final _noteCtrl = TextEditingController(
    text: widget.customer?.note ?? '',
  );

  bool _submitted = false;
  bool _deleting = false;

  bool get _isEditing => widget.customer != null;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final bloc = context.read<CustomerBloc>();
    if (_submitted || bloc.state.saveStatus == CustomerSaveStatus.saving) {
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    _submitted = true;
    setState(() {});

    if (_isEditing) {
      bloc.add(
        CustomerUpdated(
          widget.customer!.copyWith(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim().isEmpty
                ? null
                : _phoneCtrl.text.trim(),
            email: _emailCtrl.text.trim().isEmpty
                ? null
                : _emailCtrl.text.trim(),
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          ),
        ),
      );
    } else {
      bloc.add(
        CustomerAdded(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        ),
      );
    }
  }

  void _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text(
          'Are you sure you want to delete "${widget.customer!.name}"?',
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
    context.read<CustomerBloc>().add(CustomerDeleted(widget.customer!.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerBloc, CustomerState>(
      listenWhen: (prev, curr) =>
          (_submitted || _deleting) && prev.saveStatus != curr.saveStatus,
      listener: (ctx, state) {
        if (state.saveStatus == CustomerSaveStatus.saved) {
          AppSnackBar.success(ctx, 'Customer saved');
          Navigator.pop(ctx, true);
        } else if (state.saveStatus == CustomerSaveStatus.error) {
          _submitted = false;
          _deleting = false;
          setState(() {});
          AppSnackBar.error(ctx, state.errorMessage ?? 'Error');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Customer' : 'Add Customer'),
        ),
        bottomNavigationBar: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (_, state) {
            final isSaving = state.saveStatus == CustomerSaveStatus.saving;
            return StickyActionBar(
              primaryLabel: _isEditing ? 'Save' : 'Add Customer',
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
                  icon: Icons.person_outline,
                  title: 'Customer Information',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? 'Name is required'
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FormSectionCard(
                  icon: Icons.note_outlined,
                  title: 'Notes',
                  child: TextFormField(
                    controller: _noteCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Add a note about this customer...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ),
                if (_isEditing && widget.customer!.visitCount > 0) ...[
                  const SizedBox(height: 16),
                  FormSectionCard(
                    icon: Icons.bar_chart_outlined,
                    title: 'Statistics',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StatRow(
                          label: 'Total Visits',
                          value: widget.customer!.visitCount.toString(),
                        ),
                        const SizedBox(height: 8),
                        _StatRow(
                          label: 'Total Spent',
                          value: widget.customer!.totalSpent.toStringAsFixed(2),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
