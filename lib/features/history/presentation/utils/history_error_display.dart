import 'package:promsell_pos_ce/features/history/presentation/bloc/history_bloc.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

String historyErrorMessage(AppLocalizations l10n, String? keyOrMessage) {
  if (keyOrMessage == null || keyOrMessage.isEmpty) {
    return l10n.errorOccurred;
  }
  return switch (keyOrMessage) {
    HistoryErrorKeys.saleAlreadyVoided => l10n.saleAlreadyVoided,
    HistoryErrorKeys.saleNotFound => l10n.saleNotFound,
    HistoryErrorKeys.dayClosed => l10n.voidBlockedDayClosed,
    HistoryErrorKeys.generic => l10n.errorOccurred,
    _ => keyOrMessage,
  };
}
