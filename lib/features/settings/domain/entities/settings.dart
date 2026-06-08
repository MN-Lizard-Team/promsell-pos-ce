import 'package:equatable/equatable.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/backup_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/daily_close_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/device_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/discount_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/draft_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/image_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/payment_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/receipt_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/shop_info.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/stock_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/tax_config.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/ui_config.dart';

class Settings extends Equatable {
  const Settings({
    this.shopInfo = const ShopInfo(),
    this.receiptConfig = const ReceiptConfig(),
    this.taxConfig = const TaxConfig(),
    this.discountConfig = const DiscountConfig(),
    this.stockConfig = const StockConfig(),
    this.imageConfig = const ImageConfig(),
    this.paymentConfig = const PaymentConfig(),
    this.deviceConfig = const DeviceConfig(),
    this.uiConfig = const UiConfig(),
    this.dailyCloseConfig = const DailyCloseConfig(),
    this.backupConfig = const BackupConfig(),
    this.draftConfig = const DraftConfig(),
    this.onboardingCompleted = false,
  });

  final ShopInfo shopInfo;
  final ReceiptConfig receiptConfig;
  final TaxConfig taxConfig;
  final DiscountConfig discountConfig;
  final StockConfig stockConfig;
  final ImageConfig imageConfig;
  final PaymentConfig paymentConfig;
  final DeviceConfig deviceConfig;
  final UiConfig uiConfig;
  final DailyCloseConfig dailyCloseConfig;
  final BackupConfig backupConfig;
  final DraftConfig draftConfig;
  final bool onboardingCompleted;

  Settings copyWith({
    ShopInfo? shopInfo,
    ReceiptConfig? receiptConfig,
    TaxConfig? taxConfig,
    DiscountConfig? discountConfig,
    StockConfig? stockConfig,
    ImageConfig? imageConfig,
    PaymentConfig? paymentConfig,
    DeviceConfig? deviceConfig,
    UiConfig? uiConfig,
    DailyCloseConfig? dailyCloseConfig,
    BackupConfig? backupConfig,
    DraftConfig? draftConfig,
    bool? onboardingCompleted,
  }) {
    return Settings(
      shopInfo: shopInfo ?? this.shopInfo,
      receiptConfig: receiptConfig ?? this.receiptConfig,
      taxConfig: taxConfig ?? this.taxConfig,
      discountConfig: discountConfig ?? this.discountConfig,
      stockConfig: stockConfig ?? this.stockConfig,
      imageConfig: imageConfig ?? this.imageConfig,
      paymentConfig: paymentConfig ?? this.paymentConfig,
      deviceConfig: deviceConfig ?? this.deviceConfig,
      uiConfig: uiConfig ?? this.uiConfig,
      dailyCloseConfig: dailyCloseConfig ?? this.dailyCloseConfig,
      backupConfig: backupConfig ?? this.backupConfig,
      draftConfig: draftConfig ?? this.draftConfig,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  List<Object?> get props => [
    shopInfo,
    receiptConfig,
    taxConfig,
    discountConfig,
    stockConfig,
    imageConfig,
    paymentConfig,
    deviceConfig,
    uiConfig,
    dailyCloseConfig,
    backupConfig,
    draftConfig,
    onboardingCompleted,
  ];
}
