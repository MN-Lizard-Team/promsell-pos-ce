import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/primitives/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/product/domain/usecases/clear_orphaned_images.dart';

class ClearImageCacheButton extends StatelessWidget {
  const ClearImageCacheButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return OutlinedButton.icon(
      icon: const Icon(Icons.delete_sweep_outlined),
      label: Text(l10n.clearImageCache),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        side: BorderSide(color: theme.colorScheme.error),
        minimumSize: const Size(double.infinity, 48),
      ),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.clearImageCache),
            content: Text(l10n.clearImageCacheConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.delete),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        final usecase = GetIt.I<ClearOrphanedImages>();
        final deleted = await usecase();
        if (context.mounted) {
          AppSnackBar.success(
            context,
            '${l10n.imageCacheCleared} ($deleted files)',
          );
        }
      },
    );
  }
}
