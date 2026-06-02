import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:promsell_pos_ce/core/di/injection_container.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';
import 'package:promsell_pos_ce/core/widgets/app_snack_bar.dart';
import 'package:promsell_pos_ce/features/sale/domain/entities/cart_item.dart';
import 'package:promsell_pos_ce/features/sale/domain/repositories/draft_cart_repository.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_bloc.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_event.dart';
import 'package:promsell_pos_ce/features/sale/presentation/bloc/sale_state.dart';
import 'package:promsell_pos_ce/features/settings/presentation/cubit/settings_cubit.dart';

class CartHeader extends StatefulWidget {
  const CartHeader({
    super.key,
    required this.state,
    this.expanded = false,
    this.sizePreset,
    this.onSizePresetChanged,
    this.widthPreset,
    this.onWidthPresetChanged,
  });

  final SaleState state;
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
    final draftName = widget.state.activeDraftName?.isNotEmpty == true
        ? widget.state.activeDraftName!
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 6, 8, 6),
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
                            widget.state.activeDraftId != null &&
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
              BlocBuilder<SettingsCubit, SettingsState>(
                builder: (_, settingsState) {
                  final settings = settingsState.settings;
                  final isUltra = settings.ultraCompactMode;
                  final isCompact = settings.cartCompactMode;
                  final (icon, tooltip) = isUltra
                      ? (Icons.density_small, context.l10n.cartCompactNormal)
                      : isCompact
                      ? (Icons.view_list, context.l10n.cartCompactUltra)
                      : (Icons.view_agenda, context.l10n.cartCompactCompact);
                  return IconButton(
                    icon: Icon(icon, size: 20),
                    tooltip: tooltip,
                    onPressed: () {
                      final cubit = context.read<SettingsCubit>();
                      if (isUltra) {
                        cubit.update(
                          settings.copyWith(
                            ultraCompactMode: false,
                            cartCompactMode: false,
                          ),
                        );
                      } else if (isCompact) {
                        cubit.update(
                          settings.copyWith(
                            cartCompactMode: false,
                            ultraCompactMode: true,
                          ),
                        );
                      } else {
                        cubit.update(
                          settings.copyWith(
                            cartCompactMode: true,
                            ultraCompactMode: false,
                          ),
                        );
                      }
                    },
                  );
                },
              ),
              PopupMenuButton<String>(
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'new_draft',
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          size: 18,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 10),
                        Text(context.l10n.newDraft),
                      ],
                    ),
                  ),
                  if (!widget.state.isEmpty)
                    PopupMenuItem(
                      value: 'clear_cart',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            context.l10n.clearCart,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'new_draft':
                      _showCreateDialog(context);
                    case 'clear_cart':
                      _confirmClearCart(context);
                  }
                },
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

  void _showCreateDialog(BuildContext context) {
    final bloc = context.read<SaleBloc>();
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(context.l10n.newDraft),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(hintText: context.l10n.draftNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = ctrl.text.trim().isEmpty ? null : ctrl.text.trim();
              bloc.add(SaleDraftCreated(name: name));
              Navigator.pop(context);
            },
            child: Text(context.l10n.save),
          ),
        ],
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    final bloc = context.read<SaleBloc>();
    final prevItems = List<CartItem>.from(bloc.state.items);
    final prevDiscountType = bloc.state.cartDiscountType;
    final prevDiscountValue = bloc.state.cartDiscountValue;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(context.l10n.clearCart),
        content: Text(context.l10n.confirmClearCart),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final l10n = context.l10n;
              bloc.add(const SaleCartCleared());
              Navigator.pop(dialogCtx);
              AppSnackBar.withAction(
                context,
                l10n.cartCleared,
                actionLabel: l10n.undo,
                onAction: () => bloc.add(
                  SaleCartRestored(
                    items: prevItems,
                    cartDiscountType: prevDiscountType,
                    cartDiscountValue: prevDiscountValue,
                  ),
                ),
              );
            },
            child: Text(
              context.l10n.clearCart,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
