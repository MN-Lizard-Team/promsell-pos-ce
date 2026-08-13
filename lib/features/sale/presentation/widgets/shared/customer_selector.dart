import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/customer/domain/entities/customer.dart';
import 'package:promsell_pos_ce/features/customer/domain/repositories/customer_repository.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_event.dart';
import 'package:promsell_pos_ce/features/customer/presentation/bloc/customer_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_bottom_sheet.dart';

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

  /// Opens customer picker (dense selector and bill meta chips).
  static Future<void> openPicker(BuildContext context) async {
    final cartBloc = context.read<CartBloc>();
    final selectedId = cartBloc.state.customerId;
    final customerBloc = sl<CustomerBloc>()..add(const CustomersSubscribed());

    final picked = await PosBottomSheet.show<String?>(
      context: context,
      isScrollControlled: true,
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;
    final height = MediaQuery.sizeOf(context).height * 0.72;

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title row — Material handle already from PosBottomSheet.
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 8, 8),
            child: Row(
              children: [
                Icon(Icons.person_outline, color: scheme.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.selectCustomer,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (widget.selectedId != null)
                  TextButton(
                    onPressed: () => Navigator.pop(context, ''),
                    style: TextButton.styleFrom(foregroundColor: scheme.error),
                    child: Text(l10n.clearCustomer),
                  ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchCustomers,
                prefixIcon: Icon(Icons.search, color: scheme.onSurfaceVariant),
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withValues(
                  alpha: 0.28,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: pos.billStubBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: pos.billStubBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: scheme.primary, width: 1.5),
                ),
              ),
              onChanged: (q) =>
                  context.read<CustomerBloc>().add(CustomerSearchChanged(q)),
            ),
          ),
          Divider(height: 1, color: pos.billStubBorder),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state.status == CustomerStatus.loading &&
                    state.customers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = state.filtered;
                if (list.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.person_search_outlined,
                    title: state.searchQuery.isEmpty
                        ? l10n.noCustomersYet
                        : l10n.noCustomersFound,
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      Divider(height: 1, indent: 72, color: pos.billStubBorder),
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final selected = c.id == widget.selectedId;
                    final initial = c.name.isNotEmpty
                        ? c.name[0].toUpperCase()
                        : '?';
                    return Material(
                      color: selected
                          ? scheme.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context, c.id),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: selected
                                    ? scheme.primary
                                    : scheme.surfaceContainerHighest.withValues(
                                        alpha: 0.55,
                                      ),
                                foregroundColor: selected
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    if (c.phone != null &&
                                        c.phone!.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        c.phone!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: scheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (selected)
                                Icon(
                                  Icons.check_circle,
                                  color: scheme.primary,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
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
