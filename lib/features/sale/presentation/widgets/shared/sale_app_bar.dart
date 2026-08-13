import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/utils/date_formatter.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/svg_icon.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/theme/pos_theme_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_app_bar_actions.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/shared/sale_barcode_scanner.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Sale page AppBar with title, live clock, bill count, search strip, and actions.
class SaleAppBar extends StatefulWidget implements PreferredSizeWidget {
  const SaleAppBar({super.key, required this.onSearchTap});

  final VoidCallback onSearchTap;

  @override
  State<SaleAppBar> createState() => _SaleAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(128);
}

class _SaleAppBarState extends State<SaleAppBar> {
  StreamSubscription<DateTime>? _clockSub;
  final _clockController = StreamController<DateTime>.broadcast();

  @override
  void initState() {
    super.initState();
    _clockSub = Stream<DateTime>.periodic(
      const Duration(seconds: 30),
      (_) => DateTime.now(),
    ).listen((now) => _clockController.add(now));
  }

  @override
  void dispose() {
    _clockSub?.cancel();
    _clockController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final pos = context.posTheme;

    // Primary teal chrome — shared with PosPrimaryAppBar / open bills.
    // Soft shadow under bar — PosTheme elevChrome / shadowChromeAlpha.
    return AppBar(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: pos.elevChrome,
      scrolledUnderElevation: pos.elevChrome,
      shadowColor: pos.shadowKey.withValues(alpha: pos.shadowChromeAlpha),
      forceMaterialTransparency: false,
      toolbarHeight: 64,
      titleSpacing: 16,
      titleTextStyle: TextStyle(
        color: scheme.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        fontFamily: 'NotoSansThai',
      ),
      iconTheme: IconThemeData(color: scheme.onPrimary),
      actionsIconTheme: IconThemeData(color: scheme.onPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(pos.appBarBottomRadius),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.salePageTitle),
          StreamBuilder<DateTime>(
            stream: _clockController.stream,
            initialData: DateTime.now(),
            builder: (context, snap) {
              final now = snap.data ?? DateTime.now();
              final billCount = context.select<DraftBloc, int>(
                (b) => b.state.openBillCount,
              );
              final label = DateFormatter.formatDateTimeWithSuffix(
                context,
                now,
                context.l10n.saleBillAt(billCount),
              );
              return Text(
                label,
                style: TextStyle(
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'NotoSansThai',
                ),
              );
            },
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Material(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('sale-open-search'),
              onTap: widget.onSearchTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 24, color: scheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.l10n.searchProducts,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFamily: 'NotoSansThai',
                        ),
                      ),
                    ),
                    if (context.select(
                      (SettingsCubit c) => c.state.settings.barcodeScanEnabled,
                    ))
                      IconButton(
                        tooltip: context.l10n.scanBarcode,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        icon: SvgIcon(
                          'barcode-scan-icon',
                          size: 24,
                          color: scheme.primary,
                        ),
                        onPressed: () => openSaleBarcodeScanner(context),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: const [SaleAppBarActions(), SizedBox(width: 4)],
    );
  }
}
