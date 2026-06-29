import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_header/cart_header_dialogs.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_header/cart_header_menu.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartHeader extends StatelessWidget {
  const CartHeader({
    super.key,
    required this.cartState,
    required this.draftState,
    this.expanded = false,
    this.sizePreset,
    this.onSizePresetChanged,
    this.widthPreset,
    this.onWidthPresetChanged,
  });

  final CartState cartState;
  final DraftState draftState;
  final bool expanded;
  final double? sizePreset;
  final ValueChanged<double>? onSizePresetChanged;
  final double? widthPreset;
  final ValueChanged<double>? onWidthPresetChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final draftName = draftState.activeDraftName?.isNotEmpty == true
        ? draftState.activeDraftName!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                color: theme.colorScheme.primary,
                size: 22,
                semanticLabel: context.l10n.cartTitle,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  draftName ?? context.l10n.cartTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onSizePresetChanged != null)
                SizedBox(
                  width: 100,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                    ),
                    child: Slider(
                      value: sizePreset ?? 0.0,
                      min: 0.0,
                      max: 1.0,
                      divisions: 2,
                      label: (sizePreset ?? 0.0) == 0.0
                          ? 'S'
                          : (sizePreset ?? 0.0) == 0.5
                          ? 'M'
                          : 'L',
                      onChanged: onSizePresetChanged,
                    ),
                  ),
                ),
              if (onWidthPresetChanged != null)
                SizedBox(
                  width: 100,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                    ),
                    child: Slider(
                      value: widthPreset ?? 0.0,
                      min: 0.0,
                      max: 1.0,
                      divisions: 1,
                      label: (widthPreset ?? 0.0) == 0.0 ? 'S' : 'L',
                      onChanged: onWidthPresetChanged,
                    ),
                  ),
                ),
              CartHeaderMenu(
                cartState: cartState,
                onToggleCompact: () {
                  final cubit = context.read<SettingsCubit>();
                  final isUltra = cubit.state.settings.ultraCompactMode;
                  cubit.updateField(
                    (s) => s.copyWith(ultraCompactMode: !isUltra),
                  );
                },
                onNewDraft: () => CartHeaderDialogs.showCreateDialog(context),
                onClearCart: () => CartHeaderDialogs.confirmClearCart(context),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          indent: 14,
          endIndent: 14,
        ),
      ],
    );
  }
}
