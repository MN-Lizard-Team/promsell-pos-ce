import 'package:flutter/material.dart';
import 'package:promsell_pos_ce/core/extensions/l10n_extension.dart';

class HomeMenuGrid extends StatelessWidget {
  const HomeMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final items = [
      _MenuItem(
        icon: Icons.point_of_sale,
        label: l10n.navSale,
        iconColor: cs.primary,
      ),
      _MenuItem(
        icon: Icons.inventory_2_outlined,
        label: l10n.navProducts,
        iconColor: cs.secondary,
      ),
      _MenuItem(
        icon: Icons.people_outline,
        label: l10n.customersTitle,
        iconColor: cs.tertiary,
      ),
      _MenuItem(
        icon: Icons.local_offer_outlined,
        label: l10n.promotionsTitle,
        iconColor: cs.error,
      ),
      _MenuItem(
        icon: Icons.receipt_long_outlined,
        label: l10n.homeHistory,
        iconColor: cs.secondary,
      ),
      _MenuItem(
        icon: Icons.task_alt,
        label: l10n.homeCloseDay,
        iconColor: cs.primary,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.homeMainMenu,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemBuilder: (context, i) {
              final item = items[i];
              return _MenuButton(item: item, index: i);
            },
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.item, required this.index});
  final _MenuItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      shadowColor: cs.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.iconColor.withValues(alpha: 0.12),
                ),
                child: Icon(item.icon, size: 28, color: item.iconColor),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    // Navigation is handled by the parent HomePage via a callback map
    // We use a simple approach: find the HomePage ancestor and call its handler
    final handler = HomeMenuGridTapHandler.of(context);
    handler?.onTap(index);
  }
}

typedef HomeMenuTapCallback = void Function(int index);

class HomeMenuGridTapHandler extends InheritedWidget {
  const HomeMenuGridTapHandler({
    super.key,
    required this.onTap,
    required super.child,
  });

  final HomeMenuTapCallback onTap;

  static HomeMenuGridTapHandler? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeMenuGridTapHandler>();
  }

  @override
  bool updateShouldNotify(HomeMenuGridTapHandler oldWidget) =>
      onTap != oldWidget.onTap;
}
