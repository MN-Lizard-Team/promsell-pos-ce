import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/errors/app_error.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/l10n/app_localizations.dart';

/// Consistent error display widget with icon, message, and optional retry.
class ErrorDisplay extends StatelessWidget {
  const ErrorDisplay({
    super.key,
    required this.error,
    this.onRetry,
    this.compact = false,
  });

  final AppError error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final errorInfo = _getErrorInfo(error, l10n);

    if (compact) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(errorInfo.icon, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorInfo.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(onPressed: onRetry, child: Text(l10n.retry)),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              errorInfo.icon,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 16),
            Text(
              errorInfo.title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorInfo.message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _ErrorInfo _getErrorInfo(AppError error, AppLocalizations l10n) {
    return switch (error) {
      ValidationError(:final message) => _ErrorInfo(
        icon: Icons.error_outline,
        title: l10n.validationError,
        message: message,
      ),
      NotFoundError(:final resource, :final id) => _ErrorInfo(
        icon: Icons.search_off,
        title: l10n.notFound,
        message: id != null
            ? l10n.resourceNotFoundWithId(resource, id)
            : l10n.resourceNotFound(resource),
      ),
      BusinessRuleError(:final rule, :final details) => _ErrorInfo(
        icon: Icons.warning_amber_rounded,
        title: l10n.businessRuleViolation,
        message: details ?? _translateBusinessRule(rule, l10n),
      ),
      DatabaseError(:final message) => _ErrorInfo(
        icon: Icons.storage_rounded,
        title: l10n.databaseError,
        message: message,
      ),
      NetworkError(:final statusCode, :final message) => _ErrorInfo(
        icon: Icons.wifi_off,
        title: l10n.networkError,
        message: message ?? l10n.networkErrorDefault(statusCode ?? 0),
      ),
      FileSystemError(:final message) => _ErrorInfo(
        icon: Icons.folder_off,
        title: l10n.fileSystemError,
        message: message,
      ),
      PermissionDeniedError(:final permission) => _ErrorInfo(
        icon: Icons.lock_outline,
        title: l10n.permissionDenied,
        message: l10n.permissionDeniedMessage(permission),
      ),
      UnknownError(:final message) => _ErrorInfo(
        icon: Icons.error,
        title: l10n.unexpectedError,
        message: message,
      ),
    };
  }

  String _translateBusinessRule(String rule, AppLocalizations l10n) {
    // Map common business rules to localized messages
    return switch (rule) {
      'InsufficientStock' => l10n.insufficientStock,
      'DuplicateBarcode' => l10n.duplicateBarcode,
      'InvalidDiscount' => l10n.invalidDiscount,
      'NegativePrice' => l10n.negativePriceNotAllowed,
      _ => rule, // Fallback to rule name
    };
  }
}

class _ErrorInfo {
  const _ErrorInfo({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}
