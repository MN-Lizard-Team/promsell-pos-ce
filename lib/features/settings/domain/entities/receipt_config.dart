import 'package:equatable/equatable.dart';

class ReceiptConfig extends Equatable {
  const ReceiptConfig({
    this.receiptSize = '80mm',
    this.receiptPreviewStyle = 'thermal',
    this.receiptNote = '',
    this.showShopInfo = true,
    this.autoPrintPrompt = true,
    this.showPreSalePreview = true,
    this.showPostSalePreview = true,
  });

  final String receiptSize;
  final String receiptPreviewStyle;
  final String receiptNote;
  final bool showShopInfo;
  final bool autoPrintPrompt;
  final bool showPreSalePreview;
  final bool showPostSalePreview;

  ReceiptConfig copyWith({
    String? receiptSize,
    String? receiptPreviewStyle,
    String? receiptNote,
    bool? showShopInfo,
    bool? autoPrintPrompt,
    bool? showPreSalePreview,
    bool? showPostSalePreview,
  }) {
    return ReceiptConfig(
      receiptSize: receiptSize ?? this.receiptSize,
      receiptPreviewStyle: receiptPreviewStyle ?? this.receiptPreviewStyle,
      receiptNote: receiptNote ?? this.receiptNote,
      showShopInfo: showShopInfo ?? this.showShopInfo,
      autoPrintPrompt: autoPrintPrompt ?? this.autoPrintPrompt,
      showPreSalePreview: showPreSalePreview ?? this.showPreSalePreview,
      showPostSalePreview: showPostSalePreview ?? this.showPostSalePreview,
    );
  }

  @override
  List<Object?> get props => [
    receiptSize,
    receiptPreviewStyle,
    receiptNote,
    showShopInfo,
    autoPrintPrompt,
    showPreSalePreview,
    showPostSalePreview,
  ];
}
