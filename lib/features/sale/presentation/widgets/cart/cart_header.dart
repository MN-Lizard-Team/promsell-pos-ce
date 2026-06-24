import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/cart_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/draft_state.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_header/cart_header_dialogs.dart';
import 'package:promsell_pos_ce/features/sale/presentation/widgets/cart/cart_header/cart_header_menu.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartHeader extends StatefulWidget {
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
  State<CartHeader> createState() => _CartHeaderState();
}

class _CartHeaderState extends State<CartHeader> {
  late final Future<int> _countFuture;

  @override
  void initState() {
    super.initState();
    _countFuture = sl<DraftCartRepository>().countDrafts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final draftName = widget.draftState.activeDraftName?.isNotEmpty == true
        ? widget.draftState.activeDraftName!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 8, 4),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FutureBuilder<int>(
                      future: _countFuture,
                      builder: (_, snap) {
                        final count = snap.hasError ? null : snap.data;
                        final draftIndex =
                            widget.draftState.activeDraftId != null &&
                                count != null &&
                                count > 0
                            ? ' · 1/${count.clamp(1, 999)}'
                            : snap.hasError
                            ? ' · —'
                            : '';
                        return Text(
                          '${draftName ?? context.l10n.cartTitle}$draftIndex',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                    if (draftName != null)
                      Text(
                        context.l10n.cartTitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.onSizePresetChanged != null)
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
                      value: widget.sizePreset ?? 0.0,
                      min: 0.0,
                      max: 1.0,
                      divisions: 1,
                      label: (widget.sizePreset ?? 0.0) == 0.0 ? 'S' : 'L',
                      onChanged: widget.onSizePresetChanged,
                    ),
                  ),
                ),
              if (widget.onWidthPresetChanged != null)
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
                      value: widget.widthPreset ?? 0.0,
                      min: 0.0,
                      max: 1.0,
                      divisions: 1,
                      label: (widget.widthPreset ?? 0.0) == 0.0 ? 'S' : 'L',
                      onChanged: widget.onWidthPresetChanged,
                    ),
                  ),
                ),
              CartHeaderMenu(
                cartState: widget.cartState,
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
