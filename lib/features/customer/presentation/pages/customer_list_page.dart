import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/money_text.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_event.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_state.dart';
import 'package:promsell_pos_ce/features/customer/presentation/pages/customer_form_page.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<CustomerBloc>()..add(const CustomersSubscribed()),
      child: const _CustomerListView(),
    );
  }
}

class _CustomerListView extends StatefulWidget {
  const _CustomerListView();

  @override
  State<_CustomerListView> createState() => _CustomerListViewState();
}

class _CustomerListViewState extends State<_CustomerListView> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<CustomerBloc>().add(const CustomerSearchChanged(''));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return BlocListener<CustomerBloc, CustomerState>(
      listenWhen: (prev, curr) =>
          curr.status == CustomerStatus.failure &&
          prev.status != CustomerStatus.failure,
      listener: (ctx, state) {
        AppSnackBar.error(ctx, state.errorMessage ?? ctx.l10n.errorOccurred);
      },
      child: Scaffold(
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.searchCustomers,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  style: theme.textTheme.titleMedium,
                  onChanged: (q) => context.read<CustomerBloc>().add(
                    CustomerSearchChanged(q),
                  ),
                )
              : Text(l10n.customersTitle),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              final customers = state.filtered;

              if (state.status == CustomerStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (customers.isEmpty) {
                return _EmptyState(
                  hasSearch: state.searchQuery.isNotEmpty,
                  onAdd: () => _showAddForm(context),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: customers.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final customer = customers[index];
                  return _CustomerTile(
                    customer: customer,
                    onTap: () => _showEditForm(context, customer),
                  );
                },
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddForm(context),
          heroTag: 'customer_add_fab',
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  Future<void> _showAddForm(BuildContext context) async {
    final bloc = context.read<CustomerBloc>();
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            BlocProvider.value(value: bloc, child: const CustomerFormPage()),
      ),
    );
  }

  Future<void> _showEditForm(BuildContext context, Customer customer) async {
    final bloc = context.read<CustomerBloc>();
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CustomerFormPage(customer: customer),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSearch, required this.onAdd});
  final bool hasSearch;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasSearch ? Icons.search_off : Icons.people_outline,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? l10n.noCustomersFound : l10n.noCustomersYet,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch ? l10n.tryDifferentSearch : l10n.addFirstCustomer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (!hasSearch) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.person_add),
                label: Text(l10n.addCustomer),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({required this.customer, required this.onTap});
  final Customer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final currency = context.watch<SettingsCubit>().state.settings.currency;
    final initials = _getInitials(customer.name);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Text(
            initials,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
          customer.name,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.phone != null && customer.phone!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.phone, size: 14),
                  const SizedBox(width: 4),
                  Text(customer.phone!),
                ],
              ),
            if (customer.email != null && customer.email!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.email, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      customer.email!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (customer.visitCount > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.customerVisits(customer.visitCount),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.payments_outlined,
                    size: 14,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  MoneyText(
                    value: customer.totalSpent.value,
                    currency: currency,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
