import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/domain/money.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/utils/app_logger.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_empty_state.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/draft_cart.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/domain/services/sale_payable_calculator.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/checkout_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_checkout_helper.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_bill_switch_guard.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_list_query.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/draft_park_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_create_dialog.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_search_bar.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet/draft_tile.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/pos_primary_app_bar.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Open bills board (parked / multi-bill).
///
/// Open with [SavedBillsPage.open]: full route on phone, side sheet on tablet.
class SavedBillsPage extends StatefulWidget {
  const SavedBillsPage({super.key, this.asSideSheet = false});

  /// When true, chrome is compact for end-aligned side sheet (no route AppBar
  /// back — sheet provides dismiss).
  final bool asSideSheet;

  /// Present open bills: **side sheet** when width ≥ tablet split, else full page.
  ///
  /// Blocked while cart payment-locked or checkout waiting/processing.
  static Future<void> open(BuildContext context) async {
    final draftBloc = context.read<DraftBloc>();
    final cartBloc = context.read<CartBloc>();
    final settingsCubit = context.read<SettingsCubit>();
    CheckoutBloc checkoutBloc;
    try {
      checkoutBloc = context.read<CheckoutBloc>();
    } catch (e, stack) {
      AppLogger.warning(
        'SavedBillsPage: CheckoutBloc not in context, using sl',
        error: e,
        stack: stack,
      );
      checkoutBloc = sl<CheckoutBloc>();
    }
    if (DraftBillSwitchGuard.isBlockedFromStates(
      cart: cartBloc.state,
      checkout: checkoutBloc.state,
    )) {
      AppSnackBar.warning(context, context.l10n.cartPaymentInProgress);
      return;
    }
    final rootNav = Navigator.of(context, rootNavigator: true);
    final isModal = ModalRoute.of(context) is PopupRoute;
    final size = MediaQuery.sizeOf(context);
    final pos =
        Theme.of(context).extension<PosThemeExtension>() ??
        PosThemeExtension.light;
    final useSideSheet = size.width >= pos.tabletSplitBreakpoint;

    Widget wrap(Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: draftBloc),
        BlocProvider.value(value: cartBloc),
        BlocProvider.value(value: checkoutBloc),
        BlocProvider.value(value: settingsCubit),
      ],
      child: child,
    );

    Future<void> present() async {
      if (!rootNav.mounted) return;
      if (useSideSheet) {
        final sheetWidth = math.min(440.0, size.width * 0.48);
        await showGeneralDialog<void>(
          context: rootNav.context,
          barrierDismissible: true,
          barrierLabel: MaterialLocalizations.of(
            rootNav.context,
          ).modalBarrierDismissLabel,
          barrierColor: Colors.black54,
          transitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (ctx, anim, secondary) {
            return Align(
              alignment: Alignment.centerRight,
              child: Material(
                // Cap at elevModal — freestyle 12 broke Sale elevation ladder.
                elevation: pos.elevModal,
                shadowColor: pos.shadowKey.withValues(
                  alpha: pos.shadowChromeAlpha,
                ),
                color: pos.catalogBackground,
                child: SizedBox(
                  width: sheetWidth,
                  height: size.height,
                  child: wrap(const SavedBillsPage(asSideSheet: true)),
                ),
              ),
            );
          },
          transitionBuilder: (ctx, anim, secondary, child) {
            final curved = CurvedAnimation(
              parent: anim,
              curve: Curves.easeOutCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          },
        );
        return;
      }

      await rootNav.push<void>(
        MaterialPageRoute(builder: (_) => wrap(const SavedBillsPage())),
      );
    }

    if (isModal) {
      Navigator.of(context).pop();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        present();
      });
      return;
    }

    await present();
  }

  @override
  State<SavedBillsPage> createState() => _SavedBillsPageState();
}

class _SavedBillsPageState extends State<SavedBillsPage> {
  late Future<List<DraftCart>> _draftsFuture;
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchCtrl.clear();
    _searchFocus.unfocus();
    setState(() {
      _query = '';
      _searching = false;
    });
  }

  void _reload() => setState(() {
    _draftsFuture = sl<DraftCartRepository>().listDrafts();
  });

  List<DraftCart> _filterAndSort(List<DraftCart> drafts, String? activeId) {
    final settings = context.read<SettingsCubit>().state.settings;
    return DraftListQuery.filterAndSort(
      drafts,
      activeId: activeId,
      query: _query,
      settings: settings,
    );
  }

  bool get _paymentBlocked {
    final cart = context.read<CartBloc>().state;
    final checkout = context.read<CheckoutBloc>().state;
    return DraftBillSwitchGuard.isBlockedFromStates(
      cart: cart,
      checkout: checkout,
    );
  }

  void _blockedSnack() {
    if (!mounted) return;
    AppSnackBar.warning(context, context.l10n.cartPaymentInProgress);
  }

  Future<bool> _switchTo(String draftId, {bool popAfter = true}) async {
    if (_paymentBlocked) {
      _blockedSnack();
      return false;
    }
    final draftBloc = context.read<DraftBloc>();
    final cartBloc = context.read<CartBloc>();
    final locked = cartBloc.state.paymentLocked;
    if (draftBloc.state.activeDraftId != draftId) {
      final startNonce = draftBloc.state.opNonce;
      draftBloc.add(
        DraftSwitched(draftId, paymentLocked: locked, liveCart: cartBloc.state),
      );
      try {
        final next = await draftBloc.stream
            .firstWhere(
              (s) =>
                  s.opNonce > startNonce &&
                  s.lastOp == 'switch' &&
                  (s.opStatus == DraftOpStatus.success ||
                      s.opStatus == DraftOpStatus.failure),
            )
            .timeout(const Duration(seconds: 8));
        if (next.opStatus != DraftOpStatus.success ||
            next.activeDraftId != draftId) {
          if (mounted) {
            if (next.errorMessage == DraftBillSwitchGuard.errorCode) {
              _blockedSnack();
            } else {
              AppSnackBar.error(context, context.l10n.errorOccurred);
            }
          }
          return false;
        }
      } catch (e, stack) {
        AppLogger.warning(
          'SavedBillsPage._switchBill timeout/error',
          error: e,
          stack: stack,
        );
        if (mounted) {
          AppSnackBar.error(context, context.l10n.errorOccurred);
        }
        return false;
      }
    }
    if (!mounted) return false;
    if (popAfter) Navigator.maybePop(context);
    return true;
  }

  Future<void> _payBill(DraftCart draft) async {
    if (draft.itemCount <= 0) return;
    if (_paymentBlocked) {
      _blockedSnack();
      return;
    }
    final draftBloc = context.read<DraftBloc>();
    final cartBloc = context.read<CartBloc>();
    final checkoutBloc = context.read<CheckoutBloc>();
    final settingsCubit = context.read<SettingsCubit>();
    final nav = Navigator.of(context);
    final locked = cartBloc.state.paymentLocked;

    if (draftBloc.state.activeDraftId != draft.id) {
      final startNonce = draftBloc.state.opNonce;
      draftBloc.add(
        DraftSwitched(
          draft.id,
          paymentLocked: locked,
          liveCart: cartBloc.state,
        ),
      );
      try {
        final next = await draftBloc.stream
            .firstWhere(
              (s) =>
                  s.opNonce > startNonce &&
                  s.lastOp == 'switch' &&
                  (s.opStatus == DraftOpStatus.success ||
                      s.opStatus == DraftOpStatus.failure),
            )
            .timeout(const Duration(seconds: 8));
        if (next.opStatus != DraftOpStatus.success ||
            next.activeDraftId != draft.id ||
            next.loadedDraft?.id != draft.id) {
          if (mounted) {
            if (next.errorMessage == DraftBillSwitchGuard.errorCode) {
              _blockedSnack();
            } else {
              AppSnackBar.error(context, context.l10n.errorOccurred);
            }
          }
          return;
        }
      } catch (e, stack) {
        AppLogger.warning(
          'SavedBillsPage._payBill switch timeout/error',
          error: e,
          stack: stack,
        );
        if (mounted) {
          AppSnackBar.error(context, context.l10n.errorOccurred);
        }
        return;
      }
    }

    // Always wait until cart reflects this draft (never assume non-empty = ready).
    final targetItemCount = draft.itemCount;
    bool cartLooksReady(c) =>
        !c.paymentLocked &&
        c.itemCount == targetItemCount &&
        (targetItemCount == 0 || !c.isEmpty);

    if (!cartLooksReady(cartBloc.state)) {
      try {
        await cartBloc.stream
            .firstWhere(cartLooksReady)
            .timeout(const Duration(seconds: 8));
      } catch (e, stack) {
        AppLogger.warning(
          'SavedBillsPage._payBill cart-ready timeout',
          error: e,
          stack: stack,
        );
        if (mounted) {
          AppSnackBar.error(context, context.l10n.errorOccurred);
        }
        return;
      }
    }

    if (!mounted) return;
    if (cartBloc.state.isEmpty && targetItemCount > 0) {
      AppSnackBar.error(context, context.l10n.errorOccurred);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    nav.pop();
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

  double _payable(DraftCart draft) {
    final settings = context.read<SettingsCubit>().state.settings;
    return SalePayableCalculator.forCartFields(
      itemsSubtotal: draft.items.fold(Money.zero, (s, i) => s + i.subtotal),
      cartDiscountAmount: draft.cartDiscountAmount,
      promotionDiscountAmount: draft.promotionDiscountAmount,
      settings: settings,
      cartServiceChargeRate: draft.serviceChargeRate,
    ).payableTotal.value;
  }

  Widget _sectionHeader(String title, ThemeData theme, PosThemeExtension pos) {
    return Padding(
      key: ValueKey('sale_bills_section_$title'),
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: pos.activeBillRail,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tileFor(
    DraftCart draft, {
    required bool isActive,
    required bool canDelete,
    required String currency,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    final payable = _payable(draft);
    return DraftTile(
      id: draft.id,
      name: draft.name,
      itemCount: draft.itemCount,
      total: payable,
      currency: currency,
      isActive: isActive,
      updatedAt: draft.updatedAt,
      tableId: draft.tableId,
      note: draft.note,
      previewItemName: draft.items.isNotEmpty
          ? draft.items.first.product.name
          : null,
      orderChannel: draft.orderChannel,
      l10n: l10n,
      theme: theme,
      onSwitch: isActive
          ? () => Navigator.maybePop(context)
          : () => _switchTo(draft.id),
      onPay: draft.itemCount > 0 ? () => _payBill(draft) : null,
      onDelete: canDelete
          ? () {
              if (_paymentBlocked) {
                _blockedSnack();
                return;
              }
              final locked = context.read<CartBloc>().state.paymentLocked;
              context.read<DraftBloc>().add(
                DraftDeleted(draft.id, paymentLocked: locked),
              );
              // Reload via DraftBloc listener (opNonce) — no fixed delay.
            }
          : null,
      onRename: (name) {
        if (_paymentBlocked) {
          _blockedSnack();
          return;
        }
        final locked = context.read<CartBloc>().state.paymentLocked;
        context.read<DraftBloc>().add(
          DraftRenamed(draftId: draft.id, name: name, paymentLocked: locked),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = context.watch<SettingsCubit>().state.settings;
    final currency = settings.currency;
    final pos = context.posTheme;

    final body = BlocListener<DraftBloc, DraftState>(
      listenWhen: (prev, curr) =>
          prev.activeDraftId != curr.activeDraftId ||
          prev.draftCount != curr.draftCount ||
          prev.openBillCount != curr.openBillCount ||
          (prev.opNonce != curr.opNonce &&
              curr.opStatus == DraftOpStatus.success),
      listener: (ctx, st) => _reload(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Column(
            children: [
              BlocBuilder<DraftBloc, DraftState>(
                buildWhen: (p, c) =>
                    p.activeDraftId != c.activeDraftId ||
                    p.activeDraftName != c.activeDraftName ||
                    p.draftCount != c.draftCount ||
                    p.openBillCount != c.openBillCount,
                builder: (context, draftState) {
                  final max = settings.draftConfig.maxDrafts;
                  final nearCap = draftState.draftCount >= max - 3;
                  final name = draftState.activeDraftName?.trim();
                  final currentLabel = (name != null && name.isNotEmpty)
                      ? l10n.cartActiveBill(name)
                      : l10n.currentBill;
                  return Column(
                    children: [
                      Material(
                        key: const ValueKey('sale_bills_current_header'),
                        color: pos.billStubPaper,
                        elevation: pos.elevPaper,
                        shadowColor: pos.shadowKey.withValues(
                          alpha: pos.shadowDockNearAlpha,
                        ),
                        surfaceTintColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            pos.billStubRadius,
                          ),
                          side: BorderSide(
                            color: pos.activeBillRail.withValues(alpha: 0.55),
                            width: 1.2,
                          ),
                        ),
                        child: InkWell(
                          onTap: () => Navigator.maybePop(context),
                          borderRadius: BorderRadius.circular(
                            pos.billStubRadius,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: pos.activeBillRail,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Icon(
                                  Icons.receipt_long_outlined,
                                  color: pos.activeBillRail,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentLabel,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                      ),
                                      Text(
                                        l10n.openBillsCount(
                                          draftState.openBillCount,
                                        ),
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.maybePop(context),
                                  child: Text(l10n.done),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (nearCap) ...[
                        const SizedBox(height: 6),
                        Material(
                          key: const ValueKey('sale_bills_max_banner'),
                          color: theme.colorScheme.errorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              pos.billStubRadius,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    l10n.maxDraftsReached(max),
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
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
                            : Icons.receipt_long_outlined,
                        title: _query.isNotEmpty
                            ? l10n.noMatchingDrafts
                            : l10n.noSavedBills,
                        message: _query.isNotEmpty
                            ? null
                            : l10n.noSavedBillsHint,
                      );
                    }

                    final active = drafts
                        .where((d) => d.id == activeDraftId)
                        .toList();
                    final parked = drafts
                        .where((d) => d.id != activeDraftId)
                        .toList();
                    // Capacity/delete from full set — not search-filtered rows.
                    final canDelete = allDrafts.length > 1;

                    final children = <Widget>[];
                    if (active.isNotEmpty) {
                      children.add(
                        _sectionHeader(
                          l10n.openBillsSectionSelling,
                          theme,
                          pos,
                        ),
                      );
                      for (final d in active) {
                        children.add(
                          _tileFor(
                            d,
                            isActive: true,
                            canDelete: canDelete,
                            currency: currency,
                            l10n: l10n,
                            theme: theme,
                          ),
                        );
                      }
                    }
                    if (parked.isNotEmpty) {
                      children.add(
                        _sectionHeader(l10n.openBillsSectionParked, theme, pos),
                      );
                      for (final d in parked) {
                        children.add(
                          _tileFor(
                            d,
                            isActive: false,
                            canDelete: canDelete,
                            currency: currency,
                            l10n: l10n,
                            theme: theme,
                          ),
                        );
                      }
                    }

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 16),
                      children: children,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: pos.catalogBackground,
      appBar: PosPrimaryAppBar(
        // Open bills: square bottom edge (no radius).
        roundBottom: false,
        // Tight spacing when title is the search field.
        titleSpacing: _searching ? 0 : null,
        automaticallyImplyLeading: !widget.asSideSheet && !_searching,
        leading: _searching
            ? IconButton(
                key: const ValueKey('sale_bills_search_back'),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Icons.arrow_back),
                onPressed: _closeSearch,
              )
            : null,
        title: _searching
            ? DraftSearchBar(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                query: _query,
                l10n: l10n,
                embeddedInAppBar: true,
                onChanged: (v) => setState(() => _query = v),
                onClear: () {
                  _searchCtrl.clear();
                  setState(() => _query = '');
                  _searchFocus.requestFocus();
                },
              )
            : Text(l10n.draftsTitle),
        actions: [
          if (!_searching)
            IconButton(
              key: const ValueKey('sale_bills_search_icon'),
              tooltip: l10n.searchDrafts,
              onPressed: _openSearch,
              icon: const Icon(Icons.search),
            ),
          if (!_searching)
            IconButton(
              key: const ValueKey('sale_bills_new_bill'),
              tooltip: l10n.newDraft,
              // 1-tap: auto-named empty bill (DraftNaming). Long-press → name dialog.
              onPressed: () => _startNewBillAuto(context),
              onLongPress: () => _showCreateDialog(context, l10n),
              icon: const Icon(Icons.add),
            ),
          if (widget.asSideSheet && !_searching)
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: body,
    );
  }

  /// 1-tap new bill — auto name via bloc [DraftNaming.forNewEmptyBill].
  Future<void> _startNewBillAuto(BuildContext context) async {
    final ok = await DraftParkActions.startNewBill(
      context,
      confirmIfNotEmpty: true,
      showSuccessSnack: true,
    );
    if (ok && mounted) _reload();
  }

  /// Long-press + — optional custom name dialog.
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
