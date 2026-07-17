import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_park_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_create_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_search_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_tile.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Full-page **open bills** list (parked / multi-bill).
///
/// Open with [SavedBillsPage.open] so parent blocs are shared.
class SavedBillsPage extends StatefulWidget {
  const SavedBillsPage({super.key});

  /// Push full page; if opened from a modal (e.g. cart sheet), pop modal first
  /// then push on the **root** navigator so bills sit above Sale.
  static Future<void> open(BuildContext context) async {
    final draftBloc = context.read<DraftBloc>();
    final cartBloc = context.read<CartBloc>();
    final settingsCubit = context.read<SettingsCubit>();
    // CheckoutBloc is always on Sale; fall back to DI if missing.
    CheckoutBloc checkoutBloc;
    try {
      checkoutBloc = context.read<CheckoutBloc>();
    } catch (_) {
      checkoutBloc = sl<CheckoutBloc>();
    }
    final rootNav = Navigator.of(context, rootNavigator: true);
    final isModal = ModalRoute.of(context) is PopupRoute;

    void pushPage() {
      if (!rootNav.mounted) return;
      rootNav.push<void>(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: draftBloc),
              BlocProvider.value(value: cartBloc),
              BlocProvider.value(value: checkoutBloc),
              BlocProvider.value(value: settingsCubit),
            ],
            child: const SavedBillsPage(),
          ),
        ),
      );
    }

    if (isModal) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) => pushPage());
      return;
    }

    pushPage();
  }

  @override
  State<SavedBillsPage> createState() => _SavedBillsPageState();
}

class _SavedBillsPageState extends State<SavedBillsPage> {
  late Future<List<DraftCart>> _draftsFuture;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _reload() => setState(() {
    _draftsFuture = sl<DraftCartRepository>().listDrafts();
  });

  List<DraftCart> _filterAndSort(List<DraftCart> drafts, String? activeId) {
    // Bills with lines only; keep empty active so cashier can still manage it.
    var result = drafts.where((d) {
      if (d.itemCount > 0) return true;
      return d.id == activeId;
    }).toList();
    if (_query.isNotEmpty) {
      final lower = _query.toLowerCase();
      result = result
          .where((d) => (d.name ?? '').toLowerCase().contains(lower))
          .toList();
    }
    result.sort((a, b) {
      final aActive = a.id == activeId ? 1 : 0;
      final bActive = b.id == activeId ? 1 : 0;
      if (aActive != bActive) return bActive - aActive;
      final aItems = a.itemCount > 0 ? 1 : 0;
      final bItems = b.itemCount > 0 ? 1 : 0;
      if (aItems != bItems) return bItems - aItems;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return result;
  }

  Future<void> _switchTo(String draftId, {bool popAfter = true}) async {
    final draftBloc = context.read<DraftBloc>();
    if (draftBloc.state.activeDraftId != draftId) {
      draftBloc.add(DraftSwitched(draftId));
      try {
        await draftBloc.stream
            .firstWhere(
              (s) =>
                  s.activeDraftId == draftId &&
                  (s.loadedDraft == null || s.loadedDraft!.id == draftId),
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    if (!mounted) return;
    if (popAfter) Navigator.maybePop(context);
  }

  Future<void> _payBill(DraftCart draft) async {
    if (draft.itemCount <= 0) return;
    final draftBloc = context.read<DraftBloc>();
    final cartBloc = context.read<CartBloc>();
    final checkoutBloc = context.read<CheckoutBloc>();
    final settingsCubit = context.read<SettingsCubit>();
    final nav = Navigator.of(context);

    if (draftBloc.state.activeDraftId != draft.id) {
      draftBloc.add(DraftSwitched(draft.id));
      try {
        await draftBloc.stream
            .firstWhere(
              (s) =>
                  s.activeDraftId == draft.id && s.loadedDraft?.id == draft.id,
            )
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        if (mounted) return;
      }
    }

    // SalePage restores cart on loadedDraft; wait until cart has lines.
    if (cartBloc.state.isEmpty) {
      try {
        await cartBloc.stream
            .firstWhere((c) => !c.isEmpty)
            .timeout(const Duration(seconds: 5));
      } catch (_) {
        // Fall through — navigateToCheckout will show cartEmpty if still empty.
      }
    }

    if (!mounted) return;
    // Unfocus search before route dispose (avoids controller listener race).
    FocusManager.instance.primaryFocus?.unfocus();
    nav.pop();
    // Root navigator context is above Sale MultiBlocProvider — pass blocs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!nav.mounted) return;
      navigateToCheckout(
        nav.context,
        cartBloc: cartBloc,
        checkoutBloc: checkoutBloc,
        draftBloc: draftBloc,
        settingsCubit: settingsCubit,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final currency = settings.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.draftsTitle),
        actions: [
          IconButton(
            tooltip: l10n.newDraft,
            onPressed: () => _showCreateDialog(context, l10n),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: BlocListener<DraftBloc, DraftState>(
        listenWhen: (prev, curr) =>
            prev.activeDraftId != curr.activeDraftId ||
            prev.draftCount != curr.draftCount ||
            prev.openBillCount != curr.openBillCount ||
            (prev.opNonce != curr.opNonce &&
                curr.opStatus == DraftOpStatus.success),
        listener: (ctx, st) => _reload(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                // Park CTA: catalog + cart footer only (P1 de-dupe).
                DraftSearchBar(
                  controller: _searchCtrl,
                  query: _query,
                  l10n: l10n,
                  onChanged: (v) => setState(() => _query = v),
                  onClear: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<DraftCart>>(
                    future: _draftsFuture,
                    builder: (_, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final allDrafts = snap.data ?? [];
                      final activeDraftId = context
                          .read<DraftBloc>()
                          .state
                          .activeDraftId;
                      final drafts = _filterAndSort(allDrafts, activeDraftId);
                      if (drafts.isEmpty) {
                        return AppEmptyState(
                          icon: _query.isNotEmpty
                              ? Icons.search_off
                              : Icons.bookmarks_outlined,
                          title: _query.isNotEmpty
                              ? l10n.noMatchingDrafts
                              : l10n.noSavedBills,
                          message: _query.isNotEmpty
                              ? null
                              : l10n.noSavedBillsHint,
                        );
                      }
                      return ListView.builder(
                        itemCount: drafts.length,
                        itemBuilder: (_, i) {
                          final draft = drafts[i];
                          final isActive = draft.id == activeDraftId;
                          final payable = SalePayableCalculator.forCartFields(
                            itemsSubtotal: draft.items.fold(
                              Money.zero,
                              (s, i) => s + i.subtotal,
                            ),
                            cartDiscountAmount: draft.cartDiscountAmount,
                            promotionDiscountAmount:
                                draft.promotionDiscountAmount,
                            settings: settings,
                            cartServiceChargeRate: draft.serviceChargeRate,
                          ).payableTotal.value;
                          return DraftTile(
                            id: draft.id,
                            name: draft.name,
                            itemCount: draft.itemCount,
                            total: payable,
                            currency: currency,
                            isActive: isActive,
                            updatedAt: draft.updatedAt,
                            l10n: l10n,
                            theme: theme,
                            onSwitch: isActive
                                ? () => Navigator.maybePop(context)
                                : () => _switchTo(draft.id),
                            onPay: draft.itemCount > 0
                                ? () => _payBill(draft)
                                : null,
                            onDelete: drafts.length > 1
                                ? () {
                                    context.read<DraftBloc>().add(
                                      DraftDeleted(draft.id),
                                    );
                                    Future.delayed(
                                      const Duration(milliseconds: 300),
                                      _reload,
                                    );
                                  }
                                : null,
                            onRename: (name) {
                              context.read<DraftBloc>().add(
                                DraftRenamed(draftId: draft.id, name: name),
                              );
                              Future.delayed(
                                const Duration(milliseconds: 300),
                                _reload,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final name = await DraftCreateDialog.show(context, l10n);
    if (name == null || !context.mounted) return;
    final ok = await DraftParkActions.startNewBill(
      context,
      name: name.isEmpty ? null : name,
      confirmIfNotEmpty: true,
      showSuccessSnack: true,
    );
    if (ok && mounted) _reload();
  }
}
