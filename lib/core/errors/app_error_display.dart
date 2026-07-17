import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Extension to convert AppError to user-facing display message.
extension AppErrorDisplay on AppError {
  /// Get a localized message suitable for snackbars and toasts.
  String displayMessage(AppLocalizations l10n) {
    return switch (this) {
      ValidationError(:final message) => message,
      NotFoundError(:final resource, :final id) =>
        id != null
            ? '${l10n.resourceNotFound(resource)} ($id)'
            : l10n.resourceNotFound(resource),
      BusinessRuleError(:final rule, :final details) =>
        details ?? _businessRuleMessage(rule, l10n),
      DatabaseError(:final message) => message,
      NetworkError(:final message, :final statusCode) =>
        message ?? l10n.networkErrorDefault(statusCode ?? 0),
      FileSystemError(:final message) => message,
      PermissionDeniedError(:final permission) => l10n.permissionDeniedMessage(
        permission,
      ),
      UnknownError(:final message) => message,
    };
  }

  String _businessRuleMessage(String rule, AppLocalizations l10n) {
    return switch (rule) {
      'DuplicateBarcode' => l10n.duplicateBarcode,
      'InsufficientStock' => l10n.insufficientStock,
      'InvalidDiscount' => l10n.invalidDiscount,
      'NegativePrice' => l10n.negativePriceNotAllowed,
      _ => rule,
    };
  }
}
