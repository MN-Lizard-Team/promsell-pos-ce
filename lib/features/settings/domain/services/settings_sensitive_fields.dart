import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// True when PromptPay identity fields change (POST-090 E0c domain gate).
bool settingsSensitivePaymentChanged(Settings before, Settings after) {
  return before.promptpayId != after.promptpayId ||
      before.billerId != after.billerId;
}

/// True when a sensitive money-policy field changes (V092-B.3).
///
/// Covers: discount enable/limits, oversell, day-lock, backup encryption.
/// PromptPay identity is handled by [settingsSensitivePaymentChanged].
bool settingsSensitivePolicyChanged(Settings before, Settings after) {
  return before.enableItemDiscount != after.enableItemDiscount ||
      before.enableCartDiscount != after.enableCartDiscount ||
      before.maxDiscountPercent != after.maxDiscountPercent ||
      before.maxDiscountAmount != after.maxDiscountAmount ||
      before.allowOversell != after.allowOversell ||
      before.dailyCloseLock != after.dailyCloseLock ||
      before.backupEncryptionEnabled != after.backupEncryptionEnabled;
}

/// Combined sensitive-change check (PromptPay identity + money policy).
bool settingsSensitiveChanged(Settings before, Settings after) {
  return settingsSensitivePaymentChanged(before, after) ||
      settingsSensitivePolicyChanged(before, after);
}
