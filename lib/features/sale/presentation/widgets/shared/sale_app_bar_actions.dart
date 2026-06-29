import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/drafts/drafts_bottom_sheet.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';

class SaleAppBarActions extends StatelessWidget {
  const SaleAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocBuilder<SettingsCubit, SettingsState>(
          builder: (ctx, settingsState) {
            if (!settingsState.settings.barcodeScanEnabled) {
              return const SizedBox.shrink();
            }
            return IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: context.l10n.scanBarcode,
              onPressed: () async {
                final bloc = context.read<CartBloc>();
                final settings = settingsState.settings;
                final productRepo = sl<ProductRepository>();
                await showProductBarcodeScanner(
                  context,
                  beepOnScan: settings.barcodeBeepOnScan,
                  formats: barcodeFormatsFromNames(
                    settings.barcodeEnabledFormats,
                  ),
                  autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
                  continuousScan: settings.barcodeContinuousScan,
                  onScanned: (barcode) {
                    bloc.add(CartBarcodeScanned(barcode));
                  },
                  onLookup: (barcode) =>
                      productRepo.getProductByBarcode(barcode),
                );
              },
            );
          },
        ),
        BlocBuilder<DraftBloc, DraftState>(
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
    );
  }
}
