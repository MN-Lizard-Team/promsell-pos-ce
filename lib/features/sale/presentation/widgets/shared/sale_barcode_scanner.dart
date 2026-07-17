import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/barcode/barcode_scanner_dialog.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/repositories/product_repository.dart';
import 'package:promsell_pos_ce/features/product/presentation/widgets/product_tile/product_navigation.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_event.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

/// Opens the product barcode scanner and routes results into [CartBloc].
Future<void> openSaleBarcodeScanner(BuildContext context) async {
  final cartBloc = context.read<CartBloc>();
  final settings = context.read<SettingsCubit>().state.settings;
  if (!settings.barcodeScanEnabled) return;

  final productRepo = sl<ProductRepository>();
  final l10n = context.l10n;
  final saleContext = context;

  await showProductBarcodeScanner(
    context,
    beepOnScan: settings.barcodeBeepOnScan,
    formats: barcodeFormatsFromNames(settings.barcodeEnabledFormats),
    autoOpenManualDelay: settings.barcodeAutoOpenManualDelay,
    continuousScan: settings.barcodeContinuousScan,
    currency: settings.currency,
    onScanned: (barcode) {
      cartBloc.add(CartBarcodeScanned(barcode));
    },
    onLookup: (barcode) => productRepo.getProductByBarcode(barcode),
    onCreateProductFromBarcode: (code) async {
      if (!saleContext.mounted) return;
      final saved = await showProductCreatePage(
        saleContext,
        initialBarcode: code,
      );
      if (!saleContext.mounted) return;
      if (saved) {
        cartBloc.add(CartBarcodeScanned(code));
        AppSnackBar.success(saleContext, l10n.productCreatedAddedToCart);
      }
    },
  );
}
