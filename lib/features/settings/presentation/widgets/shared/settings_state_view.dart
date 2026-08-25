import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/settings/domain/entities/settings.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class SettingsStateView extends StatelessWidget {
  const SettingsStateView({
    required this.state,
    required this.onRetry,
    required this.builder,
    super.key,
  });

  final SettingsState state;
  final VoidCallback onRetry;
  final Widget Function(Settings settings) builder;

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      SettingsStatus.initial || SettingsStatus.loading => const Center(
        child: CircularProgressIndicator(),
      ),
      SettingsStatus.failure => _FailureView(onRetry: onRetry),
      SettingsStatus.loaded ||
      SettingsStatus.saving ||
      SettingsStatus.saved => builder(state.settings),
    };
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              l10n.errorOccurred,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
