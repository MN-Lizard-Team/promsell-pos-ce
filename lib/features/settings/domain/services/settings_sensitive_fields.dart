import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';

/// True when PromptPay identity fields change (POST-090 E0c domain gate).
bool settingsSensitivePaymentChanged(Settings before, Settings after) {
  return before.promptpayId != after.promptpayId ||
      before.billerId != after.billerId;
}
