import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/layout/form_section_card.dart';
import 'package:promsell_pos_ce/core/widgets/layout/sticky_action_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_text_field.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_event.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

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

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showAppConfirm(
      context,
      title: l10n.deleteCustomerTitle,
      message: '',
      detail: widget.customer!.name,
      confirmLabel: l10n.delete,
      cancelLabel: l10n.cancel,
      destructive: true,
      confirmIcon: Icons.person_remove_outlined,
    );
    if (!mounted || !confirmed) return;
    _deleting = true;
    setState(() {});
    context.read<CustomerBloc>().add(CustomerDeleted(widget.customer!.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final currency = context.watch<SettingsCubit>().state.settings.currency;

    return BlocListener<CustomerBloc, CustomerState>(
      listenWhen: (prev, curr) =>
          (_submitted || _deleting) && prev.saveStatus != curr.saveStatus,
      listener: (ctx, state) {
        if (state.saveStatus == CustomerSaveStatus.saved) {
          AppSnackBar.success(ctx, ctx.l10n.customerSaved);
          Navigator.pop(ctx, true);
        } else if (state.saveStatus == CustomerSaveStatus.error) {
          _submitted = false;
          _deleting = false;
          setState(() {});
          AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.errorOccurred);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? l10n.editCustomerTitle : l10n.addCustomer),
        ),
        bottomNavigationBar: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (_, state) {
            final isSaving = state.saveStatus == CustomerSaveStatus.saving;
            return StickyActionBar(
              primaryLabel: _isEditing ? l10n.save : l10n.addCustomer,
              onPrimary: _submit,
              dangerLabel: _isEditing ? l10n.delete : null,
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
                  title: l10n.customerInfoSection,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTextField(
                        controller: _nameCtrl,
                        labelText: l10n.customerNameLabel,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? l10n.customerNameRequired
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _phoneCtrl,
                        labelText: l10n.customerPhoneLabel,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _emailCtrl,
                        labelText: l10n.customerEmailLabel,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FormSectionCard(
                  icon: Icons.note_outlined,
                  title: l10n.customerNotesSection,
                  child: AppTextField(
                    controller: _noteCtrl,
                    hintText: l10n.customerNoteHint,
                    maxLines: 3,
                  ),
                ),
                if (_isEditing && widget.customer!.visitCount > 0) ...[
                  const SizedBox(height: 16),
                  FormSectionCard(
                    icon: Icons.bar_chart_outlined,
                    title: l10n.customerStatisticsSection,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _StatRow(
                          label: l10n.customerTotalVisits,
                          value: widget.customer!.visitCount.toString(),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.customerTotalSpent,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            MoneyText(
                              value: widget.customer!.totalSpent.value,
                              currency: currency,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
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
