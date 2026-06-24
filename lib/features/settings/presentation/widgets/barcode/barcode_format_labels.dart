import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

String barcodeFormatLabel(BuildContext context, String name) {
  final l10n = context.l10n;
  switch (name) {
    case 'ean13':
      return l10n.barcodeFormatEan13;
    case 'ean8':
      return l10n.barcodeFormatEan8;
    case 'upcA':
      return l10n.barcodeFormatUpcA;
    case 'upcE':
      return l10n.barcodeFormatUpcE;
    case 'code128':
      return l10n.barcodeFormatCode128;
    case 'code39':
      return l10n.barcodeFormatCode39;
    case 'itf':
      return l10n.barcodeFormatItf;
    case 'qrCode':
      return l10n.barcodeFormatQrCode;
    case 'dataMatrix':
      return l10n.barcodeFormatDataMatrix;
    case 'pdf417':
      return l10n.barcodeFormatPdf417;
    case 'aztec':
      return l10n.barcodeFormatAztec;
    case 'codabar':
      return l10n.barcodeFormatCodabar;
    default:
      return name;
  }
}
