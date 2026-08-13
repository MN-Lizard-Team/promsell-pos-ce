import 'package:promsell_pos_ce/l10n/app_localizations.dart';

String qualityLabel(int quality, AppLocalizations l10n) {
  if (quality <= 50) return l10n.imageQualityDraft;
  if (quality <= 70) return l10n.imageQualityStandard;
  if (quality <= 80) return l10n.imageQualityHigh;
  if (quality <= 90) return l10n.imageQualityBest;
  return l10n.imageQualityOriginal;
}

String widthLabel(int width, AppLocalizations l10n) {
  if (width <= 400) return l10n.imageWidthSmall;
  if (width <= 600) return l10n.imageWidthMedium;
  if (width <= 800) return l10n.imageWidthLarge;
  if (width <= 1200) return l10n.imageWidthExtraLarge;
  return l10n.imageWidthFullHD;
}
