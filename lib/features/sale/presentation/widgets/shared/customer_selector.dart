import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_event.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';

/// Cart/checkout control to attach or clear a loyalty customer.
class CustomerSelector extends StatelessWidget {
  const CustomerSelector({super.key, this.dense = false});

  final bool dense;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      buildWhen: (p, c) => p.customerId != c.customerId,
      builder: (context, cart) {
        return FutureBuilder<Customer?>(
          future: cart.customerId == null
              ? Future<Customer?>.value(null)
              : sl<CustomerRepository>().getCustomerById(cart.customerId!),
          builder: (context, snap) {
            final customer = snap.data;
            final label =
                customer?.name ??
                (cart.customerId != null
                    ? context.l10n.customerNotFound
                    : context.l10n.selectCustomer);
            final subtitle = customer?.phone;

            return ListTile(
              contentPadding: dense
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
              leading: Icon(
                cart.customerId == null
                    ? Icons.person_add_alt_1_outlined
                    : Icons.person_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: subtitle != null && subtitle.isNotEmpty
                  ? Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cart.customerId != null)
                    IconButton(
                      tooltip: context.l10n.clearCustomer,
                      icon: const Icon(Icons.close),
                      onPressed: () => context.read<CartBloc>().add(
                        const CartCustomerSet(null),
                      ),
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => openPicker(context),
            );
          },
        );
      },
    );
  }

  /// Opens customer picker (used by dense selector and bill meta chips).
  static Future<void> openPicker(BuildContext context) async {
    final cartBloc = context.read<CartBloc>();
    final selectedId = cartBloc.state.customerId;
    final customerBloc = sl<CustomerBloc>()..add(const CustomersSubscribed());

    final picked = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return BlocProvider.value(
          value: customerBloc,
          child: _CustomerPickerSheet(selectedId: selectedId),
        );
      },
    );

    await customerBloc.close();
    if (!context.mounted) return;
    // Sheet returns id, '' for clear, or null if dismissed without change.
    if (picked == null) return;
    cartBloc.add(CartCustomerSet(picked.isEmpty ? null : picked));
  }
}

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({this.selectedId});
  final String? selectedId;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final height = MediaQuery.sizeOf(context).height * 0.7;

    return SizedBox(
      height: height,
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.selectCustomer,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (widget.selectedId != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    child: Text(l10n.clearCustomer),
                  ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: l10n.searchCustomers,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (q) =>
                  context.read<CustomerBloc>().add(CustomerSearchChanged(q)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading &&
                    state.customers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = state.filtered;
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      state.searchQuery.isEmpty
                          ? l10n.noCustomersYet
                          : l10n.noCustomersFound,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final selected = c.id == widget.selectedId;
                    return ListTile(
                      selected: selected,
                      leading: CircleAvatar(
                        child: Text(
                          c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text(c.name),
                      subtitle: c.phone != null && c.phone!.isNotEmpty
                          ? Text(c.phone!)
                          : null,
                      trailing: selected
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, c.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
