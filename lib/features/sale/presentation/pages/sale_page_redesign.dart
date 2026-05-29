import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/adaptive_breakpoints.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_bloc.dart';
import 'package:promsell_pos_ce/features/product/presentation/bloc/product_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart_panel.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/sale_catalog.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<ProductBloc>()),
        BlocProvider(
          create: (_) => sl<SaleBloc>()..add(const SaleDraftInitialized()),
        ),
      ],
      child: const _SaleView(),
    );
  }
}

class _SaleView extends StatelessWidget {
  const _SaleView();

  @override
  Widget build(BuildContext context) {
    final isExpanded = AdaptiveBreakpoints.isExpanded(context);

    return BlocListener<ProductBloc, ProductState>(
      listenWhen: (prev, curr) =>
          curr.status == ProductStatus.success &&
          prev.products != curr.products,
      listener: (context, state) {
        context.read<SaleBloc>().add(SaleCartProductsRefreshed(state.products));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.salePageTitle),
          actions: [
            BlocBuilder<SaleBloc, SaleState>(
              builder: (ctx, state) => IconButton(
                icon: Badge(
                  isLabelVisible: state.activeDraftId != null,
                  child: const Icon(Icons.bookmarks_outlined),
                ),
                tooltip: ctx.l10n.draftsTitle,
                onPressed: () => DraftsBottomSheet.show(ctx),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(12, 0, 12, isExpanded ? 12 : 8),
            child: isExpanded
                ? const Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: SaleCatalog()),
                      SizedBox(width: 12),
                      SizedBox(width: 390, child: CartPanel(expanded: true)),
                    ],
                  )
                : const Column(
                    children: [
                      Expanded(child: SaleCatalog()),
                      SizedBox(height: 8),
                      CartPanel(expanded: false),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
